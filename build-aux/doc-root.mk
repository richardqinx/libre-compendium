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

# libre-compendium root document orchestration
-include $(abs_builddir)/build-aux/doc-projects.mk
DOC_PROJECTS ?= $(shell find $(abs_top_srcdir)/math $(abs_top_srcdir)/physics -mindepth 2 -maxdepth 2 -type f -name main.tex -printf '%h\n' | sed 's#^$(abs_top_srcdir)/##' | sort)
DOC_ENABLE_HTML ?= yes
DOC_ENABLE_SVG ?= yes
DOC_ENGINE ?= xelatex
PROJECT ?=

.PHONY: all pdf html svg check list-projects logs clean-dist common-manual

all: pdf html svg

list-projects:
	@for p in $(DOC_PROJECTS); do echo $$p; done

pdf:
	@set -eu; projects='$(PROJECT)'; test -n "$$projects" || projects='$(DOC_PROJECTS)'; \
	  for p in $$projects; do \
	    case " $(DOC_PROJECTS) " in *" $$p "*) ;; *) echo "Unknown PROJECT=$$p" >&2; exit 2;; esac; \
	    $(MAKE) -C "$(abs_top_srcdir)/$$p" BUILD_ROOT="$(abs_builddir)/build/$$p" DIST_ROOT="$(abs_builddir)/dist/$$p" LC_ROOT="$(abs_top_srcdir)" LC_ENGINE="$(DOC_ENGINE)" pdf; \
	  done

html:
	@if test "$(DOC_ENABLE_HTML)" != yes; then echo 'HTML disabled at configure time'; exit 0; fi; \
	set -eu; projects='$(PROJECT)'; test -n "$$projects" || projects='$(DOC_PROJECTS)'; \
	  for p in $$projects; do \
	    case " $(DOC_PROJECTS) " in *" $$p "*) ;; *) echo "Unknown PROJECT=$$p" >&2; exit 2;; esac; \
	    $(MAKE) -C "$(abs_top_srcdir)/$$p" BUILD_ROOT="$(abs_builddir)/build/$$p" DIST_ROOT="$(abs_builddir)/dist/$$p" LC_ROOT="$(abs_top_srcdir)" LC_ENGINE="$(DOC_ENGINE)" html; \
	  done

svg:
	@if test "$(DOC_ENABLE_SVG)" != yes; then echo 'SVG disabled at configure time'; exit 0; fi; \
	set -eu; projects='$(PROJECT)'; test -n "$$projects" || projects='$(DOC_PROJECTS)'; \
	  for p in $$projects; do \
	    case " $(DOC_PROJECTS) " in *" $$p "*) ;; *) echo "Unknown PROJECT=$$p" >&2; exit 2;; esac; \
	    $(MAKE) -C "$(abs_top_srcdir)/$$p" BUILD_ROOT="$(abs_builddir)/build/$$p" DIST_ROOT="$(abs_builddir)/dist/$$p" LC_ROOT="$(abs_top_srcdir)" LC_ENGINE="$(DOC_ENGINE)" svg; \
	  done

check: pdf
	@set -eu; test -d "$(abs_builddir)/dist"; echo 'Document build checks passed.'

logs:
	@projects='$(PROJECT)'; test -n "$$projects" || projects='$(DOC_PROJECTS)'; for p in $$projects; do echo "--- $$p"; $(MAKE) -C "$(abs_top_srcdir)/$$p" BUILD_ROOT="$(abs_builddir)/build/$$p" logs; done

clean-dist:
	rm -rf "$(abs_builddir)/dist"

install-data-local: all
	@set -eu; if test -d "$(abs_builddir)/dist"; then $(MKDIR_P) "$(DESTDIR)$(docdir)"; cp -a "$(abs_builddir)/dist/." "$(DESTDIR)$(docdir)/"; fi

uninstall-local:
	rm -rf "$(DESTDIR)$(docdir)"

clean-local: clean-dist
	rm -rf "$(abs_builddir)/build"

common-manual:
	$(MAKE) -C "$(abs_top_srcdir)/common/doc" BUILD_ROOT="$(abs_builddir)/build/common-manual" DIST_ROOT="$(abs_builddir)/dist/common-manual" LC_ROOT="$(abs_top_srcdir)" pdf
