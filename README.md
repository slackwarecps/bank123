# bank123

A new Flutter project.

1 Configure a versao do Android minimo de 18

Emulador PIN: 12345

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


