# .PHONY build
IMAGE = "joeblackwaslike/devcontainer:latest"

build:
	DOCKER_BUILDKIT=1 docker buildx build --progress=plain .devcontainer -t $(IMAGE)

shell:
	docker run -it --rm -v $(HOME)/.orbstack/run/docker.sock:/var/run/docker.sock   $(IMAGE) /bin/zsh
