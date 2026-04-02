-- ~/.config/nvim/lua/plugins/swift.lua
-- Swift.nvim для LazyVim - ВСЕ команды под <leader>X

return {
  {
    "devswiftzone/swift.nvim",
    ft = "swift",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      features = {
        lsp = {
          enabled = true,
          auto_setup = true,
          on_attach = function(client, bufnr)
            -- Отключаем старый маппинг для <Space>e <Space>q
            vim.keymap.del("n", "<leader>e", { buffer = bufnr })
            vim.keymap.del("n", "<leader>f", { buffer = bufnr })
            vim.keymap.del("n", "<leader>ca", { buffer = bufnr })
            vim.keymap.del("n", "<leader>rn", { buffer = bufnr })
            vim.keymap.del("n", "<leader>q", { buffer = bufnr })
            vim.keymap.del("n", "[d", { buffer = bufnr })
            vim.keymap.del("n", "]d", { buffer = bufnr })
          end,
        },
        formatter = { enabled = true, auto_format = true, tool = "swiftformat" },
        linter = { enabled = true, auto_lint = true, severety = "warning", config_file = "~/.swiftlinter.yml" },
        build_runner = { enabled = true, show_output = true },
        target_manager = { enabled = true, auto_select = true },
        -- debugger отключен потому что нормально не рабоатет!
        debugger = {
          enabled = false,
          lldb_path = nil, -- nil = auto-detect

          -- Visual indicators
          signs = {
            breakpoint = "●", -- Breakpoint symbol
            current_line = "➤", -- Current line symbol
          },

          -- Colors (Neovim highlight groups)
          colors = {
            breakpoint = "DiagnosticError",
            current_line = "DiagnosticInfo",
          },

          -- Debug output window
          window = {
            position = "bottom", -- "bottom", "right", "float"
            size = 15, -- Height/width depending on position
          },
        },
        snippets = { enabled = true },
        xcode = { enabled = vim.fn.has("mac") == 1 },
        project_detector = { enabled = true },
        version_validator = { enabled = true },
      },
    },

    config = function(_, opts)
      require("swift").setup(opts)

      local map = vim.keymap.set
      local window_height = math.floor(vim.o.columns * 0.25)

      -- BUILD
      -- map("n", "<leader>Xb", ":SwiftBuild<CR>", { desc = "Build" })
      map("n", "<leader>Xb", function()
        vim.cmd("botright vsplit | terminal swift build 2>&1 | xcbeautify")
        -- vim.cmd("resize " .. window_height)
        vim.cmd("setlocal bufhidden=wipe")
        vim.cmd("nnoremap <buffer> q :bdelete!<CR>")
      end, { desc = "Build" })

      -- map("n", "<leader>Xr", ":SwiftRun<CR>", { desc = "Run" })
      map("n", "<leader>Xr", function()
        vim.cmd("botright  vsplit | terminal swift run")
        -- vim.cmd("resize " .. window_height)
        vim.cmd("setlocal bufhidden=wipe")
        vim.cmd("nnoremap <buffer> q :bdelete!<CR>")
      end, { desc = "Run" })

      -- map("n", "<leader>Xt", ":SwiftTest<CR>", { desc = "Test All" })
      map("n", "<leader>Xt", function()
        vim.cmd("botright  vsplit | terminal swift test 2>&1 | xcbeautify")
        -- vim.cmd("resize " .. window_height)
        vim.cmd("setlocal bufhidden=wipe")
        vim.cmd("nnoremap <buffer> q :bdelete!<CR>")
      end, { desc = "Test All" })

      map("n", "<leader>Xc", function()
        vim.cmd("botright  vsplit | terminal swift clean")
        -- vim.cmd("resize " .. window_height)
        vim.cmd("setlocal bufhidden=wipe")
        vim.cmd("nnoremap <buffer> q :bdelete!<CR>")
      end, { desc = "Clean" })

      map("n", "<leader>XR", ":SwiftRelease<CR>", { desc = "Release Build" })

      -- TARGET
      map("n", "<leader>XTg", ":SwiftTarget<CR>", { desc = "Select Target" })
      map("n", "<leader>XTl", ":SwiftTargetList<CR>", { desc = "List Targets" })

      -- PLATFORM & SIMULATOR
      map("n", "<leader>Xp", ":SwiftPlatform pick<CR>", { desc = "Pick Platform" })
      map("n", "<leader>Xi", ":SwiftSimulator list<CR>", { desc = "List Simulators" })
      map("n", "<leader>XI", ":SwiftSimulator boot<CR>", { desc = "Boot Simulator" })
      map("n", "<leader>Xk", ":SwiftSimulator shutdown<CR>", { desc = "Shutdown Simulator" })

      -- XCODE
      if vim.fn.has("mac") == 1 then
        map("n", "<leader>XXb", ":SwiftXcodeBuild<CR>", { desc = "Xcode Build" })
        map("n", "<leader>XXs", ":SwiftXcodeScheme<CR>", { desc = "Xcode Select Scheme" })
        map("n", "<leader>XXo", ":SwiftXcodeOpen<CR>", { desc = "Open in Xcode" })
      end

      -- SNIPPETS & FORMAT
      map("n", "<leader>Xs", ":SwiftSnippets<CR>", { desc = "List Snippets" })
      map("n", "<leader>Xf", ":SwiftFormat<CR>", { desc = "Format File" })
      map("v", "<leader>Xf", ":SwiftFormatSelection<CR>", { desc = "Format Selection" })

      -- INFO
      map("n", "<leader>Xv", ":SwiftVersionInfo<CR>", { desc = "Version Info" })
      map("n", "<leader>Xh", ":checkhealth swift<CR>", { desc = "Health Check" })
    end,
  },

  -- ═══════════════════════════════════════════════════════════════════
  -- ПРОСТОЕ ДОБАВЛЕНИЕ КОНФИГУРАЦИЙ DAP
  -- ═══════════════════════════════════════════════════════════════════
  {
    "mfussenegger/nvim-dap",
    -- ОПЦИИ: LazyVim автоматически смерджит наши opts с их настройками
    opts = {
      adapters = {
        lldb = function(callback, config)
          local lldb_dap_path = vim.fn.trim(vim.fn.system("xcrun -f lldb-dap"))
          callback({
            type = "executable",
            command = lldb_dap_path,
            name = "lldb",
          })
        end,
      },
      configurations = {
        swift = {
          {
            name = "Launch Swift executable",
            type = "lldb",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/.build/debug/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            args = {},
            console = "externalTerminal",
          },
          {
            name = "Attach to process",
            type = "lldb",
            request = "attach",
            program = function()
              return vim.fn.input("Process ID or name: ")
            end,
          },
        },
        swift_test = {
          {
            name = "Run Swift tests",
            type = "lldb",
            request = "launch",
            program = function()
              local test_path = vim.fn.getcwd() .. "/.build/debug/"
              local test_name = vim.fn.glob(test_path .. "*PackageTests.xctest/Contents/MacOS/*")
              if test_name == "" then
                test_name = vim.fn.input("Path to test executable: ", test_path, "file")
              end
              return test_name
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            args = {},
            console = "externalTerminal",
          },
        },
      },
    },
  },

  -- ═══════════════════════════════════════════════════════════════════
  -- WHICH-KEY
  -- ═══════════════════════════════════════════════════════════════════
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>X", group = "Swift" },
        { "<leader>XX", group = "Xcode" },
        { "<leader>XT", group = "Target" },
      },
    },
  },

  -- ═══════════════════════════════════════════════════════════════════
  -- Treesitter
  -- ═══════════════════════════════════════════════════════════════════
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "swift" })
      end
    end,
  },
}
