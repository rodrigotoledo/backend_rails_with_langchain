# Configuração do RuboCop no VSCode

## Problema Resolvido

O RuboCop está instalado dentro do container Docker, mas as extensões do VSCode tentam encontrá-lo localmente. Este guia explica como configurar corretamente.

## Extensões Instaladas

Você tem duas extensões Ruby instaladas:
1. `misogi.ruby-rubocop` - RuboCop linter
2. `testdouble.vscode-standard-ruby` - Standard Ruby (baseado em RuboCop)

## Solução Implementada

### 1. Script Wrapper

Foi criado o arquivo `bin/rubocop-wrapper.sh` que:
- Detecta se está rodando dentro ou fora do container
- Executa o RuboCop dentro do container Docker automaticamente
- Funciona tanto com container rodando quanto parado

### 2. Configurações do VSCode

O arquivo `.vscode/settings.json` foi atualizado para:
- Usar o script wrapper em vez de procurar o RuboCop localmente
- Configurar o caminho correto para o arquivo `.rubocop.yml`
- Desabilitar execução automática no save (para evitar lentidão)

## Como Testar

### Teste no Terminal

```bash
# Testar o wrapper diretamente
./bin/rubocop-wrapper.sh app/models/client.rb

# Ou usar o Make
make rubocop

# Auto-corrigir problemas
make rubocop-fix
```

### Teste no VSCode

1. Abra qualquer arquivo Ruby (ex: `app/models/client.rb`)
2. Abra a paleta de comandos (`Cmd+Shift+P`)
3. Digite "RuboCop" e selecione uma das opções:
   - "Ruby: Execute RuboCop" - Executar RuboCop
   - "Ruby: Autocorrect all problems with RuboCop" - Corrigir automaticamente

## Extensões Recomendadas

Se ainda tiver problemas, considere instalar a extensão oficial:

```vscode-extensions
rubocop.vscode-rubocop
```

Esta é a extensão oficial do RuboCop e tem melhor suporte para executáveis customizados.

## Alternativa: Dev Container

Para uma experiência ainda melhor, você pode usar Dev Containers:

1. Instale a extensão:
   ```vscode-extensions
   ms-vscode-remote.remote-containers
   ```

2. Isso permitirá que o VSCode rode completamente dentro do container, eliminando qualquer problema de paths.

## Desabilitando Extensões Conflitantes

Se ainda houver problemas, você pode desabilitar uma das extensões Ruby:

1. Vá em Extensions (`Cmd+Shift+X`)
2. Procure por "ruby-rubocop" ou "standard-ruby"
3. Clique em "Disable" na que não está funcionando

## Troubleshooting

### Erro: "rubocop command not found"

```bash
# Certifique-se que o container está rodando
docker-compose ps

# Certifique-se que o script é executável
chmod +x bin/rubocop-wrapper.sh

# Teste manualmente
./bin/rubocop-wrapper.sh --version
```

### RuboCop muito lento no VSCode

Isso é normal ao usar Docker. Para melhorar:

1. Desabilite `ruby.rubocop.onSave` (já está desabilitado)
2. Execute RuboCop manualmente quando necessário
3. Ou use o terminal: `make rubocop`

### Extensão não reconhece o wrapper

Tente recarregar o VSCode:
1. Cmd+Shift+P
2. Digite "Reload Window"
3. Selecione "Developer: Reload Window"

## Executando RuboCop

### Via Terminal (Recomendado para Docker)

```bash
# Verificar todos os arquivos
make rubocop

# Verificar um arquivo específico
docker-compose exec app bundle exec rubocop app/models/client.rb

# Auto-corrigir
make rubocop-fix
```

### Via VSCode

- **Command Palette** (`Cmd+Shift+P`):
  - "Ruby: Execute RuboCop"
  - "Ruby: Autocorrect with RuboCop"

- **Status Bar**: Clique no ícone do RuboCop (se aparecer)

## Configuração Adicional

Se preferir que o RuboCop rode automaticamente ao salvar:

```json
// .vscode/settings.json
{
  "ruby.rubocop.onSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.rubocop": "explicit"
  }
}
```

⚠️ **Nota**: Isso pode deixar o save lento com Docker.

---

**Status**: ✅ Configurado e funcionando
**Última atualização**: 20 de Dezembro de 2025
