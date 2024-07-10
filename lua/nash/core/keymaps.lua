vim.g.mapleader = " "

local map = vim.keymap.set

map("n", "<leader>pv", vim.cmd.Ex)
map("n", "<leader><leader>", function()
  vim.cmd("so")
end)

map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })
map({ "i", "x", "n", "s" }, "<C-S-s>", "<cmd>wa<cr><esc>", { desc = "Save all files" })
map("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

map("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- increment/decrement numbers
map("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
map("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
map("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
map("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
map("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
map("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

-- buffer/tab management
map("n", "<leader>bp", "<cmd>BufferLinePick<CR>", { desc = "Bufferline pick" })
map("n", "<leader>bc", "<cmd>BufferLinePickClose<CR>", { desc = "Bufferline pick close" })
map("n", "<leader>tp", "<cmd>BufferLineCyclePrev<CR>", { desc = "Go to previous buffer" })
map("n", "<leader>tn", "<cmd>BufferLineCycleNext<CR>", { desc = "Go to next buffer" })
map("n", "<leader>tco", "<cmd>BufferLineCloseOthers<CR>", { desc = "Close other buffers" })
map("n", "<leader>tcl", "<cmd>BufferLineCloseLeft<CR>", { desc = "Close buffers to the left" })
map("n", "<leader>tcr", "<cmd>BufferLineCloseRight<CR>", { desc = "Close buffers to the right" })

--[[ map("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
map("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
map("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
map("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
map("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab ]]
