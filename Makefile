SCRIPT = scripts/local-site.sh

default: build-and-run

build-and-run: serve

serve: $(SCRIPT)
	$<

build: $(SCRIPT)
	$< $@

run : $(SCRIPT)
	$< $@
