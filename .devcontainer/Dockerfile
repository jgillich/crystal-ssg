# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.231.5/containers/debian/.devcontainer/base.Dockerfile

# [Choice] Debian version (use bullseye on local arm64/Apple Silicon): bullseye, buster
ARG VARIANT="buster"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

RUN apt update && apt install build-essential fswatch -y \
  && curl -fsSL https://crystal-lang.org/install.sh | bash \
  && wget https://github.com/elbywan/crystalline/releases/latest/download/crystalline_x86_64-unknown-linux-gnu.gz -O crystalline.gz \
  && gzip -d crystalline.gz && chmod +x crystalline && mv crystalline /usr/local/bin/crystalline \
  && mkdir -p /etc/nix \
  && bash -c "printf \"sandbox = false\" > /etc/nix/nix.conf"



USER vscode
ENV USER=vscode

RUN bash -c "sh <(curl -L https://releases.nixos.org/nix/nix-2.6.1/install) --no-daemon" \
  && . /home/vscode/.nix-profile/etc/profile.d/nix.sh \
  && nix-env -iA -f '<nixpkgs>' watchexec