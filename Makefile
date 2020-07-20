INPUT=404.txt
OUTPUT=index.html

.PHONY: build update

build: update
	bin/build.sh < $(INPUT) > $(OUTPUT)

update:
	bin/update.sh < $(INPUT) > $(INPUT).tmp
	mv $(INPUT).tmp $(INPUT)
