# [1.2.0](https://github.com/docked-titan-foundation/helmkit/compare/v1.1.0...v1.2.0) (2026-04-15)


### Features

* **helmkit:** Upgrade Helmkit to use helm v4.1.1, helm diff v3.15.3 and helm secrets v4.7.4 ([9058a40](https://github.com/docked-titan-foundation/helmkit/commit/9058a407b4adc22d5d2675bb6b8493e0a6613d3c))

# [1.1.0](https://github.com/docked-titan-foundation/helmkit/compare/v1.0.0...v1.1.0) (2026-04-14)


### Features

* **actions:** add new helmkit actions ([ecea9c7](https://github.com/docked-titan-foundation/helmkit/commit/ecea9c7aa3cd1489a96f31bbf4a1d3516d4d1a5b))

# [1.1.0](https://github.com/docked-titan-foundation/helmkit/compare/v1.0.0...v1.1.0) (2026-04-14)


### Features

* **actions:** add new helmkit actions ([ecea9c7](https://github.com/docked-titan-foundation/helmkit/commit/ecea9c7aa3cd1489a96f31bbf4a1d3516d4d1a5b))

# [1.0.0](https://github.com/docked-titan-foundation/helmkit/compare/v0.0.0...v1.0.0) (2026-04-12)

### Features

* feat: Helmkit - Alpine-based Docker image with Helm, Helmfile, kubectl, Helm Diff, Helm Secrets, and SOPS
    - Lightweight Alpine image with Kubernetes tooling pre-installed
    - CI/CD pipeline with semantic release versioning
    - GPG-signed commits and Cosign image verification
    - Automated testing, security scanning (Trivy), and SBOM generation
    - Non-root user support for security hardening
