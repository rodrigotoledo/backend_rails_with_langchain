# 🚀 Guia Rápido - Sistema de Embeddings

## ✅ O Que Foi Implementado

Sistema completo de **busca semântica** usando IA, suportando:
- ✅ **OpenAI** (text-embedding-3-small, ada-002, etc.)
- ✅ **Google Gemini** (text-embedding-004)
- ✅ Gem **neighbor** para busca vetorial eficiente
- ✅ PostgreSQL com **pgvector**
- ✅ Dimensões configuráveis via `.env`

## ⚡ Setup Rápido

### 1. Configurar .env

```bash
# Escolha o provider
AI_PROVIDER=openai

# Configure o modelo e dimensões
AI_EMBEDDING_MODEL=text-embedding-3-small
AI_EMBEDDING_DIMENSIONS=1536

# Adicione sua API key
OPENAI_API_KEY=sk-your-key-here
```

### 2. Rodar Migrations

```bash
make db-migrate
# ou
docker-compose exec app rails db:migrate
```

### 3. Sincronizar Embeddings

```bash
# Sincronizar todos os clientes
docker-compose exec app rails embeddings:sync_all

# Ou apenas um cliente específico
docker-compose exec app rails "embeddings:sync_client[1]"
```

## 🔍 Como Usar

### No Rails Console

```ruby
# Buscar clientes por similaridade
Client.search_by_similarity("médico em São Paulo", limit: 5)

# Buscar endereços
Address.search_by_similarity("Avenida Paulista", limit: 10)

# Usando o serviço diretamente
service = ClientEmbeddingService.new
clients = service.search_clients("engenheiro", limit: 5)
```

### Via Rake Tasks

```bash
# Buscar
docker-compose exec app rails "embeddings:search['João Silva']"

# Ver configuração
docker-compose exec app rails embeddings:config

# Limpar tudo
docker-compose exec app rails embeddings:clear_all
```

## 🔄 Alternando Provedores

### Para OpenAI

```bash
AI_PROVIDER=openai
AI_EMBEDDING_MODEL=text-embedding-3-small
AI_EMBEDDING_DIMENSIONS=1536
OPENAI_API_KEY=sk-your-key
```

### Para Gemini

```bash
AI_PROVIDER=gemini
AI_EMBEDDING_MODEL=text-embedding-004
AI_EMBEDDING_DIMENSIONS=768
GEMINI_API_KEY=your-key
```

**⚠️ Importante**: Ao mudar de provider, limpe os embeddings antigos:

```bash
docker-compose exec app rails embeddings:clear_all
docker-compose exec app rails embeddings:sync_all
```

## 📊 Comandos Úteis

```bash
# Ver status
docker-compose exec app rails embeddings:config

# Sincronizar tudo
docker-compose exec app rails embeddings:sync_all

# Sincronizar um cliente
docker-compose exec app rails "embeddings:sync_client[123]"

# Buscar
docker-compose exec app rails "embeddings:search['termo de busca']"

# Limpar embeddings
docker-compose exec app rails embeddings:clear_all
```

## 🎯 Callbacks Automáticos

Os embeddings são atualizados automaticamente quando:

**Client:**
- Nome muda
- Email muda
- CPF muda
- Telefone muda

**Address:**
- Qualquer campo muda (após criação)

## 💰 Custos

### OpenAI

- **text-embedding-3-small**: $0.02 por 1M tokens (Recomendado)
- **text-embedding-3-large**: $0.13 por 1M tokens
- **text-embedding-ada-002**: $0.10 por 1M tokens

### Gemini

- **text-embedding-004**: Grátis (com limites de requisições)

## 🐛 Troubleshooting

### "OpenAI API Key not set"

```bash
# Verifique
docker-compose exec app env | grep OPENAI_API_KEY

# Configure no .env e reinicie
docker-compose restart app
```

### "Dimension mismatch"

```bash
# Limpe e resincronize
docker-compose exec app rails embeddings:clear_all
docker-compose exec app rails embeddings:sync_all
```

### Busca lenta

```bash
# Verifique se os índices existem
docker-compose exec app rails db:migrate:status

# Recriar índices se necessário
docker-compose exec app rails db:migrate:redo VERSION=20251220090100
```

## 📚 Documentação Completa

Para detalhes completos, veja: [docs/EMBEDDINGS_SYSTEM.md](./EMBEDDINGS_SYSTEM.md)

## 🔗 Arquivos Importantes

- `app/services/ai_embedding_service.rb` - Serviço genérico de AI
- `app/services/client_embedding_service.rb` - Serviço de embeddings de clientes
- `config/initializers/ai_provider.rb` - Configuração do provider
- `lib/tasks/embeddings.rake` - Rake tasks
- `app/models/client.rb` - Model com neighbor
- `app/models/address.rb` - Model com neighbor

---

**Status**: ✅ Implementado e funcionando
**Data**: 20 de Dezembro de 2025
