{ ... }:{
  programs.nushell.extraConfig = /* nu */ ''
    $env.config.keybindings = ($env.config.keybindings | append [
      # Ctrl+F for forward char
      {
        name: forward_char
        modifier: control
        keycode: char_f
        mode: [emacs vi_insert]
        event: { edit: moveright }
      }
      
      # Ctrl+B for backward char
      {
        name: backward_char
        modifier: control
        keycode: char_b
        mode: [emacs vi_insert]
        event: { edit: moveleft }
      }
      
      # Ctrl+K for forward word
      {
        name: forward_word
        modifier: control
        keycode: char_k
        mode: [emacs vi_insert]
        event: { edit: movewordright }
      }
      
      # Ctrl+J for backward word
      {
        name: backward_word
        modifier: control
        keycode: char_j
        mode: [emacs vi_insert]
        event: { edit: movewordleft }
      }
      
      # Ctrl+D to kill/cut to end of line
      {
          name: kill_line
          modifier: control
          keycode: char_d
          mode: [emacs vi_insert]
          event: { edit: cuttolineend }
      }
      
      # Ctrl+H to delete word backwards
      {
          name: backward_kill_word
          modifier: control
          keycode: char_h
          mode: [emacs vi_insert]
          event: { edit: backspaceword }
      }
    ])
  '';
}
