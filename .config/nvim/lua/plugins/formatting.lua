return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local enabled = {
          python = true,
          lua = true,
          javascript = true,
          typescript = true,
          javascriptreact = true,
          typescriptreact = true,
          html = true,
          css = true,
          java = true,
        }
        if enabled[vim.bo[bufnr].filetype] then
          return { timeout_ms = 500 }
        end
      end,
      default_format_opts = {
        lsp_format = 'fallback',
      },
      formatters_by_ft = {
        python = { 'black' },
        lua = { 'stylua' },
        javascript = { 'prettierd' },
        typescript = { 'prettierd' },
        javascriptreact = { 'prettierd' },
        typescriptreact = { 'prettierd' },
        html = { 'prettierd' },
        css = { 'prettierd' },
        java = { 'prettierd' },
      },
    },
    keys = {
      {
        '<leader>f',
        function() require('conform').format { async = true } end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
  },
}
