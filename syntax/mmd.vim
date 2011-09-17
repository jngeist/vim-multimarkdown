" Vim syntax file
" Language:	Multimarkdown
" Maintainer:	Josh Geist
" URL:		http://www.jnicholasgeist.com
" Version:	0.1
" Last Change:  2011 July 05
" Remark:	Derived from Ben Williams's Markdown plugin for vim 
"               (http://plasticboy.com/markdown-vim-mode/)
" Remark:	Uses HTML syntax file
" Remark:	I don't do anything with angle brackets (<>) because that would too easily
"		easily conflict with HTML syntax
" TODO: 	Handle stuff contained within stuff (e.g. headings within blockquotes)


" Read the HTML syntax to start with
if version < 600
  so <sfile>:p:h/html.vim
else
  runtime! syntax/html.vim
  unlet b:current_syntax
endif

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" don't use standard HiLink, it will not work with included syntax files
if version < 508
  command! -nargs=+ HtmlHiLink hi link <args>
else
  command! -nargs=+ HtmlHiLink hi def link <args>
endif

syn spell toplevel
syn case ignore
syn sync linebreaks=1

"additions to HTML groups
syn region htmlBold     start=/\\\@<!\(^\|\A\)\@=\*\@<!\*\*\*\@!/     end=/\\\@<!\*\@<!\*\*\*\@!\($\|\A\)\@=/   contains=@Spell,htmlItalic
syn region htmlItalic   start=/\\\@<!\(^\|\A\)\@=\*\@<!\*\*\@!/       end=/\\\@<!\*\@<!\*\*\@!\($\|\A\)\@=/      contains=htmlBold,@Spell
syn region htmlBold     start=/\\\@<!\(^\|\A\)\@=_\@<!___\@!/         end=/\\\@<!_\@<!___\@!\($\|\A\)\@=/       contains=htmlItalic,@Spell
syn region htmlItalic   start=/\\\@<!\(^\|\A\)\@=_\@<!__\@!/          end=/\\\@<!_\@<!__\@!\($\|\A\)\@=/        contains=htmlBold,@Spell

syn match mkdTableCaption     "|\n\zs\[[^]]*\]$"
syn match mkdTableCaption     "^\[[^]]*\]\ze\n|"

syn region mkdMetadata start=/\%^.*:.*$/ end=/^$/ contains=mkdMetadataKey,mkdMetadataText fold
syn match mkdMetadataKey /^[^:]*\ze:/ contained
syn match mkdMetadataText /:.*/ contained

" [link](URL) | [link][id] | [link][]
syn region mkdLink matchgroup=mkdDelimiter      start="\!\?\[\ze[^]]*\][[(]" end="\]\ze\s*[([]" contains=@Spell nextgroup=mkdURL,mkdID skipwhite
syn region mkdID matchgroup=mkdDelimiter        start="\["    end="\]" contained
syn region mkdURL matchgroup=mkdDelimiter       start="("     end=")"  contained
" mkd  inline links:           protocol   optional  user:pass@       sub/domain                 .com, .co.uk, etc      optional port   path/querystring/hash fragment
"                            ------------ _____________________ --------------------------- ________________________ ----------------- __
"syntax match   mkdInlineURL /https\?:\/\/\(\w\+\(:\w\+\)\?@\)\?\([A-Za-z][-_0-9A-Za-z]*\.\)\{1,}\(\w\{2,}\.\?\)\{1,}\(:[0-9]\{1,5}\)\?\S*/

"define Multimarkdown variants
syn match  mmdFootnoteMarker  "\[^\S\+\]"
syn match  mmdFootnoteIdentifier  "\[^.\+\]:" contained
syn region mmdFootnoteText  start="^\s\{0,3\}\[^.\+\]:[ \t]" end="^$" contains=mmdFootnoteIdentifier

" Link definitions: [id]: URL (Optional Title)
" TODO handle automatic links without colliding with htmlTag (<URL>)
"syn region mkdLinkDef matchgroup=mkdDelimiter   start="^ \{,3}\zs\[[^^#]" end="]:" oneline nextgroup=mkdLinkDefTarget skipwhite
"syn region mkdLinkDefTarget start="<\?\zs\S" excludenl end="\ze[>[:space:]\n]"   contained nextgroup=mkdLinkTitle,mkdLinkDef skipwhite skipnl oneline
"syn region mkdLinkTitle matchgroup=mkdDelimiter start=+"+     end=+"+  contained
"syn region mkdLinkTitle matchgroup=mkdDelimiter start=+'+     end=+'+  contained
"syn region mkdLinkTitle matchgroup=mkdDelimiter start=+(+     end=+)+  contained

syn region mkdReference start=/^\[[^]]*\]:/ end=/^$/ contains=mkdLinkDef,mkdLinkDefTarget,mkdLinkTitle,mkdLinkAttrib,mkdSourceDef,mkdSource,mmdFootnoteIdentifier,mmdFootnoteText  
syn match  mkdLinkDef   /^\[[^^#]\S\+\]:/ nextgroup=mkdLinkDefTarget contained
syn match  mkdLinkDefTarget /\s*\S\+:\S\+/   nextgroup=mkdLinkTitle contained
syn match  mkdLinkTitle /"[^"]*"/ nextgroup=mkdLinkAttrib contained
syn match  mkdLinkTitle /'[^']*'/ nextgroup=mkdLinkAttrib contained
syn match  mkdLinkTitle /([^)]*)/ nextgroup=mkdLinkAttrib contained
syn match  mkdLinkAttrib /\S\+=\S\+/ contained

syn match  mkdSourceDef   /^\[#\S\+\]:/ nextgroup=mkdSource
syn region mkdSource  start="^\s\{0,3\}\[#\S\+\]:\s\?" end="^$"

"define Markdown groups
syn match  mkdLineContinue ".$" contained
syn match  mkdRule      /^\s*\*\s\{0,1}\*\s\{0,1}\*$/
syn match  mkdRule      /^\s*-\s\{0,1}-\s\{0,1}-$/
syn match  mkdRule      /^\s*_\s\{0,1}_\s\{0,1}_$/
syn match  mkdRule      /^\s*-\{3,}$/
syn match  mkdRule      /^\s*\*\{3,5}$/
syn match  mkdListItem  "^\s*[-*+]\s\+"
syn match  mkdListItem  "^\s*\d\+\.\s\+"
syn match  mkdCode      /^\s*\n\(\(\s\{4,}[^ ]\|\t\+[^\t]\).*\n\)\+/
syn match  mkdLineBreak /  \+$/
syn region mkdCode      start=/\\\@<!`/                   end=/\\\@<!`/
syn region mkdCode      start=/\s*``[^`]*/          end=/[^`]*``\s*/
syn region mkdBlockquote start=/^\s*>/              end=/$/                 contains=mkdLineBreak,mkdLineContinue,@Spell
syn region mkdCode      start="<pre[^>]*>"         end="</pre>"
syn region mkdCode      start="<code[^>]*>"        end="</code>"

"HTML headings
syn region htmlH1       start="^\s*#"                   end="\($\|#\+\)" contains=@Spell
syn region htmlH2       start="^\s*##"                  end="\($\|#\+\)" contains=@Spell
syn region htmlH3       start="^\s*###"                 end="\($\|#\+\)" contains=@Spell
syn region htmlH4       start="^\s*####"                end="\($\|#\+\)" contains=@Spell
syn region htmlH5       start="^\s*#####"               end="\($\|#\+\)" contains=@Spell
syn region htmlH6       start="^\s*######"              end="\($\|#\+\)" contains=@Spell
syn match  htmlH1       /^.\+\n=\+$/ contains=@Spell
syn match  htmlH2       /^.\+\n-\+$/ contains=@Spell



" fold region for headings
syn region mkdHeaderFold
    \ start="^\s*\z(#\+\)"
    \ skip="^\s*\z1#\+"
    \ end="^\(\s*#\)\@="
    \ fold contains=TOP

" fold region for references
syn region mkdReferenceFold
    \ start="^<!--\z(\S*\)-->"
    \ end="^<!--END\z1-->"
    \ fold contains=TOP

" fold region for lists
syn region mkdListFold
    \ start="^\z(\s*\)\*\z(\s*\)"
    \ skip="^\z1 \z2\s*[^#]"
    \ end="^\(.\)\@="
    \ fold contains=TOP


syn sync fromstart
setlocal foldmethod=syntax



"highlighting for Markdown groups
HtmlHiLink mkdString	    String
HtmlHiLink mkdCode          String
HtmlHiLink mkdBlockquote    Comment
HtmlHiLink mkdLineContinue  Comment
HtmlHiLink mkdListItem      Identifier
HtmlHiLink mkdRule          Identifier
HtmlHiLink mkdLineBreak     Todo
HtmlHiLink mkdLink          htmlLink
HtmlHiLink mkdURL           htmlString
HtmlHiLink mkdInlineURL     htmlLink
HtmlHiLink mkdID            Identifier
HtmlHiLink mkdLinkDef       mkdID
HtmlHiLink mkdLinkDefTarget mkdURL
HtmlHiLink mkdLinkTitle     htmlString
HtmlHiLink mmdFootnoteMarker    Constant
HtmlHiLink mmdFootnoteIdentifier    Constant
HtmlHiLink mmdFootnoteText     String

HtmlHiLink mkdMetadataKey   Function
HtmlHiLink mkdTableCaption  String
HtmlHiLink mkdSourceDef     Statement
HtmlHiLink mkdSource        String
HtmlHiLink mkdLinkAttrib    Function

HtmlHiLink mkdDelimiter     Delimiter

let b:current_syntax = "mmd"

delcommand HtmlHiLink
" vim: ts=8
