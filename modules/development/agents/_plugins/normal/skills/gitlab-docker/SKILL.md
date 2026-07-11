---
name: gitlab-docker
description: Use when the user is configuring GitLab CI pipelines for Docker image builds, especially with Kaniko, crane, or dind. Covers Researchable's shared CI templates, registry auth configuration, and the Docker Hub auth endpoint footgun.
---

# Researchable GitLab CI Docker Build Templates

Shared templates live in `researchable/general/templates/gitlab/base` (branch `master`).
A local checkout may exist at `~/Researchable/general/templates/gitlab/base`.

## Available Build/Deploy Templates

| Template | Tool | Auth method | Use case |
|---|---|---|---|
| `kaniko/build.yml` | Kaniko | Raw JSON config (`/kaniko/.docker/config.json`) | Build + push without Docker daemon (no dind needed) |
| `docker/build.yml` | Docker (dind) | `docker login` | Build + push with Docker daemon |
| `docker/buildv2.yml` | Docker (dind) | `docker login` (inputs-based) | Same as above, supports multiple instances via `job_prefix` |
| `docker/publish.yml` | crane | `crane auth login` (global vars) | Tag/promote existing images |
| `docker/publishv2.yml` | crane | `crane auth login` (inputs-based) | Same as above, supports multiple instances via `job_prefix` |

## CRITICAL: Docker Hub Auth Endpoint Mismatch

**This is the most common source of failures.**

Kaniko writes a Docker config JSON keyed by the registry host for authentication:

```json
{"auths":{"<REGISTRY_LOGIN_HOST_OVERWRITE>":{"auth":"<base64>"}}}
```

Docker Hub's **image registry** host is `docker.io`, but its **authentication endpoint** is `https://index.docker.io/v1/`. These are NOT the same. If you set `REGISTRY_HOST: docker.io` without overriding the login host, Kaniko will try to authenticate against `docker.io` and **fail silently or with a cryptic 401/403**.

### The fix

When using `kaniko/build.yml` with Docker Hub, you MUST set:

```yaml
variables:
  REGISTRY_LOGIN_HOST_OVERWRITE: https://index.docker.io/v1/
```

This only applies to the **kaniko** template. The `docker/build.yml` and `docker/publish*.yml` templates use `docker login` / `crane auth login` which handle endpoint resolution internally.

### When is the override NOT needed?

- When pushing to **GitLab Container Registry** (`$CI_REGISTRY`) -- the login host and push host are the same.
- When pushing to **other registries** (ECR, GCR, GHCR) -- typically the login host matches the push host.
- When using the `docker/build.yml` or `docker/publish*.yml` templates -- they don't use the raw JSON config approach.

## Registry Variable Patterns

### Global variables (used by non-inputs templates)

```yaml
variables:
  IMAGE_NAME: researchableuser/<service-name>
  IMAGE_TAGS: $CI_COMMIT_SHA,latest        # CSV of tags
  REGISTRY_USERNAME: $DOCKER_HUB_USERNAME   # DOCKER_HUB_USERNAME is set globally in our gitlab tenant.
  REGISTRY_PASSWORD: $DOCKER_HUB_PASSWORD   # DOCKER_HUB_PASSWORD is set globally in our gitlab tenant.
  REGISTRY_HOST: docker.io                  # or $CI_REGISTRY for GitLab
  CONTEXT: $CI_PROJECT_DIR                  # Dockerfile context path
```

### Docker Hub preset

```yaml
variables:
  REGISTRY_HOST: docker.io
  REGISTRY_USERNAME: $DOCKER_HUB_USERNAME
  REGISTRY_PASSWORD: $DOCKER_HUB_PASSWORD
```

## Build Argument Conventions

The templates auto-detect environment variables by prefix and pass them as `--build-arg`:

| Prefix | Behavior | Example |
|---|---|---|
| `ENV_*` | Strips `ENV_` prefix, passes as `--build-arg` | `ENV_RAILS_ENV: production` -> `--build-arg RAILS_ENV=production` |
| `BUILD_ARG_*` | Strips `BUILD_ARG_` prefix, passes as `--build-arg` | `BUILD_ARG_NODE_ENV: production` -> `--build-arg NODE_ENV=production` |
| `BUILD_TARGET` | Passed as `--target` for multi-stage builds | `BUILD_TARGET: runtime` -> `--target runtime` |

## Complete Example: Kaniko + Docker Hub

```yaml
include:
  - project: researchable/general/templates/gitlab/base
    ref: master
    file: kaniko/build.yml
  - project: researchable/general/templates/gitlab/base
    ref: master
    file: docker/publishv2.yml
    inputs:
      registry_host: docker.io
      registry_username: $DOCKER_HUB_USERNAME
      registry_password: $DOCKER_HUB_PASSWORD
      image_name: researchableuser/my-service
      job_prefix: dev
      environment: develop
      deploy_branch: develop
      image_tags: $CI_COMMIT_SHA,latest

variables:
  IMAGE_NAME: researchableuser/my-service
  IMAGE_TAGS: $CI_COMMIT_SHA,latest
  REGISTRY_USERNAME: $DOCKER_HUB_USERNAME
  REGISTRY_PASSWORD: $DOCKER_HUB_PASSWORD
  REGISTRY_HOST: docker.io
  CONTEXT: $CI_PROJECT_DIR

build_job:
  extends: .kaniko_build_job
  stage: build
  variables:
    # CRITICAL: Docker Hub requires this override for Kaniko auth
    REGISTRY_LOGIN_HOST_OVERWRITE: https://index.docker.io/v1/
    # Optional build args
    ENV_RAILS_ENV: development
```

## Complete Example: Kaniko + GitLab Registry

```yaml
include:
  - project: researchable/general/templates/gitlab/base
    ref: master
    file: kaniko/build.yml

variables:
  IMAGE_NAME: $CI_PROJECT_PATH
  IMAGE_TAGS: $CI_COMMIT_SHA,latest
  REGISTRY_USERNAME: $CI_REGISTRY_USER
  REGISTRY_PASSWORD: $CI_REGISTRY_PASSWORD
  REGISTRY_HOST: $CI_REGISTRY
  CONTEXT: $CI_PROJECT_DIR

build_job:
  extends: .kaniko_build_job
  stage: build
  # No REGISTRY_LOGIN_HOST_OVERWRITE needed -- GitLab Registry login host matches push host
```

## Kaniko Resource Overrides

For large images that may OOM:

```yaml
build_job:
  extends: .kaniko_build_job
  variables:
    KUBERNETES_MEMORY_REQUEST: 2Gi
    KUBERNETES_MEMORY_LIMIT: 4Gi
    KUBERNETES_CPU_LIMIT: 2
    CACHE: 'true'
    COMPRESSED_CACHING: 'false'  # Avoid OOM from compressed caching
```

## Other Available Templates

The base repo also provides templates for:

- `claude/review.yml` -- AI code review
- `composer/commit-to-composer.yml` -- Kustomize image updates (inputs: `refname`, `script`)
- `semantic-release/template.yml` -- Automated versioning
- `ruby/rubocop.yml`, `ruby/rspec_with_pg.yml` -- Ruby CI
- `js/` -- JavaScript CI
- `helm/` -- Helm chart operations
- `terraform/` -- Terraform operations
- `trivy/` -- Container security scanning
- `sonar/` -- SonarQube analysis
- `sealed-secrets/` -- Sealed secrets management
- `security/` -- Security scanning (also see `Security/SAST.gitlab-ci.yml` built-in template)
- `avoid-duplicate-pipelines.yml` -- Prevent duplicate pipeline runs
