{ ... }:{
  programs.nushell.extraConfig = /* nu */ ''
    # Run nushell commands as sudo
    def nsudo [command: string] {
      sudo nu -c $command
    }

    # LS commands with pipes (aliases can't have pipes)
    def lf [] {
      ls | where type == file
    }

    def ldir [] {
      ls | where type == dir
    }

    def lk [] {
      ls | sort-by size --reverse
    }

    def lc [] {
      ls | sort-by modified
    }

    def labc [] {
      ls | sort-by name --ignore-case
    }

    # Searches for text in all files in the current folder
    def ftext [pattern: string] {
      ls **/* 
      | where type == "file"
      | each { |file|
          try {
            open $file.name 
            | lines 
            | enumerate 
            | each { |line|
                if ($line.item | str contains -i $pattern) {
                  {
                    file: $file.name,
                    line: ($line.index + 1),
                    text: $line.item
                  }
                }
              }
            | compact
          } catch {
            []
          }
        }
      | flatten
    }

    # Extract archives
    def extract [...archives: string] {
      for archive in $archives {
        if not ($archive | path exists) {
          print $"'($archive)' is not a valid file!"
          continue
        }

        match ($archive | path parse | get extension) {
          "bz2" => { bunzip2 $archive }
          "gz" => { gunzip $archive }
          "zip" => { unzip $archive }
          "Z" => { uncompress $archive }
          "7z" => { 7z x $archive }
          "rar" => { rar x $archive }
          "tar" => { tar xvf $archive }
          "tbz2" => { tar xvjf $archive }
          "tgz" => { tar xvzf $archive }
          _ => {
            # Try to detect tar archives by full extension
            if ($archive | str ends-with ".tar.bz2") {
              tar xvjf $archive
            } else if ($archive | str ends-with ".tar.gz") {
              tar xvzf $archive
            } else {
              print $"Don't know how to extract '($archive)'..."
            }
          }
        }
      }
    }

    # Git commit with message
    def gcom [message: string] {
      git add .
      git commit -S -m $message
    }

    # Lazy git: add, commit, and push
    def lazyg [message: string] {
      git add .
      git commit -S -m $message
      git push
    }

    # Safely stash, fetch, and rebase current branch
    def stashrebase [] {
      # Ensure we're in a git repo
      if (git rev-parse --is-inside-work-tree | complete | get exit_code) != 0 {
        print "Not a git repository."
        return
      }

      # Get current branch
      let current_branch = (git branch --show-current | str trim)

      if ($current_branch | is-empty) {
        print "Not on any branch (detached HEAD?)."
        return
      }

      # Determine default remote
      let remote = (git remote | lines | first)

      if ($remote | is-empty) {
        print "No remote configured."
        return
      }

      # Check for uncommitted changes
      let has_changes = (git diff-index --quiet HEAD | complete | get exit_code) != 0

      if $has_changes {
        print "Stashing changes..."
        git stash push -u -m $"auto-stash before pulling ($current_branch)"
      } else {
        print "No local changes to stash."
      }

      print $"Fetching latest from ($remote)..."
      git fetch $remote

      print $"Rebasing onto ($remote)/($current_branch)..."
      let rebase_result = (git rebase $"($remote)/($current_branch)" | complete)

      if $rebase_result.exit_code == 0 {
        print "Rebase successful!"
        if $has_changes {
          print "Reapplying stashed changes..."
          let pop_result = (git stash pop | complete)
          if $pop_result.exit_code != 0 {
            print "Could not reapply stash cleanly. Resolve manually."
          }
        }

        print $"Done! ($current_branch) is up to date with ($remote)/($current_branch)."

        } else {
          print "Rebase encountered conflicts. Resolve them, then run:"
          print "    git rebase --continue"
          print "When done, you can reapply your stash manually with:"
          print "    git stash pop"
      }
    }

    # Make a new directory and cd into it
    def --env mkcd [path: string] {
      mkdir $path
      cd $path
    }

    # Start or reattach to a tmux session with the given name
    def tn [name: string] {
      tmux new -A -s $name
    }

    # Kill a tmux session with the given name
    def tk [name: string] {
      tmux kill-session -t $name
    }

    # Show path as a list
    def paths [] {
      $env.PATH | each { |p| print $p }
    }

    # FZF file editor
    def fe [] {
      let selected = (fzf -m --preview="bat --style=plain --color=always {}")
      if not ($selected | is-empty) {
        nvim ...(echo $selected | lines)
      }
    }

    # FZF file editor with sudo
    def sfe [] {
      let selected = (fzf -m --preview="bat --style=plain --color=always {}")
      if not ($selected | is-empty) {
        sudo nvim ...(echo $selected | lines)
      }
    }

    # Search command line history
    def h [pattern: string] {
      history | where command =~ $pattern
    }

    # SEARCH RUNNING PROCESSES
    def p [pattern: string] {
      ls | grep -I $pattern
    }

    # SEARCH FILES IN THE CURRENT DIRECTORY
    def f [pattern: string] {
      ls **/* | where name =~ ('(?I)' + $pattern)
    }
  '';
}
