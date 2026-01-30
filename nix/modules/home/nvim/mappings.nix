{ ... }:{
  programs.neovim.initLua = ''
    local options = {
      noremap = true,
      silent = true,
    }
    
    vim.g.mapleader = " "
    vim.g.maplocalleader = " "
    
    local map = vim.keymap.set
    
    -- General
    map("n", "<leader>e", ":Explore<CR>", options)
    map("n", "<leader>re", ":Rex<CR>", options)
    map("n", "<leader>h", ":let @/ = '''<CR>", options) --Clear history
    map("n", "<leader>p", '"0p', options) -- Paste last yanked
    map("n", "<leader>bd", ':bdelete<CR>', options) -- Delete current buffer
    map("n", "<leader>sc", ":setlocal spell!<CR>", options) -- Toggle spellchecking
    map("v", "p", '"_dP', options) -- Keep last yanked when pasting
    map("v", "<", "<gv", options) -- Stay in indent mode
    map("v", ">", ">gv", options) -- Stay in indent mode
    map("n", "<C-q>", ": q! <CR>", options) -- Quit file
    map("n", "x", '"_x', options) -- Delete single character without copying into register
    map("n", "<C-d>", "<C-d>zz", options) -- Vertical scroll and center
    map("n", "<C-u>", "<C-u>zz", options) -- Vertical scroll and center
    map("n", "n", "nzzzv", options) -- Find and center
    map("n", "N", "Nzzzv", options) -- Find and center
    map("n", "<M-j>", ":m .+1<CR>==", options) -- Move line down one
    map("v", "<M-j>", ":m '>+1<CR>gv=gv", options) -- Move selected lines down one
    map("n", "<M-k>", ":m .-2<CR>==", options) -- Move line up one
    map("v", "<M-k>", ":m '<-2<CR>gv=gv", options) -- Move selected lines up one
    map({ "n", "v", "x" }, ";", ":") -- No need to shift for commands
    map({ "n", "v", "x" }, ":", ";") -- Whatever this does
    
    -- Window
    map("n", "<C-w>l", "<C-w><", options)
    map("n", "<C-w>h", "<C-w>>", options)
    map("n", "<C-w>k", "<C-w>+", options)
    map("n", "<C-w>j", "<C-w>-", options)
    map("n", "<leader>wc", ":close<CR>", options) -- Close current window
    map("n", "<leader>ws", ":split<CR>", options) -- Split window horizontally
    map("n", "<leader>wv", ":vsplit<CR>", options) -- Split window vertically
    map("n", "<C-h>", ":wincmd h<CR>", options) -- Navigate Split Left
    map("n", "<C-j>", ":wincmd j<CR>", options) -- Navigate Split Down
    map("n", "<C-k>", ":wincmd k<CR>", options) -- Navigate Split Up
    map("n", "<C-l>", ":wincmd l<CR>", options) -- Navigate Split Right
    
    -- LSP
    map("n", "<leader>M", ":Mason<CR>", options)
    map("n", "<leader>I", ":LspInfo<CR>", options)
    map("n", "<leader>f", ":lua vim.lsp.buf.format({ async = true })<CR>", options)
    map("n", "<leader>o", ":lua vim.diagnostic.open_float()<CR>", options)
    map("n", "<leader>ln", ":lua vim.diagnostic.goto_next()<CR>", options)
    map("n", "<leader>lp", ":lua vim.diagnostic.goto_previous()<CR>", options)
    map("n", "<leader>lq", ":lua vim.diagnostic.setloclist()<CR>", options)
    -- Previous comment
    map("n", "[c", function()
      vim.fn.search([[^\s*\(//\|#\|--\|\/\*\|;\|#|\)]], "bW")
    end, options)
    -- Next comment
    map("n", "]c", function()
      vim.fn.search([[^\s*\(//\|#\|--\|\/\*\|;\|#|\)]], "W")
    end, options)
    
    -- Gitsigns
    map("n", "<leader>gb", ":Gitsigns blame_line<CR>", options)
    map("n", "<leader>gt", ":Gitsigns toggle_current_line_blame<CR>", options)
    map("n", "<leader>gh", ":Gitsigns preview_hunk_inline<CR>", options)
    map("n", "<leader>gp", ":Gitsigns preview_hunk<CR>", options)
    map("n", "<leader>gd", ":Gitsigns diffthis<CR>", options)
    
    -- Telescope
    map("n", "<leader>T", ":Telescope<CR>", options)
    map("n", "<leader>tf", ":Telescope find_files<CR>", options)
    map("n", "<leader>tg", ":Telescope git_files<CR>", options)
    map("n", "<leader>ts", ":Telescope grep_string<CR>", options)
    map("n", "<leader>tl", ":Telescope live_grep<CR>", options)
    map("n", "<leader>tb", ":Telescope buffers<CR>", options)
    map("n", "<leader>tu", ":Telescope oldfiles<CR>", options)
    map("n", "<leader>tc", ":Telescope commands<CR>", options)
    map("n", "<leader>th", ":Telescope command_history<CR>", options)
    map("n", "<leader>tp", ":Telescope quickfix<CR>", options)
    map("n", "<leader>tq", ":Telescope loclist<CR>", options)
    map("n", "<leader>tj", ":Telescope jumplist<CR>", options)
    map("n", "<leader>ta", ":Telescope current_buffer_fuzzy_find<CR>", options)
    
    map("n", "<leader>tr", ":Telescope lsp_references<CR>", options)
    map("n", "<leader>tz", ":Telescope lsp_incoming_calls<CR>", options)
    map("n", "<leader>to", ":Telescope lsp_outgoing_calls<CR>", options)
    map("n", "<leader>tw", ":Telescope lsp_document_symbols<CR>", options)
    map("n", "<leader>te", ":Telescope diagnostics<CR>", options)
    map("n", "<leader>ti", ":Telescope lsp_implementations<CR>", options)
    map("n", "<leader>td", ":Telescope lsp_definitions<CR>", options)
    map("n", "<leader>tt", ":Telescope lsp_type_definitions<CR>", options)
    
    -- Typst
    map("n", "<leader>yp", ":TypstPreview<CR>", options)
    map("n", "<leader>yu", ":TypstPreviewUpdate<CR>", options)
    map("n", "<leader>ys", ":TypstPreviewStop<CR>", options)
    map("n", "<leader>yt", ":TypstPreviewToggle<CR>", options)
    map("n", "<leader>yc", ":TypstPreviewFollowCursor<CR>", options)
    map("n", "<leader>yn", ":TypstPreviewNoFollowCursor<CR>", options)
    map("n", "<leader>yf", ":TypstPreviewFollowCursorToggle<CR>", options)
    map("n", "<leader>yy", ":TypstPreviewSyncCursor<CR>", options)
    
    -- Automatically make a new session
    map("n", "<leader>ss", function()
      vim.cmd("mksession!")
      print("Session saved!")
    end, { desc = "Save session" })
    
    --create a new terminal running racket
    map("n", "<leader>sr", function()
      vim.cmd("w") -- Save file first
      local file_path = vim.fn.expand("%:p")
      -- Open terminal split at the bottom
      vim.cmd("botright split")
      vim.cmd("resize 15")
      -- Start racket with a specific command to ensure clean exit
      vim.cmd("terminal racket")
      -- Set up terminal buffer options for better cleanup
      vim.cmd([[setlocal bufhidden=wipe]]) -- Wipe buffer when hidden
      vim.cmd([[setlocal nobuflisted]]) -- Don't show in buffer list
      vim.defer_fn(function()
        local chan = vim.b.terminal_job_id
        if chan then
          vim.fn.chansend(chan, string.format('(enter! (file "%s"))\n', file_path))
        end
      end, 500)
    end, { desc = "Start Racket REPL and enter current file" })

  '';
}
