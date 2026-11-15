% libre-compendium
%
% Copyright (C) 2026 Richard Qin
%
% This file is part of libre-compendium.
%
% libre-compendium is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% libre-compendium is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with libre-compendium.  If not, see <https://www.gnu.org/licenses/>.

\NeedsTeXFormat{LaTeX2e}[2022-11-01]
\ProvidesClass{lc-figure}[2026/11/13 v0.1.0 独立图形文档类]
\RequirePackage{iftex}
\ifPDFTeX\ClassError{lc}{请使用 XeLaTeX 或 LuaLaTeX 编译}{}\csname @@end\endcsname\fi
\def\lc@color{full}\def\lc@fonts{auto}\def\lc@figures{inline}\def\lc@kind{figure}
\DeclareKeys{
 color .choices:nn={full,gray}{\def\lc@color{#1}},
 fonts .choices:nn={auto,noto,fandol}{\def\lc@fonts{#1}}}
\ProcessKeyOptions
\LoadClass[border=2pt]{standalone}
\RequirePackage[UTF8,fontset=none]{ctex}
\input{lc-project.def}\input{lc-names-zh.def}
\RequirePackage{amsmath}\RequirePackage{mathtools}
\RequirePackage{lc-fonts}\RequirePackage{lc-colors}\RequirePackage{lc-meta}
\RequirePackage{lc-math}\RequirePackage{lc-figure}
\NewDocumentCommand{\lchistory}{mmmm}{}
\NewDocumentCommand{\lcsource}{mmm}{}
