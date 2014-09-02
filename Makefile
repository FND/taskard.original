.PHONY: dev undev server terminate autobundle debundle bundle dist_dir tmp_dir

export PATH := ./node_modules/.bin:$(PATH)
export BROWSERIFY_OPTIONS := --extension=".coffee" -o dist/bundle.js \
	scripts/main.coffee

dev: undev autobundle server

undev: debundle terminate

server: terminate tmp_dir
	./server & \
		echo $$! > tmp/server.pid

terminate:
	kill `cat tmp/server.pid` || true
	rm tmp/server.pid || true

autobundle: debundle dist_dir tmp_dir
	`which watchify` -v $(BROWSERIFY_OPTIONS) & \
		echo $$! > tmp/autobundle.pid

debundle:
	kill `cat tmp/autobundle.pid` || true
	rm tmp/autobundle.pid || true

bundle: dist_dir
	`which browserify` $(BROWSERIFY_OPTIONS)

dist_dir:
	mkdir -p dist

tmp_dir:
	mkdir -p tmp
