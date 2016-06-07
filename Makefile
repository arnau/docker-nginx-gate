VERSION = test
IMAGE = arnau/nginx-gate:$(VERSION)
JWT_SECRET ?= VGhpcyBzZWNyZXQgaXMgc3RvcmVkIGJhc2UtNjQgZW5jb2RlZCBvbiB0aGUgcHJveHkgaG9zdA

build:
	docker build -t $(IMAGE) .
.PHONY: build

install:
	docker run -d \
             --env JWT_SECRET=$(JWT_SECRET) \
             --env JWT_SECRET_IS_BASE64_ENCODED=true \
             --publish 1080:80 \
             --publish 1443:443 \
             --name gate \
             $(IMAGE)
.PHONY: install

clean:
	docker rm -vf gate
.PHONY: clean

shell:
	docker run --rm -it $(IMAGE) sh
.PHONY: shell

logs:
	docker logs -f gate
.PHONY: logs

token:
	curl -XPOST http://localhost:1080/sign \
       -d '{"sub": "arnau", "iss": "local"}'
.PHONY: sign

test: test-secure test-secure-admin
.PHONY: test

test-secure:
	curl -i \
       -H 'Authorization: Bearer $(TOKEN)' \
       -XGET http://localhost:1080/secure
.PHONY: test-secure

test-secure-admin:
	curl -i \
       -H 'Authorization: Bearer $(TOKEN)' \
       -XGET http://localhost:1080/secure/admin
.PHONY: test-secure-admin
