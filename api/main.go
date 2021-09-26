package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
)

var db = make(map[string]string)

func setupRouter() *gin.Engine {
	// Disable Console Color
	// gin.DisableConsoleColor()
	r := gin.Default()

	// Ping test
	r.GET("/ping", func(c *gin.Context) {
		c.String(http.StatusOK, "pong")
	})

	authorized := r.Group("/", gin.BasicAuth(gin.Accounts{
		"foo":  "bar", // user:foo password:bar
		"manu": "123", // user:manu password:123
	}))

	/* example curl for /admin with basicauth header
	   Zm9vOmJhcg== is base64("foo:bar")
	   curl -X POST \
	   http://localhost:8080/admin \
	   -H 'authorization: Basic Zm9vOmJhcg==' \
	   -H 'content-type: application/json' \
	   -d '{"value":"bar"}'
	*/

	authorized.POST("admin", func(c *gin.Context) {
		user := c.MustGet(gin.AuthUserKey).(string)
		fmt.Printf("%s", user)
		// Parse JSON
		var foo struct {
			Result string `json:"zone" binding:"required"`
			Foo    string `json:"ip" binding:"required"`
			Id     string `json:"id" binding:"required"`
			Test   string `json:"test" binding:"required"`
		}

		if c.Bind(&foo) == nil {
			fmt.Printf("\nFoo is %s; Result is %s\n", foo.Foo, foo.Result)
			baz := fmt.Sprintf("grafana_box_up{id=\"%s\",ip=\"%s\",zone=\"%s\"} \"%s\"\n", foo.Id, foo.Foo, foo.Result, foo.Test)
			c.JSON(http.StatusOK, gin.H{"status": "ok"})

			f, err := os.OpenFile("text.log",
				os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
			if err != nil {
				log.Println(err)
			}
			defer f.Close()

			if _, err := f.WriteString(baz); err != nil {
				log.Println(err)
			}
		}
	})

	return r
}

func main() {
	r := setupRouter()
	// Listen and Server in 0.0.0.0:8080
	r.Run(":8080")
}

// func check(e error) {
// 	if e != nil {
// 		panic(e)
// 	}
// }
