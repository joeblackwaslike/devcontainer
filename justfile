local_image  := "joeblackwaslike/devcontainer:latest"
remote_image := "ghcr.io/joeblackwaslike/devcontainer:latest"

# Build the image locally
build:
    DOCKER_BUILDKIT=1 docker buildx build --progress=plain image -t {{local_image}}

# Build multi-arch and push to GHCR
push:
    docker buildx build \
        --platform linux/amd64,linux/arm64 \
        --progress=plain \
        --push \
        -t {{remote_image}} \
        image

# Open a shell in the local image
shell:
    docker run -it --rm \
        -v $HOME/.orbstack/run/docker.sock:/var/run/docker.sock \
        {{local_image}} /bin/zsh

# Install a dev container template into a project (interactive)
init target=".":
    bash scripts/install.sh {{target}}

# Run smoke tests against the local image (goss)
test: build
    docker run --rm -v "$(pwd)/tests/goss.yaml:/goss.yaml:ro" {{local_image}} \
        goss validate --format documentation --color

# Publish templates to GHCR (requires CR_PAT env var)
publish-templates:
    GITHUB_TOKEN="$CR_PAT" devcontainer templates publish \
        -r ghcr.io \
        -n joeblackwaslike \
        ./src
