{ pkgs, ... }:

let
  tmux-transient-status = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-transient-status";
    version    = "unstable-2024";
    src = pkgs.fetchFromGitHub {
      owner  = "TheSast";
      repo   = "tmux-transient-status";
      rev    = "main";
      sha256 = "04fwmzf0zn4550kw11mz3irxrz85zs9kvrhc5xak212m2pr2gqkw";
    };
  };
in
{
  home.packages = with pkgs; [ tmux ];

  imports = [
    ./tmux-menu.nix
    ./tmux-scratch.nix
  ];

  programs.tmux = {
    enable     = true;
    terminal   = "screen-256color";
    escapeTime = 0;
    baseIndex  = 1;
    mouse      = true;
    prefix     = "C-Space";
    keyMode    = "vi";

    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = yank;
        extraConfig = ''
          bind-key -T copy-mode-vi v send-keys -X begin-selection
          bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
          bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
        '';
      }
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-processes 'ssh'
        '';
      }
      {
        plugin = tmux-transient-status;
        extraConfig = ''
          set -g @transient-status-delay '0.2'
          set -g @transient-status-stall '2.0'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-save-interval '5'
          # set -g @continuum-restore 'on'
        '';
      }
      vim-tmux-navigator
    ];

    extraConfig = ''
      # Send prefix with C-Space C-Space
      bind C-Space send-prefix

      # 1-based indexing for panes
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      # Navigation between windows
      bind -n M-H previous-window
      bind -n M-L next-window

      # Navigation between panes
      bind -n C-h select-pane -L
      bind -n C-j select-pane -D
      bind -n C-k select-pane -U
      bind -n C-l select-pane -R

      # Pane resizing (with prefix)
      bind -r h resize-pane -L 5
      bind -r j resize-pane -D 5
      bind -r k resize-pane -U 5
      bind -r l resize-pane -R 5
      bind -r m resize-pane -Z

      # Splitting — preserve working directory
      unbind '"'
      bind - split-window -v -c "#{pane_current_path}"
      unbind %
      bind \\ split-window -h -c "#{pane_current_path}"

      # New window in current directory
      bind c new-window -c "#{pane_current_path}"

      # Kill pane instantly
      bind-key X kill-pane

      # Renaming
      bind-key r command-prompt -p "Rename session:" "rename-session '%%'"
      bind-key R rename-session "#{b:pane_current_path}"

      # Session list popup
      bind w display-popup -E -w 30% -h 50% tmux-menu

      # Scratchpad popup + popup key table
      bind T display-popup -E -w 80% -h 80% tmux-scratch
      bind -T popup t send-keys t
      bind -T popup q send-keys q
      bind -T popup T detach
      bind -T popup C-[ copy-mode

      # True colour
      set-option -sa terminal-overrides ",xterm*:Tc"

      set-option -g status-position top

      # ── Theme ──────────────────────────
      set -g status on
      set -g status-interval 5

      set -g status-style bg=default,fg=default

      set -g status-left-length 50
      set -g status-right-length 100

      set -g @pill_bg "colour2"
      set -g @pill_fg "default"
      set -g @pill_left_sep ""
      set -g @pill_right_sep ""

      set -g status-left " "

      set -g window-status-format " #W "
      set -g window-status-current-format "#[fg=#{@pill_bg}]#{@pill_left_sep}#[bg=#{@pill_bg},fg=#{@pill_fg}] #W #[fg=#{@pill_bg},bg=default]#{@pill_right_sep}"

      set -g status-right "#[fg=#{@pill_bg}]#{@pill_left_sep}#[bg=#{@pill_bg},fg=#{@pill_fg}] #S #[fg=#{@pill_bg},bg=default]#{@pill_right_sep} "
      # ─────────────────────────────────────────────────────────────────────────
    '';
  };
}
