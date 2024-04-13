FROM alpine:3.19.1

# Versions can be overriden via --build-arg
# e.g docker build -t <image_name> --build-arg KUBECTL_VERSION=X.XX.X .
ARG KUBECTL_VERSION=1.29.2
ARG KUSTOMIZE_VERSION=5.4.1
ARG HELM_VERSION=3.14.3
ARG KUBECONFORM_VERSION=0.6.3
ARG OPKUSTOMIZE_VERSION=1.2.0
ARG KUBECTLXTRA_VERSION=1.0.0

COPY ./scripts/binary_installer.sh ./binary_installer.sh

#Dependencies
RUN apk add --update --no-cache curl ca-certificates bash git gettext

#Change to shell to bash
SHELL ["/bin/bash", "-c"]

# Uses custom script to install binaries
# ./binary_installer.sh <binary_name> <script_mode> <release_url> <install_path> [verify_cmd] [--debug]
# If ARCH is needed use '{INJECT_ARCH}' to let the script inject the value into the urls

#Install kubectl
RUN ./binary_installer.sh kubectl binary "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/{INJECT_ARCH}/kubectl" /usr/bin/ help
## Install kubectlxtra (wrapper)
RUN ./binary_installer.sh kubectlxtra binary "https://raw.githubusercontent.com/alexbaeza/kubectlxtra/v${KUBECTLXTRA_VERSION}/kubectlxtra.sh" /usr/bin/ help
## Install kustomize
RUN ./binary_installer.sh kustomize tar "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv${KUSTOMIZE_VERSION}/kustomize_v${KUSTOMIZE_VERSION}_linux_{INJECT_ARCH}.tar.gz" /usr/bin/ version
## Install opkustomize (wrapper)
RUN ./binary_installer.sh opkustomize binary "https://raw.githubusercontent.com/alexbaeza/opkustomize/v${OPKUSTOMIZE_VERSION}/opkustomize.sh" /usr/bin/ help
## Install Helm
RUN ./binary_installer.sh helm tar "https://get.helm.sh/helm-v${HELM_VERSION}-linux-{INJECT_ARCH}.tar.gz" /usr/bin/ "version"
## Install kubeconform
RUN ./binary_installer.sh kubeconform tar "https://github.com/yannh/kubeconform/releases/download/v${KUBECONFORM_VERSION}/kubeconform-linux-{INJECT_ARCH}.tar.gz" /usr/bin/ "-v"

WORKDIR /apps
