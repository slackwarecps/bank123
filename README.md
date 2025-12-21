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
* Nos header sempre devem ir o Token jwt do Firebase e o id da conta(x-account-id) alem de um x-correlationId (x-correlationId )
localhost:8080/bff-bank123/extrato/v1/listagem
localhost:8080/bff-bank123/extrato/v1/saldo

Para acessar a documentacao do swagger gerada no springboot acesse: http://localhost:8080/swagger-ui/index.html



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


## Requisitos Funcionais - Últimas Alterações

### Home Page
- Saudação alterada para "Bem vindo!".
- Interface simplificada: removidos os botões de POCs (Contatos, Secure Storage, Shared Preferences e Biometria).
- Menu superior direito adicionado com opções: **Perfil**, **Configurações** e **Sair**.
- Identidade visual consolidada com o ícone `account_balance` no cabeçalho.

### Login e Autenticação
- **Biometria Condicional:** O botão de login por biometria só é exibido se o usuário habilitar esta opção na tela de Configurações.
- **Valores de Teste:** Campos de e-mail e senha pré-preenchidos com `teste@teste.com.br` e `teste123`.
- **Identidade Visual:** Ícone central alterado para `account_balance`.

### Fluxo de Cadastro
- **Criação de Conta:** Novo usuário é registrado no Firebase Authentication.
- **Análise de Segurança:** Após o cadastro, o usuário é desconectado imediatamente e recebe uma mensagem informando que deve aguardar até 5 minutos para análise antes de tentar o primeiro login.
- **Redirecionamento:** O usuário é levado de volta para a tela de login após confirmar a mensagem de sucesso.
- **Ícone:** Utilização do ícone `person_add_outlined`.

### Configurações
- **Controle de Biometria:** Opção (Toggle) para habilitar ou desabilitar o login por biometria.
- **Persistência Segura:** A preferência do usuário é salva utilizando o **Flutter Secure Storage**, garantindo que a escolha persista entre sessões de forma protegida.
- **Padrão:** A funcionalidade vem desligada por padrão.

### Tela de Perfil
- **Detalhamento de Token:** Exibição de informações técnicas extraídas do Firebase JWT:
    - E-mail e UID do usuário.
    - Timestamps de emissão (iat) e expiração (exp).
    - Conteúdo da claim personalizada `bank123/jwt/claims`.
- **Gestão de Token:** Campo para visualização do Token JWT completo com funcionalidade de "Copiar Token" para a área de transferência.

### Interface e Tema
- **Material Design 3:** App totalmente convertido para o padrão Material 3, utilizando um `colorSchemeSeed` baseado na cor vermelha.
- **Splash Screen:** Fundo alterado para a cor Marrom (Colors.brown) com elementos em branco.

### Gestão de Sessão e Conta
- **Persistência de Conta:** Após o login, o `numeroConta` é extraído das claims do token JWT e persistido de forma segura no **Flutter Secure Storage** sob a chave `NUMERO_CONTA`.
- **Cabeçalhos Dinâmicos:** O valor persistido em `NUMERO_CONTA` é injetado automaticamente no header `x-account-id` de todas as requisições ao BFF via interceptor do Dio.

## 🏛️ Arquitetura da Solução

Este projeto adota uma arquitetura **Cloud Native** moderna, focada em segurança e separação de responsabilidades. O aplicativo Flutter atua como um cliente "burro" (stateless), delegando a lógica de negócios pesada para o Backend (BFF) e a identidade para o Firebase.

### Diagrama de Integração
![alt text](image.png)

### 🔄 Fluxo de Dados e Segurança

1.  **Autenticação (Identity Provider):**
    * O usuário realiza login via **Firebase Auth** (Google/Email).
    * O App recebe um **JWT (JSON Web Token)** assinado. Nenhuma senha é trafegada para o nosso backend.
    
2.  **API Gateway (Zuplo):**
    * Todas as requisições HTTP saem do App apontando para o **API Gateway**.
    * O App implementa **SSL Pinning** (via Dio) para garantir que está conversando com o Gateway legítimo, prevenindo ataques *Man-in-the-Middle*.

3.  **Backend for Frontend (BFF):**
    * O App envia o JWT no header `Authorization: Bearer <token>`.
    * O App aguarda respostas em JSON padronizado para montar as telas.

### 🛠️ Tech Stack Mobile
* **Framework:** Flutter (Dart)
* **Http Client:** Dio (com Interceptors para Auth e Logging)
* **State Management:** (Coloque o seu aqui: Provider/Bloc/Riverpod)
## 🛠️ Documentação Técnica

Para desenvolvedores que desejam contribuir ou manter este projeto, consulte o guia detalhado de arquitetura, padrões e configuração no arquivo:

👉 **[DEVELOPER.md](DEVELOPER.md)**