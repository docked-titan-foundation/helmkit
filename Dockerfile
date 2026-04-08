FROM alpine:latest

ARG HELM_VERSION=3.15.0
ARG HELMFILE_VERSION=1.4.3
ARG KUBECTL_VERSION=1.30.0
ARG HELM_DIFF_VERSION=3.10.0
ARG HELM_SECRETS_VERSION=3.2.0

ENV HELM_VERSION=${HELM_VERSION}
ENV HELMFILE_VERSION=${HELMFILE_VERSION}
ENV KUBECTL_VERSION=${KUBECTL_VERSION}
ENV HELM_DIFF_VERSION=${HELM_DIFF_VERSION}
ENV HELM_SECRETS_VERSION=${HELM_SECRETS_VERSION}

RUN apk add --no-cache curl wget ca-certificates

RUN wget -O /usr/local/bin/helm https://github.com/helm/helm/releases/download/v${HELM_VERSION}/helm-${HELM_VERSION}-linux-amd64.tar.gz && \
    tar -xzf /usr/local/bin/helm -C /usr/local/bin helm && \
    rm /usr/local/bin/helm-${HELM_VERSION}-linux-amd64.tar.gz && \
    chmod +x /usr/local/bin/helm

RUN wget -O /usr/local/bin/helmfile https://github.com/helmfile/helmfile/releases/download/v${HELMFILE_VERSION}/helmfile_${HELMFILE_VERSION}_linux_amd64 && \
    chmod +x /usr/local/bin/helmfile

RUN wget -O /usr/local/bin/kubectl https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x /usr/local/bin/kubectl

RUN helm plugin install https://github.com/databus23/helm-diff --version v${HELM_DIFF_VERSION}

RUN helm plugin install https://github.com/jkroepke/helm-secrets --version v${HELM_SECRETS_VERSION}

RUN helmfile --version && \
    kubectl version --client && \
    helm version

WORKDIR /workspace

CMD ["/bin/sh"]