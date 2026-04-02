return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts_extend = { "spec" },
  opts = {
    preset = "modern",
    defaults = {},
    spec = {
      {
        mode = { "n", "x" },
        { "<leader>a", group = "+ai" },
      },
    },
  },
}
