package function

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"strings"

	"github.com/go-redis/redis"
)

var redisClient *redis.Client

func init() {
	redisClient = redis.NewClient(&redis.Options{
		Network:  "tcp",
		Addr:     os.Getenv("REDIS_ADDR"),
		Password: os.Getenv("REDIS_PASSWD"),
	})
}

func GetCounters(w http.ResponseWriter, r *http.Request) {
	iter := redisClient.Scan(0, "counter:*", 0).Iterator()
	count := make(map[string]int64)
	for iter.Next() {
		key := strings.Replace(iter.Val(), "counter:", "", 1)
		count[key], _ = redisClient.Get(iter.Val()).Int64()
	}
	if err := iter.Err(); err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintf(w, "Error on execute redis command: %s", err)
	}
	json.NewEncoder(w).Encode(count)
}

func SetCounter(w http.ResponseWriter, r *http.Request) {
	key := r.FormValue("key")
	if key == "" {
		w.WriteHeader(http.StatusBadRequest)
		fmt.Fprintf(w, "invalid key")
		return
	}
	result := redisClient.Incr(fmt.Sprintf("counter:%s", key))
	if result.Err() != nil {
		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintf(w, "Error on execute redis command: %s", result.Err().Error())
		return
	}
	fmt.Fprintf(w, "%d", result.Val())
	w.WriteHeader(http.StatusOK)
}
