#!make
.PHONY: install compile test

install:
	npm install

compile:
	npm run compile

test:
	npm test

