all: build push

build:
	docker build -t quay.io/abhinavdahiya/bootkube-fluentd:latest .

push:
	docker push quay.io/abhinavdahiya/bootkube-fluentd:latest

