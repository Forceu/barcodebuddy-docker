package fileinit

import (
	"fmt"
	"log"
	"os"
	"supervisor/osutils"
)

func Start() {
	fmt.Println("Initialising container")
	initPaths()
	setPermissions()
	generateSslKey()
}

func initPaths() {
	err := os.MkdirAll("/config/keys", os.ModePerm)
	check(err)
	err = os.MkdirAll("/config/data", os.ModePerm)
	check(err)
	linkDataDirectory()
}

func setPermissions() {
	if err := osutils.ChownFolderRecursive("/app", "barcodebuddy"); err != nil {
		log.Printf("Warning: chown /app failed: %v (continuing)", err)
	}
	if err := osutils.ChownFolderRecursive("/config", "barcodebuddy"); err != nil {
		log.Printf("Warning: chown /config failed: %v (continuing)", err)
	}
	fmt.Println("File permissions set")
}

func generateSslKey() {
	keyExists, err := osutils.FileExists("/config/keys/cert.key")
	check(err)
	certExists, err := osutils.FileExists("/config/keys/cert.crt")
	check(err)
	if keyExists && certExists {
		fmt.Println("Using SSL keys found in /config/keys")
		return
	}
	fmt.Println("Generating new SSL key")
	err = osutils.RunCmd("openssl", []string{"req", "-new", "-x509", "-days", "3650", "-nodes", "-out",
		"/config/keys/cert.crt", "-keyout", "/config/keys/cert.key", "-subj",
		"/C=US/ST=CA/L=Homelab/O=BarcodeBuddy/OU=BB Server/CN=*"}, "root", false)
	check(err)
}

func linkDataDirectory() {
	const appPath = "/app/bbuddy/data"
	const volumePath = "/config/data"
	pathExists, err := osutils.FileExists(appPath)
	check(err)

	if !pathExists {
		err = os.Symlink(volumePath, appPath)
		check(err)
		return
	}
	isSymbolicLink, err := osutils.IsSymbolicLink(appPath)
	check(err)
	if !isSymbolicLink {
		err = os.RemoveAll(appPath)
		check(err)
		err = os.Symlink(volumePath, appPath)
		check(err)
	}
}

func check(err error) {
	if err != nil {
		log.Fatal(err)
	}
}
