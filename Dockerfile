# ============================================================
# Stage 1: Binary Fetcher / Builder
# ============================================================
FROM alpine:3.23@sha256:5b10f432ef3da1b8d4c7eb6c487f2f5a8f096bc91145e68878dd4a5019afde11 AS fetcher

ARG HELM_VERSION=4.2.0
ARG HELMFILE_VERSION=1.5.1
ARG KUBECTL_VERSION=1.36.1
ARG SOPS_VERSION=3.13.1
ARG HELM_SHA256="97dbeb971be4ac4b27e3839976d9564c0fb35c6f3b1da89dd1e292d236af4096"
ARG KUBECTL_SHA256="629d3f410e09bf49b64ae7079f7f0bda1191efed311f7d37fdbab0ad5b0ec2b7"
ARG SOPS_SHA256="620a9d7e3352ababeca6908cea24a6e8b14ce89a448ddbd3f94f1ef3398f470a"

ENV HELM_VERSION=${HELM_VERSION}
ENV HELMFILE_VERSION=${HELMFILE_VERSION}
ENV KUBECTL_VERSION=${KUBECTL_VERSION}
ENV SOPS_VERSION=${SOPS_VERSION}

# hadolint ignore=DL3018
RUN apk add --no-cache \
    curl \
    ca-certificates \
    gnupg

WORKDIR /downloads

RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
        x86_64) ARCH=amd64 ;; \
        aarch64) ARCH=arm64 ;; \
    esac && \
    curl -fsSL -o /tmp/helm.tar.gz "https://get.helm.sh/helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz" && \
    printf '%s  /tmp/helm.tar.gz\n' "${HELM_SHA256}" > /tmp/helm.checksum && \
    sha256sum -c /tmp/helm.checksum && \
    tar -xzf /tmp/helm.tar.gz -C /usr/local/bin --strip-components=1 "linux-${ARCH}/helm" && \
    rm /tmp/helm.tar.gz /tmp/helm.checksum && \
    chmod +x /usr/local/bin/helm

RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
        x86_64) ARCH=amd64 ;; \
        aarch64) ARCH=arm64 ;; \
    esac && \
    curl -fsSL -o /tmp/helmfile.tar.gz "https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_${ARCH}.tar.gz" && \
    tar -xzf /tmp/helmfile.tar.gz -C /usr/local/bin helmfile && \
    rm /tmp/helmfile.tar.gz && \
    chmod +x /usr/local/bin/helmfile

RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
        x86_64) ARCH=amd64 ;; \
        aarch64) ARCH=arm64 ;; \
    esac && \
    curl -fsSL -o /usr/local/bin/kubectl "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${ARCH}/kubectl" && \
    printf '%s  /usr/local/bin/kubectl\n' "${KUBECTL_SHA256}" > /tmp/kubectl.checksum && \
    sha256sum -c /tmp/kubectl.checksum && \
    rm /tmp/kubectl.checksum && \
    chmod +x /usr/local/bin/kubectl

RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
        x86_64) ARCH=amd64 ;; \
        aarch64) ARCH=arm64 ;; \
    esac && \
    curl -fsSL \
    "https://github.com/getsops/sops/releases/download/v${SOPS_VERSION}/sops-v${SOPS_VERSION}.linux.${ARCH}" \
    -o /usr/local/bin/sops && \
    printf '%s  /usr/local/bin/sops\n' "${SOPS_SHA256}" > /tmp/sops.checksum && \
    sha256sum -c /tmp/sops.checksum && \
    rm /tmp/sops.checksum && \
    chmod 755 /usr/local/bin/sops

# ============================================================
# Stage 2: Plugin Installer (needs Helm binary)
# ============================================================
FROM fetcher AS plugin-installer

# Use system-wide plugin directory accessible to non-root users
ENV HELM_PLUGINS=/usr/local/share/helm/plugins
ENV HELM_DATA_HOME=/usr/local/share/helm
RUN mkdir -p "${HELM_PLUGINS}"

# Import GPG keys for plugin verification
RUN mkdir -p /usr/local/share/helm/keys && \
    curl -fsSL https://github.com/jkroepke.gpg -o /usr/local/share/helm/keys/jkroepke.gpg.raw && \
    gpg --dearmor < /usr/local/share/helm/keys/jkroepke.gpg.raw > /usr/local/share/helm/keys/jkroepke.gpg && \
    chmod 600 /usr/local/share/helm/keys/jkroepke.gpg && \
    rm /usr/local/share/helm/keys/jkroepke.gpg.raw

ARG HELM_DIFF_VERSION=3.15.5
ARG HELM_SECRETS_VERSION=4.7.4

# hadolint ignore=DL3018
RUN apk add --no-cache \
    git && \
    rm -rf /var/cache/apk/*

# Install plugins to system-wide directory
RUN helm plugin install https://github.com/databus23/helm-diff --version ${HELM_DIFF_VERSION} --verify=false && \
    helm plugin install https://github.com/jkroepke/helm-secrets/releases/download/v${HELM_SECRETS_VERSION}/secrets-${HELM_SECRETS_VERSION}.tgz --keyring /usr/local/share/helm/keys/jkroepke.gpg && \
    helm plugin install https://github.com/jkroepke/helm-secrets/releases/download/v${HELM_SECRETS_VERSION}/secrets-getter-${HELM_SECRETS_VERSION}.tgz --keyring /usr/local/share/helm/keys/jkroepke.gpg && \
    helm plugin install https://github.com/jkroepke/helm-secrets/releases/download/v${HELM_SECRETS_VERSION}/secrets-post-renderer-${HELM_SECRETS_VERSION}.tgz --keyring /usr/local/share/helm/keys/jkroepke.gpg

# ============================================================
# Stage 3: Final Runtime Image
# ============================================================
FROM alpine:3.23@sha256:5b10f432ef3da1b8d4c7eb6c487f2f5a8f096bc91145e68878dd4a5019afde11 AS runtime

ARG APP_VERSION
ARG BUILD_DATE
ARG VCS_REF

# OCI Image Spec Labels
LABEL org.opencontainers.image.title="helmkit" \
      org.opencontainers.image.description="Hardened Helm tooling image for CI/CD" \
      org.opencontainers.image.version="${APP_VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.source="https://github.com/docked-titan-foundation/helmkit" \
      org.opencontainers.image.licenses="GPL-3.0" \
      org.opencontainers.image.vendor="Docked Titan Foundation"

# hadolint ignore=DL3018
RUN apk add --no-cache \
    ca-certificates \
    git \
    openssh-client \
    gnupg \
    age \
    bash && \
    rm -rf /var/cache/apk/*

# Copy verified binaries from fetcher stage
COPY --from=fetcher /usr/local/bin/helm      /usr/local/bin/helm
COPY --from=fetcher /usr/local/bin/helmfile  /usr/local/bin/helmfile
COPY --from=fetcher /usr/local/bin/kubectl   /usr/local/bin/kubectl
COPY --from=fetcher /usr/local/bin/sops      /usr/local/bin/sops

# Copy Helm plugins from plugin-installer stage (system-wide location)
COPY --from=plugin-installer /usr/local/share/helm/plugins /usr/local/share/helm/plugins

# Create non-root user and set permissions
RUN addgroup -g 1000 helmkit && \
    adduser -u 1000 -G helmkit -s /bin/bash -D helmkit && \
    mkdir -p /workspace /home/helmkit/.kube /home/helmkit/.config/helm /home/helmkit/.cache/helm && \
    chown -R helmkit:helmkit /workspace /home/helmkit && \
    chown -R helmkit:helmkit /usr/local/share/helm/plugins && \
    chmod -R 755 /usr/local/share/helm/plugins

# Set plugin environment
ENV HELM_PLUGINS=/usr/local/share/helm/plugins
ENV HELM_CACHE_HOME=/home/helmkit/.cache/helm

# Set secure filesystem permissions
RUN chmod 755 /usr/local/bin/helm \
              /usr/local/bin/helmfile \
              /usr/local/bin/kubectl \
              /usr/local/bin/sops

WORKDIR /workspace
USER helmkit

# Healthcheck (validates tools are functional)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD helm version --short && helmfile --version && kubectl version --client

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["helm version && helmfile --version && kubectl version --client"]

# ============================================================
# Stage 4: Actions Image
# ============================================================
FROM runtime AS actions

ARG APP_VERSION
ARG BUILD_DATE
ARG VCS_REF

ENV HELM_PLUGINS=/usr/local/share/helm/plugins
ENV HELM_CACHE_HOME=/home/helmkit/.cache/helm

# OCI Image Spec Labels
LABEL org.opencontainers.image.title="helmkit actions" \
      org.opencontainers.image.description="Hardened Helm tooling image for CI/CD" \
      org.opencontainers.image.version="${APP_VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.source="https://github.com/docked-titan-foundation/helmkit-action" \
      org.opencontainers.image.licenses="GPL-3.0" \
      org.opencontainers.image.vendor="Docked Titan Foundation"


COPY scripts/action/entrypoint.sh /entrypoint.sh

# hadolint ignore=DL3002
USER root

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
