# bank123

A new Flutter project.

1 Configure a versao do Android minimo de 18

Emulador PIN: 12345

caminho: /Users/fabioalvaropereira/workspaces/tcc/Projeto Bank123/bank123

## 

Crie uma lista de contatos usando dio e getx para buscar a lista de contatos no servidor. 

Arquitetura
App FLutter > Backend Spring Boot Rest.


### Lista de Contatos
GET 192.168.1.100/bank123/bl/contatos
Header 
minha-conta:123456
Authentication:{meutoken}

{
dados:[
    {
        "nome":"Tatiana",
        "chavePix":{"tipo":"email","valor":"fabio.alvaro@email.com"}
    }
]
}


## BACKEND E BANCO

## FIREBASE LOGIN
projeto bank123
logar usando Email/Senha

## BACKEND
Spring Boot , Java 17, Spring Security
* vscode
* macbook
* Nos header sempre devem ir o Token jwt do Firebase e o id da conta alem de um x-correlationId
localhost:8080/bff-bank123/extrato/v1/listagem
localhost:8080/bff-bank123/extrato/v1/saldo



### BANCO DE DADOS
Utilizado como o banco de dados para guardar informações como o saldo e as movimentações da conta

Postgres SQL
usuario bank123
senha senhabank123
nome do banco bank123_db

- Contas
    numeroConta Integer
    dataCriacao DateTimeStamp
    saldo Float com duas casas decimais exemplo R$ 999.999.999,99
- livroCaixa
    idtransacao: 321654
    dataTransacao: DateTimeStamp
    valorTransacao 60,00
    numeroConta 123456
    operacao: ENTRADA/SAIDA
    destino: Fabio Pereira
    origem: Tatiana Favoretti


