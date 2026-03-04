{ pkgs, autoImport, ... }:

let
  pywal16-nvim = pkgs.vimUtils.buildVimPlugin {
    pname   = "pywal16.nvim";
    version = "main";
    src = pkgs.fetchFromGitHub {
      owner = "uZer";
      repo  = "pywal16.nvim";
      rev   = "main";
      hash  = "sha256-EXe7xhzAbU5sWcr4KbA6bqDaALM8WmOWTal41tVfP4w=";
    };
    nvimRequireCheck = "pywal16";
 };

in
{
  imports = autoImport { path = ./.; };

  programs.neovim = {
    enable        = true;
    defaultEditor = true;
    viAlias       = true;
    vimAlias      = true;
    vimdiffAlias  = true;

    # ── Plugins ───────────────────────────────────────────────────────────────
    plugins = with pkgs.vimPlugins; [
      # Completion
      blink-cmp
      luasnip
      vim-snippets

      # LSP
      nvim-lspconfig
      mason-nvim
      mason-lspconfig-nvim

      # Treesitter
      (nvim-treesitter.withPlugins (p: with p; [
        lua nix bash rust go c cpp python typescript javascript
        html css json yaml toml markdown typst racket zig nu
        rasi glsl ini zsh tmux
      ]))
      nvim-treesitter-textobjects

      # Fuzzy finding
      telescope-nvim
      plenary-nvim

      # Git
      gitsigns-nvim

      # UI / editing helpers
      nvim-web-devicons
      nvim-colorizer-lua
      mini-nvim
      ts-comments-nvim
      vim-tmux-navigator

      # Colorscheme
      pywal16-nvim

      # Typst preview
      typst-preview-nvim
    ];

    # ── System tools exposed to neovim ────────────────────────────────────────
    extraPackages = with pkgs; [
      # LSP servers
      lua-language-server
      nil
      bash-language-server
      clang-tools
      pyright
      rust-analyzer
      zls
      marksman
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      emmet-language-server
      racket
      typst
      tinymist

      tree-sitter
      graphviz
      ripgrep
      fd
      git
    ];
  };
}

