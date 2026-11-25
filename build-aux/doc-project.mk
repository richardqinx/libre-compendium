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

# Discover top-level document entrypoints containing \documentclass; projects
# may override DOC_TARGETS or MAIN_OUTPUT_NAME in their own Makefile.
DOC_TARGETS ?= $(sort $(basename $(notdir $(shell grep -l '^[^%]*\\documentclass' "$(PROJECT_SRC)"/*.tex 2>/dev/null))))
MAIN_OUTPUT_NAME ?= $(strip $(shell \
  if test -f "$(PROJECT_SRC)/main.tex"; then \
    if grep -q 'lc-article' "$(PROJECT_SRC)/main.tex"; then echo article; \
    elif grep -q 'lc-lecture' "$(PROJECT_SRC)/main.tex"; then echo lecture; \
    elif grep -q 'lc-problemset' "$(PROJECT_SRC)/main.tex"; then echo problemset; \
    else echo main; fi; \
  else echo main; fi))

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
	  for target in $(DOC_TARGETS); do \
	    src="$(PROJECT_SRC)/$$target.tex"; \
	    out="$$target"; \
	    if test "$$target" = main; then out="$(MAIN_OUTPUT_NAME)"; fi; \
	    LC_ROOT="$(LC_ROOT)" LC_ENGINE="$(LC_ENGINE)" LC_BUILD_DIR="$(LATEX_BUILD)" LC_OUT_DIR="$(LATEX_BUILD)" LC_AUX_DIR="$(LATEX_BUILD)" \
	      "$(LATEXMK)" -cd -r "$(LATEX_RC)" -outdir="$(LATEX_BUILD)" -auxdir="$(LATEX_BUILD)" "$$src"; \
	    cp "$(LATEX_BUILD)/$$target.pdf" "$(PDF_DIST)/$$out.pdf"; \
	  done

html: svg
	@set -eu; mkdir -p "$(HTML_BUILD)" "$(HTML_DIST)" "$(BUILD_ROOT)/texmf-var"; \
	  for target in $(DOC_TARGETS); do \
	    src="$(PROJECT_SRC)/$$target.tex"; \
	    out="$$target"; \
	    if test "$$target" = main; then out="$(MAIN_OUTPUT_NAME)"; fi; \
	    mkdir -p "$(HTML_BUILD)/$$out" "$(HTML_DIST)/$$out"; \
	    sh "$(LC_ROOT)/common/build-aux/lc-version.sh" > "$(HTML_BUILD)/$$out/lc-version.tex"; \
	    (cd "$(HTML_BUILD)/$$out" && \
	      TEXMFVAR="$(BUILD_ROOT)/texmf-var" \
	      TEXINPUTS="$(HTML_TEX4HT_DIR):$(LC_ROOT)/common/tex//:$(LC_ROOT)/common/license/:$(PROJECT_SRC):$(HTML_BUILD)/$$out:" \
	      BIBINPUTS="$(PROJECT_SRC):" \
	      "$(MAKE4HT)" -l -c lc-html.cfg -d "$(HTML_DIST)/$$out" "$$src" "" "" "" "-interaction=nonstopmode"); \
	    cp "$(HTML_TEX4HT_DIR)/lc.css" "$(HTML_DIST)/$$out/lc.css"; \
	    test -f "$(HTML_DIST)/$$out/$$target.html" && cp "$(HTML_DIST)/$$out/$$target.html" "$(HTML_DIST)/$$out/index.html"; \
	  done

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
	@set -eu; for target in $(DOC_TARGETS); do \
	  out="$$target"; \
	  if test "$$target" = main; then out="$(MAIN_OUTPUT_NAME)"; fi; \
	  test -s "$(PDF_DIST)/$$out.pdf"; \
	done

logs:
	@find "$(BUILD_ROOT)" -type f -name '*.log' -print 2>/dev/null || true

clean:
	rm -rf "$(BUILD_ROOT)" "$(DIST_ROOT)"

help:
	@echo 'Targets: all pdf html svg check logs clean'
