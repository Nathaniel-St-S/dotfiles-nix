{ ... }:
let
  init-content = /* zsh */ ''
    # Keybinds
    ## Setting up vi mode
    bindkey -v
    export KEYTIMEOUT=1
    # press o in normal mode to edit in neovim
    autoload edit-command-line
    zle -N edit-command-line
    bindkey -M vicmd o edit-command-line
    export VI_MODE_SET_CURSOR=true
    function zle-keymap-select() {
      if [[ ''${KEYMAP} == vicmd ]]; then
        echo -ne '\e[2 q' # block
      else
        echo -ne '\e[6 q' # beam
      fi
    }
    zle -N zle-keymap-select
    function zle-line-init(){
      zle -K viins
      echo -ne '\e[6 q'
    }
    zle -N zle-line-init
    # Yank to system clipboard using OSC 52 (works over SSH)
    function vi-yank-clipboard {
      zle vi-yank
      # OSC 52 escape sequence to copy to system clipboard
      printf "\033]52;c;$(printf "%s" "$CUTBUFFER" | base64 | tr -d '\n')\a"
    }
    zle -N vi-yank-clipboard
    # Copy curent command to clipboard
    copy-command() {
      # OSC 52 escape sequence to copy to system clipboard
      printf "\033]52;c;$(printf "%s" "$BUFFER" | base64 | tr -d '\n')\a"
      zle -M "Copied to clipboard"
    }
    zle -N copy-command
    bindkey -M vicmd 'y' vi-yank-clipboard
    bindkey -M vicmd ':' undefined-key
    bindkey -M vicmd 'u' undo
    bindkey -M vicmd '^R' redo
    bindkey '^_' undo
    bindkey '^Y' redo
    bindkey ' '  magic-space
    bindkey '^p' history-search-backward
    bindkey '^n' history-search-forward
    bindkey '^a' beginning-of-line
    bindkey '^e' end-of-line
    bindkey '^d' kill-line
    bindkey '^j' backward-word
    bindkey '^k' forward-word
    bindkey '^H' backward-kill-word
    bindkey -s '^Xgc' 'gcom ""'$'\e[D'
    bindkey -s '^Xgp' 'lazyg ""'$'\e[D'
    bindkey '^Xc' copy-command
    bindkey '^f' forward-char
    bindkey '^b' backward-char

    # ~ls everytime the working directory changes
    chpwd_functions=(''${chpwd_functions[@]} "list_all")

    # Custom prompt or other zsh configurations
    setopt PROMPT_SUBST

    # Searches for text in all files in the current folder
    ftext() {
      grep -iIHrn --color=always "$1" . | less -r
    }

    # Extracts any archive(s)
    extract() {
      for archive in "$@"; do
        if [ -f "$archive" ]; then
          case $archive in
          *.tar.bz2) tar xvjf $archive ;;
          *.tar.gz) tar xvzf $archive ;;
          *.bz2) bunzip2 $archive ;;
          *.rar) rar x $archive ;;
          *.gz) gunzip $archive ;;
          *.tar) tar xvf $archive ;;
          *.tbz2) tar xvjf $archive ;;
          *.tgz) tar xvzf $archive ;;
          *.zip) unzip $archive ;;
          *.Z) uncompress $archive ;;
          *.7z) 7z x $archive ;;
          *) echo "don't know how to extract '$archive'..." ;;
          esac
        else
          echo "'$archive' is not a valid file!"
        fi
      done
    }

    gcom() {
      git add .
      git commit -m "$1"
    }

    lazyg() {
      git add .
      git commit -m "$1"
      git push
    }

    # Safely stash, fetch, and rebase current branch
    stashrebase() {
      if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "Not a git repository."
        return 1
      fi
      
      local current_branch
      current_branch=$(git branch --show-current)
      
      if [[ -z "$current_branch" ]]; then
        echo "Not on any branch (detached HEAD?)."
        return 1
      fi
      
      local remote
      remote=$(git remote 2>/dev/null | head -n1)
      if [[ -z "$remote" ]]; then
        echo "No remote configured."
        return 1
      fi
      
      local stashed=false
      if ! git diff-index --quiet HEAD --; then
        echo "Stashing changes..."
        git stash push -u -m "auto-stash before pulling $current_branch"
        stashed=true
      else
        echo "No local changes to stash."
      fi
      
      echo "Fetching latest from $remote..."
      git fetch "$remote"
      
      echo "Rebasing onto $remote/$current_branch..."
      if git rebase "$remote/$current_branch"; then
        echo "Rebase successful!"
        if $stashed; then
          echo "Reapplying stashed changes..."
          git stash pop || echo "Could not reapply stash cleanly. Resolve manually."
        fi
        echo "Done! $current_branch is up to date with $remote/$current_branch."
      else
        echo "Rebase encountered conflicts. Resolve them, then run:"
        echo "    git rebase --continue"
        echo "When done, you can reapply your stash manually with:"
        echo "    git stash pop"
        return 1
      fi
    }

    function up {

      local counter=''${1:-1}
      local dirup="../"
       local out=""

       while (( counter > 0 )); do
         let counter--
         out="''${out}$dirup"
       done

       cd $out
    }

    # Make a new directory and cd into it
    mkcd() {
      case "$1" in
        */..|*/../) cd -- "$1";; 
        /*/../*) (cd "''${1%/../*}/.." && mkdir -p "./''${1##*/../}") && cd -- "$1";;
        /*) mkdir -p "$1" && cd "$1";;
        */../*) (cd "./''${1%/../*}/.." && mkdir -p "./''${1##*/../}") && cd "./$1";;
        ../*) (cd .. && mkdir -p "''${1#.}") && cd "$1";;
        *) mkdir -p "./$1" && cd "./$1";;
      esac
    }

    #Start or reattatch to a tmux session with the given name
    tn () {
      tmux new -A -s "$1"
    }

    #Kill a tmux session with the given name
    tk () { 
      tmux kill-session -t "$1"
    }

    # Function for the ls hook
    function list_all() {
      emulate -L zsh
      ls -aFh --color=always --group-directories-first
    }

  '';
in
{
  programs.zsh.initContent = init-content;
}
