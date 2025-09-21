require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- JSON formatting
map("n", "<leader>fj", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format JSON file" })

-- Yazi file manager keybindings
map("n", "<leader>-", "<cmd>Yazi<cr>", { desc = "Open yazi at current file" })
map("n", "<leader>cw", "<cmd>Yazi cwd<cr>", { desc = "Open yazi in working directory" })
map("n", "<c-up>", "<cmd>Yazi toggle<cr>", { desc = "Resume last yazi session" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
