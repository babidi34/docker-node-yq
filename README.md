Here is a simple `README.md` for your project that contains both the Dockerfile and GitLab CI/CD configuration.

# Node.js + yq Docker Image with GitLab CI/CD

This project provides a Docker image based on Node.js (alpine) with `yq` by Mike Farah installed. The GitLab CI/CD pipeline is configured to build and push the Docker image to the GitLab container registry.

## Project Overview

The Docker image includes:
- **Node.js 16 (Alpine)**: A lightweight version of Node.js.
- **yq**: A lightweight and portable command-line YAML processor written in Go.

The GitLab CI pipeline:
- Builds the Docker image.
- Tags the image with either the Git commit hash or the Git tag.
- Pushes the image to the GitLab container registry.

## Dockerfile

The Dockerfile uses Node.js 16 (Alpine) as the base image and installs `yq` for YAML processing.

```Dockerfile
# Step 1: Use Node.js as base image
FROM node:16-alpine

ENV yq_version 4.44.3

# Step 2: Install curl, rsync, and yq
RUN apk add --no-cache curl rsync && \
    curl -sSLo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v$yq_version/yq_linux_amd64 && \
    chmod +x /usr/local/bin/yq

# Step 3: Set the working directory
WORKDIR /app

# Step 4: Default command (optional)
CMD ["node", "--version"]
```

## GitLab CI/CD Configuration

This is the GitLab CI configuration that builds the Docker image and pushes it to the GitLab container registry. The image is tagged with either a Git tag (if available) or the Git commit hash.

```yaml
variables:
  DOCKER_BUILDKIT: '1'
  DOCKER_REGISTRY: $CI_REGISTRY_IMAGE
  FF_DISABLE_UMASK_FOR_DOCKER_EXECUTOR: '1'
  IMAGE_TAG: $CI_COMMIT_SHORT_SHA
  IMAGE_TAG_LATEST: latest

stages:
  - build

build_image:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  before_script:
    - docker --version
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
  script:
    # Use Git tag if present, otherwise fallback to commit short SHA
    - export IMAGE_TAG=${CI_COMMIT_TAG:-$IMAGE_TAG}
    - export IMAGE_TAG_LATEST=${CI_COMMIT_TAG:-$IMAGE_TAG_LATEST}
    # For caching purposes
    - docker pull $DOCKER_REGISTRY || true
    - docker build --build-arg BUILDKIT_INLINE_CACHE=1 --cache-from $DOCKER_REGISTRY --tag $DOCKER_REGISTRY:$IMAGE_TAG .
    - docker push $DOCKER_REGISTRY:$IMAGE_TAG
    # Push 'latest' tag if there is a Git tag
    - docker tag $DOCKER_REGISTRY:$IMAGE_TAG $DOCKER_REGISTRY:${IMAGE_TAG_LATEST:-latest}
    - docker push $DOCKER_REGISTRY:${IMAGE_TAG_LATEST:-latest}
  only:
    - master
    - tags
```

## How to Use

1. **Build the Docker image locally** (optional):
   ```bash
   docker build -t your-image-name .
   ```

2. **Set up the GitLab CI/CD**: 
   - This CI/CD pipeline automatically builds and pushes the Docker image to the GitLab container registry when a commit is pushed to the `master` branch or when a Git tag is created.

3. **Push your changes**: 
   - Push your commits to the repository, and GitLab CI will automatically build and push your Docker image.
   ```bash
   git push origin master
   ```

4. **Tag your commit** (optional):
   - To create a new tag and push it to GitLab:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

## Notes

- The image is tagged with the Git commit short SHA by default.
- If a Git tag is present, it will be used as the image tag.

