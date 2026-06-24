vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = { "*.ts", "*.tsx" },
  callback = function(args)
    local util = require("lspconfig.util")
    local root = util.root_pattern("deno.json", "deno.jsonc")(args.file)

    if root then
      -- You're in a Deno project! Do whatever you want here.
      vim.b.deno_project = true -- Optional: set a buffer-local flag

      local dap = require("dap")

      dap.configurations["typescript"] = {
        {
          name = "Deno Launch",
          request = "launch",
          type = "pwa-node",
          cwd = "${workspaceFolder}",
          runtimeExecutable = "deno",
          runtimeArgs = { "run", "--inspect-brk", "--allow-all" },
          program = "${file}",
          attachSimplePort = 9229,
        },
      }
    end
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = { "*.py" },
  callback = function(args)
    local util = require("lspconfig.util")
    local root = util.root_pattern("manage.py")(args.file)

    if root then
      vim.b.django_project = true

      local dap = require("dap")

      dap.configurations["python"] = {
        {
          name = "Uvicorn Launch",
          request = "launch",
          type = "debugpy",
          cwd = "${workspaceFolder}",
          runtimeExecutable = "python",
          program = "runner.py",
          args = {"--debug"},
          console = "integratedTerminal",
        },
        {
          name = "Django Launch",
          request = "launch",
          type = "debugpy",
          cwd = "${workspaceFolder}",
          runtimeExecutable = "python",
          program = "manage.py",
          args = { "runserver" },
        },
      }
    end
  end,
})

-- local open_window = function(cmd)
--   local term_buf = vim.api.nvim_create_buf(false, true) -- [listed=false, scratch=true]
--   local width = math.floor(vim.o.columns * 0.8)
--   local height = math.floor(vim.o.lines * 0.8)
--   local row = math.floor((vim.o.lines - height) / 2)
--   local col = math.floor((vim.o.columns - width) / 2)
--
--   local term_win = vim.api.nvim_open_win(term_buf, true, {
--     relative = "editor",
--     width = width,
--     height = height,
--     row = row,
--     col = col,
--     style = "minimal",
--     border = "rounded",
--   })
--
--   local job_id = vim.fn.termopen(cmd)
--
--   vim.cmd("startinsert")
--
--   local quit = function()
--     if job_id > 0 then
--       vim.fn.jobstop(job_id)
--     end
--     vim.api.nvim_win_close(term_win, true)
--   end
--
--   vim.keymap.set({ "n", "t" }, "q", quit, { buffer = term_buf, nowait = true })
-- end
--
-- local rbg = vim.api.nvim_create_augroup("rust-binds", {})
-- vim.api.nvim_create_autocmd({ "FileType" }, {
--   pattern = "rust",
--   group = rbg,
--   callback = function(o)
--     local opts = { silent = true, noremap = true, buffer = o.buf }
--     local map = function(mode, keys, cmd, desc)
--       opts.desc = desc
--       vim.keymap.set(mode, keys, cmd, opts)
--     end
--
--     map("n", "<leader>mc", function()
--       open_window("cargo clippy")
--     end, "Clippy")
--
--     map("n", "<leader>mf", function()
--       open_window("cargo fmt")
--     end, "Format all")
--
--     map("n", "<leader>ms", function()
--       open_window("cargo sqlx prepare")
--     end, "SQLX Prepare")
--
--     map("n", "<leader>mb", function()
--       open_window("cargo build")
--     end, "Build")
--
--     map("n", "<leader>mr", function()
--       open_window("cargo run")
--     end, "Run")
--
--     map("n", "<leader>mt", function()
--       open_window("cargo test")
--     end, "Test")
--   end,
-- })
--
-- local make_term_navigable = function(term)
--   vim.keymap.set({ "n", "t" }, "q", function()
--     term:shutdown()
--   end, { buffer = term.bufnr, nowait = true })
--
--   vim.keymap.set("t", "<c-h>", "<C-\\><C-n><cmd>TmuxNavigateLeft<cr>", { buffer = term.bufnr })
--   vim.keymap.set("n", "<c-h>", ":TmuxNavigateLeft<cr>", { buffer = term.bufnr })
--   vim.keymap.set("t", "<c-j>", "<C-\\><C-n><cmd>TmuxNavigateDown<cr>", { buffer = term.bufnr })
--   vim.keymap.set("n", "<c-j>", ":TmuxNavigateDown<cr>", { buffer = term.bufnr })
--   vim.keymap.set("t", "<c-k>", "<C-\\><C-n><cmd>TmuxNavigateUp<cr>", { buffer = term.bufnr })
--   vim.keymap.set("n", "<c-k>", ":TmuxNavigateUp<cr>", { buffer = term.bufnr })
--   vim.keymap.set("t", "<c-l>", "<C-\\><C-n><cmd>TmuxNavigateRight<cr>", { buffer = term.bufnr })
--   vim.keymap.set("n", "<c-l>", ":TmuxNavigateRight<cr>", { buffer = term.bufnr })
-- end
--
-- local tsbg = vim.api.nvim_create_augroup("ts-binds", {})
-- vim.api.nvim_create_autocmd({ "FileType" }, {
--   pattern = { "typescriptreact", "typescript" },
--   group = tsbg,
--   callback = function(o)
--     local Terminal = require("toggleterm.terminal").Terminal
--
--     local run_term = Terminal:new({
--       cmd = "yarn run dev",
--       display_name = "Run",
--       hidden = true,
--       direction = "horizontal",
--       auto_scroll = true,
--       close_on_exit = false,
--     })
--
--     local opts = { silent = true, noremap = true, buffer = o.buf }
--     local map = function(mode, keys, cmd, desc)
--       opts.desc = desc
--       vim.keymap.set(mode, keys, cmd, opts)
--     end
--
--     map("n", "<leader>mr", function()
--       run_term:toggle()
--     end, "Run")
--
--     make_term_navigable(run_term)
--   end,
-- })
--
-- local pbg = vim.api.nvim_create_augroup("python-binds", {})
-- vim.api.nvim_create_autocmd({ "FileType" }, {
--   pattern = "python",
--   group = pbg,
--   callback = function(o)
--     local Terminal = require("toggleterm.terminal").Terminal
--
--     local run_term = Terminal:new({
--       cmd = "python manage.py runserver",
--       display_name = "Run",
--       hidden = true,
--       direction = "horizontal",
--       auto_scroll = true,
--       close_on_exit = false,
--     })
--
--     local opts = { silent = true, noremap = true, buffer = o.buf }
--     local map = function(mode, keys, cmd, desc)
--       opts.desc = desc
--       vim.keymap.set(mode, keys, cmd, opts)
--     end
--
--     map("n", "<leader>mr", function()
--       run_term:toggle()
--     end, "Run")
--
--     make_term_navigable(run_term)
--   end,
-- })
