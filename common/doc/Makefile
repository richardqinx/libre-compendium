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

# libre-compendium common manual entry point
PROJECT_SRC := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
LC_ROOT ?= $(abspath $(PROJECT_SRC)/../..)
BUILD_ROOT ?= $(PROJECT_SRC)/build
DIST_ROOT ?= $(PROJECT_SRC)/dist
LC_ENGINE ?= xelatex
LATEXMK ?= latexmk

MANUAL_TEX := $(PROJECT_SRC)/manual.tex
LATEX_RC := $(PROJECT_SRC)/latexmkrc
LATEX_BUILD := $(BUILD_ROOT)/latex
PDF_DIST := $(DIST_ROOT)/pdf

.PHONY: all pdf check logs clean help

all: pdf

pdf:
	@set -eu; mkdir -p "$(LATEX_BUILD)" "$(PDF_DIST)"; \
	  LC_ROOT="$(LC_ROOT)" LC_ENGINE="$(LC_ENGINE)" LC_BUILD_DIR="$(LATEX_BUILD)" LC_OUT_DIR="$(LATEX_BUILD)" LC_AUX_DIR="$(LATEX_BUILD)" \
	    "$(LATEXMK)" -cd -r "$(LATEX_RC)" -outdir="$(LATEX_BUILD)" -auxdir="$(LATEX_BUILD)" "$(MANUAL_TEX)"; \
	  cp "$(LATEX_BUILD)/manual.pdf" "$(PDF_DIST)/manual.pdf"

check: pdf
	@test -s "$(PDF_DIST)/manual.pdf"

logs:
	@find "$(BUILD_ROOT)" -type f -name '*.log' -print 2>/dev/null || true

clean:
	rm -rf "$(BUILD_ROOT)" "$(DIST_ROOT)"

help:
	@echo 'Targets: all pdf check logs clean'
