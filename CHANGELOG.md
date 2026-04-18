## [1.5.2](https://github.com/docked-titan-foundation/helmkit/compare/v1.5.1...v1.5.2) (2026-04-18)


### Bug Fixes

* **ci:** ensure pushed image digest matches scanned image for supply-chain integrity ([0791d1f](https://github.com/docked-titan-foundation/helmkit/commit/0791d1fb83984e6c0a0a80542032bba0d7bfabde))
* **ci:** use correct input 'file' instead of 'dockerfile' in build-push-action ([898f087](https://github.com/docked-titan-foundation/helmkit/commit/898f0875ee5ed9137d3faa7006f49f1f4ce6906d))

## [1.5.1](https://github.com/docked-titan-foundation/helmkit/compare/v1.5.0...v1.5.1) (2026-04-18)


### Bug Fixes

* **ci:** add SLSA build provenance attestation for container images ([3bf6878](https://github.com/docked-titan-foundation/helmkit/commit/3bf6878ec9b93f85211e86d6a84dfeb08ed6e977))

# [1.5.0](https://github.com/docked-titan-foundation/helmkit/compare/v1.4.0...v1.5.0) (2026-04-17)


### Features

* create attestation automation for docker images ([56776da](https://github.com/docked-titan-foundation/helmkit/commit/56776dadd331b6fbf6dae472b5ef2e6716aa22ce))

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
