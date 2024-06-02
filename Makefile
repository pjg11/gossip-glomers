.PHONY: default help clean 1 2 3a

default: help

1: bin/echo # Echo
	./maelstrom/maelstrom test -w echo --bin $^ --node-count 1 --time-limit 10

2: bin/unique-ids # Unique ID Generation
	./maelstrom/maelstrom test -w unique-ids --bin $^ --time-limit 30 --rate 1000 --node-count 3 --availability total --nemesis partition

3a: bin/single-broadcast # Single-Node Broadcast
	./maelstrom/maelstrom test -w broadcast --bin $^ --node-count 1 --time-limit 20 --rate 10

3b: bin/multi-broadcast # Multi-Node Broadcast
	./maelstrom/maelstrom test -w broadcast --bin $^ --node-count 5 --time-limit 20 --rate 10

3c: bin/fault-broadcast # Fault-Tolerant Broadcast
	./maelstrom/maelstrom test -w broadcast --bin $^ --node-count 5 --time-limit 20 --rate 10 --nemesis partition

bin/%: %.go
	go build -o $@ $^

help: # Print this help message
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile \
	| while read -r l; do \
			printf "\033[1;37m%5s\033[00m:%s\n" "$$(echo $$l | cut -f 1 -d':')" "$$(echo $$l | cut -f 2- -d'#')"; \
		done \
	| column -c2 -t -s :

clean: # Remove generated files
	rm -rf bin/ store/
