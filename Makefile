IMAGE_NAME?=jkaninda/laravel-php-fpm
PHP_VERSIONS?=8.1 8.2 8.3 8.4 8.5
LATEST_PHP?=8.5

.PHONY: all
all: build

##@ Build
.PHONY: build
build: $(addprefix build-,$(PHP_VERSIONS))

.PHONY: build-alpine
build-alpine: $(addsuffix -alpine,$(addprefix build-,$(PHP_VERSIONS)))

.PHONY: build-latest
build-latest: build-$(LATEST_PHP) build-$(LATEST_PHP)-alpine
	docker tag ${IMAGE_NAME}:$(LATEST_PHP) ${IMAGE_NAME}:latest
	docker tag ${IMAGE_NAME}:$(LATEST_PHP)-alpine ${IMAGE_NAME}:alpine

# Legacy images (7.2, 7.3, 7.4, 8.0)
.PHONY: build-7.2 build-7.3 build-7.4 build-8.0
build-7.2 build-7.3 build-7.4 build-8.0: build-%:
	docker build -f src/docker/$*/Dockerfile -t ${IMAGE_NAME}:$* .

.PHONY: build-%-alpine
build-%-alpine:
	docker build --build-arg phpVersion=$* -f src/docker/Dockerfile.alpine -t ${IMAGE_NAME}:$*-alpine .

.PHONY: build-%
build-%:
	docker build --build-arg phpVersion=$* -f src/docker/Dockerfile -t ${IMAGE_NAME}:$* .

##@ Test
.PHONY: test
test: build-$(LATEST_PHP)
	IMAGE=${IMAGE_NAME}:$(LATEST_PHP) ./tests/integration.sh

.PHONY: test-alpine
test-alpine: build-$(LATEST_PHP)-alpine
	IMAGE=${IMAGE_NAME}:$(LATEST_PHP)-alpine ./tests/integration.sh
