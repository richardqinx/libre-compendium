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
\ProvidesClass{lc-article}[2026/11/13 v0.1.0 论文报告文档类]
\RequirePackage{iftex}
\ifPDFTeX\ClassError{lc}{请使用 XeLaTeX 或 LuaLaTeX 编译}{}\csname @@end\endcsname\fi
\DeclareKeys{
 style .choices:nn={boxed,classic}{\def\lc@style{#1}},
 color .choices:nn={full,gray}{\def\lc@color{#1}},
 fonts .choices:nn={auto,noto,fandol}{\def\lc@fonts{#1}},
 status .choices:nn={release,draft}{\def\lc@status{#1}},
 figures .choices:nn={inline,cache,external}{\def\lc@figures{#1}}
}
\def\lc@color{full}\def\lc@fonts{auto}\def\lc@status{release}\def\lc@figures{inline}
\def\lc@kind{article}\def\lc@style{classic}
\def\lc@pedagogy{false}\def\lc@exercises{false}\def\lc@bib{true}\def\lc@profile{standard}
\DeclareKeys{
 pedagogy .choices:nn={true,false}{\def\lc@pedagogy{#1}},
 exercises .choices:nn={true,false}{\def\lc@exercises{#1}}}
\ProcessKeyOptions
\LoadClass[UTF8,zihao=-4,fontset=none]{ctexart}
\RequirePackage{lc-base}
\ExplSyntaxOn
\str_if_eq:eeT{\lc@pedagogy}{true}{\RequirePackage{lc-pedagogy}}
\str_if_eq:eeT{\lc@exercises}{true}{\RequirePackage{lc-exercise}\lcset{solutions=end}}
\ExplSyntaxOff
\ExplSyntaxOn
\str_if_eq:eeT{\lc@bib}{true}{\RequirePackage{lc-biblio}}
\ExplSyntaxOff
\RequirePackage{lc-attribution}
\RequirePackage{lc-license}

\ExplSyntaxOn
\tl_new:N\g__lc_abstract_keywords_tl
\cs_new_protected:Npn\lc@keywordsfromaux#1{\tl_gset:Nn\g__lc_abstract_keywords_tl{#1}}
\NewDocumentCommand{\lckeywords}{m}{
 \par\noindent\textbf{\lc@name@keywords：}#1\par
 \tl_gset:Nn\g__lc_keywords_tl{#1}
 % 标题页先于摘要输出，关键词经既有 aux 传到下一轮的文档开始处。
 \protected@write\@auxout{}{\string\lc@keywordsfromaux{\unexpanded{#1}}}}
\ExplSyntaxOff
