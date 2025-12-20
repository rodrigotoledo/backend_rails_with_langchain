# Configuração do VSCode - Guia Rápido

## 📋 O que foi feito

Para evitar conflitos de configuração entre desenvolvedores, as configurações do VSCode foram movidas para um template:

### Estrutura

```
.vscode/              # ❌ NÃO commitado (adicionado ao .gitignore)
.vscode.example/      # ✅ Template commitado (todos os devs usam como base)
├── settings.json
├── extensions.json
└── README.md
```

## 🚀 Setup Inicial

Ao clonar o projeto, execute:

```bash
cp -r .vscode.example .vscode
```

Isso criará sua pasta `.vscode/` local com as configurações recomendadas.

## ✨ Configurações Incluídas

### RuboCop Integration

O VSCode está configurado para executar RuboCop **dentro do container Docker** automaticamente:

- ✅ Mesma versão do RuboCop para todos os desenvolvedores
- ✅ Sem necessidade de instalar Ruby localmente
- ✅ Funciona via `bin/rubocop-wrapper.sh`

### Extensões Recomendadas

Ao abrir o projeto, o VSCode sugerirá instalar:

- **Ruby**: rebornix.ruby, castwide.solargraph, testdouble.vscode-standard-ruby
- **Docker**: ms-azuretools.vscode-docker
- **Database**: mtxr.sqltools, mtxr.sqltools-driver-pg
- **Git**: eamodio.gitlens

## 🔧 Personalizações

Você pode modificar `.vscode/settings.json` localmente sem afetar outros desenvolvedores:

```jsonc
{
  // Suas configurações pessoais
  "workbench.colorTheme": "Dracula",
  "editor.fontSize": 14,

  // As configurações do projeto continuam ativas
  "ruby.rubocop.executePath": "${workspaceFolder}/bin/"
}
```

## ⚠️ Importante

- **NUNCA** commite a pasta `.vscode/` (ela está no `.gitignore`)
- Se fizer melhorias úteis para o time, atualize `.vscode.example/`
- Sempre use `.vscode.example/` como base para configurações do projeto

## 🐛 Troubleshooting

### RuboCop não funciona no VSCode

1. Verifique se os containers estão rodando:
   ```bash
   docker-compose ps
   ```

2. Teste o wrapper manualmente:
   ```bash
   ./bin/rubocop-wrapper.sh --version
   ```

3. Verifique permissões:
   ```bash
   chmod +x bin/rubocop-wrapper.sh
   ```

4. Recrie sua configuração:
   ```bash
   rm -rf .vscode
   cp -r .vscode.example .vscode
   ```

## 📚 Referências

- [Documentação Completa](.vscode.example/README.md)
- [Environment Variables Guide](ENVIRONMENT_VARIABLES.md)
- [Embeddings System Documentation](EMBEDDINGS_SYSTEM.md)
