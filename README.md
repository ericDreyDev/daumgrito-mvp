# Dá um grito!

MVP para conectar clientes que precisam contratar serviços domiciliares com prestadores autônomos da região.

## Estrutura

- `service`: API Node.js + Express + TypeScript, autenticação JWT e PostgreSQL.
- `mobile`: base Flutter do aplicativo.
- `app`: interface web React + Vite mantida como protótipo web para validar fluxos rapidamente.

## Funcionalidades já estruturadas

- Cadastro e login de clientes e prestadores.
- Perfil de prestador com serviços, descrição, disponibilidade, valor e avaliação média.
- Listagem e filtros de prestadores por serviço, cidade, bairro, disponibilidade e melhor avaliação.
- Detalhes do prestador e criação de solicitação de serviço.
- Rotas para chat, avaliações e pagamento simulado.
- Banco PostgreSQL com tabelas principais e prestadores de demonstração.

## Rodando localmente

### 1. Banco de dados

```bash
docker compose up -d postgres
```

O PostgreSQL fica disponível em `localhost:5432`, com:

- Banco: `daumgrito`
- Usuário: `daumgrito`
- Senha: `daumgrito`

### 2. API

```bash
cd service
cp .env.example .env
npm install
npm run dev
```

A API roda em `http://localhost:3333`.

### 3. App Flutter

A pasta `mobile` já contém a estrutura inicial de código Flutter. Para gerar as plataformas Android/iOS/Web na primeira vez:

```bash
cd mobile
flutter create .
flutter pub get
flutter run
```

No emulador Android, a API local é acessada por `http://10.0.2.2:3333`, já configurado no `ApiClient`.

### 4. Protótipo web React

Em outro terminal:

```bash
cd app
npm install
npm run dev
```

O protótipo web roda em `http://localhost:5173`.

## Rotas principais da API

### Autenticação

- `POST /auth/register`
- `POST /auth/login`

### Usuários

- `GET /users/me`
- `PUT /users/me`

### Prestadores

- `GET /providers`
- `GET /providers/:id`
- `PUT /providers/profile`

### Solicitações

- `POST /service-requests`
- `GET /service-requests`
- `GET /service-requests/:id`
- `PUT /service-requests/:id/status`

### Chat

- `POST /chats/:serviceRequestId/messages`
- `GET /chats/:serviceRequestId/messages`

### Avaliações

- `POST /reviews`
- `GET /providers/:id/reviews`

### Pagamentos

- `POST /payments`
- `GET /payments/:serviceRequestId`

## Usuários demo

O banco cria prestadores de exemplo automaticamente. Para entrar como prestador demo, use:

- E-mail: `ana.faxina@demo.local`
- Senha: `demo123`

Também é possível criar novas contas pelo app.

## O que ainda falta aprimorar nas funcionalidades principais

- Chat no front-end/app: tela de conversa, envio de mensagem, polling ou WebSocket e indicadores de autor/data.
- Avaliações no front-end/app: liberar avaliação quando a solicitação estiver `Concluído`, listar comentários no perfil do prestador e recalcular média.
- Jornada do prestador: editar perfil completo, ver solicitações recebidas, alterar status, responder chat e registrar disponibilidade.
- Jornada do cliente: acompanhar solicitações, cancelar, confirmar conclusão e consultar pagamentos.
- Pagamento simulado: tela de criação/visualização de pagamento e status.
- Autorização: garantir que só cliente/prestador envolvidos acessem chat, solicitação, avaliação e pagamento.
- Persistência de sessão no Flutter com `shared_preferences`.
- Testes automatizados da API e validações mais ricas.

## Próximos passos naturais

- Criar telas completas para chat, avaliações e pagamento.
- Adicionar regras de autorização por solicitação.
- Adicionar testes automatizados da API.
- Completar cadastro no Flutter e telas específicas de cliente/prestador.
