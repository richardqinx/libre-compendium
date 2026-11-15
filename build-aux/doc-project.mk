# libre-compendium
#
# Copyright (C) 2026 Richard Qin
#
# This file is part of libre-compendium.
#
# libre-compendium is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# libre-compendium is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with libre-compendium.  If not, see <https://www.gnu.org/licenses/>.

# libre-compendium shared per-project document rules

PROJECT_SRC ?= $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
LC_ROOT ?= $(abspath $(PROJECT_SRC)/../..)
BUILD_ROOT ?= $(PROJECT_SRC)/build
DIST_ROOT ?= $(PROJECT_SRC)/dist
LC_ENGINE ?= xelatex
LATEXMK ?= latexmk
MAKE4HT ?= make4ht
DVISVGM ?= dvisvgm
PDFCAIRO ?= pdftocairo
XELATEX ?= xelatex
HTML_TEX4HT_DIR ?= $(LC_ROOT)/common/tex/tex4ht

MAIN_TEX := $(PROJECT_SRC)/main.tex
PROBLEMSET_TEX := $(PROJECT_SRC)/problemset.tex
LATEX_RC := $(PROJECT_SRC)/latexmkrc
LATEX_BUILD := $(BUILD_ROOT)/latex
SVG_BUILD := $(BUILD_ROOT)/tikz
SVG_DIST := $(DIST_ROOT)/svg
HTML_BUILD := $(BUILD_ROOT)/html
HTML_DIST := $(DIST_ROOT)/html
PDF_DIST := $(DIST_ROOT)/pdf
TIKZ_FILES := $(wildcard $(PROJECT_SRC)/figures/tikz/*.tex)
SVG_FILES := $(patsubst $(PROJECT_SRC)/figures/tikz/%.tex,$(SVG_DIST)/%.svg,$(TIKZ_FILES))

.PHONY: all pdf html svg check logs clean help

all: pdf html svg

pdf:
	@set -eu; mkdir -p "$(LATEX_BUILD)" "$(PDF_DIST)"; \
	  if test -f "$(MAIN_TEX)"; then \
	    LC_ROOT="$(LC_ROOT)" LC_ENGINE="$(LC_ENGINE)" LC_BUILD_DIR="$(LATEX_BUILD)" LC_OUT_DIR="$(LATEX_BUILD)" LC_AUX_DIR="$(LATEX_BUILD)" \
	      "$(LATEXMK)" -cd -r "$(LATEX_RC)" -outdir="$(LATEX_BUILD)" -auxdir="$(LATEX_BUILD)" "$(MAIN_TEX)"; \
	    cp "$(LATEX_BUILD)/main.pdf" "$(PDF_DIST)/lecture.pdf"; \
	  fi; \
	  if test -f "$(PROBLEMSET_TEX)"; then \
	    LC_ROOT="$(LC_ROOT)" LC_ENGINE="$(LC_ENGINE)" LC_BUILD_DIR="$(LATEX_BUILD)" LC_OUT_DIR="$(LATEX_BUILD)" LC_AUX_DIR="$(LATEX_BUILD)" \
	      "$(LATEXMK)" -cd -r "$(LATEX_RC)" -outdir="$(LATEX_BUILD)" -auxdir="$(LATEX_BUILD)" "$(PROBLEMSET_TEX)"; \
	    cp "$(LATEX_BUILD)/problemset.pdf" "$(PDF_DIST)/problemset.pdf"; \
	  fi

html: svg
	@set -eu; mkdir -p "$(HTML_BUILD)" "$(HTML_DIST)"; \
	  if test -f "$(MAIN_TEX)"; then \
	    mkdir -p "$(HTML_BUILD)/lecture" "$(HTML_BUILD)/lecture-build" "$(HTML_DIST)/lecture"; \
    html_dir=$$(realpath --relative-to="$(PROJECT_SRC)" "$(HTML_BUILD)/lecture"); \
    html_build_dir=$$(realpath --relative-to="$(PROJECT_SRC)" "$(HTML_BUILD)/lecture-build"); \
    (cd "$(PROJECT_SRC)" && TEXINPUTS="$(HTML_TEX4HT_DIR):$(LC_ROOT)/common/tex//:$(LC_ROOT)/common/license/:$(PROJECT_SRC):" "$(MAKE4HT)" -x -d "$$html_dir" -B "$$html_build_dir" "main.tex" NoFonts); \
    html_root=$$(find "$(HTML_BUILD)/lecture" -type f -name 'main.html' -print -quit | sed 's#/main\.html$$##'); \
    test -n "$$html_root"; \
    cp -a "$$html_root/." "$(HTML_DIST)/lecture/"; \
    cp "$(HTML_TEX4HT_DIR)/lc.css" "$(HTML_DIST)/lecture/main.css"; \
	    test -f "$(HTML_DIST)/lecture/main.html" && cp "$(HTML_DIST)/lecture/main.html" "$(HTML_DIST)/lecture/index.html" || true; \
	  fi; \
	  if test -f "$(PROBLEMSET_TEX)"; then \
	    mkdir -p "$(HTML_BUILD)/problemset" "$(HTML_BUILD)/problemset-build" "$(HTML_DIST)/problemset"; \
    html_dir=$$(realpath --relative-to="$(PROJECT_SRC)" "$(HTML_BUILD)/problemset"); \
    html_build_dir=$$(realpath --relative-to="$(PROJECT_SRC)" "$(HTML_BUILD)/problemset-build"); \
    (cd "$(PROJECT_SRC)" && TEXINPUTS="$(HTML_TEX4HT_DIR):$(LC_ROOT)/common/tex//:$(LC_ROOT)/common/license/:$(PROJECT_SRC):" "$(MAKE4HT)" -x -d "$$html_dir" -B "$$html_build_dir" "problemset.tex" NoFonts); \
    html_root=$$(find "$(HTML_BUILD)/problemset" -type f -name 'problemset.html' -print -quit | sed 's#/problemset\.html$$##'); \
    test -n "$$html_root"; \
    cp -a "$$html_root/." "$(HTML_DIST)/problemset/"; \
    cp "$(HTML_TEX4HT_DIR)/lc.css" "$(HTML_DIST)/problemset/main.css"; \
	    test -f "$(HTML_DIST)/problemset/problemset.html" && cp "$(HTML_DIST)/problemset/problemset.html" "$(HTML_DIST)/problemset/index.html" || true; \
	  fi

svg: $(SVG_FILES)

$(SVG_DIST)/%.svg: $(PROJECT_SRC)/figures/tikz/%.tex
	@set -eu; mkdir -p "$(SVG_BUILD)/wrappers" "$(SVG_DIST)"; \
	  wrapper="$(SVG_BUILD)/wrappers/$*.tex"; \
	  { \
	    printf '%s\n' '\documentclass{lc-figure}'; \
	    printf '%s\n' '\colorlet{CADef}{lc-def}'; \
	    printf '%s\n' '\colorlet{CAThm}{lc-thm}'; \
	    printf '%s\n' '\colorlet{CAMethod}{lc-method}'; \
	    printf '%s\n' '\colorlet{CAPitfall}{lc-pitfall}'; \
	    printf '%s\n' '\colorlet{CAExample}{lc-example}'; \
	    printf '%s\n' '\begin{document}'; \
	    printf '\\input{%s}\n' "$<"; \
	    printf '%s\n' '\end{document}'; \
	  } > "$$wrapper"; \
	  TEXINPUTS="$(LC_ROOT)/common/tex//:$(LC_ROOT)/common/license/:$(PROJECT_SRC):" "$(XELATEX)" -interaction=nonstopmode -halt-on-error -output-directory="$(SVG_BUILD)/wrappers" "$$wrapper" >/dev/null; \
	  if command -v "$(DVISVGM)" >/dev/null 2>&1 && "$(DVISVGM)" --pdf "$(SVG_BUILD)/wrappers/$*.pdf" -o "$@" >/dev/null 2>&1; then \
	    :; \
	  else \
	    "$(PDFCAIRO)" -svg "$(SVG_BUILD)/wrappers/$*.pdf" "$@"; \
	  fi

check: pdf
	@test -s "$(PDF_DIST)/lecture.pdf" || test ! -f "$(MAIN_TEX)"
	@test -s "$(PDF_DIST)/problemset.pdf" || test ! -f "$(PROBLEMSET_TEX)"

logs:
	@find "$(BUILD_ROOT)" -type f -name '*.log' -print 2>/dev/null || true

clean:
	rm -rf "$(BUILD_ROOT)" "$(DIST_ROOT)"

help:
	@echo 'Targets: all pdf html svg check logs clean'
