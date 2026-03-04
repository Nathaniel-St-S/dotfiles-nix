{ ... }:{
  programs.neovim.initLua = /* lua */ ''
    -- ============================================================================
    -- HIGHLIGHTS
    -- ============================================================================
    local function set_highlights()
      local ok, pywal = pcall(require, "pywal16.core")
      local colors = ok and pywal.get_colors() or {
        foreground = "#f8f8f2",
        color1     = "#ff5555",
        color2     = "#50fa7b",
        color3     = "#ffb86c",
        color4     = "#8be9fd",
        color5     = "#bd93f9",
        color6     = "#ff79c6",
        color8     = "#6272a4",
      }
      vim.api.nvim_set_hl(0, "StatusLineBold",     { fg = colors.foreground, bold = true })
      vim.api.nvim_set_hl(0, "StatusLineMode",     { fg = colors.color6, bold = true })
      vim.api.nvim_set_hl(0, "StatusLineFile",     { fg = colors.foreground })
      vim.api.nvim_set_hl(0, "StatusLineGit",      { fg = colors.color4 })
      vim.api.nvim_set_hl(0, "StatusLineError",    { fg = colors.color1 })
      vim.api.nvim_set_hl(0, "StatusLineWarn",     { fg = colors.color3 })
      vim.api.nvim_set_hl(0, "StatusLineSearch",   { fg = colors.color2 })
      vim.api.nvim_set_hl(0, "StatusLineSize",     { fg = colors.color8 })
      vim.api.nvim_set_hl(0, "StatusLineEnc",      { fg = colors.color8 })
      vim.api.nvim_set_hl(0, "StatusLineBuf",      { fg = colors.color5 })
      vim.api.nvim_set_hl(0, "StatusLineModified", { fg = colors.color3 })
      vim.api.nvim_set_hl(0, "StatusLineRO",       { fg = colors.color1 })
    end
    
    vim.api.nvim_create_autocmd("VimEnter",    { callback = set_highlights })
    vim.api.nvim_create_autocmd("ColorScheme", { callback = set_highlights })
    
    -- ============================================================================
    -- GIT BRANCH
    -- ============================================================================
    local cached_branch = ""
    local cached_repo   = ""
    
    local function update_branch()
      vim.system({ "git", "branch", "--show-current" }, { text = true }, function(result)
        cached_branch = (result.code == 0 and result.stdout ~= "")
          and result.stdout:gsub("\n", "")
          or ""
      end)
      vim.system({ "git", "rev-parse", "--show-toplevel" }, { text = true }, function(result)
        if result.code == 0 and result.stdout ~= "" then
          cached_repo = vim.fn.fnamemodify(result.stdout:gsub("\n", ""), ":t")
        else
          cached_repo = ""
        end
      end)
    end
    
    vim.uv.new_timer():start(0, 5000, vim.schedule_wrap(update_branch))
    
    local function git_branch()
      if cached_branch == "" then return "" end
      return "\u{f101} " .. cached_repo .. " \u{e725} " .. cached_branch
    end
    
    -- ============================================================================
    -- COMPONENTS
    -- ============================================================================
    local function mode_icon()
      local modes = {
        n       = " \u{f36f} NORMAL",
        i       = " \u{f36f} INSERT",
        v       = " \u{f36f} VISUAL",
        V       = " \u{f36f} V-LINE",
        ["\22"] = " \u{f36f} V-BLOCK",
        c       = " \u{f36f} COMMAND",
        s       = " \u{f36f} SELECT",
        S       = " \u{f36f} S-LINE",
        ["\19"] = " \u{f36f} S-BLOCK",
        R       = " \u{f36f} REPLACE",
        r       = " \u{f36f} REPLACE",
        ["!"]   = " \u{f36f} SHELL",
        t       = " \u{f36f} TERMINAL",
      }
      return modes[vim.fn.mode()]
    end
    
    local function file_type()
      local icons = {
        lua             = "\u{e620} ", python          = "\u{e73c} ",
        javascript      = "\u{e74e} ", typescript      = "\u{e628} ",
        javascriptreact = "\u{e7ba} ", typescriptreact = "\u{e7ba} ",
        html            = "\u{e736} ", css             = "\u{e749} ",
        scss            = "\u{e749} ", json            = "\u{e60b} ",
        conf            = "\u{e615} ", markdown        = "\u{e73e} ",
        typst           = "\u{f37f} ", pdf             = "\u{f1c1} ",
        vim             = "\u{e62b} ", sh              = "\u{f489} ",
        bash            = "\u{ebca} ", zsh             = "\u{f489} ",
        nu              = "\u{f054} ", rust            = "\u{e7a8} ",
        go              = "\u{e65e} ", c               = "\u{e61e} ",
        cpp             = "\u{e61d} ", zig             = "\u{e6a9} ",
        java            = "\u{e738} ", php             = "\u{e73d} ",
        ruby            = "\u{e739} ", racket          = "\u{e6b1} ",
        scheme          = "\u{e6b1} ", lisp            = "\u{e6b1} ",
        swift           = "\u{e699} ", kotlin          = "\u{e634} ",
        dart            = "\u{e798} ", elixir          = "\u{e7cd} ",
        haskell         = "\u{e777} ", sql             = "\u{e706} ",
        yaml            = "\u{e8eb} ", toml            = "\u{e6b2} ",
        xml             = "\u{f05c} ", kdl             = "\u{ebe5} ",
        dockerfile      = "\u{f308} ", gitcommit       = "\u{e702} ",
        gitconfig       = "\u{f1d3} ", gitignore       = "\u{f02a2} ",
        sshconfig       = "\u{e8b1} ", vue             = "\u{e6a0} ",
        svelte          = "\u{e697} ", astro           = "\u{e735} ",
        text            = "\u{f0219} ", help           = "\u{f0ba5} ",
      }
      local ft = vim.bo.filetype
      if ft == "" then return "\u{f09a8} " end
      return icons[ft] or ""
    end
    
    local function file_size()
      local size = vim.fn.getfsize(vim.fn.expand('%'))
      if size < 0 then return "" end
      if size < 1024 then
        return "\u{f1c9} " .. size .. "B"
      elseif size < 1024 * 1024 then
        return "\u{f1c9} " .. string.format("%.1fK", size / 1024)
      else
        return "\u{f1c9} " .. string.format("%.1fM", size / (1024 * 1024))
      end
    end
    
    local function buffer_count()
      local bufs = vim.fn.getbufinfo({ buflisted = 1 })
      local total = #bufs
      if total <= 1 then return "" end
      local current = vim.fn.bufnr('%')
      for i, buf in ipairs(bufs) do
        if buf.bufnr == current then
          return "[" .. i .. "/" .. total .. "] \u{e621}"
        end
      end
      return ""
    end
    
    local function lsp_errors()
      local n = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
      return n > 0 and " \u{ea87} " .. n or ""
    end
    
    local function lsp_warnings()
      local n = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
      return n > 0 and "  \u{f071} " .. n or ""
    end
    
    local function search_count()
      local ok, result = pcall(vim.fn.searchcount, { maxcount = 999 })
      if not ok or not result or not result.total or not result.current then return "" end
      if result.total == 0 then return "" end
      return " \u{f002} " .. result.current .. "/" .. result.total .. " "
    end
    
    local function macro_recording()
      local reg = vim.fn.reg_recording()
      if reg == "" then return "" end
      return "@" .. reg
    end
    
    -- ============================================================================
    -- GLOBALS
    -- ============================================================================
    _G.mode_icon    = mode_icon
    _G.git_branch   = git_branch
    _G.file_type    = file_type
    _G.file_size    = file_size
    _G.buffer_count = buffer_count
    _G.lsp_errors   = lsp_errors
    _G.lsp_warnings = lsp_warnings
    _G.search_count = search_count
    _G.macro_recording = macro_recording
    
    -- ============================================================================
    -- STATUSLINE
    -- ============================================================================
    local active_statusline = table.concat {
      " ",
      "%#StatusLineMode#",   "%{v:lua.mode_icon()}",
      "%#StatusLine#",       " \u{eab5}",
      "%#StatusLineError#",  "%{v:lua.macro_recording()}",
      "%#StatusLine#",       "\u{eab6} ",
      "%#StatusLineFile#",   "%{v:lua.file_type()}",
                             "%{&buftype=='nofile'?''':fnamemodify(expand('%'),':~:.')} ",
      "%#StatusLineModified#", "%{&modified?'\u{ea71} ':'''}",
      "%#StatusLineRO#",     "%{(&readonly||!&modifiable)?'\u{f023}':'''}",
      "%#StatusLine#",       "%{&buftype=='help'?'\u{f02d6}':'''}",
      "%#StatusLineGit#",    "%{v:lua.git_branch()}",
      "%#StatusLine#",
      "%=",
      "%#StatusLineSearch#", "%{v:lua.search_count()}",
      "%#StatusLineError#",  "%{v:lua.lsp_errors()}",
      "%#StatusLineWarn#",   "%{v:lua.lsp_warnings()}",
      "%#StatusLine#",
      "%=",
      "%#StatusLineBuf#",    "%{v:lua.buffer_count()} ",
      "%#StatusLineSize#",   "%{v:lua.file_size()} ",
      "%#StatusLineEnc#",    "%{toupper(&fileencoding)} ",
      "%#StatusLine#",
    }
    
    local inactive_statusline = "  %f %h%m%r \u{e0b1} %{v:lua.file_type()} %=  %l:%c   %P "
    
    vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
      callback = function() vim.opt_local.statusline = active_statusline end
    })
    
    vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
      callback = function() vim.opt_local.statusline = inactive_statusline end
    })
    
    vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
      callback = function() vim.cmd("redrawstatus") end
    })
  '';
}
