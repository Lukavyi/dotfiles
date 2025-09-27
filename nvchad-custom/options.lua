require "nvchad.options"

-- add yours here!

-- Enable relative line numbers (hybrid with absolute)
vim.opt.relativenumber = true

-- Enable soft wrap (line wrap without inserting line breaks)
vim.opt.wrap = true
vim.opt.linebreak = true  -- Wrap at word boundaries
vim.opt.breakindent = true  -- Preserve indentation in wrapped text

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!