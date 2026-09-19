# КЭС 4×500 — расчёт

## Зависимости

Сайт:

- Python 3
- `mkdocs`
- `markdown-exec` — выполняет Python-блоки в Markdown
- `pymdown-extensions` — расширения Markdown (формулы, таблицы)

Установка (Fedora):

```bash
sudo dnf install mkdocs python3-markdown-exec python3-pymdown-extensions
```

или через pip:

```bash
pip install mkdocs markdown-exec pymdown-extensions
```

Пересборка графиков (необязательно, для `figures/`):

- `lualatex` (TeX Live с пакетом `pgfplots`)
- `mutool` (MuPDF)

```bash
sudo dnf install texlive-scheme-medium mupdf-tools
```

## Структура проекта

```
kec4x500/
├── mkdocs.yml            # конфигурация сайта
├── docs/
│   ├── index.md          # весь документ: текст, формулы, расчёт
│   ├── js/
│   │   └── tex-mml-svg.js   # MathJax (локальная копия, работает офлайн)
│   └── assets/img/       # рисунки: графики (SVG) и схемы (PNG)
├── figures/
│   ├── graphs.tex        # исходники графиков (TikZ/pgfplots)
│   └── build.sh          # сборка графиков → docs/assets/img
├── .gitignore
└── README.md
```

## Базовые команды

Запустить локально (открыть http://127.0.0.1:8000):

```bash
python3 -m mkdocs serve
```

Пересобрать графики (нужны `lualatex` и `mutool`):

```bash
sh figures/build.sh
```

> Если команда `mkdocs` доступна напрямую, вместо `python3 -m mkdocs` можно
> писать просто `mkdocs`.
