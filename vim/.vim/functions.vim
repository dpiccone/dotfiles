let v:errors = []

let s:tokens = {}
let s:tokens.IMPORT = 'import'
let s:tokens.FROM ='from'

function! s:tokenize(line)
  return split(a:line, '\s\+')
endfunction

call assert_equal(s:tokenize('foo bar  baz foo'), ['foo', 'bar', 'baz', 'foo'])
call assert_equal(s:tokenize('   foo bar  baz foo'), ['foo', 'bar', 'baz', 'foo'])

function! s:isRelativeModule(module)
  if a:module =~ '^\.\/\.*'
    return v:true
  else
    return v:false
  endif
endfunction

call assert_equal(s:isRelativeModule('./foo.bar'), v:true)
call assert_equal(s:isRelativeModule('foo.bar'), v:false)

function! s:stripQuotes(x)
  return substitute(a:x, "[\'\"]", '', 'g')
endfunction

call assert_equal(s:stripQuotes('"foo"'), 'foo')
call assert_equal(s:stripQuotes("'foo'"), 'foo')

function! s:getLinePriority(line)
  let tokens = s:tokenize(a:line)
  if tokens[0] != s:tokens.IMPORT
    return 0
  endif

  if index(tokens, s:tokens.FROM) == -1
    return 1
  endif

  let moduleToImport = s:stripQuotes(tokens[-1])

  if s:isRelativeModule(moduleToImport) == v:true
    return 5
  endif

  return 9
endfunction

call assert_equal(s:getLinePriority('foo bar'), 0)
call assert_equal(s:getLinePriority('import x from "x"'), 9)
call assert_equal(s:getLinePriority('import x from "./x"'), 5)
call assert_equal(s:getLinePriority('import "./x"'), 1)

" ==============================================================================
" Main
" ==============================================================================

function! ReorderImports() range
  let lines = getline(a:firstline, a:lastline)
  let linesWithPriority = []

  for line in lines
    let priority = s:getLinePriority(line)
    call add(linesWithPriority, [priority, line])
  endfor

  echo linesWithPriority
endfunction


" ==============================================================================
" Test / Development
" ==============================================================================
if (len(v:errors) > 0)
  echo v:errors
endif

" ==============================================================================
" Initialize
" ==============================================================================

if exists('g:loaded_reorder_imports')
  finish
endif
let g:loaded_reorder_imports = 1
