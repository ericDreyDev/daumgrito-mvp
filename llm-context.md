# LLM Context - Projeto Dá um Grito!

## Objetivo deste Documento

Este documento fornece contexto, regras, objetivos e diretrizes para qualquer LLM, agente de IA ou ferramenta de desenvolvimento assistido por IA envolvida na construção do projeto.

Todas as decisões técnicas e funcionais devem respeitar este documento.

---

# Sobre o Projeto

## Nome

Dá um Grito!

## Descrição

O Dá um Grito! é uma plataforma digital que conecta pessoas que precisam contratar serviços gerais com profissionais autônomos disponíveis em sua região.

O objetivo é simplificar a contratação de prestadores de serviços locais através de uma experiência simples, rápida e confiável.

---

# Problema que Estamos Resolvendo

Atualmente existe dificuldade para:

* Encontrar profissionais confiáveis.
* Validar a qualidade dos serviços prestados.
* Comparar opções disponíveis.
* Contratar profissionais rapidamente.
* Possuir um canal centralizado para divulgação de serviços.

A plataforma deverá resolver esses problemas.

---

# Objetivo do MVP

Construir um MVP funcional para validar a aceitação do mercado antes de investir em funcionalidades avançadas.

O MVP deve ser simples, porém completo o suficiente para validar o modelo de negócio.

---

# Público-Alvo

## Clientes

Usuários que desejam contratar serviços como:

* Faxina
* Jardinagem
* Serviços elétricos
* Serviços hidráulicos
* Montagem de móveis
* Pequenos reparos residenciais

## Prestadores de Serviço

Profissionais autônomos que desejam:

* Divulgar seus serviços
* Conseguir novos clientes
* Receber avaliações
* Gerenciar solicitações de atendimento

---

# Escopo do MVP

## Categorias Iniciais

* Faxineiro(a)
* Eletricista
* Encanador(a)
* Montador de Móveis
* Manutenção Básica
* Jardineiro

---

# Funcionalidades Obrigatórias

## Cadastro de Clientes

Campos obrigatórios:

* Nome
* E-mail
* Senha
* Telefone
* CPF / CNPJ
* Cidade

---

## Cadastro de Prestadores

Campos obrigatórios:

* Nome
* E-mail
* Senha
* Telefone
* CPF / CNPJ
* Cidade
* Foto
* Descrição Profissional
* Categorias de Serviço

---

## Autenticação

Permitir login utilizando:

* E-mail
* Senha

Utilizar autenticação baseada em JWT.

---

## Busca de Profissionais

Filtros mínimos:

* Categoria
* Cidade
* Avaliação
* Nome

---

## Perfil do Profissional

Exibir:

* Foto
* Nome
* Cidade
* Categorias
* Descrição
* Nota média
* Avaliações

---

## Solicitação de Serviço

O cliente poderá:

* Selecionar um profissional
* Criar uma solicitação
* Inserir observações

---

## Avaliação

Após o atendimento:

* Nota de 1 a 5 estrelas
* Comentário

---

# Funcionalidades Futuras (Não Implementar)

Estas funcionalidades devem ser previstas na arquitetura, porém NÃO devem ser implementadas no MVP.

## Comunicação

* Chat em tempo real
* WebSockets

## Pagamentos

* PIX
* Cartão
* Split de pagamento

## Agenda

* Calendário
* Disponibilidade

## Localização

* Geolocalização
* Mapas
* Distância entre usuários

## Notificações

* Push Notifications
* Firebase

---

# Stack Tecnológica Padrão

## Front-End

Obrigatório:

* React
* Next.js
* TypeScript

## Aplicativo Mobile
* Flutter

---

## Back-End

Obrigatório:

* Node.js
* Express
* TypeScript

---

## Banco de Dados

Obrigatório:

* PostgreSQL

---

## ORM

Obrigatório:

* Prisma ORM

---

## Hospedagem Inicial

Preferencialmente:

* Vercel (Frontend)
* Railway ou Render (Backend)
* PostgreSQL Gerenciado

---

# Arquitetura

## Backend

Estrutura mínima:

```text
src/
├── modules/
├── controllers/
├── services/
├── repositories/
├── dto/
├── entities/
├── guards/
├── middleware/
├── common/
└── config/
```

## Frontend

Estrutura mínima:

```text
src/
├── app/
├── components/
├── services/
├── hooks/
├── types/
├── lib/
├── providers/
└── utils/
```

---

# Modelagem Inicial

## User

Campos:

* id
* name
* email
* passwordHash
* phone
* role
* createdAt

---

## ProviderProfile

Campos:

* id
* userId
* description
* city
* photoUrl
* averageRating

---

## ServiceCategory

Campos:

* id
* name

---

## ServiceRequest

Campos:

* id
* clientId
* providerId
* categoryId
* description
* status
* createdAt

---

## Review

Campos:

* id
* clientId
* providerId
* rating
* comment
* createdAt

---

# Regras para Qualquer LLM

Ao gerar código:

1. Sempre utilizar TypeScript.
2. Nunca utilizar JavaScript puro.
3. Nunca criar código fictício.
4. Nunca gerar exemplos incompletos.
5. Sempre gerar arquivos completos.
6. Sempre mostrar a estrutura de pastas afetada.
7. Sempre explicar decisões arquiteturais.
8. Seguir SOLID.
9. Seguir Clean Code.
10. Seguir DRY.
11. Seguir KISS.
12. Priorizar escalabilidade.
13. Priorizar legibilidade.
14. Priorizar segurança.
15. Não implementar funcionalidades fora do MVP.
16. Não alterar requisitos sem justificativa explícita.
17. Sempre validar entradas de usuário.
18. Sempre considerar autenticação e autorização.
19. Sempre tratar erros adequadamente.
20. Sempre sugerir melhorias em uma seção separada.

---

# Critérios de Sucesso do MVP

O MVP será considerado pronto quando:

* Cliente conseguir criar conta.
* Prestador conseguir criar conta.
* Prestador conseguir publicar seu perfil.
* Cliente conseguir localizar profissionais.
* Cliente conseguir solicitar serviços.
* Cliente conseguir avaliar profissionais.

---

# O Que Deve Ser Evitado

Não implementar:

* Microserviços
* Kubernetes
* Event Sourcing
* CQRS avançado
* Arquiteturas complexas
* Integrações externas desnecessárias

O objetivo é validar negócio e não construir uma solução enterprise.

---

# Objetivo Final

Validar a demanda de mercado para uma plataforma especializada em contratação de prestadores de serviços locais antes de investir em funcionalidades avançadas, automações, pagamentos e recursos premium.