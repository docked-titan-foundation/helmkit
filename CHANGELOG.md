# [1.4.0](https://github.com/docked-titan-foundation/helmkit/compare/v1.3.0...v1.4.0) (2026-04-16)


### Bug Fixes

* **semantic-release:** Add actions correctly to the release and update the versions correctly with the script ([f38303c](https://github.com/docked-titan-foundation/helmkit/commit/f38303cb24d941fc20ca880bba8e33f68016f550))


### Features

* **actions:** Add general action in the root directory and delete the old actions folder to clean up the project. ([cf12dc4](https://github.com/docked-titan-foundation/helmkit/commit/cf12dc466ab3996dd182e4831dd33dc3cfffcb6b))

# [1.3.0](https://github.com/docked-titan-foundation/helmkit/compare/v1.2.0...v1.3.0) (2026-04-15)


### Features

* **helmkit:** update tool versions and SHA256 checksums ([bae15a9](https://github.com/docked-titan-foundation/helmkit/commit/bae15a9c08a06e271d636c53e6ec5bb902de746f))

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
