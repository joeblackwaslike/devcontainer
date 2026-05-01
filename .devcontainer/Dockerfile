FROM mcr.microsoft.com/devcontainers/base:ubuntu

ARG USERNAME=vscode
ENV DEBIAN_FRONTEND=noninteractive

# RUN apt-get update && apt-get install -y --no-install-recommends \
#     build-essential \
#     ca-certificates \
#     curl \
#     file \
#     git \
#     gpg \
#     libbz2-dev \
#     libffi-dev \
#     liblzma-dev \
#     libncursesw5-dev \
#     libreadline-dev \
#     libsqlite3-dev \
#     libssl-dev \
#     libxml2-dev \
#     libxmlsec1-dev \
#     libzstd-dev \
#     llvm \
#     locales \
#     make \
#     ruby-full \
#     tk-dev \
#     wget \
#     xz-utils \
#     zlib1g-dev \
#     zsh \
#     && rm -rf /var/lib/apt/lists/*

RUN localedef -i en_US -f UTF-8 en_US.UTF-8

# RUN usermod -aG sudo $USERNAME &&  \
#     mkdir -p /home/linuxbrew/.linuxbrew && \
#     chown -R $USERNAME: /home/linuxbrew/.linuxbrew

# USER $USERNAME

# RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)" && \
#      echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"' >> /home/vscode/.bashrc && \
#      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)" && \
#      chown -R $CONTAINER_USER: /home/linuxbrew/.linuxbrew && \
#      git config --global --add safe.directory /home/linuxbrew/.linuxbrew/Homebrew

# ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"

ADD --chmod 755 --chown=$USERNAME:$USERNAME https://raw.githubusercontent.com/seatgeek/bash-aptfile/master/bin/aptfile /usr/local/bin/aptfile

COPY .zshrc /home/$USERNAME/
COPY .mytheme.omp.yaml /home/$USERNAME/
COPY Aptfile /home/$USERNAME/

RUN aptfile /home/$USERNAME/Aptfile

RUN curl -sSL https://github.com/asdf-vm/asdf/releases/download/v0.18.1/asdf-v0.18.1-linux-arm64.tar.gz -o /tmp/asdf-v0.18.1-linux-arm64.tar.gz && \
    tar -xzf /tmp/asdf-v0.18.1-linux-arm64.tar.gz -C /usr/local/bin/ && \
    chmod 755 /usr/local/bin/asdf && \
    rm /tmp/asdf-v0.18.1-linux-arm64.tar.gz

RUN asdf plugin add python && \
    asdf install python latest:3 && \
    asdf set -u python latest:3

RUN asdf plugin add nodejs && \
    asdf install nodejs lts && \
    asdf set -u nodejs lts

RUN asdf plugin add ruby && \
    asdf install ruby latest:4 && \
    asdf set -u ruby latest:4

RUN asdf plugin add golang https://github.com/asdf-community/asdf-golang.git && \
    asdf install golang latest:1 && \
    asdf set -u golang latest:1

RUN asdf plugin add rust && \
    asdf install rust stable && \
    asdf set -u rust stable

RUN asdf plugin add bun && \
    asdf install bun latest:1 && \
    asdf set -u bun latest:1

RUN asdf plugin add pnpm && \
    asdf install pnpm latest:10 && \
    asdf set -u pnpm latest:10

RUN asdf plugin add awscli && \
    asdf install awscli latest:2 && \
    asdf set -u awscli latest:2

RUN asdf plugin add gcloud && \
    asdf install gcloud latest && \
    asdf set -u gcloud latest

RUN asdf plugin add pipx && \
    asdf install pipx latest:1 && \
    asdf set -u pipx latest:1

RUN asdf plugin add supabase-cli && \
    asdf install supabase-cli latest && \
    asdf set -u supabase-cli latest

RUN asdf plugin add yarn && \
    asdf install yarn latest && \
    asdf set -u yarn latest

RUN asdf plugin add jq && \
    asdf install jq latest && \
    asdf set -u jq latest

RUN asdf plugin add yq && \
    asdf install yq latest && \
    asdf set -u yq latest

# RUN volta install @openai/codex

# RUN curl -fsSL https://claude.ai/install.sh | zsh

# RUN go install github.com/steveyegge/beads/cmd/bd@latest
