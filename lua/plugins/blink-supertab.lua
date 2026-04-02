return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      preset = "default",
      ["<Tab>"] = {
        function(cmp)
          return cmp.is_visible() and cmp.select_next() or false
        end,
        "fallback",
      },
      ["<S-Tab>"] = {
        function(cmp)
          return cmp.is_visible() and cmp.select_prev() or false
        end,
        "fallback",
      },
      ["<CR>"] = {
        function(cmp)
          return cmp.is_visible() and cmp.accept() or false
        end,
        "fallback",
      },
    },
  },
}
