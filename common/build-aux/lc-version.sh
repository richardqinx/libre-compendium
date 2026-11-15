#!/bin/sh
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
if git rev-parse --verify HEAD >/dev/null 2>&1; then
  printf '\\lcsetversion{%s}{%s}{%s}\n' "$(git describe --tags --always --dirty)" "$(git rev-parse --short HEAD)" "$(git log -1 --format=%cs)"
else
  printf '\\lcsetversion{unversioned}{none}{}\n'
fi
