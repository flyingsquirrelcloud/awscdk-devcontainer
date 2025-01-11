# Docker Image Build and Push for `awscdk-devcontainer`

This repository contains a GitHub Actions workflow to automate the build and deployment of the `awscdk-devcontainer` Docker image. The workflow supports multi-platform builds and automatically handles versioning and tagging for Docker images.

## Features

- **Automated Builds**: Triggers on pushes to any branch.
- **Multi-Platform Support**: Builds images for both `linux/arm64` and `linux/amd64`.
- **Versioning**: Automatically determines version bump type and applies version tags.
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

| Variable               | Description                      |
|-------------------------|----------------------------------|
| `DOCKER_IMAGE_NAME`     | The name of the Docker Hub image. |

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