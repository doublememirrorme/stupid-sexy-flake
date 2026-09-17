{ config, pkgs, ... }:
let
  stateDir = "${config.xdg.stateHome}/vim";
  tsls = "${pkgs.typescript-language-server}/bin/typescript-language-server";
  eslintLs = "${pkgs.vscode-langservers-extracted}/bin/vscode-eslint-language-server";
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
    " No termguicolors: the 16 ANSI colours stay the terminal's.
    let &t_RB = "\<Esc>]11;?\<Esc>\\"

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
