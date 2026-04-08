# Contributing to Helmkit

Contributions are welcome! Please read this guide to get started.

## Development Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/docked-titan-foundation/helmkit.git
   cd helmkit
   ```

2. Build the Docker image locally:
   ```bash
   docker build -t helmkit .
   ```

3. Test the image:
   ```bash
   docker run --rm helmkit helmfile --version
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
4. Ensure the Dockerfile lints successfully:
   ```bash
   hadolint Dockerfile
   ```
5. Commit your changes (`git commit -m 'Add my feature'`)
6. Push to your fork (`git push origin feature/my-feature`)
7. Open a Pull Request

## Coding Standards

- Dockerfile should pass hadolint validation
- Use Alpine Linux as the base image
- Specify explicit versions for binaries
- Keep the image size minimal

## License

By contributing, you agree that your contributions will be licensed under the GNU General Public License v3.0.
