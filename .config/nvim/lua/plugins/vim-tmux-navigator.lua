return {
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Tmux Navigate Left" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Tmux Navigate Down" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Tmux Navigate Up" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Tmux Navigate Right" },
      { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Tmux Navigate Previous" },
      { "<C-h>", [[<C-\><C-n><cmd>TmuxNavigateLeft<cr>]],     mode = "t", desc = "Tmux Navigate Left" },
      { "<C-j>", [[<C-\><C-n><cmd>TmuxNavigateDown<cr>]],     mode = "t", desc = "Tmux Navigate Down" },
      { "<C-k>", [[<C-\><C-n><cmd>TmuxNavigateUp<cr>]],       mode = "t", desc = "Tmux Navigate Up" },
      { "<C-l>", [[<C-\><C-n><cmd>TmuxNavigateRight<cr>]],    mode = "t", desc = "Tmux Navigate Right" },
    },
  },
}
