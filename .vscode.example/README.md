# VSCode Configuration

Esta pasta contém as configurações recomendadas para o VSCode neste projeto.

## Setup Inicial

Para configurar o VSCode no seu ambiente local:

```bash
# Copie as configurações de exemplo para sua pasta .vscode local
cp -r .vscode.example .vscode
```

**Nota:** A pasta `.vscode/` está no `.gitignore` e não deve ser commitada, pois pode conter configurações pessoais de cada desenvolvedor.

## Configurações Incluídas

### settings.json
- **Editor**: Desativa auto-save, força EOL Unix, adiciona newline final
- **Ruby**: Configurado para usar RuboCop via `bin/rubocop-wrapper.sh` (executa no Docker)
- **Git**: Desativa auto-fetch por segurança
- **Exclusões**: Oculta pastas `tmp`, `log`, `storage` da busca

### extensions.json
Extensões recomendadas:
- **Ruby**: rebornix.ruby, castwide.solargraph, testdouble.vscode-standard-ruby
- **Docker**: ms-azuretools.vscode-docker, ms-vscode-remote.remote-containers
- **Database**: mtxr.sqltools, mtxr.sqltools-driver-pg
- **Utilities**: editorconfig, gitlens, markdown

## Personalizações

Você pode personalizar sua pasta `.vscode/` local sem afetar outros desenvolvedores:
- Alterar temas, keybindings pessoais
- Adicionar configurações específicas do seu sistema operacional
- Habilitar/desabilitar extensões conforme sua preferência

## RuboCop Integration

O projeto está configurado para executar RuboCop dentro do container Docker via `bin/rubocop-wrapper.sh`.

Isso garante que todos usem a mesma versão do RuboCop e suas dependências, independente do ambiente local.

### Como funciona:
1. VSCode chama `bin/rubocop-wrapper.sh`
2. Script executa `docker-compose exec app bundle exec rubocop`
3. Resultados aparecem no VSCode normalmente

### Troubleshooting:
- Se RuboCop não funcionar, verifique se os containers estão rodando: `docker-compose ps`
- Certifique-se que `bin/rubocop-wrapper.sh` tem permissão de execução: `chmod +x bin/rubocop-wrapper.sh`
