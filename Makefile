INPUT=404.txt
OUTPUT=index.html

.PHONY: build clean

build:
	bin/build.sh < $(INPUT) > $(OUTPUT)
