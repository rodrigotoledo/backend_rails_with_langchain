# 🔧 RuboCop no VSCode - Guia Rápido

## ✅ Problema Resolvido!

O RuboCop agora está configurado para funcionar corretamente com Docker no VSCode.

## 🚀 Como Usar

### Opção 1: Via Terminal (Recomendado)

```bash
# Verificar todos os arquivos
make rubocop

# Corrigir automaticamente
make rubocop-fix

# Verificar arquivo específico
docker-compose exec app bundle exec rubocop app/models/client.rb
```

### Opção 2: Via VSCode

1. Abra um arquivo Ruby
2. Pressione `Cmd+Shift+P` (ou `Ctrl+Shift+P`)
3. Digite "RuboCop" e escolha:
   - **Execute RuboCop** - Verificar o arquivo
   - **Autocorrect with RuboCop** - Corrigir automaticamente

### Opção 3: Script Wrapper

```bash
# O wrapper executa RuboCop dentro do container automaticamente
./bin/rubocop-wrapper.sh app/models/client.rb
```

## ⚙️ O Que Foi Configurado

1. ✅ **Script Wrapper** (`bin/rubocop-wrapper.sh`)
   - Detecta automaticamente se está dentro ou fora do container
   - Executa RuboCop no Docker

2. ✅ **Configurações do VSCode** (`.vscode/settings.json`)
   - Caminho correto para o executável do RuboCop
   - Desabilitado execução automática no save (para evitar lentidão)

3. ✅ **Makefile atualizado**
   - `make rubocop` - Verificar código
   - `make rubocop-fix` - Corrigir automaticamente

## 🔍 Testando

Teste se está funcionando:

```bash
# Deve retornar a versão do RuboCop
./bin/rubocop-wrapper.sh --version

# Deve analisar um arquivo
./bin/rubocop-wrapper.sh app/models/client.rb
```

## ⚠️ Problemas Conhecidos

### RuboCop ainda não funciona no VSCode?

**Solução 1: Recarregue o VSCode**
1. `Cmd+Shift+P`
2. Digite "Reload Window"
3. Pressione Enter

**Solução 2: Verifique as extensões instaladas**

Você tem duas extensões Ruby que podem conflitar:
- `misogi.ruby-rubocop`
- `testdouble.vscode-standard-ruby`

Recomendação: Desabilite uma delas ou instale a extensão oficial:

```vscode-extensions
rubocop.vscode-rubocop
```

**Solução 3: Use Dev Containers**

Para a melhor experiência, instale:

```vscode-extensions
ms-vscode-remote.remote-containers
```

Depois:
1. `Cmd+Shift+P`
2. "Remote-Containers: Reopen in Container"
3. O VSCode rodará completamente dentro do container

## 📚 Documentação Completa

Para mais detalhes, veja: [docs/VSCODE_RUBOCOP.md](./VSCODE_RUBOCOP.md)

## 💡 Dicas

### Atalhos Úteis

- **Cmd+Shift+P** → Command Palette
- **Cmd+Shift+X** → Extensions
- **Cmd+`** → Terminal

### Desabilitar Auto-save com RuboCop

Se quiser que o RuboCop rode ao salvar (pode ser lento):

```json
// .vscode/settings.json
{
  "ruby.rubocop.onSave": true
}
```

### Executar Apenas em Arquivos Modificados

```bash
# Ver arquivos modificados
git status

# RuboCop apenas em arquivos staged
git diff --name-only --cached | grep '\.rb$' | xargs docker-compose exec -T app bundle exec rubocop
```

## ✨ Status

- ✅ Script wrapper criado e funcionando
- ✅ Configurações do VSCode atualizadas
- ✅ Make commands disponíveis
- ✅ Documentação completa

**Última atualização**: 20 de Dezembro de 2025
