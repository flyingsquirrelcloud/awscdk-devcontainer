# Docker Image Build and Push for `awscdk-devcontainer`

This repository contains a GitHub Actions workflow to automate the build and deployment of the `awscdk-devcontainer` Docker image. The workflow supports multi-platform builds and automatically handles versioning and tagging for Docker images.

## Features

- **Automated Builds**: Triggers on pushes to any branch.
- **Multi-Platform Support**: Builds images for both `linux/arm64` and `linux/amd64`.
- **Versioning**: The automated versioning in this workflow applies to **patch versions** only. If a **minor** or **major** version bump is required, it must be manually set in the `.bumpversion.toml` file by updating the `current_version` field. For example:

  ```toml
  current_version = "0.0.1"
  ```

  This ensures precise control over major or minor version changes, allowing the workflow to handle incremental updates automatically while giving you flexibility for larger version updates.
  
- **Provenance and SBOM**: Generates software provenance and SBOM for improved security and traceability.
- **Main and Non-Main Branch Differentiation**:
  - **Main Branch**: Tags images as `latest` and with the new version.
  - **Non-Main Branches**: Tags images with the new version only.

---

## Workflow Overview

### Trigger

The workflow triggers on any push to the repository (`on: push`).

### Permissions

Requires the following permissions:
- `contents: write`
- `actions: write`

### Environment Variables

| Variable            | Description                      |
|---------------------|----------------------------------|
| `DOCKER_IMAGE_NAME` | The name of the Docker Hub image |

### Secrets

The workflow uses the following GitHub secrets:
- `DOCKER_HUB_USERNAME`: Your Docker Hub username.
- `DOCKER_HUB_PASSWORD`: Your Docker Hub password.
- `GITHUB_TOKEN`: Automatically provided by GitHub.

### Steps

1. **Check Out Code**:
   - Retrieves the latest code from the repository.
2. **Configure Git**:
   - Sets up Git user details for version management.
3. **Set Up Python**:
   - Installs Python 3.12 and caches dependencies.
4. **Version Management**:
   - Determines the version bump type based on the branch.
   - Uses `bump-my-version` to bump the version and tag the repository.
5. **Set up Docker Buildx**:
   - Configures Docker Buildx for multi-platform builds.
6. **Login to Docker Hub**:
   - Authenticates with Docker Hub using provided credentials.
7. **Build and Push Docker Images**:
   - Builds and pushes images to Docker Hub with the appropriate tags and configurations.

---

## Docker Image Information

The `mejatos/aws-cdk` Docker image is available on Docker Hub and provides a pre-configured environment for working with the AWS Cloud Development Kit (CDK). This image streamlines the process of deploying AWS infrastructure as code, offering a consistent and isolated environment for CDK operations.

### Key Features

- **AWS CDK Integration**: Includes the AWS CDK toolkit, enabling the definition and deployment of cloud infrastructure using familiar programming languages.
- **Pre-installed Dependencies**: Comes with all necessary dependencies for AWS CDK, reducing setup time and potential configuration issues.
- **Consistent Environment**: Provides a uniform environment across different development and deployment stages, ensuring consistent behavior.

### Usage Example

To utilize this Docker image, execute the following command:

```bash
docker run -it --rm mejatos/aws-cdk
```

This command initiates a container with the `mejatos/aws-cdk` image, allowing you to execute CDK commands within the containerized environment.

### Repository Link

For more details and to access the Docker image, visit the [mejatos/aws-cdk Docker Hub page](https://hub.docker.com/r/mejatos/aws-cdk).

---

## Docker Image Tags

### Main Branch

- `latest`
- `<new-version>` (e.g., `1.0.0`)

### Non-Main Branches

- `<new-version>` (e.g., `1.0.0-dev0`)

---

## Usage

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd <repository-name>
   ```

2. **Push Changes**:
   - Push changes to any branch to trigger the workflow.

3. **Check Docker Hub**:
   - The built image will be available on Docker Hub under the specified repository.

---

## Notes

- Ensure that your local environment has Docker installed and properly configured to pull and run images from Docker Hub.
- By incorporating the `mejatos/aws-cdk` Docker image into your workflow, you can enhance the efficiency and reliability of your AWS infrastructure development and deployment processes.

### Versioning

Each time a new feature branch is created, the semantic version for the intended production release must be set in advance. This ensures consistency and predictability in versioning across development and production environments.

#### Semantic Versioning Guidelines

If the current production version is `0.1.0`, follow the semantic versioning rules to determine the next version. For example, the next version might be `0.1.1` if only a patch update is required.

#### Example Usage of `bump-my-version`

The following command demonstrates how `bump-my-version` handles version increments:

```bash
$ bump-my-version show-bump 1.0.0-dev0
1.0.0-dev0 ── bump ─┬─ major ─ 2.0.0-dev0
                    ├─ minor ─ 1.1.0-dev0
                    ├─ patch ─ 1.0.1-dev0
                    ├─ pre_l ─ 1.0.0-rc0
                    ╰─ pre_n ─ 1.0.0-dev1
```

#### Example Workflow

**Example 1:**
- A new feature branch starts with the version set to `0.1.1`. 
  - After the first commit and push, the version increments to `0.1.1-dev1`.
  - A subsequent commit and push on the same branch will result in `0.1.1-dev2`.
  
- When the feature branch (`0.1.1-dev2`) is merged into `main`, the version automatically updates to `0.1.2`.

**Summary:**
- **Pre-release dev versions** (`dev1`, `dev2`, etc.) and **patch updates** are automatically handled through branch management activities.
- **Minor and major version updates** must be pre-determined and configured in advance for the next feature branch.

#### Steps to Configure Versioning

1. **Set `.bumpversion.toml` Configuration**:
   - Update the `current_version` field in `.bumpversion.toml` to the desired semantic version. For example:
     ```toml
     current_version = "0.2.0"
     ```

2. **Modify `docker-image.yml` Configuration**:
   - Adjust the branch-specific bump type logic:
     ```yaml
     - name: Determine Version Bump Type
       id: determine-bump
       run: |
         if [[ "${{ github.ref_name }}" == "main" ]]; then
           echo "BUMP_TYPE=patch" >> $GITHUB_ENV
         else
           echo "BUMP_TYPE=pre_n" >> $GITHUB_ENV
         fi
     ```