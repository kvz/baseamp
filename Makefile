SHELL := /bin/bash
COFFEE     = node_modules/.bin/coffee
COFFEELINT = node_modules/.bin/coffeelint
MOCHA      = node_modules/.bin/mocha --compilers coffee:coffee-script --require "coffee-script/register"
REPORTER   = spec

lint:
	@[ ! -f coffeelint.json ] && $(COFFEELINT) --makeconfig > coffeelint.json || true
	$(COFFEELINT) --file ./coffeelint.json src

build:
	make lint || true
	$(COFFEE) $(CSOPTS) -c -o lib src

test: build
	DEBUG=Baseamp:* $(MOCHA) --reporter $(REPORTER) test/ --grep "$(GREP)"

compile:
	@echo "Compiling files"
	time make build

run-export:
	source env.sh && make build && DEBUG=Baseamp:* ./bin/baseamp export ./test/fixtures/test.md

run-import:
	source env.sh && make build && DEBUG=Baseamp:* ./bin/baseamp import -

watch:
	watch -n 2 make -s compile

release-major: build test
	npm version major -m "Release %s"
	git push
	npm publish

release-minor: build test
	npm version minor -m "Release %s"
	git push
	npm publish

release-patch: build test
	npm version patch -m "Release %s"
	git push
	npm publish

.PHONY: \
	test \
	lint \
	build \
	run-import \
	run-export \
	release-major \
	release-minor \
	release-patch \
	compile \
	watch
