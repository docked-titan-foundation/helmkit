# Helmkit

A Docker image with helmfile pre-installed for Kubernetes Helm deployments.

## Version Compatibility Matrix

| helmkit | helm | helmfile | kubectl | helm-diff | helm-secrets | Date |
|---------|------|----------|---------|-----------|--------------|------|
| 0.1.0 | 3.15.0 | 1.4.3 | 1.30.0 | 3.10.0 | 3.2.0 | 2026-04-07 |

This matrix is automatically updated on each release.

## Description

Helmkit provides a lightweight Alpine-based Docker image with [helmfile](https://github.com/helmfile/helmfile) installed. This image can be used in CI/CD pipelines or local development to manage Helm releases declaratively.

## Features

- Lightweight Alpine base image
- helmfile pre-installed
- Workspaces ready for use

## Docker Image

Pull the image from GitHub Container Registry:

```bash
docker pull ghcr.io/docked-titan-foundation/helmkit:latest
```

Or specific version:

```bash
docker pull ghcr.io/docked-titan-foundation/helmkit:v1.4.3
```

## Usage

Run helmfile commands interactively:

```bash
docker run -it --rm ghcr.io/docked-titan-foundation/helmkit helmfile --version
```

Mount your helmfile configurations:

```bash
docker run -it --rm -v $(pwd):/workspace ghcr.io/docked-titan-foundation/helmkit helmfile diff
```

## Building Locally

```bash
docker build -t helmkit .
```

## Requirements

- Docker 20.10+
- For CI/CD: GitHub Actions (included)

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
