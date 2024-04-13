<div style="text-align: center" align="center">

# All-in-one Kubernetes CI/CD Docker Image

> This all-in-one Docker image is designed to provide a minimal environment with all the necessary tools for a CI/CD
> deployment in Kubernetes, no more installing tools on your ci/cd workflows.

[![Commits](https://img.shields.io/github/commit-activity/w/alexbaeza/k8s-ci-cd?style=flat)](https://github.com/alexbaeza/k8s-ci-cd/pulse)
[![Issues](https://img.shields.io/github/issues/alexbaeza/k8s-ci-cd.svg?style=flat)](https://github.com/alexbaeza/k8s-ci-cd/issues)
[![Releases](https://img.shields.io/github/v/release/alexbaeza/k8s-ci-cd.svg?style=flat)](https://github.com/alexbaeza/k8s-ci-cd/releases)

</div>

## Tools Included

| Tool                                                      | Description                                                       | Version |
|-----------------------------------------------------------|-------------------------------------------------------------------|---------|
| [kubectl](https://github.com/kubernetes/kubectl)          | Kubernetes command-line tool.                                     | 1.29.2  |
| [kubectlxtra](https://github.com/alexbaeza/kubectlxtra)   | Wrapper around kubectl with additional functionalities.           | 1.0.0   |
| [kustomize](https://github.com/kubernetes-sigs/kustomize) | Customization of Kubernetes YAML configurations.                  | 5.4.1   |
| [opkustomize](https://github.com/alexbaeza/opkustomize)   | Wrapper around kustomize with additional functionalities.         | 1.0.0   |
| [helm](https://github.com/helm/helm)                      | Kubernetes package manager.                                       | 3.14.3  |
| [kubeconform](https://github.com/yannh/kubeconform)       | Tool for validating Kubernetes YAML files against best practices. | 0.6.3   |

## Usage

1. Pull the image

```shell
docker pull betterdev/k8s-ci-cd:latest
```

2. executing Bash Shell in Container

To open a bash shell within the container:

```shell
docker run -it betterdev/k8s-ci-cd bash
```

3. Utilize the included tools (`kubectl`, `kustomize`, `Helm`, `kubeconform`, etc.) to manage your Kubernetes
   deployments seamlessly.

## Usage in your CI/CD Workflows

With this Docker image, you can build your CI/CD pipeline with the following steps:

1. Configure your CI/CD to use this image:

```shell
#Example on Github actions

name: My Github action workflow
...
jobs:
  test:
    runs-on: ubuntu-latest
    container: betterdev/k8s-ci-cd:latest # <-- Use this docker image 
    steps:
      - run: echo "Running v1.0.0 of this awesome 🐳 Docker image"

```

2. Utilize the included tools (`kubectl`, `kustomize`, `Helm`, `kubeconform`, etc.) to manage your Kubernetes
   deployments seamlessly.

## Building from Source

If you want to build this image from source, ensure you have Docker installed and follow these steps:

1. Clone the repository containing the Dockerfile and related scripts.
2. Navigate to the directory containing the Dockerfile.
3. Build the Docker image using the following command:

```bash
docker build -t <image_name> .
```

### Selecting Tool Versions

This Docker image allows you to select specific versions of the tools included. The versions are defined as build
arguments in the Dockerfile. To select a particular version for a tool, follow these steps:

1. Identify the name of the tool and its corresponding build argument in the Dockerfile. Here are the tools and their
   associated build arguments:

    - **kubectl**: `KUBECTL_VERSION`
    - **kustomize**: `KUSTOMIZE_VERSION`
    - **Helm**: `HELM_VERSION`
    - **kubeconform**: `KUBECONFORM_VERSION`

2. When building the Docker image using the `docker build` command, provide the desired versions as build arguments
   using the `--build-arg` flag. For example:

```bash
#Override kubectl and kustomize versions only
docker build -t k8s-ci-cd \
  --build-arg KUBECTL_VERSION=1.29.1 \
  --build-arg KUSTOMIZE_VERSION=3.5.4 \
  . --no-cache
```

## License

This Docker image is released under the [MIT License](LICENSE). Feel free to use and modify them
according to your needs.

