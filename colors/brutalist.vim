highlight clear
if exists("syntax_on")
	syntax reset
endif
let g:colors_name="brutalist"

if &background ==# "dark"
  let s:guifg="#fffff8"
  let s:ctermfg="231"
  let s:guifg_dim="#a7a7a7"
  let s:ctermfg_dim="248"
  let s:guifg_slight_dim="#4c4c4c"
  let s:ctermfg_slight_dim="239"
  let s:ctermfg_light="235"

  let s:guibg="#111111"
  let s:ctermbg="233"
  let s:guibg_highlight="#333300"
  let s:ctermbg_highlight="58"
  let s:guibg_highlight_3="#6f116f"
  let s:ctermbg_highlight_3="53"
  let s:guibg_light="#222227"
  let s:ctermbg_light="235"

  let s:guifg_string="#ffff00"
  let s:ctermfg_string="226"
  let s:guifg_cursor="#111111"
  let s:ctermfg_cursor="233"
  let s:guibg_cursor="#ffff00"
  let s:ctermbg_cursor="226"
  let s:guibg_cursorline="#2a2a00"
  let s:ctermbg_cursorline="236"
  let s:guifg_paren_match="#ffff00"
  let s:ctermfg_paren_match="226"

  let s:guibg_powerline_active="#c7c7c7"
  let s:ctermbg_powerline_active="251"
  let s:guibg_powerline_inactive="#999999"
  let s:ctermbg_powerline_inactive="247"
else
  let s:guifg="#111111"
  let s:ctermfg="233"
  let s:guifg_dim="#585858"
  let s:ctermfg_dim="240"
  let s:guifg_slight_dim="#b3b3b3"
  let s:ctermfg_slight_dim="249"
  let s:ctermfg_light="253"

  let s:guibg="#fffff8"
  let s:ctermbg="194"
  let s:guibg_highlight="#fff1aa"
  let s:ctermbg_highlight="229"
  let s:guibg_highlight_3="#90ee90"
  let s:ctermbg_highlight_3="120"
  let s:guibg_light="#ddddd8"
  let s:ctermbg_light="253"

  let s:guifg_string="#0000ff"
  let s:ctermfg_string="21"
  let s:guifg_cursor="#fffff8"
  let s:ctermfg_cursor="231"
  let s:guibg_cursor="#0000ff"
  let s:ctermbg_cursor="21"
  let s:guibg_cursorline="#e8e8ff"
  let s:ctermbg_cursorline="189"
  let s:guifg_paren_match="#0000ff"
  let s:ctermfg_paren_match="12"

  let s:guibg_powerline_active="#383838"
  let s:ctermbg_powerline_active="237"
  let s:guibg_powerline_inactive="#666666"
  let s:ctermbg_powerline_inactive="241"
endif

exec 'highlight Normal guifg=' . s:guifg . ' ctermfg=' . s:ctermfg . ' guibg=' . s:guibg . ' ctermbg=' . s:ctermbg . ' gui=NONE cterm=NONE'
exec 'highlight Special guifg=' . s:guifg . ' ctermfg=' . s:ctermfg . ' guibg=' . s:guibg . ' ctermbg=' . s:ctermbg . ' gui=NONE cterm=NONE'
exec 'highlight Tag guifg=' . s:guifg . ' ctermfg=' . s:ctermfg . ' guibg=' . s:guibg . ' ctermbg=' . s:ctermbg . ' gui=NONE cterm=NONE'
exec 'highlight Underlined guifg=' . s:guifg . ' ctermfg=' . s:ctermfg . ' guibg=' . s:guibg . ' ctermbg=' . s:ctermbg . ' gui=underline cterm=NONE'
exec 'highlight Comment guifg=' . s:guifg_dim . ' ctermfg=' . s:ctermfg_dim . ' guibg=' . s:guibg . ' ctermbg=' . s:ctermbg . ' gui=italic cterm=NONE'
exec 'highlight Statement guifg=' . s:guifg . ' ctermfg=' . s:ctermfg . ' guibg=' . s:guibg . ' ctermbg=' . s:ctermbg . ' gui=bold cterm=bold'
exec 'highlight SpellBad guifg=' . s:guifg . ' ctermfg=' . s:ctermfg . ' guibg=' . s:guibg . ' ctermbg=' . s:ctermbg . ' gui=bold cterm=bold'
exec 'highlight PreProc guifg=' . s:guifg . ' ctermfg=' . s:ctermfg . ' guibg=' . s:guibg . ' ctermbg=' . s:ctermbg . ' gui=NONE cterm=NONE'
exec 'highlight Include guifg=' . s:guifg . ' ctermfg=' . s:ctermfg . ' guibg=' . s:guibg . ' ctermbg=' . s:ctermbg . ' gui=italic cterm=NONE'
exec 'highlight Define guifg=' . s:guifg . ' ctermfg=' . s:ctermfg . ' guibg=' . s:guibg . ' ctermbg=' . s:ctermbg . ' gui=italic cterm=NONE'
exec 'highlight Macro guifg=' . s:guifg . ' ctermfg=' . s:ctermfg . ' guibg=' . s:guibg . ' ctermbg=' . s:ctermbg . ' gui=italic cterm=NONE'
exec 'highlight PreCondit guifg=' . s:guifg . ' ctermfg=' . s:ctermfg . ' guibg=' . s:guibg . ' ctermbg=' . s:ctermbg . ' gui=italic cterm=NONE'
exec 'highlight Type guifg=' . s:guifg . ' ctermfg=' . s:ctermfg . ' guibg=' . s:guibg . ' ctermbg=' . s:ctermbg . ' gui=NONE cterm=NONE'
exec 'highlight rustSigil guifg=' . s:guifg . ' ctermfg=' . s:ctermfg . ' guibg=' . s:guibg . ' ctermbg=' . s:ctermbg . ' gui=NONE cterm=NONE'
exec 'highlight Identifier guifg=' . s:guifg . ' ctermfg=' . s:ctermfg . ' guibg=' . s:guibg . ' ctermbg=' . s:ctermbg . ' gui=NONE cterm=NONE'
exec 'highlight Function guifg=' . s:guifg . ' ctermfg=' . s:ctermfg . ' guibg=' . s:guibg . ' ctermbg=' . s:ctermbg . ' gui=NONE cterm=NONE'
exec 'highlight Constant guifg=' . s:guifg . ' ctermfg=' . s:ctermfg . ' guibg=' . s:guibg . ' ctermbg=' . s:ctermbg . ' gui=NONE cterm=NONE'
exec 'highlight String guifg=' . s:guifg_string . ' ctermfg=' . s:ctermfg_string . ' guibg=' . s:guibg . ' ctermbg=' . s:ctermbg . ' gui=NONE cterm=NONE'
exec 'highlight LineNr guifg=' . s:guifg . ' ctermfg=' . s:ctermfg . ' guibg=' . s:guibg . ' ctermbg=' . s:ctermbg . ' gui=bold cterm=bold'
exec 'highlight Cursor guifg=' . s:guifg_cursor . ' ctermfg=' . s:ctermfg_cursor . ' guibg=' . s:guibg_cursor . ' ctermbg=' . s:ctermbg_cursor . ' gui=NONE cterm=NONE'
exec 'highlight CursorLine guibg=' . s:guibg_cursorline . ' ctermbg=' . s:ctermbg_cursorline . ' gui=NONE cterm=NONE'
exec 'highlight CursorLineNr guifg=' . s:guifg . ' ctermfg=' . s:ctermfg . ' guibg=' . s:guibg_cursorline . ' ctermbg=' . s:ctermbg_cursorline . ' gui=bold cterm=bold'
exec 'highlight Paren guifg=' . s:guifg_slight_dim . ' ctermfg=' . s:ctermfg_slight_dim . ' gui=NONE cterm=NONE'
exec 'highlight MatchParen guibg=' . s:guifg_paren_match . ' ctermbg=' . s:ctermfg_paren_match . ' gui=bold cterm=bold'
exec 'highlight IncSearch guifg=' . s:guifg . ' ctermfg=' . s:ctermfg . ' guibg=' . s:guibg_highlight_3 . ' ctermbg=' . s:ctermbg_highlight_3 . ' gui=italic cterm=NONE'
exec 'highlight Search guifg=' . s:guifg . ' ctermfg=' . s:ctermfg . ' guibg=' . s:guibg_highlight_3 . ' ctermbg=' . s:ctermbg_highlight_3 . ' gui=italic cterm=NONE'
exec 'highlight Visual guifg=' . s:guifg . ' ctermfg=' . s:ctermfg . ' guibg=' . s:guibg_highlight . ' ctermbg=' . s:ctermbg_highlight . ' gui=NONE cterm=NONE'
exec 'highlight StatusLine guibg=' . s:guibg_light . ' ctermbg=' . s:ctermbg_light . ' guifg=' . s:guifg . ' ctermfg=' . s:ctermfg . ' gui=bold cterm=bold'
exec 'highlight StatusLineNC guibg=' . s:guibg_light . ' ctermbg=' . s:ctermbg_light . ' guifg=' . s:guifg_slight_dim . ' ctermfg=' . s:ctermfg_light . ' gui=NONE cterm=NONE'
