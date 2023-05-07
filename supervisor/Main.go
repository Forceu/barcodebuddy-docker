package main

import (
	"fmt"
	"os"
	"os/signal"
	"supervisor/cronjobs"
	"supervisor/environment"
	"supervisor/fileinit"
	"supervisor/services"
	"syscall"
)

func main() {
	fmt.Println("Barcode Buddy supervisor started")
	fmt.Println("")
	fileinit.Start()
	environment.Parse()
	services.Start()
	cronjobs.Start()

	c := make(chan os.Signal)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)
	<-c
	fmt.Println("Shutting down supervisor")
	os.Exit(0)
}
