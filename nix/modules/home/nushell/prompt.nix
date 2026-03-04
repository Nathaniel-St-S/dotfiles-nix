{ ... }:{
  programs.nushell.extraConfig = /* nu */ ''
    $env.PROMPT_COMMAND = {||
      let dir = (pwd | str replace $env.HOME "~")
      let git = (do -i { 
        git branch --show-current 
        | complete 
        | get stdout 
        | str trim 
      })
      
      # Get git status indicators if in a repo
      let git_status = if not ($git | is-empty) {
        # Check for dirty/uncommitted changes
        let dirty = (do -i { 
          git status --porcelain 
          | complete 
          | get stdout 
          | str trim 
        })
        let dirty_icon = if not ($dirty | is-empty) { "*" } else { "" }
        
        # Check commits ahead/behind
        let ahead = (do -i { 
          git rev-list --count '@{upstream}..HEAD' 
          | complete 
          | get stdout 
          | str trim 
        })
        let behind = (do -i { 
          git rev-list --count 'HEAD..@{upstream}' 
          | complete 
          | get stdout 
          | str trim 
        })
        
        # Build arrows for VCS
        # - Unpushed && Unpulled "⇣⇡"
        # - Unpushed || Unpulled " ⇣" || " ⇡"
        let arrows = if ($behind != "" and $behind != "0") and ($ahead != "" and $ahead != "0") {
          " ⇣⇡"
        } else if ($behind != "" and $behind != "0") {
          " ⇣"
        } else if ($ahead != "" and $ahead != "0") {
          " ⇡"
        } else {
          ""
        }
        
        $"($dirty_icon)($arrows)"
      } else {
        ""
      }
      
      # Build left prompt with git if available
      let left = if ($git | is-empty) {
        $"(ansi {fg: 238})╭─(ansi blue)($dir)(ansi reset)"
      } else {
        $"(ansi {fg: 238})╭─(ansi blue)($dir)(ansi reset) (ansi {fg: 242})($git)($git_status)(ansi reset)"
      }
      
      $"($left)\n(ansi {fg: 238})╰─"
    }

    $env.PROMPT_COMMAND_RIGHT = {||
      let duration = (do -i { history | last | get duration })
      let time = (date now | format date "%H:%M:%S")
      
      # Build right side
      let right_parts = if ($duration != null) and ($duration > 5sec) {
        $"(ansi yellow)($duration)(ansi reset) (ansi {fg: 242})($time)(ansi reset)"
      } else {
        $"(ansi {fg: 242})($time)(ansi reset)"
      }
      
      # Add dotted line fill
      let term_width = (term size | get columns)
      let dir = (pwd | str replace $env.HOME "~")
      let git = (do -i { 
        git branch --show-current 
        | complete 
        | get stdout 
        | str trim 
      })
      
      # Get git status length for accurate spacing
      let git_status_len = if not ($git | is-empty) {
        let dirty = (do -i { 
          git status --porcelain 
          | complete 
          | get stdout 
          | str trim 
        })
        let ahead = (do -i { 
          git rev-list --count '@{upstream}..HEAD' 
          | complete 
          | get stdout 
          | str trim 
        })
        let behind = (do -i { 
          git rev-list --count 'HEAD..@{upstream}' 
          | complete 
          | get stdout 
          | str trim 
        })
        
        let dirty_len = if not ($dirty | is-empty) { 1 } else { 0 }
        let arrow_len = if ($behind != "" and $behind != "0") and ($ahead != "" and $ahead != "0") {
          3  # " ⇣⇡"
        } else if ($behind != "" and $behind != "0") or ($ahead != "" and $ahead != "0") {
          2  # " ⇣" or " ⇡"
        } else {
          0
        }
        
        $dirty_len + $arrow_len
      } else {
        0
      }
      
      # Calculate left length: "╭─" (2) + dir + trailing space (1) + optional git/status
      let left_len = if ($git | is-empty) {
        ($dir | str length) + 3  # 3 for "╭─" + trailing space
      } else {
        ($dir | str length) + ($git | str length) + $git_status_len + 4  # 4 for "╭─" + space between dir and git
      }
      
      let right_len = ($time | str length) + 1  # +1 for leading space
      let dot_count = ($term_width - $left_len - $right_len)
      let dots = if $dot_count > 0 {
        (seq 1 $dot_count | each { "·" } | str join)
      } else {
        ""
      }
      
      $"(ansi {fg: 238})($dots)(ansi reset) ($right_parts)"
    }

    $env.PROMPT_INDICATOR_VI_INSERT = {|| $"(ansi magenta)❯(ansi reset) " }
    $env.PROMPT_INDICATOR_VI_NORMAL = {|| $"(ansi magenta)❮(ansi reset) " }

    # Enable transient prompt
    $env.TRANSIENT_PROMPT_COMMAND = {|| "" }
    $env.TRANSIENT_PROMPT_COMMAND_RIGHT = {|| "" }
    $env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = {|| $"(ansi magenta)❯(ansi reset) " }
    $env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = {|| $"(ansi magenta)❮(ansi reset) " }

  '';
}
