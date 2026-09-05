package main

import (
	"embed"
	"flag"
	"fmt"
	"io/fs"
	"log"
	"net"
	"net/http"
	"os"
	"os/exec"
	"runtime"
	"time"
)

const version = "1.0.0"

//go:embed web/*
var embedded embed.FS

func main() {
	showVersion := flag.Bool("version", false, "print version and exit")
	port := flag.Int("port", 0, "listen port (0 picks a free local port)")
	noOpen := flag.Bool("no-open", false, "do not open a browser")
	flag.Parse()

	if *showVersion {
		fmt.Printf("Tier List %s\n", version)
		os.Exit(0)
	}

	webFS, err := fs.Sub(embedded, "web")
	if err != nil {
		log.Fatal(err)
	}

	addr := fmt.Sprintf("127.0.0.1:%d", *port)
	listener, err := net.Listen("tcp", addr)
	if err != nil {
		log.Fatal(err)
	}

	url := fmt.Sprintf("http://%s/", listener.Addr().String())
	fmt.Printf("Tier List %s\n", version)
	fmt.Printf("Open %s\n", url)
	fmt.Println("Press Ctrl+C to quit.")

	if !*noOpen {
		go func() {
			time.Sleep(250 * time.Millisecond)
			openBrowser(url)
		}()
	}

	http.Handle("/", http.FileServer(http.FS(webFS)))
	log.Fatal(http.Serve(listener, nil))
}

func openBrowser(url string) {
	var cmd *exec.Cmd
	switch runtime.GOOS {
	case "windows":
		cmd = exec.Command("rundll32", "url.dll,FileProtocolHandler", url)
	case "darwin":
		cmd = exec.Command("open", url)
	default:
		cmd = exec.Command("xdg-open", url)
	}
	_ = cmd.Start()
}
