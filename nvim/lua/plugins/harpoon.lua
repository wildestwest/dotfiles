-- these are based on the home row for me as I use the engramm keyboard layout.

return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")

      harpoon:setup()

      vim.keymap.set("n", "<leader>h", function()
        harpoon:list():add()
      end, { desc = "harpoon add" })
      vim.keymap.set("n", "<leader><C-h>", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = "Show harpoon list" })
      vim.keymap.set("n", "<C-c>", function()
        harpoon:list():select(1)
      end, { desc = "show harpoon slot 1" })
      vim.keymap.set("n", "<C-i>", function()
        harpoon:list():select(2)
      end, { desc = "show harpoon slot 2" })
      vim.keymap.set("n", "<C-e>", function()
        harpoon:list():select(3)
      end, { desc = "show harpoon slot 3" })
      vim.keymap.set("n", "<C-a>", function()
        harpoon:list():select(4)
      end, { desc = "show harpoon slot 4" })
      vim.keymap.set("n", "<leader><C-c>", function()
        harpoon:list():replace_at(1)
      end, { desc = "replace harpoon slot 1" })
      vim.keymap.set("n", "<leader><C-i>", function()
        harpoon:list():replace_at(2)
      end, { desc = "replace harpoon slot 2" })
      vim.keymap.set("n", "<leader><C-e>", function()
        harpoon:list():replace_at(3)
      end, { desc = "replace harpoon slot 3" })
      vim.keymap.set("n", "<leader><C-a>", function()
        harpoon:list():replace_at(4)
      end, { desc = "replace harpoon slot 4" })
    end,
  },
}
