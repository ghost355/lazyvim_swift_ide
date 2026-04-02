-- ═══════════════════════════════════════════════════════════════════════
-- ОТДЕЛЬНЫЙ ПЛАГИН ДЛЯ DAP-UI (чтобы избежать конфликта)
-- ═══════════════════════════════════════════════════════════════════════
return {
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dapui = require("dapui")

      -- Настройка dap-ui
      dapui.setup({
        layouts = {
          {
            elements = {
              { id = "scopes", size = 0.25 },
              { id = "breakpoints", size = 0.25 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.25 },
            },
            position = "left",
            size = 80,
          },
          {
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
            position = "bottom",
            size = 20,
          },
        },
      })

      -- Подключаем события dap-ui ПОСЛЕ настройки
      local dap = require("dap")

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end

      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end

      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      print("✅ dap-ui configured")
    end,
  },
}
