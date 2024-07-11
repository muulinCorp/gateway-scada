VERSION=`git describe --tags`
BUILD_TIME=`date +%FT%T%z`
LDFLAGS=-ldflags "-X main.Version=$(V) -X main.BuildTime=${BUILD_TIME}"
NAME=scada-gw

run: gen-conf
	krakend run -c krakend.json
	# docker run -p "8080:8080" -v $$PWD:/etc/krakend/ devopsfaith/krakend:2.1.4 run -c krakend.json

build-docker-img: gen-conf
	docker build -t ${NAME}:dev .
	docker rmi -f $$(docker images --filter "dangling=true" -q --no-trunc)

push-docker:
	docker tag ${NAME}:dev  94peter/${NAME}:$(V)
	docker push 94peter/${NAME}:$(V)

gen-conf: gen-setting-json
	docker run -it \
	-e FC_ENABLE=1 -e FC_PARTIALS="./partials" \
	-e FC_SETTINGS="./settings" -e FC_OUT=krakend_pretty.json \
	-v $$PWD:/etc/krakend/ devopsfaith/krakend:2.1.4 check -d -t -c ./krakend.tmpl
	docker run -i isaackuang/tools jq --compact-output <krakend_pretty.json '.' > krakend.json

merge-spec:
	docker run -it \
	-v $$PWD:/workdir 94peter/openapi-cli:v1.3 /main ms \
	-main /workdir/main_spec.yml \
	-mergeDir /workdir/allspec/ \
	-output /workdir/doc/v1_api.yml

gen-setting-json: merge-spec
	docker run -it \
	-v $$PWD:/workdir 94peter/openapi-cli:v1.3 /main togs \
	-spec /workdir/doc/v1_api.yml \
	-output /workdir/settings/endpoint.json \
	-version-replace web