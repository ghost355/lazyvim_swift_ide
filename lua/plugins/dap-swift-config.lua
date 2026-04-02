-- ~/.config/nvim/lua/plugins/dap-swift-config.lua

return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
  },
  keys = {
    -- F5: Continue / Start debugging
    {
      "<F5>",
      function()
        require("dap").continue()
      end,
      desc = "Debug: Continue / Start",
    },
    -- F9: Toggle breakpoint
    {
      "<F9>",
      function()
        require("dap").toggle_breakpoint()
      end,
      desc = "Debug: Toggle breakpoint",
    },
    -- F10: Step over
    {
      "<F10>",
      function()
        require("dap").step_over()
      end,
      desc = "Debug: Step over",
    },
    -- F11: Step into
    {
      "<F11>",
      function()
        require("dap").step_into()
      end,
      desc = "Debug: Step into",
    },
    -- F12: Step out
    {
      "<F12>",
      function()
        require("dap").step_out()
      end,
      desc = "Debug: Step out",
    },
    -- <leader>dX : Clear Breakpoints
    {
      "<leader>dX",
      function()
        require("dap").list_breakpoints()
      end,
      desc = "Clear All Breakpoints",
    },
  },
  config = function()
    local dap = require("dap")

    -- 1. СНАЧАЛА НАСТРАИВАЕМ DAP (без dap-ui)

    -- Красивые символы для breakpoint
    vim.fn.sign_define("DapBreakpoint", {
      text = "●",
      texthl = "DiagnosticError",
      linehl = "",
      numhl = "",
    })

    vim.fn.sign_define("DapBreakpointCondition", {
      text = "",
      texthl = "DiagnosticInfo",
      linehl = "",
      numhl = "",
    })

    vim.fn.sign_define("DapStopped", {
      text = "➤",
      texthl = "DiagnosticWarn",
      linehl = "Visual",
      numhl = "DiagnosticWarn",
    })

    -- Адаптер для lldb
    local lldb_path = vim.fn.trim(vim.fn.system("xcrun -f lldb-dap"))

    dap.adapters.lldb = {
      type = "executable",
      command = lldb_path,
      name = "lldb",
    }

    -- Функция для поиска пути в Xcode проекте
    local function find_xcode_executable()
      local current_dir = vim.fn.getcwd()
      local project_name = vim.fn.fnamemodify(current_dir, ":t")

      -- Пытаемся найти через xcodebuild
      local output =
        vim.fn.system("xcodebuild -showBuildSettings 2>/dev/null | grep -m1 'BUILT_PRODUCTS_DIR' | awk '{print $3}'")
      local built_products_dir = vim.fn.trim(output)

      if built_products_dir ~= "" then
        -- Формируем путь к исполняемому файлу внутри .app
        local scheme_output = vim.fn.system("xcodebuild -list 2>/dev/null | grep -A1 'Schemes:' | tail -n1 | xargs")
        local scheme_name = vim.fn.trim(scheme_output)

        if scheme_name == "" then
          scheme_name = project_name
        end

        -- Путь к .app и исполняемому файлу внутри
        local app_path = built_products_dir .. "/" .. scheme_name .. ".app"
        local executable_path = app_path .. "/" .. scheme_name

        if vim.fn.filereadable(executable_path) == 1 then
          return executable_path
        end

        -- Альтернативный вариант: ищем любой .app
        local find_app = vim.fn.system("find " .. built_products_dir .. " -name '*.app' -type d 2>/dev/null | head -1")
        local app_dir = vim.fn.trim(find_app)
        if app_dir ~= "" then
          local app_name = vim.fn.fnamemodify(app_dir, ":t:r")
          return app_dir .. "/" .. app_name
        end
      end

      -- Если не нашли, ищем через find в DerivedData
      local derived_data = vim.fn.expand("~/Library/Developer/Xcode/DerivedData")
      local find_cmd = string.format(
        "find %s -path '*/Build/Products/Debug-*/*.app' -name '%s' 2>/dev/null | head -1",
        derived_data,
        project_name
      )
      local app_path = vim.fn.trim(vim.fn.system(find_cmd))

      if app_path ~= "" then
        return app_path .. "/" .. project_name
      end

      -- Если ничего не нашли, предлагаем ввести вручную
      return vim.fn.input("Path to executable: ", "", "file")
    end

    -- Конфигурации для Swift проектов
    dap.configurations = dap.configurations or {}

    dap.configurations.swift = {
      {
        name = "Launch SPM executable",
        type = "lldb",
        request = "launch",
        program = function()
          local current_dir = vim.fn.getcwd()
          local project_name = vim.fn.fnamemodify(current_dir, ":t")
          local default_path = current_dir .. "/.build/debug/" .. project_name

          if vim.fn.filereadable(current_dir .. "/Package.swift") == 1 then
            if vim.fn.filereadable(default_path) == 1 then
              return default_path
            end
          end

          return find_xcode_executable()
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = {},
        console = "externalTerminal",
      },
      {
        name = "Launch Xcode app (auto-detect)",
        type = "lldb",
        request = "launch",
        program = find_xcode_executable,
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
    }

    dap.configurations.swift_test = {
      {
        name = "Run Swift tests",
        type = "lldb",
        request = "launch",
        program = function()
          if vim.fn.filereadable(vim.fn.getcwd() .. "/Package.swift") == 1 then
            local test_path = vim.fn.getcwd() .. "/.build/debug/"
            local test_name = vim.fn.glob(test_path .. "*PackageTests.xctest/Contents/MacOS/*")
            if test_name == "" then
              local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
              test_name = test_path
                .. project_name
                .. "PackageTests.xctest/Contents/MacOS/"
                .. project_name
                .. "PackageTests"
            end
            return test_name
          else
            local output = vim.fn.system(
              "xcodebuild -showBuildSettings 2>/dev/null | grep -m1 'BUILT_PRODUCTS_DIR' | awk '{print $3}'"
            )
            local built_products_dir = vim.fn.trim(output)

            if built_products_dir ~= "" then
              local find_test =
                vim.fn.system("find " .. built_products_dir .. " -name '*.xctest' -type d 2>/dev/null | head -1")
              local test_bundle = vim.fn.trim(find_test)
              if test_bundle ~= "" then
                local test_name = vim.fn.fnamemodify(test_bundle, ":t:r")
                return test_bundle .. "/Contents/MacOS/" .. test_name
              end
            end
          end

          return vim.fn.input("Path to test executable: ", "", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = {},
        console = "externalTerminal",
      },
    }

    print("✅ Swift DAP configurations loaded (SPM + Xcode)")
  end,
}
