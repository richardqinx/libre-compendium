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

AUTOMAKE_OPTIONS = foreign

DISTCLEANFILES = $(builddir)/build-aux/doc-projects.mk

DOC_ENGINE = @DOC_ENGINE@
DOC_ENABLE_HTML = @DOC_ENABLE_HTML@
DOC_ENABLE_SVG = @DOC_ENABLE_SVG@

# Keep source documents in the source archive, excluding generated build trees
# and local agent metadata.
DOC_SOURCE_FILES = $(shell find $(srcdir)/common $(srcdir)/math $(srcdir)/physics -type f \
  ! -path '*/build/*' ! -path '*/dist/*' ! -path '*/.agents/*' \
  -print)

EXTRA_DIST = \
  AUTHORS CONTRIBUTING COPYING COPYING.DOC ChangeLog INSTALL LICENSE-CC-BY-SA-4.0 NEWS README \
  configure.ac build-aux/discover-projects.sh build-aux/doc-project.mk build-aux/doc-root.mk \
  build-aux/gitlog-to-changelog \
  $(DOC_SOURCE_FILES)

dist-hook: gen-ChangeLog
.PHONY: gen-ChangeLog
gen-ChangeLog:
	$(AM_V_GEN)if test -e $(top_srcdir)/.git; then \
	  $(top_srcdir)/build-aux/gitlog-to-changelog \
	    --srcdir=$(top_srcdir) > $(distdir)/cl-t && \
	  { rm -f $(distdir)/ChangeLog && \
	    mv $(distdir)/cl-t $(distdir)/ChangeLog; } \
	fi

include $(srcdir)/build-aux/doc-root.mk
