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
\ProvidesClass{lc-problemset}[2026/11/13 v0.1.0 习题集文档类]
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
\def\lc@kind{problemset}\def\lc@style{boxed}
\def\lc@profile{practice}\def\lc@bib{false}
\DeclareKeys{
 profile .choices:nn={practice,homework,list}{\def\lc@profile{#1}},
 solutions .choices:nn={inline,chapter-end,end,hide}{\def\lc@override@solutions{#1}},
 show .choices:nn={answer,solution,both}{\def\lc@override@show{#1}},
 points .choices:nn={show,hide}{\def\lc@override@points{#1}},
 bib .choices:nn={true,false}{\def\lc@bib{#1}}}
\ProcessKeyOptions
\LoadClass[UTF8,zihao=-4,fontset=none]{ctexart}
\RequirePackage{lc-base}
\RequirePackage{lc-exercise}
\ExplSyntaxOn
\str_case:en{\lc@profile}{
 {practice}{\lcset{solutions=end,show=solution,points=hide}}
 {homework}{\lcset{solutions=hide,show=solution,points=show}}
 {list}{\lcset{solutions=end,show=answer,points=hide}}}
\clist_map_inline:nn{solutions,show,points}{
 \cs_if_exist:cT{lc@override@#1}{\exp_args:Ne\lcset{#1=\use:c{lc@override@#1}}}}
\ExplSyntaxOff
\ExplSyntaxOn
\str_if_eq:eeT{\lc@bib}{true}{\RequirePackage{lc-biblio}}
\ExplSyntaxOff
\RequirePackage{lc-attribution}
\RequirePackage{lc-license}
