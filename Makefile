all: build push

build:
	docker build -t sysdig/secure-image-scanning .

push:
	docker push sysdig/secure-image-scanning
