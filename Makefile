SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

INPUT?=404.txt
OUTPUT?=index.html

ARCHIVE=2024

.PHONY: build update all archive

all: build archive

build: update
	bin/build.sh < $(INPUT) > $(OUTPUT)

update:
	bin/update.sh < $(INPUT) > $(INPUT).tmp
	mv $(INPUT).tmp $(INPUT)

archive: $(ARCHIVE) $(ARCHIVE).txt $(ARCHIVE)/index.html

$(ARCHIVE):
	mkdir -p $(ARCHIVE)

$(ARCHIVE).txt:
	cp 404.txt $(ARCHIVE).txt

$(ARCHIVE)/index.html: $(ARCHIVE).txt
	$(MAKE) INPUT=$(ARCHIVE).txt OUTPUT=$(ARCHIVE)/index.html
