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
\ProvidesClass{lc-lecture}[2026/11/13 v0.1.0 课程讲义文档类]
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
\def\lc@kind{lecture}\def\lc@style{boxed}
\def\lc@scope{course}\def\lc@profile{standard}\def\lc@bib{false}
\DeclareKeys{
 scope .choices:nn={course,unit}{\def\lc@scope{#1}},
 profile .choices:nn={standard,review}{\def\lc@profile{#1}},
 bib .choices:nn={true,false}{\def\lc@bib{#1}}}
\DeclareKeys{method .choices:nn={show,degrade,hide}{\def\lc@override@method{#1}}}
\DeclareKeys{pitfall .choices:nn={show,degrade,hide}{\def\lc@override@pitfall{#1}}}
\DeclareKeys{hint .choices:nn={show,degrade,hide}{\def\lc@override@hint{#1}}}
\DeclareKeys{attention .choices:nn={show,degrade,hide}{\def\lc@override@attention{#1}}}
\DeclareKeys{examspot .choices:nn={show,degrade,hide}{\def\lc@override@examspot{#1}}}
\DeclareKeys{summary .choices:nn={show,degrade,hide}{\def\lc@override@summary{#1}}}
\ProcessKeyOptions
\ExplSyntaxOn
\str_if_eq:eeTF{\lc@scope}{course}
 {\cs_if_exist:NT\HCode{\ExplSyntaxOff\input{ctexbook-hooks.4ht}\ExplSyntaxOn}
  \LoadClass[UTF8,zihao=-4,fontset=none,oneside,openany]{ctexbook}}
 {\LoadClass[UTF8,zihao=-4,fontset=none]{ctexart}}
\ExplSyntaxOff
\RequirePackage{lc-base}
\RequirePackage{lc-pedagogy}
\RequirePackage{lc-exercise}
\lcset{solutions=hide,points=hide}
\ExplSyntaxOn
\str_if_eq:eeT{\lc@bib}{true}{\RequirePackage{lc-biblio}}
\ExplSyntaxOff
\RequirePackage{lc-attribution}
\RequirePackage{lc-license}
