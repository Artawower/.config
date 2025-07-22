# AI Integration для Helix Editor

Этот документ описывает настройку AI-powered функций автодополнения кода для редактора Helix с несколькими вариантами:

## Вариант 1: GitHub Copilot (Рекомендуется)

### 1. Установка GitHub Copilot Language Server

```bash
# Установка через npm
npm install -g @github/copilot-language-server
```

### 2. Настройка аутентификации

```bash
# Войти в GitHub Copilot (нужна подписка)
gh auth login
gh copilot auth
```

## Вариант 2: lsp-ai с Ollama (Бесплатно)

### 1. Установка Ollama и lsp-ai

```bash
# Установка Ollama (локальная AI модель)
curl -fsSL https://ollama.ai/install.sh | sh

# Скачивание модели для кода
ollama pull codellama:7b

# Установка lsp-ai
cargo install lsp-ai
```

## Конфигурация

Интеграция добавлена в файл конфигурации Helix:

### languages.toml

**По умолчанию настроен GitHub Copilot для:**
- TypeScript, JavaScript, JSX, TSX
- Python 
- Go
- Lua

**Также доступен lsp-ai с Ollama для бесплатного использования:**
- Модель CodeLlama 7B
- Автодополнение кода с контекстом до 2048 токенов  
- Чат в редакторе с триггером `!ai`

## Использование

### GitHub Copilot
1. **Автодополнение**: Начните печатать код - Copilot автоматически предложит варианты
2. **Навигация**: Используйте Tab/Enter для принятия предложений
3. **Альтернативы**: Ctrl+] для следующего предложения, Ctrl+[ для предыдущего

### lsp-ai с Ollama (если выбран как альтернатива)
1. **Автодополнение**: Работает автоматически при наборе кода  
2. **Чат**: Используйте `space + c + a` → найдите опцию с триггером `!ai`

Пример чата:
```
!ai Объясни этот код и предложи улучшения
```

### Команды LSP

В режиме normal mode доступны стандартные LSP команды:
- `K` - hover информация
- `gd` - goto definition
- `gr` - goto references  
- `gi` - goto implementation
- `gt` - goto type definition
- `space + c + a` - code actions (включая AI чат)
- `space + c + r` - rename symbol
- `space + c + f` - format selection

## Поддерживаемые языки

Интеграция активна для:
- **TypeScript/JavaScript** (с typescript-language-server)
- **JSX/TSX** React компоненты
- **Python** (с pyright + ruff-lsp)
- **Go** (с gopls)
- **Lua** (с lua-language-server)

## Дополнительные модели

Для использования других AI провайдеров, можно изменить конфигурацию в `languages.toml`:

### Anthropic Claude
```toml
[language-server.lsp-ai.config.models.anthropic]
type = "anthropic"
chat_endpoint = "https://api.anthropic.com/v1/messages"
model = "claude-3-5-sonnet-20241022"
auth_token_env_var_name = "ANTHROPIC_API_KEY"
```

### Ollama (локальная модель)
```toml
[language-server.lsp-ai.config.models.ollama]
type = "ollama"
chat_endpoint = "http://localhost:11434/v1/chat/completions"
model = "codellama"
```

## Troubleshooting

1. **lsp-ai не запускается**: Убедитесь что binary установлен и доступен в PATH
2. **API ошибки**: Проверьте правильность API ключа в переменной окружения
3. **Нет предложений**: Перезапустите Helix (`:quit-all` и запуск снова)
4. **Чат не работает**: Используйте code actions (`space + c + a`) для доступа к AI чату

## Полезные ссылки

- [LSP-AI GitHub](https://github.com/SilasMarvin/lsp-ai)
- [LSP-AI Wiki](https://github.com/SilasMarvin/lsp-ai/wiki)
- [Helix LSP Configuration](https://docs.helix-editor.com/languages.html)