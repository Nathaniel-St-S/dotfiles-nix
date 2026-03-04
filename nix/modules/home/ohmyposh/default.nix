{ pkgs, config, ... }:
let
  ohmyposh-config = pkgs.writeText "ohmyposh-config.toml" /* toml */''
    #:schema https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json

    version = 2
    final_space = true
    console_title_template = "{{ .Shell }} in {{ .Folder }}"

    [[blocks]]
    type = "prompt"
    alignment = "left"
    newline = true

    [[blocks.segments]]
    type = "text"
    style = "plain"
    foreground = "p:grey"
    template = "╭─"

    [[blocks.segments]]
    type = "path"
    style = "plain"
    foreground = "p:blue"
    template = "{{ .Path }} "

    [blocks.segments.properties]
    style = "full"
    home_icon = "~"

    [[blocks.segments]]
    type = "git"
    style = "plain"
    foreground = "p:grey"
    template = "{{ .HEAD }}{{ if or (.Working.Changed) (.Staging.Changed) }}*{{ end }}{{ if or (gt .Behind 0) (gt .Ahead 0) }} {{ if gt .Behind 0 }}⇣{{ end }}{{ if gt .Ahead 0 }}⇡{{ end }}{{ end }}{{ if gt .StashCount 0 }} 󱗾{{ end }} "

    [blocks.segments.properties]
    branch_icon = ""
    fetch_status = true
    fetch_upstream_icon = true
    fetch_stash_count = true

    [[blocks]]
    type = "prompt"
    alignment = "right"
    filler = "·"

    [[blocks.segments]]
    type = "executiontime"
    style = "plain"
    foreground = "p:yellow"
    template = "{{ .FormattedMs }} "

    [blocks.segments.properties]
    threshold = 5000
    style = "roundrock"

    [[blocks.segments]]
    type = "python"
    style = "plain"
    foreground = "p:grey"
    template = "{{ if .Venv }}{{ .Venv }} {{ end }}"

    [blocks.segments.properties]
    display_default = false
    fetch_virtual_env = true
    display_version = false

    [[blocks.segments]]
    type = "session"
    style = "plain"
    foreground = "p:grey"
    foreground_templates = ["{{ if .Root }}p:white{{ end }}"]
    template = "{{ if .SSHSession }}{{ .UserName }}@{{ .HostName }} {{ end }}"

    [blocks.segments.properties]
    display_default = false

    [[blocks.segments]]
    type = "time"
    style = "plain"
    foreground = "p:grey"
    template = " {{ .CurrentDate | date .Format }}"

    [blocks.segments.properties]
    time_format = "15:04:05"

    [[blocks]]
    type = "prompt"
    alignment = "left"
    newline = true

    [[blocks.segments]]
    type = "text"
    style = "plain"
    foreground = "p:grey"
    template = "╰─"

    [[blocks.segments]]
    type = "status"
    style = "plain"
    foreground = "p:magenta"
    foreground_templates = ["{{ if gt .Code 0 }}p:red{{ end }}"]
    template = "❯ "

    [blocks.segments.properties]
    always_enabled = true

    [palette]
    grey = "242"
    red = "red"
    yellow = "yellow"
    blue = "blue"
    magenta = "magenta"
    cyan = "cyan"
    white = "white"

    [transient_prompt]
    foreground_templates = [
      "{{if gt .Code 0}}red{{end}}",
      "{{if eq .Code 0}}magenta{{end}}",
    ]
    background = "transparent"
    template = "❯ "

    [secondary_prompt]
    foreground = "magenta"
    background = "transparent"
    template = "::: "
  '';

  configPath = "${config.home.homeDirectory}/.config/ohmyposh/config.toml";
in
{
  home.packages = with pkgs; [ oh-my-posh ];

  xdg.configFile."ohmyposh/config.toml".source = ohmyposh-config;

  programs.oh-my-posh = {
    enable = true;
    configFile = ohmyposh-config;
    enableZshIntegration = true;
    enableBashIntegration = true;
    # Nushell integration is broken, so for now
    # oh-my-posh just needs to be called on every prompt
    enableNushellIntegration = false;
  };

  programs.nushell.extraConfig = /* nu */ ''
    $env.POSH_THEME = "${configPath}"

    $env.PROMPT_COMMAND = {||
      let width = (term size).columns
      let exit_code = ($env.LAST_EXIT_CODE? | default 0)
      let duration = ($env.CMD_DURATION_MS? | default 0 | into float)
      oh-my-posh print primary --config $env.POSH_THEME --shell nu --execution-time $duration --status $exit_code --terminal-width $width
    }

    $env.PROMPT_COMMAND_RIGHT = {||}
    $env.PROMPT_MULTILINE_INDICATOR = (oh-my-posh print secondary --config ${configPath} --shell nu | str trim -r -c "\n")
    $env.PROMPT_INDICATOR = ""
    $env.PROMPT_INDICATOR_VI_INSERT = ""
    $env.PROMPT_INDICATOR_VI_NORMAL = ""

    $env.TRANSIENT_PROMPT_COMMAND = {||
    oh-my-posh print transient --config $env.POSH_THEME --shell nu
    }
    $env.TRANSIENT_PROMPT_COMMAND_RIGHT = {||}
    $env.TRANSIENT_PROMPT_INDICATOR = ""
    $env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = ""
    $env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = ""
    $env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = ""
  '';

  }
