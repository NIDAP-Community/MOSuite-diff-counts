# hash:sha256:56c6202a1e920da0082c418155a935c9afed37961e5be6ebf90a826b207afbb3
ARG REGISTRY_HOST
FROM $REGISTRY_HOST/codeocean/mosuite-minimal:v0.5.0

ARG DEBIAN_FRONTEND=noninteractive
ARG GIT_ASKPASS
COPY git-ask-pass /

COPY postInstall /
RUN --mount=type=secret,id=secrets . /run/secrets/secrets \
    && /postInstall
