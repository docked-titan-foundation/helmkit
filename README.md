[![CI_CD](https://github.com/docked-titan-foundation/helmkit/actions/workflows/pipeline.yml/badge.svg)](https://github.com/docked-titan-foundation/helmkit/actions/workflows/pipeline.yml)
![Release](https://img.shields.io/github/v/release/docked-titan-foundation/helmkit)
[![Dependabot Updates](https://github.com/docked-titan-foundation/helmkit/actions/workflows/dependabot/dependabot-updates/badge.svg)](https://github.com/docked-titan-foundation/helmkit/actions/workflows/dependabot/dependabot-updates)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
![Stars](https://img.shields.io/github/stars/docked-titan-foundation/helmkit?style=social)

## 📝 Description

Helmkit provides a lightweight Alpine-based Docker image with Helm, Helmfile, kubectl, Helm Diff, Helm Secrets, and SOPS pre-installed. This image can be used in CI/CD pipelines or local development to manage Helm releases declaratively.

## ✨ Features

- Lightweight Alpine base image
- Helm (package manager)
- Helmfile (declarative Helm charts)
- kubectl (Kubernetes CLI)
- Helm Diff (diff plugin)
- Helm Secrets (secrets plugin)
- SOPS (Secrets OPerationS - encrypted secrets management)

## 📋 Version Matrix

| Version | Helm | Helmfile | Kubectl | Helm Diff | Helm Secrets | SOPS | Date |
|---------|------|---------|--------|----------|--------------|-----|------|
| 1.0.0 (latest)  | 3.15.0 | 1.4.3 | 1.30.0 | 3.10.0 | 3.2.0 | 3.12.2 | 2026-04-08|

[Changelog](./CHANGELOG.md)

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for setup instructions and development guidelines.

## 🔄 Pipeline Flow

```
lint
 └─▶ release
       └─▶ build (local only)
             └─▶ test (versions, plugins, non-root)
                   └─▶ security scan (CRITICAL/HIGH = fail)
                         └─▶ SBOM generation
                               └─▶ push (first public appearance)
                                     └─▶ sign
                                           └─▶ attach + sign SBOM
```

| Gate | Description |
|------|-------------|
| **Lint** | Dockerfile, YAML, and Markdown linting |
| **Release** | Semantic versioning on main branch (GPG signed commits) |
| **Build** | Docker image built locally (no push) |
| **Test** | Version validation (Helm, Helmfile, kubectl, SOPS), plugin checks (diff, secrets), non-root user |
| **Security Scan** | Trivy vulnerability scanner (CRITICAL/HIGH = fail) |
| **SBOM Generation** | SPDX JSON Software Bill of Materials |
| **Push** | First public appearance to GitHub Container Registry |
| **Sign** | Cosign image signing |
| **Attach + Sign SBOM** | Attach and sign SBOM with Cosign |

## 🐳 Docker Image

Pull the image from GitHub Container Registry:

```bash
docker pull ghcr.io/docked-titan-foundation/helmkit:latest
```

Or specific version:

```bash
docker pull ghcr.io/docked-titan-foundation/helmkit:v{VERSION}
```

## 🚀 Usage

Run helmfile commands interactively:

```bash
docker run -it --rm ghcr.io/docked-titan-foundation/helmkit helmfile --version
```

Mount your helmfile configurations:

```bash
docker run -it --rm -v $(pwd):/workspace ghcr.io/docked-titan-foundation/helmkit helmfile diff
```

### 🔐 SOPS Integration

The image includes [SOPS](https://github.com/getsops/sops) for encrypted secrets management:

```bash
# Encrypt a YAML file
docker run -it --rm -v $(pwd):/workspace ghcr.io/docked-titan-foundation/helmkit \
  sops -e -i secrets.yaml

# Decrypt and view secrets
docker run -it --rm -v $(pwd):/workspace ghcr.io/docked-titan-foundation/helmkit \
  sops secrets.yaml

# Encrypt with age key (recommended)
docker run -it --rm -v $(pwd):/workspace ghcr.io/docked-titan-foundation/helmkit \
  sops --age $(cat ~/.age/key.txt) -e -i secrets.yaml
```

The image also includes `age` (v1.2.1) for age-based encryption. For use with Helm Secrets plugin, mount your SOPS configuration and age keys:

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  -v ~/.sops.yaml:/home/helmkit/.sops.yaml:ro \
  -v ~/.age:/home/helmkit/.age:ro \
  ghcr.io/docked-titan-foundation/helmkit \
  helmfile diff
```

## 🔨 Building Locally

```bash
make build
```

## 🔐 Verification

### Verify Image Signature (Cosign)
```bash
# Install cosign first: https://docs.sigstore.dev/cosign/installation/
cosign verify \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp "https://github.com/docked-titan-foundation/helmkit" \
  ghcr.io/docked-titan-foundation/helmkit:latest
```

### Verify SBOM Attestation
```bash
cosign verify-attestation \
  --type spdxjson \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp "https://github.com/docked-titan-foundation/helmkit" \
  ghcr.io/docked-titan-foundation/helmkit:latest | jq .
```

### Inspect SBOM
```bash
docker sbom ghcr.io/docked-titan-foundation/helmkit:latest
```

## 🛡️ Security Hardening

Run with maximum security restrictions:
```bash
docker run \
  --rm \
  --read-only \
  --user 1000:1000 \
  --cap-drop ALL \
  --security-opt no-new-privileges:true \
  --tmpfs /tmp:size=100m \
  -v $(pwd):/workspace:ro \
  -v ~/.kube:/home/helmkit/.kube:ro \
  ghcr.io/docked-titan-foundation/helmkit:latest \
  helmfile diff
```

## 🔄 CI/CD Integration

### GitHub Actions
```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    container:
      image: ghcr.io/docked-titan-foundation/helmkit:latest
      options: --user 1000:1000 --read-only
    steps:
      - uses: actions/checkout@v4
      - name: Helmfile Diff
        run: helmfile diff
      - name: Helmfile Apply
        run: helmfile apply
```

### GitLab CI
```yaml
deploy:
  image: ghcr.io/docked-titan-foundation/helmkit:latest
  script:
    - helmfile diff
    - helmfile apply
```

## ⚙️ Requirements

- Docker 20.10+

---

# 🗺️ Roadmap

## 📌 Overview

This roadmap tracks the progress of the Helmkit Docker Image.


## ✅ Completed
- [x] Semantic Release versioning configured
    - [x] Beta versions  
- [x] CI/CD workflow
- [x] Pre commit configurations
    - [x] Lint Dockerfile
    - [x] Build Dockerfile
    - [x] Integration Test
- [x] Sign
    - [x] Docker image
    - [x] Tags/Releases
- [x] Docker image available
- [x] Automated Testing of the docker images built


## 🚧 In Progress
- [ ] Image maintenance
- [ ] More Integration testing scenarios

## 📋 Planned
- [ ] Pre release Versioning
- [ ] Maintenance Releases
- [ ] Version Matrix Automated
- [ ] Use Renovate Bot instead Dependabot, which supports Dockerfile ARG patterns.
- [ ] Multi-Architecture Support
- [ ] More Usage Examples
- [ ] Kubernetes Version Compatibility Matrix
- [ ] No Negative Test Cases
- [ ] Layer Optimization and Cache Efficiency
- [ ] Rebuild workflow

## 📜 License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.


## ⚠️ AI Training Notice

**This project does not authorize the use of its code, documentation, or any associated materials for training artificial intelligence (AI) or machine learning (ML) models.** Any use of this repository's content for AI/ML training purposes is strictly prohibited without explicit written permission from the project owner.
