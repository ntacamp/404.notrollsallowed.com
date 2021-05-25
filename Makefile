INPUT?=404.txt
OUTPUT?=index.html

ARCHIVE=2020

.PHONY: build update all

all: build $(ARCHIVE)/index.html

build: update
	bin/build.sh < $(INPUT) > $(OUTPUT)

update:
	bin/update.sh < $(INPUT) > $(INPUT).tmp
	mv $(INPUT).tmp $(INPUT)

$(ARCHIVE)/index.html:
	mkdir -p $(ARCHIVE)
	$(MAKE) INPUT=$(ARCHIVE).txt OUTPUT=$(ARCHIVE)/index.html
