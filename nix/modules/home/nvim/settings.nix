{ ... }:{
  programs.neovim.initLua = ''
    -- General
    vim.opt.number = true                           -- Line numbers
    vim.opt.relativenumber = true                   -- Relative line numbers
    vim.opt.cursorline = true                       -- Highlight current level
    vim.opt.wrap = false                            -- Don't wrap lines
    vim.opt.linebreak = true                        -- Don't split words
    vim.opt.scrolloff = 99                          -- Lines above/below cursor
    vim.opt.sidescrolloff = 25                      -- Columns left/right of cursor
    
    -- Indentation
    vim.opt.tabstop = 2                             -- Tab width
    vim.opt.shiftwidth = 2                          -- Indent Width
    vim.opt.softtabstop = 2                         -- Soft tab stop
    vim.opt.expandtab = true                        -- Use spaces instead of tabs
    vim.opt.smartindent = true                      -- Smart auto-indenting
    vim.opt.autoindent = true                       -- Copy indent from current line
    
    -- Folds
    vim.opt.foldmethod = "manual"                     -- Use expression for folding
    -- vim.opt.foldexpr = "nvim_treesitter#foldexpr()" -- Use treesitter for folding
    vim.opt.foldlevel = 0                             -- Keep all folds closed by defalt
    
    -- Searching
    vim.opt.ignorecase = true                       -- Case insensitive searching
    vim.opt.smartcase = true                        -- Case sensitive if uppercase in search
    vim.opt.hlsearch = false                        -- Highlight search results
    vim.opt.incsearch = true                        -- Show matches as you type
    
    -- Visual Settings
    vim.opt.termguicolors = true                    -- Enable 24bit color
    vim.opt.signcolumn = "yes:1"                    -- Show sign column
    vim.opt.cmdheight = 0                           -- Command line height
    vim.opt.completeopt = "menu,menuone,noselect"   -- Completion options
    vim.opt.showcmd = true                          -- Show command as you type
    vim.opt.showmode = false                        -- Show current mode
    vim.opt.splitbelow = true                       -- Create new splits below current one
    vim.opt.splitright = true                       -- Create new splits to the right
    vim.opt.fillchars = "eob: "                     -- Show nothing in empty file area
    vim.opt.ruler = false                           -- Don't show cursor position in command area
    
    -- File handling
    vim.opt.backup = false                          -- Create backup files
    vim.opt.writebackup = false                     -- Create backup before writing
    vim.opt.autoread = true                         -- Auto reload files changed outside neovim
    vim.opt.undofile = true                         -- Persistent undo history
    vim.opt.laststatus = 3                          -- One global status line
    
    -- Behavior settings
    vim.opt.shell = vim.env.SHELL or "/bin/sh"      -- Use $SHELL variable for commands
    vim.opt.bomb = false                            -- Don't write UTF-8 BOM
    vim.opt.encoding = "utf-8"                      -- Set encoding
    vim.opt.fileencoding = "utf-8"                  -- File encoding when writing
    vim.opt.fileformats = "unix,dos"                -- File ending formats
    vim.opt.clipboard = "unnamedplus"               -- Use system clipboard
    vim.opt.iskeyword:append("-")                   -- Treat dash as part of a word
    vim.opt.path:append("**")                       -- Include subdirectories in search
    vim.opt.mouse = "a"                             -- Enable mouse support
    vim.opt.title = false                           -- Let terminal decide title
    vim.opt.list = false                            -- Keep white space hidden
    vim.opt.shada = "'100,f1,/0"                    -- Make marks persists in a shared file
    vim.opt.viewoptions = "folds,cursor"            -- Save the folds in a view as well
    vim.opt.spelllang = 'en_us'                     -- Set spell check language to US English
    
    -- Diagnostics config
    vim.diagnostic.config({
      virtual_text = true,
      update_in_insert = true,
      severity_sort = true,
      float = {
        border = "rounded",
        source = true,
        header = "",
        prefix = ""
      },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "",
          [vim.diagnostic.severity.WARN] = "",
          [vim.diagnostic.severity.INFO] = "",
          [vim.diagnostic.severity.HINT] = "",
        },
        numhl = {
          [vim.diagnostic.severity.ERROR] = "DiagnosticErrorNum",
          [vim.diagnostic.severity.WARN] = "DiagnosticWarnNum",
          [vim.diagnostic.severity.INFO] = "DiagnosticInfoNum",
          [vim.diagnostic.severity.HINT] = "DiagnosticHintNum",
        },
        linehl = {
          [vim.diagnostic.severity.ERROR] = "DiagnosticErrorLine",
          [vim.diagnostic.severity.WARN] = "DiagnosticWarnLine",
          [vim.diagnostic.severity.INFO] = "DiagnosticInfoLine",
          [vim.diagnostic.severity.HINT] = "DiagnosticHintLine",
        }
      }
    })
    
    -- Group for autocommands
    local augroup = vim.api.nvim_create_augroup("UserConfig", {})
    
    -- Highlight yanked text
    vim.api.nvim_create_autocmd("TextYankPost",{
      group = augroup,
      callback = function ()
        vim.highlight.on_yank()
      end
    })
    
    -- Auto-resize splits when window is resized
    vim.api.nvim_create_autocmd("VimResized",{
      group = augroup,
      callback = function ()
        vim.cmd("tabdo wincmd =")
      end
    })
    
    -- Create directories when saving files
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      callback = function()
        local dir = vim.fn.expand('<afile>:p:h')
        if vim.fn.isdirectory(dir) == 0 then
          vim.fn.mkdir(dir, 'p')
        end
      end,
    })
    
    -- Save view on exit
    vim.api.nvim_create_autocmd("BufWinLeave", {
      pattern = "*",
      callback = function()
        if vim.bo.buftype == ""
          and vim.fn.expand("%") ~= ""
          and vim.fn.index({ "commit", "gitrebase", "xxd" }, vim.bo.filetype) == -1
          and not vim.o.diff then
          vim.cmd("mkview")
        end
      end,
    })
    
    -- Reload view on enter
    vim.api.nvim_create_autocmd("BufWinEnter", {
      pattern = "*",
      callback = function()
        if vim.bo.buftype == ""
          and vim.fn.expand("%") ~= ""
          and vim.fn.index({ "commit", "gitrebase", "xxd" }, vim.bo.filetype) == -1
          and not vim.o.diff then
          vim.cmd("silent! loadview")
          vim.fn.setreg("/", "")
        end
      end,
    })
    
    -- Wrap, linebreak, and spellcheck in markdown, typst, and text files
    vim.api.nvim_create_autocmd("FileType", {
      group = augroup,
      pattern = { "markdown", "typst", "text", "gitcommit" },
      callback = function ()
        vim.opt_local.wrap = true
        vim.opt_local.linebreak = true
        vim.opt_local.spell = true
      end,
    })
    
    -- Make $ a pair in typst files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "typst",
      callback = function()
        vim.keymap.set("i", "$", "$$<Left>", { buffer = true })
      end,
    })
  '';
}
