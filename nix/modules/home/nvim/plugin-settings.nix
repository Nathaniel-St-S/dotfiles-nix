{ pkgs, username, ... }:{
  programs.neovim.initLua = /* lua */ ''
    -- ────────────────────────────────────────────────────────────────────────
    -- Colorscheme
    -- ────────────────────────────────────────────────────────────────────────
    require("pywal16").setup()
    vim.cmd.colorscheme("pywal16")
    
    -- ────────────────────────────────────────────────────────────────────────
    -- blink.cmp
    -- ────────────────────────────────────────────────────────────────────────
    vim.api.nvim_set_hl(0, "BlinkCmpSel", { bold = true, italic = true })
    vim.api.nvim_set_hl(0, "BlinkCmpSignatureHelpActiveParameter",
      { bold = true, italic = true, underdotted = true })
    
    require("blink.cmp").setup({
      keymap = {
        preset    = "none",
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<Tab>"] = { "accept", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
        ["<C-e>"] = { "cancel", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        ["<C-s>"] = { "show_signature", "hide_signature", "fallback" },
      },
      appearance = {
        kind_icons = {
          Text          = "󰉿", Method       = "m", Function  = "󰊕",
          Constructor   = "", Field        = "", Variable  = "󰆧",
          Class         = "󰌗", Interface    = "", Module    = "",
          Property      = "", Unit         = "", Value     = "󰎠",
          Enum          = "", Keyword      = "󰌋", Snippet   = "",
          Color         = "󰏘", File         = "󰈙", Reference = "",
          Folder        = "󰉋", EnumMember   = "", Constant  = "󰇽",
          Struct        = "", Event        = "", Operator  = "󰆕",
          TypeParameter = "󰊄",
        },
      },
      completion = {
        list = {
          max_items = 10,
          selection = { preselect = true, auto_insert = false },
        },
        menu = {
          border           = "rounded",
          winhighlight     = "Normal:Normal,FloatBorder:FloatBorder,CursorLine:BlinkCmpSel",
          direction_priority = { "s", "n" },
        },
        documentation = {
          auto_show          = true,
          auto_show_delay_ms = 500,
          window = { border = "rounded" },
        },
        ghost_text = { enabled = false },
      },
      signature = {
        enabled = true,
        window  = { border = "rounded" },
      },
      snippets = { preset = "luasnip" },
      sources = {
        default   = { "lsp", "path", "snippets", "buffer" },
        providers = {
          lsp      = { min_keyword_length = 2 },
          buffer   = { min_keyword_length = 4 },
          path     = { min_keyword_length = 2 },
          snippets = { min_keyword_length = 2 },
        },
      },
      cmdline = {
        keymap = {
          preset    = "none",
          ["<C-p>"] = { "select_prev", "fallback" },
          ["<C-n>"] = { "select_next", "fallback" },
          ["<Tab>"] = { "accept", "fallback" },
          ["<C-e>"] = { "cancel", "fallback" },
        },
        completion = {
          ghost_text = { enabled = false },
          menu       = { auto_show = true },
        },
      },
    })
    
    -- ────────────────────────────────────────────────────────────────────────
    -- LuaSnip
    -- ────────────────────────────────────────────────────────────────────────
    local ls = require("luasnip")
    ls.setup({
      history              = true,
      updateevents         = "TextChanged,TextChangedI",
      enable_autosnippets  = true,
      store_selection_keys = "<Tab>",
    })
    require("luasnip.loaders.from_snipmate").lazy_load()

    vim.keymap.set("n", "<leader><leader>s", function()
      require("luasnip.loaders.from_snipmate").load()
      vim.notify("SnipMate snippets reloaded", vim.log.levels.INFO)
    end, { desc = "Reload LuaSnip snippets" })
    
    -- ────────────────────────────────────────────────────────────────────────
    -- nvim-lspconfig
    -- ────────────────────────────────────────────────────────────────────────
    local capabilities = require("blink.cmp").get_lsp_capabilities()
    
    -- Apply capabilities + shared settings to every server.
    vim.lsp.config("*", {
      capabilities = capabilities,
      settings = {
        Lua = {
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
          },
        },
        nixd = {
          nixpkgs = {
            expr = [[
              let
                flake = builtins.getFlake "path:/home/${username}/dotfiles";
              in
                flake.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}
            ]],
          },
          options = {
            nixos = {
              expr = [[
                (builtins.getFlake "path:/home/${username}/dotfiles").nixosConfigurations.nixos.options
              ]],
            },
            ["home-manager"] = {
              expr = [[
                (builtins.getFlake "path:/home/${username}/dotfiles").nixosConfigurations.nixos.options.home-manager.users.type.getSubOptions []
              ]],
            },
          },
        },
      },
    })

    local nix_managed_servers = {
      "lua_ls",
      "nixd",
      "bashls",
      "clangd",
      "pyright",
      "rust_analyzer",
      "zls",
      "marksman",
      "ts_ls",
      "html",
      "cssls",
      "jsonls",
      "emmet_language_server",
      "tinymist",
      "racket_langserver",
    }

    for _, server in ipairs(nix_managed_servers) do
      vim.lsp.enable(server)
    end

    -- ────────────────────────────────────────────────────────────────────────
    -- lsp blocks
    -- ────────────────────────────────────────────────────────────────────────
    require("otter").setup({
      buffers = {
        set_filetype = true,
        write_to_disk = false,
      },
      handle_leading_whitespace = true,
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "nix", "markdown" },
      callback = function()
        require("otter").activate({ "lua", "bash", "python", "html", "css", "nix", }, true, true)
      end,
    })

    -- ────────────────────────────────────────────────────────────────────────
    -- Treesitter
    -- ────────────────────────────────────────────────────────────────────────
    vim.api.nvim_create_autocmd("FileType", {
      callback = function(event)
        local ok, _ = pcall(vim.treesitter.start, event.buf)
        if not ok then return end

        -- indentation via treesitter
        vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
    vim.filetype.add({
      extension = { rasi = "rasi" },
    })
    vim.treesitter.language.register("markdown", "mdx")
    vim.treesitter.language.register("rasi", "rasi")
    
    -- treesitter-textobjects
    require("nvim-treesitter-textobjects").setup({
      move   = { set_jumps = true },
      select = {
        lookahead       = true,
        selection_modes = {
          ["@parameter.outer"] = "v",
          ["@function.outer"]  = "V",
          ["@class.outer"]     = "<c-v>",
        },
        include_surrounding_whitespace = true,
      },
    })
    
    -- textobject movement
    local move = require("nvim-treesitter-textobjects.move")
    local sel  = require("nvim-treesitter-textobjects.select")
    
    vim.keymap.set({ "n", "x", "o" }, "[f", function()
      move.goto_previous_start("@function.outer", "textobjects")
    end)
    vim.keymap.set({ "n", "x", "o" }, "]f", function()
      move.goto_next_start("@function.outer", "textobjects")
    end)
    vim.keymap.set({ "n", "x", "o" }, "[F", function()
      move.goto_previous_end("@function.outer", "textobjects")
    end)
    vim.keymap.set({ "n", "x", "o" }, "[[", function()
      move.goto_previous_start("@class.outer", "textobjects")
    end)
    vim.keymap.set({ "n", "x", "o" }, "][", function()
      move.goto_next_start("@class.outer", "textobjects")
    end)
    
    -- textobject selection
    vim.keymap.set({ "x", "o" }, "af", function()
      sel.select_textobject("@function.outer", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "if", function()
      sel.select_textobject("@function.inner", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "ac", function()
      sel.select_textobject("@class.outer", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "ic", function()
      sel.select_textobject("@class.inner", "textobjects")
    end)
    vim.keymap.set({ "x", "o" }, "as", function()
      sel.select_textobject("@local.scope", "textobjects")
    end)
    
    -- ────────────────────────────────────────────────────────────────────────
    -- Telescope
    -- ────────────────────────────────────────────────────────────────────────
    require("telescope").setup()
    
    -- ────────────────────────────────────────────────────────────────────────
    -- Gitsigns
    -- ────────────────────────────────────────────────────────────────────────
    require("gitsigns").setup({
      on_attach = function(_)
        vim.cmd("redrawstatus")
      end,
    })
    
    -- ────────────────────────────────────────────────────────────────────────
    -- nvim-colorizer
    -- ────────────────────────────────────────────────────────────────────────
    require("colorizer").setup({
      filetypes = {
        "html", "json", "kdl", "css", "scss", "toml", "yaml", "nix",
        "sass", "less", "typescript", "javascript", "lua", "zig",
        "rust", "c", "go", "bash", "sh", "zsh", "nu", "text", "conf"
      },
      user_default_options = {
        RGB      = true,  RRGGBB   = true, names    = false,
        RRGGBBAA = true,  AARRGGBB = true, rgb_fn   = true,
        hsl_fn   = true,  css      = true, css_fn   = true,
        tailwind = true,  mode     = "background",
        sass     = { enabled = true, parsers = { "css" } },
      },
    })
    
    -- ────────────────────────────────────────────────────────────────────────
    -- mini.nvim
    -- ────────────────────────────────────────────────────────────────────────
    require("mini.indentscope").setup({
      symbol        = "│",
      try_as_border = true,
    })
    
    require("mini.ai").setup({ n_lines = 500 })
    
    require("mini.surround").setup()
    
    -- ────────────────────────────────────────────────────────────────────────
    -- ts-comments
    -- ────────────────────────────────────────────────────────────────────────
    require("ts-comments").setup({
      lang = {
        json  = "// %s",
        jsonc = "// %s",
        css   = "/* %s */",
        scss  = "/* %s */",
        rasi  = "/* %s */",
      },
    })
    
    -- ────────────────────────────────────────────────────────────────────────
    -- typst-preview
    -- ────────────────────────────────────────────────────────────────────────
    require("typst-preview").setup({})
  '';
}
