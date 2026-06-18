# Dá um grito!

MVP para conectar clientes que precisam contratar serviços domiciliares com prestadores autônomos da região.

## Estrutura

- `service`: API Node.js + Express + TypeScript, autenticação JWT e PostgreSQL.
- `mobile`: app Flutter principal.
- `app`: protótipo web React + Vite para validar fluxos rapidamente.

## Funcionalidades estruturadas

- Cadastro e login de clientes e prestadores.
- Perfil profissional do prestador com dados pessoais, descrição, experiência, categorias, documentos e selfie.
- Localização e área de atendimento do prestador.
- Controle online/offline do prestador.
- Validação do cadastro do prestador: `Pendente`, `Aprovado` ou `Reprovado`.
- Listagem pública de prestadores apenas quando aprovados e online.
- Solicitações de serviços para prestadores.
- Aba de solicitações recebidas para prestadores.
- Aba de histórico de atendimentos para prestadores, com filtros por data, categoria, status e avaliação.
- Perfil público do prestador para clientes, com avaliação média, região, serviços realizados e comentários.
- Chat demonstrativo, avaliações e pagamento simulado.

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

Para Flutter Web, o navegador pode abrir o app em uma porta local aleatória. Em desenvolvimento, deixe o CORS assim no `.env` da API:

```bash
CORS_ORIGIN=http://localhost:5173,http://localhost:*
```

### 3. App Flutter

```bash
cd mobile
flutter pub get
flutter run
```

No emulador Android, ajuste o `ApiClient` para usar `http://10.0.2.2:3333` se necessário.

### 4. Protótipo web React

```bash
cd app
npm install
npm run dev
```

O protótipo web roda em `http://localhost:5173`.

## Módulo Perfil do Prestador

### Telas Flutter

- `ProviderHomeScreen`: navegação exclusiva do prestador.
- `ProviderProfileScreen`: edição do perfil profissional, validação, documentos, localização e disponibilidade.
- `ProviderRequestsScreen`: aba de solicitações recebidas.
- `ProviderRequestDetailScreen`: detalhe da solicitação e ações de atendimento.
- `ProviderHistoryScreen`: histórico de atendimentos com filtros.
- `ProviderScheduleScreen`: agenda demonstrativa.
- `ProviderDetailScreen`: perfil público do prestador visto pelo cliente.

### Componentes e modelos

- `ProviderProfile`: modelo completo do prestador.
- `ServiceRequest`: modelo de solicitação com status normalizados.
- `RequestStatusTimeline`: linha de progresso da solicitação.
- `ProviderService`: API client para perfil, listagem pública e disponibilidade.
- `ServiceRequestService`: API client para solicitações.
- `ReviewService`: API client para avaliações.

### Modelo de dados do prestador

O perfil do prestador inclui:

- `name`, `email`, `phone`, `document`
- `photoUrl`
- `professionalDescription`
- `experience`
- `services`
- `documents`
- `selfieUrl`
- `validationStatus`: `Pendente`, `Aprovado`, `Reprovado`
- `baseAddress`
- `serviceCity`
- `serviceNeighborhood`
- `serviceRadiusKm`
- `useCurrentLocation`
- `isOnline`
- `availability`
- `averagePrice`
- `averageRating`
- `completedServicesCount`

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
- `GET /providers/:id/reviews`
- `GET /providers/me`
- `PUT /providers/profile`
- `PATCH /providers/availability`

### Solicitações

- `POST /service-requests`
- `GET /service-requests`
- `GET /service-requests/:id`
- `PUT /service-requests/:id/status`

Status de solicitação:

- `Aguardando aceite`
- `Aceito`
- `Recusado`
- `Em andamento`
- `Finalizado`
- `Cancelado`

### Chat

- `POST /chats/:serviceRequestId/messages`
- `GET /chats/:serviceRequestId/messages`

### Avaliações

- `POST /reviews`
- `GET /providers/:id/reviews`

### Pagamentos

- `POST /payments`
- `GET /payments/:serviceRequestId`

## Regras de negócio aplicadas

- Apenas usuários `provider` acessam o perfil interno de prestador, solicitações recebidas e histórico.
- Cliente não acessa telas internas do prestador no app Flutter.
- Prestador edita o próprio perfil, documentos, localização e disponibilidade.
- Prestador não altera avaliações recebidas.
- Prestador não altera `validationStatus`; aprovação/reprovação é responsabilidade administrativa.
- Prestador só aparece para clientes se estiver `Aprovado` e `isOnline = true`.
- Cliente só cria solicitação para prestador aprovado e online.
- Prestador pendente ou reprovado não recebe solicitações.
- Apenas prestadores alteram status da solicitação.
- O cliente avalia apenas solicitações finalizadas.

## Usuários demo

O banco cria prestadores e cliente de exemplo automaticamente.

Prestador demo:

- E-mail: `ana.faxina@demo.local`
- Senha: `demo123`

Cliente demo:

- E-mail: `cliente@demo.local`
- Senha: `demo123`

## Próximos passos naturais

- Criar fluxo administrativo para aprovar/reprovar prestadores.
- Persistir respostas públicas de prestadores às avaliações.
- Completar autorização por relacionamento em chat, pagamento, avaliação e solicitação.
- Evoluir upload real de documentos/selfie em vez de URLs/campos textuais.
