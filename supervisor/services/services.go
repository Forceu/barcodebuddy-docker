package services

import (
	"fmt"
	"os"
	"supervisor/environment"
	"supervisor/osutils"
)

type service struct {
	Name         string
	Executable   string
	Parameters   []string
	User         string
	ShowOutput   bool
	MaxRestarts  int
	restartCount int
	IsOptional   bool
}

func (s *service) Start(isRestart bool) {
	if !isRestart {
		fmt.Println("Starting " + s.Name)
	} else {
		fmt.Println("Restarting " + s.Name)
	}
	err := osutils.RunCmd(s.Executable, s.Parameters, s.User, s.ShowOutput)
	if err != nil {
		fmt.Printf("Error running %s: %v\n", s.Name, err)
		s.restart()
	}
}
func (s *service) restart() {
	s.restartCount = s.restartCount + 1
	if s.restartCount > s.MaxRestarts {
		if !s.IsOptional {
			fmt.Printf("Too many errors starting %s, shutting down.\n", s.Name)
			os.Exit(1)
		}
		fmt.Printf("Too many errors, not restarting %s\n", s.Name)
		return
	}
	s.Start(true)
}

var services []service

func Start() {
	services = []service{}
	services = append(services, service{
		Name:        "Redis",
		Executable:  "/usr/bin/redis-server",
		Parameters:  []string{"/etc/redis.conf", "--daemonize", "no"},
		User:        "redis",
		ShowOutput:  false,
		MaxRestarts: 0,
	})
	services = append(services, service{
		Name:        "PHP-fpm8",
		Executable:  "/usr/sbin/php-fpm8",
		Parameters:  []string{"-F"},
		User:        "barcodebuddy",
		ShowOutput:  false,
		MaxRestarts: 0,
	})

	services = append(services, service{
		Name:        "Nginx",
		Executable:  "/usr/sbin/nginx",
		Parameters:  []string{"-c", "/etc/nginx/nginx.conf"},
		User:        "root",
		ShowOutput:  false,
		MaxRestarts: 0,
	})
	services = append(services, service{
		Name:        "Websocket Server",
		Executable:  "/usr/bin/php8",
		Parameters:  []string{"/app/bbuddy/wsserver.php"},
		User:        "barcodebuddy",
		ShowOutput:  false,
		MaxRestarts: 10,
	})

	if environment.IsGrabberEnabled() {
		services = append(services, service{
			Name:        "Barcode Input Grabber",
			Executable:  "/bin/bash",
			Parameters:  []string{"/app/bbuddy/example/grabInput.sh"},
			User:        "root",
			ShowOutput:  true,
			MaxRestarts: 10,
			IsOptional:  true,
		})
	}

	for i, _ := range services {
		go services[i].Start(false)
	}

}
