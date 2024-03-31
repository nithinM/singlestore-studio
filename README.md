# SingleStore Studio Docker Automation

This project automates Docker builds for SingleStore Studio, ensuring the latest versions are always available as Docker images on Docker Hub. It leverages GitHub Actions for version tracking and build automation.

## Docker Hub

Discover our Docker images: [Your Docker Hub Repository](https://hub.docker.com/r/nithinm/singlestore-studio)

![Docker Pulls](https://img.shields.io/docker/pulls/nithinm/singlestore-studio.svg) ![Docker Image Size](https://img.shields.io/docker/image-size/nithinm/singlestore-studio/latest.svg)

## How It Works

- **On PR Creation**: Initiates a Docker build for the latest version specified, without marking it in `versions.txt`.
- **On PR Approval**: Builds and pushes the Docker image to Docker Hub and updates `versions.txt` to reflect the new build.

## Getting Started

Fork or clone this repository if you're interested in using or contributing to this project. Your contributions are welcome, whether they involve adding new versions to `versions.txt`, enhancing the automation scripts, or fixing bugs.

## Contributing

We encourage contributions from the community. Here's how you can contribute:
- **Suggesting Enhancements**: Open an issue to suggest improvements.
- **Reporting Bugs**: If you find a bug, please report it by opening an issue.
- **Opening Pull Requests**: Feel free to create pull requests with new features or fixes.

Before contributing, please review the [CONTRIBUTING.md](CONTRIBUTING.md) document for guidelines on how to submit contributions.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Disclaimer

This is an unofficial project and is not affiliated with SingleStore Inc. It's created and maintained by the community.
