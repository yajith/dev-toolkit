# Note: these can be overriden on the command line e.g. `make VERSION=2024.08`
VERSION=2024.08

.PHONY: setup clean base

setup:
	docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
	docker buildx create --name multiarch --driver docker-container --use
	docker buildx inspect --bootstrap

clean:
	docker buildx rm multiarch

base: setup
	docker buildx build --push --platform=linux/arm64,linux/amd64 -t yajithd/dev-toolkit:$(VERSION) -f Dockerfile .
