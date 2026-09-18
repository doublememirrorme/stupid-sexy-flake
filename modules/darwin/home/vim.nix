{ config, pkgs, ... }:
let
  palette = import ./tinacious-palette.nix;
  stateDir = "${config.xdg.stateHome}/vim";
  # The tmux-theme script in appearance.nix drops the current variant here on
  # every light/dark flip. The FocusGained handler below reads it.
  appearanceFile = "${config.xdg.stateHome}/appearance";
  tsls = "${pkgs.typescript-language-server}/bin/typescript-language-server";
  eslintLs = "${pkgs.vscode-langservers-extracted}/bin/vscode-eslint-language-server";

  # One block of :hi commands per Tinacious variant, from the palette's text
  # table. Emitted twice into colors/tinacious.vim, once per branch.
  # No ctermfg or ctermbg anywhere: this scheme is for termguicolors, and
  # colour numbers would only bring back the washed out ANSI slots it exists
  # to get away from. The cterm= attributes are still set, since the terminal
  # draws bold, italic and undercurl from those.
  mkHighlights =
    variant:
    let
      t = variant.text;
    in
    ''
      " Body text. Normal keeps guibg=NONE so the terminal's own background
      " shows through. That way the ground flips the instant iTerm2 swaps its
      " light and dark colours, and a vim pane matches the shell pane next to it.
      hi Normal         guifg=${t.normal} guibg=NONE
      hi Comment        guifg=${t.comment} gui=italic cterm=italic
      hi Constant       guifg=${t.constant}
      hi Number         guifg=${t.constant}
      hi Boolean        guifg=${t.constant}
      hi Float          guifg=${t.constant}
      hi String         guifg=${t.string}
      hi Character      guifg=${t.string}
      " Identifier takes the type colour, not the function colour. vim's
      " bundled TypeScript syntax routes every type reference, type alias name
      " and type parameter through Identifier, so on the function colour an
      " interface and a function came out the same green. VS Code paints
      " entity.name.type and support.type in the blue, so this follows it.
      " Plain variables are unaffected, that syntax leaves them on
      " typescriptBlock, which has no highlight at all.
      hi Identifier     guifg=${t.type} gui=NONE cterm=NONE
      hi Function       guifg=${t.function}
      hi Statement      guifg=${t.statement} gui=NONE cterm=NONE
      hi Conditional    guifg=${t.statement}
      hi Repeat         guifg=${t.statement}
      hi Label          guifg=${t.statement}
      hi Keyword        guifg=${t.statement}
      hi Exception      guifg=${t.statement}
      " Tag defaults to Special, which would make JSX element names cyan.
      hi Tag            guifg=${t.statement}
      " Punctuation stays body text, the way the VS Code theme has it.
      hi Operator       guifg=${t.normal}
      hi Delimiter      guifg=${t.normal}
      " PreProc is where vim's bundled TypeScript syntax files park call
      " arguments and parameter names: typescriptCall, typescriptParamImpl,
      " typescriptFuncCallArg and typescriptArrowFuncArg all link here. So it
      " takes the parameter colour. Include, Define, Macro and PreCondit link
      " to PreProc by default and follow along.
      hi PreProc        guifg=${t.parameter} gui=italic cterm=italic
      hi Type           guifg=${t.type} gui=NONE cterm=NONE
      hi StorageClass   guifg=${t.type}
      hi Structure      guifg=${t.type}
      hi Typedef        guifg=${t.type}
      hi Special        guifg=${t.special}
      hi SpecialChar    guifg=${t.special}
      hi Debug          guifg=${t.special}
      hi SpecialComment guifg=${t.comment} gui=italic cterm=italic
      hi Underlined     guifg=${t.type} gui=underline cterm=underline
      hi Ignore         guifg=${t.lineNr}
      hi Error          guifg=${t.statement} guibg=NONE gui=bold cterm=bold
      hi Todo           guifg=${variant.background} guibg=${t.string} gui=bold cterm=bold

      " Chrome. Anything that is a badge with white text on it uses the same
      " pink the tmux bar, the yazi bars and the VS Code status bar use.
      hi LineNr          guifg=${t.lineNr} guibg=NONE
      hi LineNrAbove     guifg=${t.lineNr} guibg=NONE
      hi LineNrBelow     guifg=${t.lineNr} guibg=NONE
      hi CursorLineNr    guifg=${t.statement} guibg=${t.cursorLine} gui=bold cterm=bold
      hi CursorLine      guifg=NONE guibg=${t.cursorLine} gui=NONE cterm=NONE
      hi CursorColumn    guifg=NONE guibg=${t.cursorLine}
      hi ColorColumn     guifg=NONE guibg=${t.cursorLine}
      hi CursorLineSign  guifg=NONE guibg=${t.cursorLine}
      hi CursorLineFold  guifg=NONE guibg=${t.cursorLine}
      hi Visual          guifg=NONE guibg=${t.visual}
      hi VisualNOS       guifg=NONE guibg=${t.visual}
      hi Search          guifg=${palette.white} guibg=${palette.pink}
      hi IncSearch       guifg=${palette.white} guibg=${palette.pinkDeep}
      hi CurSearch       guifg=${palette.white} guibg=${palette.pinkDeep}
      hi MatchParen      guifg=${t.statement} guibg=${t.visual} gui=bold cterm=bold
      hi StatusLine      guifg=${palette.white} guibg=${palette.pink} gui=bold cterm=bold
      hi StatusLineNC    guifg=${t.normal} guibg=${t.pmenu} gui=NONE cterm=NONE
      hi VertSplit       guifg=${variant.border} guibg=NONE
      hi WinSeparator    guifg=${variant.border} guibg=NONE
      hi TabLine         guifg=${t.normal} guibg=${t.pmenu} gui=NONE cterm=NONE
      hi TabLineSel      guifg=${palette.white} guibg=${palette.pink} gui=bold cterm=bold
      hi TabLineFill     guifg=NONE guibg=${t.pmenu}
      hi Pmenu           guifg=${t.normal} guibg=${t.pmenu}
      hi PmenuSel        guifg=${t.normal} guibg=${t.pmenuSel} gui=bold cterm=bold
      " The kind and detail columns of the completion menu. They use
      " menuKind and menuExtra, not the body type and comment colours, because
      " the menu has its own ground. See tinacious-palette.nix for the numbers.
      hi PmenuKind       guifg=${t.menuKind} guibg=${t.pmenu}
      hi PmenuKindSel    guifg=${t.menuKind} guibg=${t.pmenuSel}
      hi PmenuExtra      guifg=${t.menuExtra} guibg=${t.pmenu}
      hi PmenuExtraSel   guifg=${t.menuExtra} guibg=${t.pmenuSel}
      hi PmenuSbar       guifg=NONE guibg=${t.pmenu}
      hi PmenuThumb      guifg=NONE guibg=${t.lineNr}
      hi WildMenu        guifg=${palette.white} guibg=${palette.pink} gui=bold cterm=bold
      hi QuickFixLine    guifg=NONE guibg=${t.pmenuSel}
      hi Folded          guifg=${t.comment} guibg=${t.cursorLine} gui=italic cterm=italic
      hi FoldColumn      guifg=${t.lineNr} guibg=NONE
      hi SignColumn      guifg=${t.lineNr} guibg=NONE
      hi NonText         guifg=${t.lineNr}
      hi EndOfBuffer     guifg=${t.lineNr}
      hi SpecialKey      guifg=${t.special}
      hi Conceal         guifg=${t.comment} guibg=NONE
      hi Directory       guifg=${t.type} gui=bold cterm=bold
      hi Title           guifg=${t.statement} gui=bold cterm=bold
      hi Question        guifg=${t.function}
      hi MoreMsg         guifg=${t.function}
      hi ModeMsg         guifg=${t.normal} gui=bold cterm=bold
      hi WarningMsg      guifg=${t.string} gui=bold cterm=bold
      hi ErrorMsg        guifg=${palette.white} guibg=${palette.pinkDeep} gui=bold cterm=bold
      hi Cursor          guifg=${variant.background} guibg=${palette.pink}

      " Diffs carry the meaning in the foreground. Four tinted backgrounds
      " would mean four more colours measured against two grounds, and the
      " plain fg version reads fine in both.
      hi DiffAdd    guifg=${t.function} guibg=NONE
      hi DiffDelete guifg=${t.statement} guibg=NONE
      hi DiffChange guifg=${t.type} guibg=NONE
      hi DiffText   guifg=${palette.white} guibg=${palette.pinkDeep} gui=bold cterm=bold

      hi SpellBad   guisp=${t.statement} gui=undercurl cterm=undercurl
      hi SpellCap   guisp=${t.type} gui=undercurl cterm=undercurl
      hi SpellRare  guisp=${t.constant} gui=undercurl cterm=undercurl
      hi SpellLocal guisp=${t.special} gui=undercurl cterm=undercurl

      " vim-lsp. The names come from the plugin source rather than a guess:
      " autoload/lsp/internal/diagnostics/{signs,highlights,virtual_text}.vim
      " and autoload/lsp/internal/{document_highlight,inlay_hints}.vim. Each
      " of those only installs its own link when the group does not exist yet,
      " so defining them here wins. Error takes the keyword pink, warning the
      " string amber, information the type blue and hint the comment grey, so
      " severity reads off the same four colours the code already uses.
      hi LspErrorText       guifg=${t.statement} guibg=NONE
      hi LspWarningText     guifg=${t.string} guibg=NONE
      hi LspInformationText guifg=${t.type} guibg=NONE
      hi LspHintText        guifg=${t.comment} guibg=NONE
      hi LspErrorHighlight       guisp=${t.statement} gui=undercurl cterm=undercurl
      hi LspWarningHighlight     guisp=${t.string} gui=undercurl cterm=undercurl
      hi LspInformationHighlight guisp=${t.type} gui=undercurl cterm=undercurl
      hi LspHintHighlight        guisp=${t.comment} gui=undercurl cterm=undercurl
      hi LspErrorVirtualText       guifg=${t.statement} gui=italic cterm=italic
      hi LspWarningVirtualText     guifg=${t.string} gui=italic cterm=italic
      hi LspInformationVirtualText guifg=${t.type} gui=italic cterm=italic
      hi LspHintVirtualText        guifg=${t.comment} gui=italic cterm=italic
      " The other occurrences of the symbol under the cursor.
      hi lspReference           guifg=NONE guibg=${t.visual}
      hi lspInlayHintsType      guifg=${t.comment} gui=italic cterm=italic
      hi lspInlayHintsParameter guifg=${t.comment} gui=italic cterm=italic

      " Three TypeScript groups that Identifier does not reach. Checked
      " against syntax/shared/typescriptcommon.vim rather than guessed:
      " typescriptInterfaceName links to Function there, so an interface name
      " came out in the function green; typescriptEnum, the region holding an
      " enum's name, links to nothing at all, so the name was body text; and
      " typescriptEnumKeyword links to Identifier, which would now paint the
      " `enum` keyword blue while `class` and `interface` stay pink.
      " These are plain links, not `hi def link`, so they survive the syntax
      " file loading later and are re-applied on every background flip.
      hi link typescriptInterfaceName Type
      hi link typescriptEnum          Type
      hi link typescriptEnumKeyword   Keyword
      " `using` is a declaration keyword like const and let, and those are on
      " Keyword. Left alone it would follow Identifier into the type blue.
      hi link typescriptUsing         Keyword
    '';
in
{
  # Vim itself is pkgs.vim from modules/shared/packages.nix; this only adds a
  # vimrc. programs.vim is not used: it installs a second vim (vim-full, a GTK
  # build on darwin without the Cocoa clipboard) into the per-user profile
  # ahead of the system one, and always adds vim-sensible.
  #
  # Vim 9.1.0327+ reads $XDG_CONFIG_HOME/vim/vimrc when neither ~/.vimrc nor
  # ~/.vim/vimrc exists, which is the case here.

  # vim-lsp goes into Vim's package path. With the XDG vimrc in use, packpath
  # starts with ~/.config/vim and does not contain ~/.vim, so this is the only
  # pack/*/start directory Vim scans. The symlink points at the store path
  # nixpkgs pins.
  xdg.configFile."vim/pack/nix/start/vim-lsp".source = pkgs.vimPlugins.vim-lsp;

  # A real colorscheme file, not a block of :hi lines in the vimrc. Vim asks
  # the terminal for its background colour with OSC 11 and the answer only
  # arrives after the vimrc has finished running, so :hi lines in the vimrc
  # would run once against the wrong variant and stay wrong. A file is
  # re-sourced by vim itself every time 'background' changes, as long as
  # g:colors_name is set and the scheme does not set 'background' itself.
  xdg.configFile."vim/colors/tinacious.vim".text = ''
    " Tinacious Design for vim, generated from modules/darwin/home/vim.nix.
    " Edit that, not this. The colours come from tinacious-palette.nix, the
    " same file iTerm2, tmux, yazi and lazygit read.
    "
    " Deliberately does not touch 'background'. Vim reloads a colorscheme when
    " 'background' changes, and a scheme that sets it would undo the reload.
    hi clear
    if exists('syntax_on')
      syntax reset
    endif
    let g:colors_name = 'tinacious'

    if &background ==# 'light'
    ${mkHighlights palette.light}
    else
    ${mkHighlights palette.dark}
    endif
  '';

  xdg.configFile."vim/vimrc".text = ''
    " Start from Vim's own defaults.vim, which is skipped once a vimrc exists.
    " It gives nocompatible, incsearch, scrolloff=5, ttimeoutlen=100, syntax on,
    " filetype plugin indent on and cursor position restore.
    unlet! skip_defaults_vim
    source $VIMRUNTIME/defaults.vim

    " Mouse. defaults.vim only gives mouse=nvi under tmux-256color, and SGR
    " reporting is not autodetected through tmux (its version reply is 84, and
    " the tmux terminfo has no XM). Plain xterm mode stops past column 223.
    set mouse=a
    set ttymouse=sgr

    " macOS clipboard: this build has +clipboard, so * is the pasteboard.
    if has('clipboard')
      set clipboard=unnamed
    endif

    " Ask the terminal for its background colour (OSC 11, which tmux answers
    " on iTerm2's behalf) so 'background' follows the Tinacious light or dark
    " profile.
    let &t_RB = "\<Esc>]11;?\<Esc>\\"

    " True colour, with the scheme in colors/tinacious.vim. This used to lean
    " on the terminal's own 16 ANSI slots instead, and that is what made light
    " mode unreadable: vim's built-in light scheme resolves Type, Constant,
    " Comment, PreProc and Identifier to ANSI slots 2, 1, 4, 5 and 6, and the
    " Tinacious light terminal palette paints those slots with colours picked
    " for a dark ground. Measured as text on #f8f8ff they run 1.85:1 to 3.21:1,
    " well under the 4.5:1 readability bar. The upstream light VS Code theme is
    " no better, 1.81:1 to 3.21:1, so the scheme carries its own darkened light
    " variant. Dark mode keeps the upstream colours, which measure 3.13 to 11.21.
    set termguicolors
    " tmux-256color's terminfo has no RGB, Tc, setrgbf or setrgbb, so with
    " termguicolors on and t_8f and t_8b empty vim emits no colour at all,
    " which is worse than the problem above. Today they get filled in by
    " vim's runtime XTGETTCAP probe of tmux, but that is a probe and it can
    " come back empty. Spelling them out removes the dependency.
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    colorscheme tinacious

    " Vim queries OSC 11 once at startup and never asks again, so a vim that
    " was already open keeps yesterday's variant after the appearance flips.
    " The tmux-theme script in appearance.nix, which dark-mode-notify runs on
    " every flip, leaves the current variant in this file, so re-read it
    " whenever the window gets the focus back.
    " tmux-256color has no entry for focus reporting, so t_fe and t_fd arrive
    " empty and the mode has to be turned on by hand. tmux has focus-events on
    " and passes 1004 through. This vim recognises the incoming ESC [ I and
    " ESC [ O on its own, the two key codes below are the pairing :help
    " xterm-focus-event prescribes and cost nothing.
    " The limit: a flip that happens while this vim already has the focus, a
    " scheduled switch at sunset say, is not noticed until the focus leaves
    " and comes back. iTerm2 repaints its own background at once, so until
    " then the ground is the new variant and the text is the old one. Clicking
    " away and back fixes it, and so does :e.
    let &t_fe = "\<Esc>[?1004h"
    let &t_fd = "\<Esc>[?1004l"
    execute "set <FocusGained>=\<Esc>[I"
    execute "set <FocusLost>=\<Esc>[O"

    function! s:SyncBackground() abort
      if !filereadable('${appearanceFile}')
        return
      endif
      let l:want = trim(get(readfile('${appearanceFile}', "", 1), 0, ""))
      " A half written or truncated file must not be able to wreck the colours.
      if l:want !~# '^\%(dark\|light\)$' || l:want ==# &background
        return
      endif
      " Setting this re-sources colors/tinacious.vim, which picks the branch.
      let &background = l:want
    endfunction
    augroup appearance_sync
      autocmd!
      autocmd FocusGained * call s:SyncBackground()
    augroup END

    set number
    " The vimrc shipped with the vim package caps this at 50 before we run.
    set history=1000
    set hlsearch ignorecase smartcase
    set expandtab shiftwidth=2 tabstop=2 softtabstop=2 autoindent
    set hidden
    set splitright splitbelow
    set wildmode=longest:full,full

    " Keep swap, backup, undo and viminfo out of the working tree. Vim only
    " writes into directories that exist; home-manager creates them below.
    set directory=${stateDir}/swap//
    set backupdir=${stateDir}/backup//
    set undodir=${stateDir}/undo
    set undofile
    set viminfofile=${stateDir}/viminfo
    " netrw otherwise drops its history next to this vimrc.
    let g:netrw_home = '${stateDir}'

    " TypeScript and Next.js through vim-lsp (pack/nix/start/vim-lsp above).
    " The servers are referenced by store path, so nothing lands on PATH. When
    " a path is missing, executable() is false, the server is never registered
    " and the User autocmds never fire, so this block is inert without errors.
    " The same holds when the plugin itself is missing.
    " Loading the client costs about 11ms at startup, so hold it back until a
    " web file is opened. lsp#enable() fires lsp_setup and then walks the
    " buffers already loaded, so the file that triggered it still attaches.
    let g:lsp_auto_enable = 0
    autocmd FileType typescript,typescriptreact,javascript,javascriptreact
          \ ++once call lsp#enable()

    let g:lsp_use_native_client = 1
    " Off: the plugin would otherwise take over foldmethod and add an A> sign
    " on every line with a code action.
    let g:lsp_fold_enabled = 0
    let g:lsp_document_code_action_signs_enabled = 0
    " Signs and virtual text are on by default; this adds the full message
    " for the cursor line in the command line and keeps virtual text on the
    " same line instead of a line below.
    let g:lsp_diagnostics_echo_cursor = 1
    let g:lsp_diagnostics_virtual_text_align = 'after'
    " vscode-eslint-language-server delivers diagnostics via pull.
    let g:lsp_diagnostics_pull_enabled = 1

    " Project root: the nearest directory holding any of these markers, with
    " more matches breaking ties. In a monorepo that is the package, not the
    " repo root. Vim's cwd plays no part, yazi can start vim anywhere.
    function! s:LspRoot() abort
      return lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(
            \ lsp#utils#get_buffer_path(), ['tsconfig.json', 'package.json', '.git/']))
    endfunction

    let s:web = ['typescript', 'typescriptreact', 'javascript', 'javascriptreact']

    " Uses the project's own node_modules/typescript when there is one
    " (walking up from the root, so hoisted workspace copies count) and falls
    " back to the TypeScript 5 nixpkgs patched in.
    if executable('${tsls}')
      autocmd User lsp_setup call lsp#register_server({
            \ 'name': 'typescript-language-server',
            \ 'cmd': ['${tsls}', '--stdio'],
            \ 'root_uri': {server_info -> s:LspRoot()},
            \ 'allowlist': s:web,
            \ })
    endif

    " The eslint server defaults validate to off and reads everything else
    " from workspace/configuration, so the settings have to be sent. It loads
    " the project's own eslint and config (flat or eslintrc, its choice).
    function! s:EslintConfig(server_info) abort
      let l:root = lsp#get_server_root_uri('eslint')
      return {
            \ 'validate': 'on',
            \ 'run': 'onType',
            \ 'nodePath': v:null,
            \ 'workingDirectory': {'mode': 'auto'},
            \ 'workspaceFolder': {'name': fnamemodify(lsp#utils#uri_to_path(l:root), ':t'), 'uri': l:root},
            \ 'problems': {'shortenToSingleLine': v:false},
            \ 'codeActionOnSave': {'enable': v:false, 'mode': 'all'},
            \ 'codeAction': {
            \   'disableRuleComment': {'enable': v:true, 'location': 'separateLine'},
            \   'showDocumentation': {'enable': v:true},
            \ },
            \ 'format': v:false,
            \ 'quiet': v:false,
            \ 'onIgnoredFiles': 'off',
            \ 'rulesCustomizations': [],
            \ }
    endfunction

    if executable('${eslintLs}')
      autocmd User lsp_setup call lsp#register_server({
            \ 'name': 'eslint',
            \ 'cmd': ['${eslintLs}', '--stdio'],
            \ 'root_uri': {server_info -> s:LspRoot()},
            \ 'allowlist': s:web,
            \ 'workspace_config': function('s:EslintConfig'),
            \ })
    endif

    " Mouse hover tooltips, the VS Code habit. 'balloonexpr' has to answer on
    " the spot, and an LSP round trip is not on the spot, so the expression
    " fires the request and returns nothing. The reply calls balloon_show()
    " when it lands, which is allowed from a channel callback.
    let s:balloon_seq = 0

    " MarkupContent.normalize defaults to compact, which folds a whole code
    " fence onto one line: "```typescript (alias) interface Foo ```". Dropping
    " lines that start with ``` would then throw the signature away with the
    " fence. Off, the fence keeps its own line and the signature keeps its own.
    let s:markup_opts = {'compact': v:false}

    " Lazily imported: touching vital at vimrc time would pull the whole
    " plugin in and undo the 11ms the deferred lsp#enable() buys. Nothing
    " calls this before a server has replied, so the plugin is loaded by then.
    function! s:MarkupContent() abort
      if !exists('s:markup_content')
        let s:markup_content = vital#lsp#import('VS.LSP.MarkupContent')
      endif
      return s:markup_content
    endfunction

    " Mirrors vim-lsp's own s:get_contents in
    " autoload/lsp/internal/document_hover/under_cursor.vim. Handing the raw
    " contents to MarkupContent.normalize instead would throw on a list of
    " dicts, which is the MarkedString[] shape servers are still allowed to
    " send, and tsserver does.
    function! s:HoverText(contents) abort
      if type(a:contents) == v:t_string
        return a:contents
      elseif type(a:contents) == v:t_list
        let l:parts = map(copy(a:contents), {i, part -> s:HoverText(part)})
        return join(filter(l:parts, {i, part -> !empty(part)}), "\n\n")
      elseif type(a:contents) == v:t_dict && has_key(a:contents, 'value')
        if get(a:contents, 'kind', "") ==? 'markdown'
          return s:MarkupContent().normalize(a:contents['value'], s:markup_opts)
        elseif has_key(a:contents, 'language')
          return s:MarkupContent().normalize(a:contents, s:markup_opts)
        endif
        return a:contents['value']
      endif
      return ""
    endfunction

    function! s:BalloonReply(seq, data) abort
      " The pointer moved on while the server was thinking, so this answer is
      " about somewhere else now.
      if a:seq != s:balloon_seq
        return
      endif
      let l:response = get(a:data, 'response', {})
      if lsp#client#is_error(l:response)
        return
      endif
      let l:result = get(l:response, 'result', v:null)
      if type(l:result) != v:t_dict
        return
      endif
      let l:lines = split(s:HoverText(get(l:result, 'contents', "")), "\n", 1)
      " Fences are pure noise with no syntax highlighting behind them.
      call filter(l:lines, {i, line -> line !~# '^```'})
      while !empty(l:lines) && empty(trim(l:lines[0]))
        call remove(l:lines, 0)
      endwhile
      if empty(l:lines)
        return
      endif
      " tsserver will happily hand back a page of jsdoc. A balloon is not a pager.
      call balloon_show(l:lines[:19])
    endfunction

    function! s:BalloonExpr() abort
      " First thing, before any early return. Every evaluation means the
      " pointer moved somewhere new, so any reply still in flight is now about
      " the wrong place and has to be dropped. Bumping this after a return
      " would leave the old reply matching and painting a stale tooltip.
      let s:balloon_seq += 1
      " What vim puts in v:beval_text is the word under or after the pointer,
      " so it scans forward, and this only comes back empty on a blank line or
      " in the trailing whitespace past the last word.
      if empty(trim(v:beval_text))
        return ""
      endif
      let l:servers = filter(lsp#get_allowed_servers(v:beval_bufnr),
            \ {i, name -> lsp#capabilities#has_hover_provider(name)
            \             && lsp#get_server_status(name) ==# 'running'})
      if empty(l:servers)
        return ""
      endif
      " Vim hands over a 1 based line in v:beval_lnum and a 1 based byte
      " column in v:beval_col, which is exactly what vim_to_lsp takes.
      " Converting to UTF-16 by hand would disagree with K and with the
      " diagnostics, since the plugin counts code points everywhere.
      " The bufnr key never reaches the wire, lsp#client#send_request copies
      " only method and params. It tells lsp#request which buffer to sync to
      " the server before asking, and left out it defaults to bufnr('%').
      " The pointer can sit over a window that is not the current one, and
      " then the URI names the hovered buffer while the didChange flushes the
      " current one. Measured: hover a call site in a split whose function was
      " edited but not written, and without this key the answer comes back
      " from the text on disk. With it the answer matches the buffer.
      call lsp#send_request(l:servers[0], {
            \ 'method': 'textDocument/hover',
            \ 'bufnr': v:beval_bufnr,
            \ 'params': {
            \   'textDocument': lsp#get_text_document_identifier(v:beval_bufnr),
            \   'position': lsp#utils#position#vim_to_lsp(v:beval_bufnr,
            \                 [v:beval_lnum, v:beval_col]),
            \ },
            \ 'on_notification': function('s:BalloonReply', [s:balloon_seq]),
            \ })
      return ""
    endfunction

    " Only in buffers a server attached to, so other files keep the plain
    " gutter and the default completion feel. Completion stays manual
    " (<C-x><C-o>); `set autocomplete` plus `set complete+=o` would make it
    " automatic with no extra plugin.
    function! s:OnLspBufferEnabled() abort
      setlocal omnifunc=lsp#complete
      setlocal completeopt=menuone,noinsert,noselect,popup
      setlocal signcolumn=yes
      nmap <buffer> gd <plug>(lsp-definition)
      nmap <buffer> gr <plug>(lsp-references)
      nmap <buffer> gi <plug>(lsp-implementation)
      nmap <buffer> gy <plug>(lsp-type-definition)
      nmap <buffer> K <plug>(lsp-hover)
      nmap <buffer> <leader>rn <plug>(lsp-rename)
      nmap <buffer> <leader>ca <plug>(lsp-code-action-float)
      nmap <buffer> ]d <plug>(lsp-next-diagnostic)
      nmap <buffer> [d <plug>(lsp-previous-diagnostic)

      " Hover tooltips. 'balloonexpr' is global-local, so setlocal leaves the
      " global one empty and a plain text buffer evaluates nothing at all.
      " 'balloonevalterm' and 'balloondelay' are global only, which is why
      " they wait here until a server has actually attached to something.
      " <SID> does get expanded in a :setlocal, it comes out as <SNR>nn_.
      " Any-motion mouse tracking comes on with balloonevalterm, one extra
      " \e[?1003h. Drag selection is unaffected.
      " This is one way: the two global options are never turned back off, so
      " after the first TypeScript file every later buffer in the session
      " keeps any-motion tracking on. Those buffers have no local balloonexpr
      " and vim does not evaluate an empty one, so nothing is shown and
      " nothing is asked of a server. The only cost is one mouse report per
      " pointer move through tmux, which is not worth the bookkeeping to undo.
      if has('balloon_eval_term')
        setlocal balloonexpr=<SID>BalloonExpr()
        set balloonevalterm
        set balloondelay=500
      endif

      " Jump to the definition on ctrl+click. Three layers had to let it
      " through: iTerm2 (PassOnControlClick in iterm2.nix), tmux (the
      " C-MouseDown1Pane binding in tmux.nix) and now vim.
      " <LeftMouse> runs first so the cursor lands where the pointer is, then
      " the definition request goes out. Both ways back work: vim-lsp calls
      " lsp#utils#tagstack#_update() before it opens the location, so CTRL-T
      " returns, and the open itself runs `normal! m'`, so CTRL-O does too.
      " Not `setlocal tagfunc=lsp#tagfunc`, which would be the tidier route.
      " Inside it, lsp#tag#tagfunc waits on the server by calling
      " lsp#utils#_wait(-1, ..., 50).
      " This vim has no wait(), that one is Neovim's, so _wait falls to its
      " polyfill: a `sleep 50m` loop whose guard is `l:timeout < 0 || ...`,
      " which a negative timeout makes true forever. A wedged or slow tsserver
      " would hang vim on every ctrl+click and every CTRL-]. CTRL-C does break
      " out, the polyfill catches Vim:Interrupt, so it is an interruptible
      " hang rather than a lockup, but it is still the wrong feel for a click.
      " So CTRL-] keeps plain tags and the mouse gets the async command.
      nnoremap <buffer> <C-LeftMouse> <LeftMouse><Cmd>LspDefinition<CR>
    endfunction
    augroup lsp_install
      autocmd!
      autocmd User lsp_buffer_enabled call s:OnLspBufferEnabled()
    augroup END

    " Format on demand with the project's prettier, never on save (VS Code has
    " formatOnSave off). Runs from the file's directory so npx finds the
    " project's copy whatever vim's cwd is. Saves first, then reloads. update
    " runs before the rest, so a modified buffer is never discarded.
    function! s:Prettier() abort
      update
      let l:out = system('cd ' . shellescape(expand('%:p:h'))
            \ . ' && npx --no-install prettier --write ' . shellescape(expand('%:p')))
      if v:shell_error
        echohl ErrorMsg | echomsg 'prettier: ' . trim(l:out) | echohl None
        return
      endif
      edit
    endfunction
    command! Prettier call s:Prettier()
  '';

  xdg.stateFile = {
    "vim/swap/.keep".text = "";
    "vim/backup/.keep".text = "";
    "vim/undo/.keep".text = "";
  };
}
