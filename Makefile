.PHONY: default help clean echo unique-ids

default: help

echo: bin/echo # Challenge 1
	./maelstrom/maelstrom test -w $@ --bin $^

unique-ids: bin/unique-ids # Challenge 2
	./maelstrom/maelstrom test -w $@ --bin $^ --time-limit 30 --rate 1000 --node-count 3 --availability total --nemesis partition

bin/%: %.go
	go build -o $@ $^

help: # Print this help message
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile \
	| while read -r l; do \
			printf "\033[1;37m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; \
		done \
	| column -c2 -t -s :

clean: # Remove generated files
	rm -rf bin
