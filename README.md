## Зависимости

Сайт:

- `mkdocs`
- `markdown-exec` — выполняет Python-блоки в Markdown
- `pymdown-extensions` — расширения Markdown (формулы, таблицы)

Установка (dnf):

```bash
sudo dnf install mkdocs python3-markdown-exec python3-pymdown-extensions
```

или через pip:

```bash
pip install mkdocs markdown-exec pymdown-extensions
```

Пересборка графиков:

- `lualatex` (TeX Live с пакетом `pgfplots`)
- `mutool` (MuPDF)

```bash
sudo dnf install texlive-scheme-medium mupdf-tools
```

## Структура

```
kec4x500/
├── mkdocs.yml             # конфигурация сайта
├── docs/
│   ├── index.md           # документ
│   ├── js/
│   │   └── tex-mml-svg.js # MathJax (локальная копия)
│   └── assets/img/        # рисунки: графики (SVG) и схемы (PNG)
├── figures/
│   ├── graphs.tex         # исходники графиков (TikZ/pgfplots)
│   └── build.sh           # сборка графиков docs/assets/img
├── .gitignore
└── README.md
```

## Использование

Запустить локально (http://127.0.0.1:8000):

```bash
python3 -m mkdocs serve
```

Пересобрать графики (нужны `lualatex` и `mutool`):

```bash
sh figures/build.sh
```
