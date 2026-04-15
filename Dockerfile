# ============================================================
# Stage 1: Binary Fetcher / Builder
# ============================================================
FROM alpine:3.23@sha256:25109184c71bdad752c8312a8623239686a9a2071e8825f20acb8f2198c3f659 AS fetcher

ARG HELM_VERSION=4.1.4
ARG HELMFILE_VERSION=1.4.4
ARG KUBECTL_VERSION=1.33.9
ARG SOPS_VERSION=3.12.2
ARG HELM_SHA256="70b2c30a19da4db264dfd68c8a3664e05093a361cefd89572ffb36f8abfa3d09"
ARG KUBECTL_SHA256="9e33e3234c0842cd44a12c13e334b4ce930145ea84b855ce7cc0a7b6bc670c22"
ARG SOPS_SHA256="14e2e1ba3bef31e74b70cf0b674f6443c80f6c5f3df15d05ffc57c34851b4998"

ENV HELM_VERSION=${HELM_VERSION}
ENV HELMFILE_VERSION=${HELMFILE_VERSION}
ENV KUBECTL_VERSION=${KUBECTL_VERSION}
ENV SOPS_VERSION=${SOPS_VERSION}

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

COPY --from=fetcher /usr/local/bin/helm /usr/local/bin/helm

RUN mkdir -p ~/.config/helm/keys && \
    curl -fsSL https://github.com/jkroepke.gpg -o ~/.config/helm/keys/jkroepke.gpg.raw && \
    gpg --dearmor < ~/.config/helm/keys/jkroepke.gpg.raw > ~/.config/helm/keys/jkroepke.gpg && \
    chmod 600 ~/.config/helm/keys/jkroepke.gpg && \
    rm ~/.config/helm/keys/jkroepke.gpg.raw

ARG HELM_DIFF_VERSION=3.15.5
ARG HELM_SECRETS_VERSION=4.7.4

# Runtime-only dependencies (minimal)
RUN apk add --no-cache \
    git && \
    # Remove package cache
    rm -rf /var/cache/apk/*

RUN helm plugin install https://github.com/databus23/helm-diff --version ${HELM_DIFF_VERSION} --verify=false && \
    helm plugin install https://github.com/jkroepke/helm-secrets/releases/download/v${HELM_SECRETS_VERSION}/secrets-${HELM_SECRETS_VERSION}.tgz --keyring ~/.config/helm/keys/jkroepke.gpg && \
    helm plugin install https://github.com/jkroepke/helm-secrets/releases/download/v${HELM_SECRETS_VERSION}/secrets-getter-${HELM_SECRETS_VERSION}.tgz --keyring ~/.config/helm/keys/jkroepke.gpg && \
    helm plugin install https://github.com/jkroepke/helm-secrets/releases/download/v${HELM_SECRETS_VERSION}/secrets-post-renderer-${HELM_SECRETS_VERSION}.tgz --keyring ~/.config/helm/keys/jkroepke.gpg

# ============================================================
# Stage 3: Final Runtime Image
# ============================================================
FROM alpine:3.23@sha256:25109184c71bdad752c8312a8623239686a9a2071e8825f20acb8f2198c3f659 AS runtime

ARG APP_VERSION="1.0.0"
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

# Runtime-only dependencies (minimal)
RUN apk add --no-cache \
    ca-certificates \
    git \
    openssh-client \
    gnupg \
    age \
    bash && \
    # Remove package cache
    rm -rf /var/cache/apk/*

# Copy verified binaries from builder stages
COPY --from=fetcher /usr/local/bin/helm      /usr/local/bin/helm
COPY --from=fetcher /usr/local/bin/helmfile  /usr/local/bin/helmfile
COPY --from=fetcher /usr/local/bin/kubectl   /usr/local/bin/kubectl

# Copy Helm plugins from plugin stage
COPY --from=plugin-installer /root/.local/share/helm/plugins \
     /home/helmkit/.local/share/helm/plugins

# Create non-root user
RUN addgroup -g 1000 helmkit && \
    adduser -u 1000 -G helmkit -s /bin/bash -D helmkit && \
    mkdir -p /workspace /home/helmkit/.kube /home/helmkit/.config/helm && \
    chown -R helmkit:helmkit /workspace /home/helmkit

# Set secure filesystem permissions
RUN chmod 755 /usr/local/bin/helm \
              /usr/local/bin/helmfile \
              /usr/local/bin/kubectl

WORKDIR /workspace
USER helmkit

# Healthcheck (validates tools are functional)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD helm version --short && helmfile --version && kubectl version --client

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["helm version && helmfile --version && kubectl version --client"]