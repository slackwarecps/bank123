# 👨‍💻 Guia do Desenvolvedor - Bank123 Mobile

Bem-vindo à documentação técnica do projeto **Bank123**. Este guia destina-se a desenvolvedores que irão manter, refatorar ou expandir o aplicativo.

---

## 🛠 Tech Stack e Dependências Principais

O projeto foi construído utilizando **Flutter** com foco em uma arquitetura limpa e reativa.

| Tecnologia | Pacote | Uso Principal |
| :--- | :--- | :--- |
| **Linguagem** | Dart 3+ | Linguagem base. |
| **Framework** | Flutter (Material 3) | UI Kit e renderização. |
| **Gerência de Estado** | `get` (GetX) | Injeção de dependência, rotas e reatividade. |
| **Autenticação** | `firebase_auth` | Gerenciamento de sessão (Email/Senha). |
| **Biometria** | `local_auth` | Autenticação biométrica local (Digital/FaceID). |
| **Armazenamento Seguro** | `flutter_secure_storage` | Persistência de configurações sensíveis. |
| **HTTP Client** | `dio` | Comunicação com APIs REST (BFF). |

---

## 📂 Estrutura de Diretórios

A estrutura do projeto segue uma organização por funcionalidade e responsabilidade técnica:

```
lib/
├── app/                  # (Opcional) Estruturas globais
├── bindings/             # Injeção de dependências do GetX (Ex: AuthBinding)
├── controllers/          # Lógica de negócios e estado da UI (GetXControllers)
│   ├── cadastro_controller.dart
│   ├── configuracao_controller.dart
│   ├── login_controller.dart
│   └── perfil_controller.dart
├── models/               # Modelos de dados e DTOs
├── pages/                # Páginas secundárias (Ex: Contatos)
├── services/             # Camada de serviços (API, Firebase wrappers)
├── telas/                # Telas principais do fluxo (Login, Home, Perfil)
│   ├── diversos/         # Telas de POC e testes
│   └── ...
├── main.dart             # Ponto de entrada e definição de rotas
└── firebase_options.dart # Configuração gerada pelo FlutterFire
```

> **Nota:** Existe uma mistura atual entre pastas `telas/` e `pages/`. Para novas funcionalidades, prefira padronizar (sugestão: mover tudo para `modules/` ou `ui/`).

---

## 🧠 Gerenciamento de Estado (GetX)

Utilizamos o padrão **Reativo** do GetX.

1.  **Controllers:** Estendem `GetxController`.
2.  **Variáveis Reativas:** Usamos `.obs` (Ex: `var isLoading = false.obs;`).
3.  **UI:** Usamos `Obx(() => Widget)` para escutar mudanças e atualizar a tela automaticamente.
4.  **Injeção:** Usamos `Get.put()` ou `Get.find()` para acessar controllers.

**Exemplo de Padrão:**
```dart
// Controller
class MeuController extends GetxController {
  final count = 0.obs;
  void increment() => count.value++;
}

// UI
final controller = Get.put(MeuController());
Obx(() => Text('${controller.count.value}'));
```

---

## 🔐 Segurança e Autenticação

Este é um ponto crítico do projeto (TCC de Segurança).

### 1. Fluxo de Login Híbrido
O login suporta E-mail/Senha e Biometria.
*   **E-mail/Senha:** Autentica diretamente no Firebase Auth.
*   **Biometria:** Utiliza `local_auth`. **Regra Importante:** O botão de biometria só aparece se a flag `biometric_enabled` for `true` no Secure Storage.

### 2. Persistência Segura
Utilizamos `flutter_secure_storage` para salvar dados sensíveis e preferências de segurança.
*   **Chave `biometric_enabled`:** ('true'/'false') Define se o usuário permitiu login biométrico.

### 3. Análise de Token (JWT)
Na tela de Perfil, decodificamos o `IdToken` do Firebase para inspeção de segurança:
*   Extração de Claims (`bank123/jwt/claims`).
*   Verificação de Scopes.
*   Timestamps (iat, exp).

---

## 🚀 Configuração de Ambiente

### Pré-requisitos
*   Flutter SDK (Stable Channel)
*   Java JDK 11 ou 17
*   Conta no Firebase configurada

### Configurando o Firebase
O projeto utiliza `flutterfire`. Se clonar o repositório, rode:
```bash
flutterfire configure
```
Selecione o projeto `draft1-app-fabao`.

### Gerando Ícones
Para atualizar os ícones do launcher:
```bash
flutter pub run flutter_launcher_icons
```

---

## 📏 Padrões de Código e Commits

*   **Linting:** O projeto usa `flutter_lints`. Rode `flutter analyze` antes de commitar.
*   **Nomenclatura:**
    *   Classes: `PascalCase` (Ex: `LoginController`)
    *   Arquivos: `snake_case` (Ex: `login_controller.dart`)
    *   Variáveis: `camelCase` (Ex: `isBiometricEnabled`)
*   **Interface:** Utilize os componentes do **Material 3**. Evite cores *hardcoded*; use `Theme.of(context).colorScheme`.

---

## 🐛 Troubleshooting Comum

**1. Erro de `CocoaPods` no iOS**
Rode: `cd ios && rm -rf Pods Podfile.lock && pod install --repo-update`

**2. Hot Reload não funciona**
Verifique se você não alterou uma dependência ou o `main()`. Nesses casos, use **Hot Restart** (`Shift + Cmd + F5` no VSCode).

**3. Biometria não funciona no Emulador**
No emulador Android, você deve configurar uma digital nas configurações de segurança do Android primeiro. No iOS Simulator, use o menu *Features > Face ID > Enrolled*.

---
*Documentação gerada em Dezembro de 2025.*
