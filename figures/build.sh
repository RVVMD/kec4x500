# Сборка графиков из TikZ (pgfplots) в SVG
# Требуется lualatex и mutool
set -eu
cd "$(dirname "$0")"

rm -rf build
mkdir -p build

lualatex -interaction=nonstopmode -halt-on-error -output-directory=build graphs.tex >build/lualatex.log
mutool draw -F svg -o build/g-%d.svg build/graphs.pdf

cp build/g-1.svg ../docs/assets/img/load-rusn.svg
cp build/g-2.svg ../docs/assets/img/load-gen.svg
cp build/g-3.svg ../docs/assets/img/power-gen.svg
cp build/g-4.svg ../docs/assets/img/power-rusn.svg
cp build/g-5.svg ../docs/assets/img/perets-var1.svg
cp build/g-6.svg ../docs/assets/img/perets-var2.svg

rm -rf build
echo "graphs rebuilt"
