package cronjobs

import (
	"fmt"
	"supervisor/osutils"
	"time"
)

type cronjob struct {
	Executable      string
	Parameters      []string
	User            string
	IntervalSeconds int
	isStopped       bool
}

func (j *cronjob) Start() {
	if j.isStopped {
		return
	}
	j.execute()
	select {
	case <-time.After(time.Duration(j.IntervalSeconds) * time.Second):
		go j.Start()
	}
}

func (j *cronjob) execute() {
	err := osutils.RunCmd(j.Executable, j.Parameters, j.User, false)
	if err != nil {
		fmt.Printf("Unable running cronjob %s:\n", j.Executable)
		fmt.Println(err)
	}
}

func (j *cronjob) Stop() {
	j.isStopped = true
}

func Start() {
	bbCron := cronjob{
		Executable:      "/usr/bin/php8",
		Parameters:      []string{"/app/bbuddy/cron.php"},
		User:            "barcodebuddy",
		IntervalSeconds: 120,
	}
	go bbCron.Start()
}
