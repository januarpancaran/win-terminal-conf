return {
  {
    "mason-org/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  {
    "mason-org/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "bashls",
          "clangd",
          "cmake",
          "csharp_ls",
          "cssls",
          "gopls",
          "html",
          "intelephense",
          "jdtls",
          "jsonls",
          "lua_ls",
          "marksman",
          "ruff",
          "rust_analyzer",
          "sqls",
          "svelte",
          "tailwindcss",
          "terraformls",
          "ts_ls",
          "yamlls",
        }
      })
    end,
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")

      lspconfig.bashls.setup({})
      lspconfig.clangd.setup({})
      lspconfig.cmake.setup({})
      lspconfig.csharp_ls.setup({})
      lspconfig.cssls.setup({})
      lspconfig.gopls.setup({})
      lspconfig.html.setup({})
      lspconfig.intelephense.setup({})
      lspconfig.jdtls.setup({})
      lspconfig.jsonls.setup({})
      lspconfig.lua_ls.setup({})
      lspconfig.marksman.setup({})
      lspconfig.ruff.setup({})
      lspconfig.rust_analyzer.setup({})
      lspconfig.sqls.setup({})
      lspconfig.svelte.setup({})
      lspconfig.tailwindcss.setup({})
      lspconfig.terraformls.setup({})
      lspconfig.ts_ls.setup({})
      lspconfig.yamlls.setup({})
    end,
  },
}
