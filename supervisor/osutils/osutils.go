package osutils

import (
	"bufio"
	"errors"
	"fmt"
	"io"
	"os"
	"os/exec"
	"os/user"
	"path/filepath"
	"strconv"
	"syscall"
)

func RunCmd(path string, arguments []string, username string, printOutput bool) error {
	var stdout io.ReadCloser
	var err error
	cmd := exec.Command(path, arguments...)
	uid, gid, err := getUserIds(username)
	if err != nil {
		return err
	}

	cmd.SysProcAttr = &syscall.SysProcAttr{}
	cmd.SysProcAttr.Credential = &syscall.Credential{Uid: uint32(uid), Gid: uint32(gid)}

	if printOutput {
		stdout, err = cmd.StdoutPipe()
		if err != nil {
			return err
		}
	}

	err = cmd.Start()
	if err != nil {
		return err
	}

	if printOutput {
		scanner := bufio.NewScanner(stdout)
		for scanner.Scan() {
			message := scanner.Text()
			fmt.Println(message)
		}
	}
	err = cmd.Wait()
	if err != nil {
		return err
	}
	return nil
}

func FileExists(name string) (bool, error) {
	_, err := os.Stat(name)
	if err == nil {
		return true, nil
	}
	if errors.Is(err, os.ErrNotExist) {
		return false, nil
	}
	return false, err
}

func IsSymbolicLink(path string) (bool, error) {
	fileInfo, err := os.Lstat(path)
	if err != nil {
		return false, err
	}
	return fileInfo.Mode()&os.ModeSymlink != 0, nil
}

func ChownFolderRecursive(path, username string) error {
	uid, gid, err := getUserIds(username)
	if err != nil {
		return err
	}
	err = filepath.Walk(path, func(filePath string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if err = os.Chown(filePath, int(uid), int(gid)); err != nil {
			return err
		}

		return nil
	})
	if err != nil {
		return err
	}
	return nil
}

func getUserIds(username string) (int64, int64, error) {

	u, err := user.Lookup(username)
	if err != nil {
		return 0, 0, err
	}
	uid, err := strconv.ParseInt(u.Uid, 10, 32)
	if err != nil {
		return 0, 0, err
	}
	gid, err := strconv.ParseInt(u.Gid, 10, 32)
	if err != nil {
		return 0, 0, err
	}

	return uid, gid, nil
}
