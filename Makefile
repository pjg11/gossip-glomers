default: help

bin/%: %.go
	go build -o $@ $^

.PHONY: echo
echo: bin/echo # Challenge 1
	./maelstrom/maelstrom test -w echo --bin bin/echo --node-count 1 --time-limit 10

.PHONY: help
help: # Print this help message
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

.PHONY: clean
clean: # Cleanup generated files
	rm -rf bin
