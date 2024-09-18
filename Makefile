IMAGE_NAME:jkaninda/laravel-php-fpm
build-8.1:
	docker buildx build -f src/docker/8.1/Dockerfile -t ${IMAGE_NAME}:8.1 .
build-8.2:
	docker buildx build -f src/docker/8.2/Dockerfile -t ${IMAGE_NAME}:8.2 .
build-8.3:
	docker buildx build -f src/docker/8.3/Dockerfile -t ${IMAGE_NAME}:8.3 .