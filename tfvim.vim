" helper
function! s:charToCol()
  if strlen(s:charCol()) ==# 3
    return getline('.')[0 : col('.')+1]
  else
    return getline('.')[0 : col('.')-1]
  endif
endfunction

function! s:charCol()
  return matchstr(getline('.'), '.', col('.')-1)
endfunction

function! s:lineChar()
  return getline('.')[0 : len(getline('.'))]
endfunction

function! s:reverseString(str)
  return join(reverse(split(a:str, '\zs')), '')
endfunction

" TerraformJumpDefinition
function! s:TerraformJumpDefinition()
  let file = expand("%:p")
  let dir = expand("%:p:h")
  let c = s:charToCol()
  let cs = split(c, '\zs')
  let l = s:lineChar()
  let cl = len(cs)
  let cw = ''

  let cr = s:reverseString(c)
  let r = '\v^([a-z]|[A-Z]|[1-9]|_|-|\.)+'
  let m = matchstr(cr, r)
  if m !=# ''
    let cw .= s:reverseString(m)
  else
    echo 'No match before'
    return
  endif

  let r = '\v(^.{' . cl . '})@<=(([a-z]|[A-Z]|[1-9]|_|-|\.)+)'
  let m = matchstr(l, r)
  if m !=# ''
    let cw .= m
  else
    echo 'No match behind'
    return
  endif

  let cws = split(cw, '\.')

  if len(cws) < 2
    echo '. less than 1, ' . cw
    return
  endif

  let grepCmd = ''

  if executable('rg')
    let grepCmd .= 'rg --line-number' " Use ripgrep
  else
    if stridx(system("grep --version"), "BSD") ==# "-1"
      let grepCmd .= 'grep -onP' " Use GNU grep option
    else
      let grepCmd .= 'grep -onE' " Use BSD grep option
    endif
  endif

  if cws[0] ==# "var"
    let grepCmd .= printf(" '^variable\\s+\"%s\"'", cws[1])
  elseif cws[0] ==# "data"
    if len(cws) < 3
      let grepCmd .= printf(" '^data\\s+\"%s\"'", cws[1])
    else
      let grepCmd .= printf(" '^data\\s+\"%s\"\\s+\"%s\"'", cws[1], cws[2])
    endif
  elseif cws[0] ==# "module"
    let grepCmd .= printf(" '^module\\s+\"%s\"'", cws[1])
  elseif cws[0] ==# "local"
    echo "local is not supported"
  else
    let grepCmd .= printf(" '^resource\\s+\"%s\"\\s+\"%s\"'", cws[0], cws[1])
  endif

  let grepRes = ''
  let f = ''
  for m in split(system('ls *.tf ' . dir), '\n')
    let grepRes = system(grepCmd . ' ' . m)
    if grepRes !=# ''
      let matchFile = m
      break
    endif
  endfor

  echo grepCmd

  let rs = split(grepRes, ':')  " [line_number, match]

  if grepRes ==# '' || len(rs) < 2 || rs[0] !~# '^\d\+$'
    echo 'Not defined, ' . cw
    return
  endif

  execute 'e +' . rs[0] . ' ' . matchFile
endfunction

command! TerraformJumpDefinition call <SID>TerraformJumpDefinition()

" TerraformReferences
function! s:TerraformReferences()
  let l = s:lineChar()
  let dir = expand("%:p:h")
  let m = ''

  if matchstr(l, '^resource') !=# ''
  elseif matchstr(l, '^data') !=# ''
    let m .= 'data.'
  elseif matchstr(l, '^module') !=# ''
    let m .= 'module.'
  elseif matchstr(l, '^variable') !=# ''
    let m .= 'var.'
  else
    echo "Not supported type"
    return
  endif

  let m .= substitute(substitute(matchstr(l, '\v".*"'), '"', '', 'g'), '\v\s+', '.', 'g')
  if m !=# ''
    let m = system("rg -n '" . m . "' " . dir)
    if m !=# ''
      execute 'lcd' dir
      cexpr m | copen
    else
      echo "No references '" . m . "'"
    endif
  else
    echo 'Failed parse'
  endif
endfunction

command! TerraformReferences call <SID>TerraformReferences()

" tfref
function! s:tfref()
  if executable('tfref')
    let cursorline=line('.')
    let absolutePath=expand('%:p')
    let cmd = "!tfref -f \"" . absolutePath . "\" " . cursorline
    execute cmd
  else
    echo 'Install tfref command, https://github.com/kis9a/tfref'
  endif
endfunction

command! TFRef call <SID>tfref()
