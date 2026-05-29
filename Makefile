SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

INPUT?=404.txt
OUTPUT?=index.html

ARCHIVE=2025

.PHONY: build update all archive serve

all: build archive

build: update
	bin/build.sh < $(INPUT) > $(OUTPUT)

update:
	bin/update.sh < $(INPUT) > $(INPUT).tmp
	mv $(INPUT).tmp $(INPUT)

serve: build
	python3 << 'EOF'
	import http.server, socketserver, subprocess
	ip = subprocess.check_output(['hostname', '-I']).decode().split()[0]
	server = socketserver.TCPServer(('0.0.0.0', 0), http.server.SimpleHTTPRequestHandler)
	print(f'http://{ip}:{server.server_address[1]}')
	server.serve_forever()
	EOF

archive: $(ARCHIVE) $(ARCHIVE).txt $(ARCHIVE)/index.html

$(ARCHIVE):
	mkdir -p $(ARCHIVE)

$(ARCHIVE).txt:
	cp 404.txt $(ARCHIVE).txt

$(ARCHIVE)/index.html: $(ARCHIVE).txt
	$(MAKE) INPUT=$(ARCHIVE).txt OUTPUT=$(ARCHIVE)/index.html
