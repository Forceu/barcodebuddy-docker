package services

import (
	"fmt"
	"supervisor/environment"
	"supervisor/osutils"
)

type service struct {
	Name          string
	Executable    string
	Parameters    []string
	User          string
	ShowOutput    bool
	RestartOnFail bool
	MaxRestarts   int
}

func (s *service) Start() { // TODO
	fmt.Println("Starting " + s.Name)
	err := osutils.RunCmd(s.Executable, s.Parameters, s.User, true)
	if err != nil {
		fmt.Printf("Cannot start %s: %v\n", s.Name, err)
	}
}

var services []service

func Start() {
	services = []service{}
	services = append(services, service{
		Name:          "Redis",
		Executable:    "/usr/bin/redis-server",
		Parameters:    []string{"/etc/redis.conf", "--daemonize", "no"},
		User:          "redis",
		ShowOutput:    false,
		RestartOnFail: false,
	})
	services = append(services, service{
		Name:          "PHP-fpm8",
		Executable:    "/usr/sbin/php-fpm8",
		Parameters:    []string{"-F"},
		User:          "barcodebuddy",
		ShowOutput:    false,
		RestartOnFail: false,
	})

	services = append(services, service{
		Name:          "Nginx",
		Executable:    "/usr/sbin/nginx",
		Parameters:    []string{"-c", "/etc/nginx/nginx.conf"},
		User:          "root",
		ShowOutput:    false,
		RestartOnFail: false,
	})
	services = append(services, service{
		Name:          "Websocket Server",
		Executable:    "/usr/bin/php8",
		Parameters:    []string{"/app/bbuddy/wsserver.php"},
		User:          "barcodebuddy",
		ShowOutput:    false,
		RestartOnFail: true,
		MaxRestarts:   10,
	})

	if environment.IsGrabberEnabled() {
		services = append(services, service{
			Name:          "Barcode Input Grabber",
			Executable:    "/bin/bash",
			Parameters:    []string{"/app/bbuddy/example/grabInput.sh"},
			User:          "root",
			ShowOutput:    true,
			RestartOnFail: true,
			MaxRestarts:   10,
		})
	}

	for i, _ := range services {
		go services[i].Start()
	}

}
