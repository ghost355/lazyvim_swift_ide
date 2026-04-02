-- ~/.config/nvim/lua/plugins/xkbswitch.lua
return {
  "ivanesmantovich/xkbswitch.nvim",
  lazy = false, -- загружать сразу при старте
  priority = 1000, -- высокий приоритет для ранней загрузки
  config = function()
    -- Базовая настройка
    require("xkbswitch").setup()
  end,
}

