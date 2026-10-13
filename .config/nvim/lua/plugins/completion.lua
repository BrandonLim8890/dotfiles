return {
  {
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then return end
          return 'make install_jsregexp'
        end)(),
        opts = {},
      },
      'folke/lazydev.nvim',
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'enter',
        ['<C-f>'] = {
          function()
            local ok, suggestion = pcall(require, 'copilot.suggestion')
            if ok and suggestion.is_visible() then
              suggestion.accept()
              return true
            end
          end,
          'scroll_documentation_down',
          'fallback',
        },
      },
      appearance = { nerd_font_variant = 'mono' },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
        accept = { auto_brackets = { enabled = false } },
      },
      sources = {
        default = vim.list_extend({ 'lsp', 'path', 'lazydev', 'snippets' }, require('env').is_hubspot and { 'hs_translations' } or {}),
        providers = {
          hs_translations = require('env').is_hubspot and {
            name = 'HubSpot Translations',
            module = 'hubspot-completion',
            score_offset = 100,
          } or nil,
          lazydev = {
            min_keyword_length = 2,
            name = 'LazyDev',
            module = 'lazydev.integrations.blink',
            score_offset = 5,
          },
          path = { min_keyword_length = 0, score_offset = 10 },
          lsp = { score_offset = 1000 },
          snippets = { min_keyword_length = 2, score_offset = -100 },
        },
      },
      snippets = { preset = 'luasnip' },
      fuzzy = { implementation = 'lua' },
      signature = { enabled = true },
    },
  },

  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
}
