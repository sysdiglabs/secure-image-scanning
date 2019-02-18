all: build push

build:
	docker build -t sysdiglabs/secure-image-scanning .

push:
	docker push sysdiglabs/secure-image-scanning
