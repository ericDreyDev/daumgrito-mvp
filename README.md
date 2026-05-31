# Dá um grito!

MVP para conectar clientes que precisam contratar serviços domiciliares com prestadores autônomos da região.

## Estrutura

- `service`: API Node.js + Express + TypeScript, autenticação JWT e SQLite.
- `app`: interface web React + Vite para validar cadastro, login, listagem de prestadores, filtros, perfil do prestador e solicitação de serviço.

## Funcionalidades já estruturadas

- Cadastro e login de clientes e prestadores.
- Perfil de prestador com serviços, descrição, disponibilidade, valor e avaliação média.
- Listagem e filtros de prestadores por serviço, cidade, bairro, disponibilidade e melhor avaliação.
- Detalhes do prestador e criação de solicitação de serviço.
- Rotas para chat, avaliações e pagamento simulado.
- Banco SQLite com tabelas principais e prestadores de demonstração.

## Rodando localmente

### 1. API

```bash
cd service
cp .env.example .env
npm install
npm run dev
```

A API roda em `http://localhost:3333`.

### 2. App

Em outro terminal:

```bash
cd app
npm install
npm run dev
```

O app roda em `http://localhost:5173`.

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

## Próximos passos naturais

- Criar telas completas para chat, avaliações e pagamento.
- Adicionar regras de autorização por solicitação.
- Evoluir o banco para PostgreSQL quando sair do MVP local.
- Adicionar testes automatizados da API.
- Criar versão Flutter usando a mesma API.
