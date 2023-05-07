package environment

import (
	"bufio"
	"bytes"
	"fmt"
	"log"
	"os"
	"strings"
	"supervisor/osutils"
)

var useGrabber = false

func IsGrabberEnabled() bool {
	return useGrabber
}

func Parse() {
	fmt.Println("Parsing environment variables")
	parseMain()
	parseTimezone()
	parseNginxEnv()
}

func parseMain() {
	if os.Getenv("IGNORE_SSL_CA") == "true" {
		fmt.Println("WARNING: User requested to ignore invalid SSL certificates")
		err := osutils.RunCmd("/bin/sed", []string{"-i", "s/const CURL_ALLOW_INSECURE_SSL_CA.*/const CURL_ALLOW_INSECURE_SSL_CA=true;/g", "/app/bbuddy/config-dist.php"}, "root", false)
		check(err)
	}
	if os.Getenv("IGNORE_SSL_HOST") == "true" {
		fmt.Println("WARNING: User requested to ignore invalid SSL certificate hosts")
		err := osutils.RunCmd("/bin/sed", []string{"-i", "s/const CURL_ALLOW_INSECURE_SSL_HOST.*/const CURL_ALLOW_INSECURE_SSL_HOST=true;/g", "/app/bbuddy/config-dist.php"}, "root", false)
		check(err)
	}
	if os.Getenv("ATTACH_BARCODESCANNER") == "true" {
		fmt.Println("Enabling input grabber")
		useGrabber = true
	} else {
		fmt.Println("ATTACH_BARCODESCANNER not set, disabling input grabber")
	}
}

func parseTimezone() {
	const filePath = "/etc/php8/php.ini"
	var timezone = os.Getenv("TZ")
	if timezone == "" {
		fmt.Println("No timezone specified. To set timezone, set environment variable TZ")
		return
	}
	fmt.Println("Setting timezone to " + timezone)
	content, err := os.ReadFile(filePath)
	check(err)
	var contentString []string
	scanner := bufio.NewScanner(bytes.NewReader(content))

	for scanner.Scan() {
		line := scanner.Text()
		if !strings.Contains(line, "date.timezone=") {
			contentString = append(contentString, line)
		} else {
			if line == "date.timezone="+timezone {
				return
			}
		}
	}
	contentString = append(contentString, "date.timezone="+timezone)
	err = os.WriteFile(filePath, []byte(strings.Join(contentString, "\n")), 0644)
	check(err)
}

func parseNginxEnv() {
	const filePath = "/etc/nginx/site-confs/barcodebuddy.conf"
	var updatedConfig []string
	wholeConfig, err := os.ReadFile(filePath)
	check(err)
	var configEnvPart []string
	foundLine := false
	scanner := bufio.NewScanner(bytes.NewReader(wholeConfig))

	for scanner.Scan() {
		line := scanner.Text()
		if !foundLine {
			updatedConfig = append(updatedConfig, line)
		} else {
			configEnvPart = append(configEnvPart, line)
		}
		if strings.Contains(line, "include /etc/nginx/fastcgi_params;") {
			foundLine = true
		}
	}
	envVars := os.Environ()
	for _, envVar := range envVars {
		if strings.HasPrefix(envVar, "BBUDDY_") {
			keyValue := strings.SplitN(envVar, "=", 2)
			envLine := fmt.Sprintf("fastcgi_param %s '%s';", keyValue[0], keyValue[1])
			if !sliceContains(configEnvPart, envLine) {
				updatedConfig = append(updatedConfig, envLine)
			}
		}
	}
	updatedConfig = append(updatedConfig, configEnvPart...)

	err = os.WriteFile(filePath, []byte(strings.Join(updatedConfig, "\n")), 0644)
	check(err)
}

func check(err error) {
	if err != nil {
		log.Fatal(err)
	}
}

func sliceContains(slice []string, element string) bool {
	for _, item := range slice {
		if item == element {
			return true
		}
	}
	return false
}
