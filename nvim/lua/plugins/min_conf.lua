-- stuff that really doesnt deserve its own file

return {
  { "linux-cultist/venv-selector.nvim", enabled = true },
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
    },
  },
  {
    "saghen/blink.cmp",
    opts = {
      keymap = { preset = "default" },
      signature = { enabled = true },
    },
  },
}
