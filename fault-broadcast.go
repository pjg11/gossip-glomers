package main

import (
	"context"
	"encoding/json"
	"log"
	"strings"
	"sync"
	"time"

	maelstrom "github.com/jepsen-io/maelstrom/demo/go"
)

func main() {
	n := maelstrom.NewNode()
	mu := sync.Mutex{}
	var messages []int

	n.Handle("broadcast", func(msg maelstrom.Message) error {
		var body map[string]any
		if err := json.Unmarshal(msg.Body, &body); err != nil {
			return err
		}

		mu.Lock()
		messages = append(messages, int(body["message"].(float64)))
		mu.Unlock()

		src := msg.Src
		dst := msg.Dest

		go func() {
			for _, node := range n.NodeIDs() {
				if node == dst || strings.HasPrefix(src, "n") {
					continue
				}

				delay := 200 * time.Millisecond

				for i := 0; i < 10; i++ {
					ctx, cancel := context.WithTimeout(context.Background(),
						time.Second*2)
					defer cancel()

					_, err := n.SyncRPC(ctx, node, body)
					if err != nil {
						time.Sleep(delay)
						delay *= 2
						continue
					}
					break
				}
			}
		}()

		return n.Reply(msg, map[string]any{
			"type": "broadcast_ok",
		})
	})

	n.Handle("read", func(msg maelstrom.Message) error {
		var body map[string]any
		if err := json.Unmarshal(msg.Body, &body); err != nil {
			return err
		}

		return n.Reply(msg, map[string]any{
			"type":     "read_ok",
			"messages": messages,
		})
	})

	n.Handle("topology", func(msg maelstrom.Message) error {
		var body map[string]any
		if err := json.Unmarshal(msg.Body, &body); err != nil {
			return err
		}

		return n.Reply(msg, map[string]any{
			"type": "topology_ok",
		})
	})

	if err := n.Run(); err != nil {
		log.Fatal(err)
	}
}
