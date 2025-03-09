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
  {
    "BourbonBidet/Barpoon",
    dependencies = {
      { "ThePrimeagen/harpoon", branch = "harpoon2" },

      -- NOTE: Pick one
      { "akinsho/bufferline.nvim" },
      -- {'romgrk/barbar.nvim'},
    },
    opts = {
      plugin = nil, -- nil | 'bufferline' | 'barbar' : The bufferline plugin to use, will automatically detect installed plugin if set to nil

      open_tab_for_current_buffer = true, -- Open a tab while viewing a buffer that's not harpooned, and then close it when leaving the buffer

      show_pin_button_on_temp_tab = true, -- Replace the close button with a pin button on the temp tab, to add it to harpoon list

      pin_icon = "󰐃", -- Icon used for the pin button  NOTE: This button will harpoon the tab, not the built-in pin feature from bufferline or barbar

      -- list of labels to correspond with your harpoon keymaps
      key_labels = nil, -- eg. 'hjkl;HJKL'

      --NOTE: config exlusive to bufferline.nvim
      bufferline = { -- Config options specific to bufferline.nvim

        hide_threshold = 0, -- Hide bufferline when less than or equal to hide_tab_amount. (Bufferline's default is 1, but for Barpoon it makes sense to show all Harpoon'd tabs)
        -- INFO: Must also set 'always_show_bufferline = false' and 'auto_toggle_bufferline = true' in your bufferline config
      },
    }, -- Config here
  },
}
