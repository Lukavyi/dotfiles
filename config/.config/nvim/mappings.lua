require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- JSON formatting
map("n", "<leader>fj", function()
  require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "Format JSON file" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
