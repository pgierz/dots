-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

-- general
lvim.log.level = "warn"
lvim.format_on_save.enabled = true
lvim.colorscheme = "catppuccin-macchiato"
lvim.transparent_window = true
vim.wo.relativenumber = true

lvim.builtin.treesitter.ensure_installed = {
  "bash",
  "c",
  "fortran",
  "lua",
  "json",
  "yaml",
  "python",
  "r",
}
lvim.builtin.treesitter.highlight.enable = true

local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  {
    command = "black",
    filetypes = { "python" }
  },
  {
    command = "isort",
    filetypes = { "python" }
  },
  {
    command = "prettier",
    filetypes = { "yaml", "json" },
  },
}

local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
  { command = "flake8",     filetypes = { "python" } },
  { command = "shellcheck", },
  { command = "codespell", },
}

-- Additional Plugins
lvim.plugins = {
  { "christoomey/vim-tmux-navigator", lazy = false },
  { "catppuccin/nvim",                as = "catppuccin" },
  { "dracula/vim" },
  { "github/copilot.vim" },
  {
    "jackMort/ChatGPT.nvim",
    config = function()
      require("chatgpt").setup({
        -- api_key_command = "gpg --decrypt ~/.local/share/password-store/tokens/chatgpt.gpg 2>/dev/null",
      }
      )
    end,
    requires = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim"
    }
  },
}

-- Tmux Navigator Keybindings
--

-- For copilot (see if this can be integrated into the plugin setup command ...?)
-- https://www.reddit.com/r/neovim/comments/qsfvki/how_to_remap_copilotvim_accept_method_in_lua/
-- Use <C-/> to accept the suggestion
vim.api.nvim_set_keymap('i', '<C-_>', 'copilot#Accept("<CR>")', { expr = true, silent = true })
-- Or use <C-e> to cancel the suggestion
vim.api.nvim_set_keymap('i', '<C-e>', 'copilot#Cancel()', { expr = true, silent = true })

-- General AI:
lvim.builtin.which_key.mappings["A"] = {
  -- Keymap for AI completion
  name = "AI",
  ["G"] = {
    name = "AI Completion Copilot",
    c = { "<cmd>Copilot .complete()<cr>", "Complete" },
    a = { "<cmd>lua require('copilot').accept()<cr>", "Accept" },
    o = { "<cmd>lua require('copilot').cancel()<cr>", "Cancel" },
  },
  -- Keymap for sending a request to ChatGPT
  ["C"] = {
    name = "ChatGPT",
    c = { "<cmd>ChatGPT<cr>", "ChatGPT" },
    a = { "<cmd>ChatGPTActAs<cr>", "ChatGPTActAs" },
    o = { "<cmd>ChatGPTCompleteCode<cr>", "ChatGPTCompleteCode" },
  },
}
