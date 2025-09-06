return {
  "nvimdev/lspsaga.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-treesitter/nvim-web-devicons",
  },
  config = function()
    require("lspsaga").setup()
  end,
}
