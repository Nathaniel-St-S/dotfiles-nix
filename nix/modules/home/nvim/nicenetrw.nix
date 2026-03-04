{ ... }:{
  programs.neovim.initLua = /* lua */ ''
    vim.g.netrw_winsize     = 20
    vim.g.netrw_banner      = 0
    vim.g.netrw_keepdir     = 0
    vim.g.netrw_sort_sequence = [[[\/]$,*]]
    vim.g.netrw_sizestyle   = "H"
    vim.g.netrw_liststyle   = 0
    vim.g.netrw_list_hide   = '^\\.\\.\\?/$,\\(^\\|\\s\\s\\)\\zs\\.\\S\\+'
    
    if vim.fn.has("unix") == 1 then
      vim.g.netrw_localcopydircmd = "cp -r"
      vim.g.netrw_localmkdir      = "mkdir -p"
      vim.g.netrw_localrmdir      = "rm -r"
    end
    
    vim.cmd("hi! link netrwMarkFile Search")
    
    local function draw_icons()
      if vim.bo.filetype ~= "netrw" then return end
      local ok, devicons = pcall(require, "nvim-web-devicons")
      if not ok then return end
    
      local default_signs = {
        netrw_dir  = { text = "",  texthl = "netrwDir"     },
        netrw_file = { text = "",  texthl = "netrwPlain"   },
        netrw_exec = { text = "",  texthl = "netrwExe"     },
        netrw_link = { text = "",  texthl = "netrwSymlink" },
      }
    
      local bufnr = vim.api.nvim_win_get_buf(0)
    
      vim.fn.sign_unplace("*", { buffer = bufnr })
      for name, opts in pairs(default_signs) do
        vim.fn.sign_define(name, opts)
      end
    
      for lnum = 1, vim.fn.line("$") do
        local line = vim.fn.getline(lnum)
        local sign_name = "netrw_file"
    
        if not line or line == "" then
          -- Skip empty lines
        elseif line:find("/$") then
          sign_name = "netrw_dir"
        elseif line:find("@%s+-->") then
          sign_name = "netrw_link"
        elseif line:find("%*$") then
          sign_name = "netrw_exec"
        else
          local ext = line:match("^.*%.(.*)")
          if not ext then
            if     line:find("LICENSE") then ext = "md"
            elseif line:find("rc$")     then ext = "conf"
            end
          end
          ext = ext or "default"
    
          local icon, hl = devicons.get_icon(line, ext, { default = "" })
          sign_name = "netrw_" .. ext
          vim.fn.sign_define(sign_name, { text = icon, texthl = hl })
        end
    
        vim.fn.sign_place(lnum, sign_name, sign_name, bufnr, { lnum = lnum })
      end
    end
    
    local function winbar_path()
      return "%#StatuslineTextMain# " .. vim.fn.expand("%:~")
    end
    
    function TargetDir()
      local target = vim.fn["netrw#Expose"]("netrwmftgt")
      if target == "n/a" then
        return "Target: None "
      end
      return "Target: " .. target:gsub("^" .. vim.loop.os_homedir(), "~") .. " "
    end
    
    WinBarNetRW = function()
      return table.concat({ winbar_path(), "%=", " ", TargetDir(), "%<" })
    end
    
    local augroup = vim.api.nvim_create_augroup("NetrwCustom", { clear = true })
    
    vim.api.nvim_create_autocmd("FileType", {
      group   = augroup,
      pattern = "netrw",
      callback = function()
        vim.wo.conceallevel = 2
        vim.wo.concealcursor = "nvc"
        vim.fn.matchadd("Conceal", "|", 10, -1, { conceal = "│" })
    
        vim.api.nvim_create_autocmd("CursorMoved", {
          buffer   = 0,
          callback = function() vim.cmd("redrawstatus") end,
        })
    
        vim.opt_local.winbar = "%!v:lua.WinBarNetRW()"
    
        draw_icons()
    
        vim.schedule(function()
          if vim.bo.filetype ~= "netrw" then return end
          local opts = { noremap = true, silent = true, buffer = true }
          local map  = vim.keymap.set
    
          -- Toggle dotfiles
          map("n", ".", function()
            vim.cmd("normal gh")
            vim.cmd("redrawstatus")
          end, opts)
    
          -- Show all currently marked files
          map("n", "fm", function()
            local files = vim.fn["netrw#Expose"]("netrwmarkfilelist")
            if type(files) == "table" and #files > 0 then
              print("Marked files:\n" .. table.concat(files, "\n"))
            else
              print("No marked files")
            end
          end, opts)
        end)
      end,
    })
    
    vim.api.nvim_create_autocmd("TextChanged", {
      group    = augroup,
      pattern  = "*",
      callback = draw_icons,
    })
  '';
}
