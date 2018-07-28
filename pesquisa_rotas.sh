#!/bin/bash
#
# Script para verificar o roteamento em varios servidores Linux automaticamente.
# O ideal é que no servidor que executar o script possua chave publica compartilhada com os demais servidores
# assim não pedira senha toda na conexão ssh.
#
# Sergei A. Martão 06/12/15

# Contador do vetor, usado para determinar o numero de servidores dentro do vetor.
let s=$s+1

# Variavel para adicionar o hostname do servidor, usado para para mostrar na tela.
# Exemplo, SERVER[$s]="FWACME"
SERVER[$s]=""

# IP do servidor usado para conectar via ssh pesquisar as rotas no arquivo interface.
#IP[$s]="192.168.0.1"
IP[$s]=""

# Para adicionar vários servidores usar a seguinte sintaxe.
#let s=$s+1
#SERVER[$s]="SERVER1"
#IP[$s]="192.168.0.254"
#let s=$s+1
#SERVER[$s]="SERVER2"
#IP[$s]="192.168.1.254"

# Porta ssh para conectar nos servidores.
# Exemplo PORTA="22"
PORTA=""

# Caminho onde o arquivo de log sera salvo.
# Exemplo, CAMINHO="/tmp/verificarota/"
CAMINHO=""

# Nome do arquivo de log
# Exemplo, ARQ="rotas"
ARQ=""

#Para ignorar rotas comentadas, adicione algum conteudo na variavel a baixo.
# caso não precise deixe vazio
# Exemplo, coment=1 ou coment=
coment=

# Verificando se a string coment esta vazia.
if [ -z $coment ];then rcoment="stringvazia"; else rcoment="^#";fi

# Criando o diretorio para armazenar as rotas e imprimir na tela.
mkdir -p $CAMINHO

# Entrada para variavel A1.
read -p "# Entre com uma rede, IP ou comentario para pesquisa no arquivo interfaces: " A1

# Pesquisando nos hosts.
for((i=1; i<=${#IP[@]}; i++));
do
	echo "" > $CAMINHO/$ARQ_${SERVER[$i]}
	# Pesquisando as rotas ativas no servidor.	
	echo "route -n | grep $A1" | ssh ${IP[$i]} -p $PORTA >> $CAMINHO/$ARQ_${SERVER[$i]} 2>/dev/null
	# Pesquisando as rotas no arquivo interfaces.
	echo "grep -i $A1 /etc/network/interfaces | grep -i route | grep -iv $rcoment" | ssh ${IP[$i]} -p $PORTA >> $CAMINHO/$ARQ_${SERVER[$i]} 2>/dev/null
done

# Limpando a tela antes  de imprimir.
clear

echo "#------------------ INICIO -------------------#" 
echo ""
# Mostrando as rotas 
for((i=1; i<=${#IP[@]}; i++));
do
	echo "#----- ${SERVER[$i]} -----#" >> $CAMINHO/$ARQ  
	echo ""
	# Mostrando apenas as rotas desejadas.
	grep -i "$A1" $CAMINHO/$ARQ_${SERVER[$i]} --color
	echo ""
done
echo ""	
echo "#-------------------- FIM --------------------#" 
echo ""
