-- Простейшая настройка проверки орфографии
return {
  {
    "LazyVim/LazyVim",
    -- Просто добавляем автокоманду, ничего не ломаем
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "md", "text", "txt", "gitcommit" },
        callback = function()
          vim.opt_local.spell = true
          vim.opt_local.spelllang = { "ru", "en" }
        end,
      })
    end,
  },
}
