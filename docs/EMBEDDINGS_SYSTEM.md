# Sistema de Embeddings com OpenAI e Gemini

## 📋 Visão Geral

Este projeto suporta **busca semântica** usando embeddings de IA com dois provedores:
- **OpenAI** (text-embedding-3-small, text-embedding-ada-002, etc.)
- **Google Gemini** (text-embedding-004, embedding-001)

Usa a gem **[neighbor](https://github.com/ankane/neighbor)** para armazenamento e busca eficiente de vetores no PostgreSQL com pgvector.

## ⚙️ Configuração

### 1. Variáveis de Ambiente

Adicione ao seu `.env`:

```bash
# Escolha o provider: 'openai' ou 'gemini'
AI_PROVIDER=openai

# Modelo de embedding
AI_EMBEDDING_MODEL=text-embedding-3-small

# Dimensões do embedding (deve corresponder ao modelo)
AI_EMBEDDING_DIMENSIONS=1536

# API Keys
OPENAI_API_KEY=your_openai_key_here
GEMINI_API_KEY=your_gemini_key_here
```

### 2. Modelos Suportados

#### OpenAI

| Modelo | Dimensões | Custo (por 1M tokens) |
|--------|-----------|----------------------|
| text-embedding-3-small | 1536 | $0.02 |
| text-embedding-3-large | 3072 | $0.13 |
| text-embedding-ada-002 | 1536 | $0.10 |

#### Gemini

| Modelo | Dimensões | Custo |
|--------|-----------|-------|
| text-embedding-004 | 768 | Grátis (com limites) |
| embedding-001 | 768 | Grátis (com limites) |

### 3. Migrations

Execute as migrations para criar as colunas de embedding com as dimensões corretas:

```bash
# Via Make
make db-migrate

# Via Docker Compose
docker-compose exec app rails db:migrate
```

As migrations criam:
- Coluna `embedding` com dimensões configuráveis via `AI_EMBEDDING_DIMENSIONS`
- Índice HNSW para busca rápida de vizinhos mais próximos
- Suporte a busca por similaridade de cosseno

## 🚀 Uso

### Sincronizar Embeddings

#### Todos os Clientes

```bash
# Via Rake task
docker-compose exec app rails embeddings:sync_all

# Via serviço Ruby
ClientEmbeddingService.new.sync_all!
```

#### Cliente Específico

```bash
# Via Rake task
docker-compose exec app rails embeddings:sync_client[123]

# Via serviço Ruby
client = Client.find(123)
ClientEmbeddingService.new.sync_client(client)
```

### Busca por Similaridade

#### No Rails Console

```ruby
# Buscar clientes similares
Client.search_by_similarity("João Silva morador de São Paulo", limit: 5)

# Buscar endereços similares
Address.search_by_similarity("Avenida Paulista São Paulo", limit: 5)

# Usando o serviço diretamente
service = ClientEmbeddingService.new
clients = service.search_clients("engenheiro de software", limit: 10)
addresses = service.search_addresses("centro de SP", limit: 10)
```

#### Via Rake Task

```bash
docker-compose exec app rails "embeddings:search['João Silva']"
```

### Verificar Configuração

```bash
docker-compose exec app rails embeddings:config
```

Saída esperada:
```
AI Provider Configuration
==================================================
Provider:      openai
Model:         text-embedding-3-small
Dimensions:    1536

API Keys:
OpenAI:        ✅ Set
Gemini:        ✅ Set

Database:
Clients with embeddings:  150/200
Addresses with embeddings: 450/600
```

## 🔄 Callbacks Automáticos

Os modelos estão configurados para sincronizar embeddings automaticamente:

### Client
Sincroniza quando:
- `name` muda
- `email` muda
- `cpf` muda
- `phone` muda

### Address
Sincroniza sempre que é salvo (se já existir no banco)

**Desabilitar auto-sync**: Remova `AI_PROVIDER` do `.env` temporariamente.

## 📊 API de Busca

### Exemplo de Controller

```ruby
# app/controllers/api/v1/search_controller.rb
class Api::V1::SearchController < ApplicationController
  def clients
    query = params[:query]
    limit = params[:limit]&.to_i || 5

    results = Client.search_by_similarity(query, limit: limit)

    render json: results,
           include: :addresses,
           methods: [:full_name]
  end

  def addresses
    query = params[:query]
    limit = params[:limit]&.to_i || 5

    results = Address.search_by_similarity(query, limit: limit)

    render json: results,
           include: :client,
           methods: [:full_address]
  end
end
```

### Rotas

```ruby
# config/routes.rb
namespace :api do
  namespace :v1 do
    get 'search/clients', to: 'search#clients'
    get 'search/addresses', to: 'search#addresses'
  end
end
```

### Exemplo de Request

```bash
# Buscar clientes
curl "http://localhost:3000/api/v1/search/clients?query=médico%20São%20Paulo&limit=5"

# Buscar endereços
curl "http://localhost:3000/api/v1/search/addresses?query=Jardins%20São%20Paulo&limit=10"
```

## 🔧 Troubleshooting

### Erro: "OpenAI API Key not set"

```bash
# Verifique se a chave está configurada
docker-compose exec app env | grep OPENAI_API_KEY

# Se não estiver, adicione ao .env e reinicie
docker-compose restart app
```

### Erro: "Embedding dimension mismatch"

Isso acontece quando você muda o modelo mas o banco ainda tem embeddings com dimensões antigas.

**Solução:**

```bash
# 1. Limpar embeddings antigos
docker-compose exec app rails embeddings:clear_all

# 2. Atualizar dimensões no .env
# AI_EMBEDDING_DIMENSIONS=3072  # para text-embedding-3-large

# 3. Recriar migrations se necessário
docker-compose exec app rails db:migrate:redo VERSION=20251220090100

# 4. Ressincronizar
docker-compose exec app rails embeddings:sync_all
```

### Busca muito lenta

```bash
# Verifique se os índices existem
docker-compose exec app rails db:migrate:status

# Recriar índices
docker-compose exec app rails db:migrate:redo VERSION=20251220090100
```

### Rate Limit da API

```ruby
# Ajuste o sleep no service
# app/services/client_embedding_service.rb

def sync_all!
  Client.find_each(batch_size: 50) do |client|
    sync_client(client)
    sleep 0.5  # Aumente para evitar rate limit
  end
end
```

## 🔀 Alternando entre Provedores

### Mudar de OpenAI para Gemini

```bash
# 1. Atualizar .env
AI_PROVIDER=gemini
AI_EMBEDDING_MODEL=text-embedding-004
AI_EMBEDDING_DIMENSIONS=768

# 2. Limpar embeddings antigos (diferentes dimensões)
docker-compose exec app rails embeddings:clear_all

# 3. Atualizar migrations (opcional, para novos ambientes)
# Edite as migrations para usar 768 dimensões

# 4. Ressincronizar tudo
docker-compose exec app rails embeddings:sync_all
```

### Mudar de Gemini para OpenAI

```bash
# 1. Atualizar .env
AI_PROVIDER=openai
AI_EMBEDDING_MODEL=text-embedding-3-small
AI_EMBEDDING_DIMENSIONS=1536

# 2. Limpar e ressincronizar
docker-compose exec app rails embeddings:clear_all
docker-compose exec app rails embeddings:sync_all
```

## 📈 Performance

### Benchmarks Aproximados

**Busca Vetorial (10K registros):**
- Busca com índice HNSW: ~10-50ms
- Busca sem índice: ~500-2000ms

**Geração de Embedding:**
- OpenAI: ~100-300ms por requisição
- Gemini: ~200-500ms por requisição

### Otimizações

1. **Batch Processing**: Processe em lotes para evitar rate limits
2. **Background Jobs**: Use Sidekiq para processar embeddings em background
3. **Cache**: Considere cachear embeddings de queries frequentes
4. **Índices**: Certifique-se que os índices HNSW estão criados

## 🧪 Testes

```ruby
# test/services/ai_embedding_service_test.rb
require 'test_helper'

class AiEmbeddingServiceTest < ActiveSupport::TestCase
  test "generates embedding with openai" do
    service = AiEmbeddingService.new(provider: 'openai')
    embedding = service.embed("test text")

    assert_not_nil embedding
    assert_equal 1536, embedding.length
  end

  test "searches for similar clients" do
    # Criar clientes de teste com embeddings
    client = clients(:one)
    ClientEmbeddingService.new.sync_client(client)

    # Buscar
    results = Client.search_by_similarity(client.name, limit: 5)

    assert_includes results, client
  end
end
```

## 📚 Recursos Adicionais

- [Neighbor Gem](https://github.com/ankane/neighbor)
- [OpenAI Embeddings](https://platform.openai.com/docs/guides/embeddings)
- [Gemini Embeddings](https://ai.google.dev/docs/embeddings_guide)
- [pgvector](https://github.com/pgvector/pgvector)

---

**Última atualização:** 20 de Dezembro de 2025
