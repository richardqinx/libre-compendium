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

doc_out_name = $(if $(filter main,$(1)),$(MAIN_OUTPUT_NAME),$(1))

LATEX_RC := $(PROJECT_SRC)/latexmkrc
LATEX_BUILD := $(BUILD_ROOT)/latex
SVG_BUILD := $(BUILD_ROOT)/tikz
SVG_DIST := $(DIST_ROOT)/svg
HTML_BUILD := $(BUILD_ROOT)/html
HTML_DIST := $(DIST_ROOT)/html
PDF_DIST := $(DIST_ROOT)/pdf
TIKZ_FILES := $(wildcard $(PROJECT_SRC)/figures/tikz/*.tex)
SVG_FILES := $(patsubst $(PROJECT_SRC)/figures/tikz/%.tex,$(SVG_DIST)/%.svg,$(TIKZ_FILES))

PROJECT_DEPS := $(shell find "$(PROJECT_SRC)" -type f \
  ! -path '$(PROJECT_SRC)/build/*' ! -path '$(PROJECT_SRC)/dist/*' ! -path '$(PROJECT_SRC)/.agents/*' \
  -print 2>/dev/null)
COMMON_PDF_DEPS := $(shell find "$(LC_ROOT)/common/tex" "$(LC_ROOT)/common/license" "$(LC_ROOT)/common/build-aux" \
  -type f ! -path '$(LC_ROOT)/common/tex/tex4ht/*' -print 2>/dev/null) \
  $(LC_ROOT)/build-aux/doc-project.mk
COMMON_HTML_DEPS := $(COMMON_PDF_DEPS) \
  $(shell find "$(HTML_TEX4HT_DIR)" -type f -print 2>/dev/null)

PDF_TARGETS := $(foreach t,$(DOC_TARGETS),$(PDF_DIST)/$(call doc_out_name,$(t)).pdf)
HTML_TARGETS := $(foreach t,$(DOC_TARGETS),$(HTML_DIST)/$(call doc_out_name,$(t))/index.html)

.PHONY: all pdf html svg check logs clean help

all: pdf html svg

pdf: $(PDF_TARGETS)

html: $(HTML_TARGETS)

svg: $(SVG_FILES)

define DOC_TARGET_RULES
$(PDF_DIST)/$(2).pdf: $(PROJECT_SRC)/$(1).tex $$(PROJECT_DEPS) $$(COMMON_PDF_DEPS)
	@set -eu; mkdir -p "$$(LATEX_BUILD)" "$$(PDF_DIST)"; \
	  LC_ROOT="$$(LC_ROOT)" LC_ENGINE="$$(LC_ENGINE)" LC_BUILD_DIR="$$(LATEX_BUILD)" LC_OUT_DIR="$$(LATEX_BUILD)" LC_AUX_DIR="$$(LATEX_BUILD)" \
	    "$$(LATEXMK)" -cd -r "$$(LATEX_RC)" -outdir="$$(LATEX_BUILD)" -auxdir="$$(LATEX_BUILD)" "$$<"; \
	  cp "$$(LATEX_BUILD)/$(1).pdf" "$$@"

$(HTML_DIST)/$(2)/index.html: $(PROJECT_SRC)/$(1).tex $$(PROJECT_DEPS) $$(COMMON_HTML_DEPS) $$(SVG_FILES)
	@set -eu; mkdir -p "$$(HTML_BUILD)/$(2)" "$$(HTML_DIST)/$(2)" "$$(BUILD_ROOT)/texmf-var"; \
	  sh "$$(LC_ROOT)/common/build-aux/lc-version.sh" > "$$(HTML_BUILD)/$(2)/lc-version.tex"; \
	  (cd "$$(HTML_BUILD)/$(2)" && \
	    TEXMFVAR="$$(BUILD_ROOT)/texmf-var" \
	    TEXINPUTS="$$(HTML_TEX4HT_DIR):$$(LC_ROOT)/common/tex//:$$(LC_ROOT)/common/license/:$$(PROJECT_SRC):$$(HTML_BUILD)/$(2):" \
	    BIBINPUTS="$$(PROJECT_SRC):" \
	    "$$(MAKE4HT)" -l -c lc-html.cfg -d "$$(HTML_DIST)/$(2)" "$$<" "" "" "" "-interaction=nonstopmode"); \
	  cp "$$(HTML_TEX4HT_DIR)/lc.css" "$$(HTML_DIST)/$(2)/lc.css"; \
	  cp "$$(HTML_DIST)/$(2)/$(1).html" "$$@"
endef

$(foreach t,$(DOC_TARGETS),$(eval $(call DOC_TARGET_RULES,$(t),$(call doc_out_name,$(t)))))

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
	@set -eu; for f in $(PDF_TARGETS); do test -s "$$f"; done

logs:
	@find "$(BUILD_ROOT)" -type f -name '*.log' -print 2>/dev/null || true

clean:
	rm -rf "$(BUILD_ROOT)" "$(DIST_ROOT)"

help:
	@echo 'Targets: all pdf html svg check logs clean'
