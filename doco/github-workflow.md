# GitHub Actions Workflow: Build and Push Docker Image

## Overview

The workflow (`.github/workflows/docker-image.yml`) automates building and pushing the `awscdk-devcontainer` Docker image to Docker Hub on every push to any branch.

---

## Trigger

```yaml
on:
  push:
    branches:
      - '**'
```

The workflow fires on **any push to any branch**. No pull request is required — pushing directly to `main` or any feature branch will trigger the build.

> **Note:** If you want to enforce PRs before merging to main, configure [branch protection rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-a-branch-protection-rule) in GitHub. The workflow itself does not require them.

---

## Version Bump Logic

The workflow uses [bump-my-version](https://github.com/callowayproject/bump-my-version) to automatically increment the version on each push.

### Branch-Specific Bump Types

| Branch | Bump Type | Example |
|--------|-----------|---------|
| `main` | `patch` | `0.1.5` → `0.1.6` |
| Any other branch | `pre_n` | `0.1.5-dev0` → `0.1.5-dev1` |

### Version Format

Defined in `.bumpversion.toml`:

- **Release version:** `{major}.{minor}.{patch}` (e.g. `0.1.6`)
- **Pre-release version:** `{major}.{minor}.{patch}-dev{n}` (e.g. `0.1.6-dev2`)

The pre-release label is always `dev` (configured as non-bumpable in `.bumpversion.toml`).

### Typical Workflow Example

1. Current production version: `0.1.5`
2. Create a feature branch and push:
   - First push → `0.1.6-dev0`
   - Second push → `0.1.6-dev1`
   - Third push → `0.1.6-dev2`
3. Merge feature branch to `main` and push:
   - Version bumps to `0.1.6` (clean release)

### Manual Version Control

**Patch versions** are handled automatically. For **minor or major** version bumps, manually update `current_version` in `.bumpversion.toml`:

```toml
current_version = "0.2.0"
```

This should be done at the start of a new feature branch when a larger version increment is needed.

---

## Docker Image Tagging

| Branch | Tags Applied |
|--------|-------------|
| `main` | `<version>` + `latest` |
| Feature branches | `<version>` only |

**Examples:**
- Push to main → `mejatos/aws-cdk:0.1.6` and `mejatos/aws-cdk:latest`
- Push to feature branch → `mejatos/aws-cdk:0.1.6-dev2`

---

## Multi-Platform Builds

Images are built for both architectures:
- `linux/arm64`
- `linux/amd64`

---

## Security & Supply Chain

- **Provenance:** Enabled — generates build provenance attestation.
- **SBOM:** Enabled — generates a Software Bill of Materials.

---

## Bot Loop Prevention

The workflow includes a guard to prevent infinite trigger loops:

```yaml
if: "!contains(github.actor, 'github-actions[bot]')"
```

Since the version bump creates a new commit and tag (pushed back to the repo), this condition ensures the workflow doesn't re-trigger on its own automated commits.

---

## Required Secrets & Variables

| Name | Type | Description |
|------|------|-------------|
| `DOCKER_HUB_USERNAME` | Secret | Docker Hub username |
| `DOCKER_HUB_PASSWORD` | Secret | Docker Hub password |
| `GITHUB_TOKEN` | Secret | Auto-provided by GitHub (used for version tagging) |
| `DOCKER_HUB_IMAGE_NAME` | Variable | Full Docker Hub image name (e.g. `mejatos/aws-cdk`) |

---

## Permissions

```yaml
permissions:
  contents: write
  actions: write
```

Required for:
- `contents: write` — pushing version bump commits and tags back to the repo
- `actions: write` — workflow management

---

## Workflow Steps Summary

1. **Check Out Code** — clones the repo
2. **Configure Git** — sets git user for automated commits
3. **Set Up Python 3.12** — required for bump-my-version
4. **Cache pip dependencies** — speeds up subsequent runs
5. **Install bump-my-version** — version management tool
6. **Determine Version Bump Type** — selects `patch` (main) or `pre_n` (branches)
7. **Bump version** — increments version, commits, and tags
8. **Get Bumped Version** — captures new version for Docker tagging
9. **Set up Docker Buildx** — enables multi-platform builds
10. **Login to Docker Hub** — authenticates for push
11. **Build and Push** — builds multi-arch image and pushes with appropriate tags
