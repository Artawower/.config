# Helix Configuration

Конфигурация Helix, адаптированная из NeoVim.

## Что перенесено из NeoVim

### ✅ Успешно адаптировано

**Горячие клавиши:**
- `Ctrl+S` - сохранение файла
- `Ctrl+.` - переключение между окнами  
- `Shift+H/J/K/L` - изменение размера окон
- `Space+y/p` - копирование/вставка в системный буфер
- `Space+q/Q` - закрытие буфера/выход
- `Space+b]/[` - навигация между буферами
- `Space+wv/ws` - разделение окон
- `Space+ff/fg/fb/fs` - файловый пикер, поиск, буферы, символы
- `Space+ca/cr/cf` - LSP действия
- `Space+/` - комментирование
- `gd/gr/gi/gt` - LSP навигация
- `K` - документация
- `f` - прыжки по словам (hop.nvim аналог)
- `F12` - терминал

**Настройки редактора:**
- Относительные номера строк
- Отступы 2 пробела (tabstop=2, shiftwidth=2, expandtab)
- Автодополнение и LSP
- Автоформатирование
- Направляющие отступов
- Прозрачный фон

**LSP серверы:**
- TypeScript/JavaScript (ts_ls)
- Python (pyright + ruff-lsp)
- Go (gopls)
- Lua (lua-language-server)
- CSS/HTML (vscode language servers)
- Vue.js (volar)
- YAML (yaml-language-server)

**Тема:**
- Catppuccin Frappe (как в NeoVim)
- Кастомная тема "my" с прозрачным фоном

### ⚠️ Частично адаптировано

**Файловый менеджер:**
- Встроенный файловый менеджер Helix (`Space+e` или `Space+fe`) - добавлен в версии 25.07
- Yazi интеграция сохранена (`Space+fd`)
- Встроенный файловый пикер Helix (`Space+ff`)
- Полная замена nvim-tree/ranger

**Терминал:**
- `F12` открывает shell
- Нет встроенного toggleterm аналога
- Используйте внешний терминальный мультиплексор

### ❌ Невозможно перенести

**Плагины:**
- Claude Code integration - специфично для NeoVim
- Copilot - нет прямой поддержки в Helix
- Telescope - заменен встроенными пикерами
- Comment.nvim - заменен встроенным комментированием
- Auto-pairs - встроено в Helix
- Gitsigns - встроена git интеграция
- Lualine - заменена встроенной statusline
- Treesitter - встроен в Helix

**Специфичные для Vim функции:**
- Сложные макросы и команды
- Vim-surround (есть базовая поддержка)
- Wakatime - нет плагинов в Helix
- Bookmarks - нет аналога

## Установка LSP серверов

```bash
# TypeScript/JavaScript
npm install -g typescript-language-server typescript

# Python
pip install pyright ruff-lsp black

# Go
go install golang.org/x/tools/gopls@latest

# Lua
brew install lua-language-server  # macOS
# или скачать с GitHub

# CSS/HTML
npm install -g vscode-langservers-extracted

# Vue
npm install -g @vue/language-server

# YAML
npm install -g yaml-language-server

# Markdown
brew install marksman  # macOS
```

## Проверка здоровья

```bash
hx --health
```

## Основные отличия от NeoVim

1. **Selection → Action** вместо **Action → Object**
2. **Встроенные возможности** вместо плагинов
3. **Минимальная конфигурация** - все работает из коробки
4. **Нет режима Ex** - команды через пикеры
5. **Tree-sitter встроен** - отличная подсветка синтаксиса

## Быстрый старт

1. Откройте файл: `hx filename`
2. Используйте `Space` для команд
3. `:` для режима команд
4. `?` для справки по клавишам

## Файлы конфигурации

- `config.toml` - основные настройки
- `languages.toml` - LSP и языки
- `themes/my.toml` - кастомная тема
