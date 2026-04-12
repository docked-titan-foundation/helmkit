# Contributing to Helmkit

Contributions are welcome! Please read this guide to get started.

## Requirements

- Docker 20.10+
- [pre-commit](https://pre-commit.com) (install via `pip install pre-commit` or `brew install pre-commit`)
- [hadolint](https://github.com/hadolint/hadolint) (optional, for local Dockerfile linting)

## Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/docked-titan-foundation/helmkit.git
   cd helmkit
   ```

2. Install pre-commit hooks:
   ```bash
   pip install pre-commit   # or: brew install pre-commit
   pre-commit install
   ```

3. Build the Docker image locally:
   ```bash
   make build
   ```

4. Test the image:
   ```bash
   make precommit
   ```

## Ways to Contribute

- Report bugs
- Suggest new features
- Improve documentation
- Submit pull requests

## Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Make your changes
4. Run pre-commit checks:
   ```bash
   pre-commit run --all-files
   ```
5. Commit your changes (`git commit -m 'Add my feature'`)
6. Push to your fork (`git push origin feature/my-feature`)
7. Open a Pull Request

## Checksum Verification Process
All binary downloads must have their SHA256 verified.
Obtain checksums from the official release page, never from third-party sources.

## Coding Standards

- All files must pass pre-commit hooks
- Dockerfile should pass hadolint validation
- Must pass integration test
- The image must build correctly
- Use Alpine Linux as the base image
- Specify explicit versions for binaries
- Keep the image size minimal

## License

By contributing, you agree that your contributions will be licensed under the GNU General Public License v3.0.
