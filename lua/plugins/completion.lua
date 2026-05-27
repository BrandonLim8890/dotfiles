return {
  {
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      { 'L3MON4D3/LuaSnip', version = '2.*', opts = {} },
      'folke/lazydev.nvim',
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = { preset = 'enter' },
      appearance = { nerd_font_variant = 'mono' },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
        accept = { auto_brackets = { enabled = false } },
      },
      sources = {
        default = { 'lsp', 'path', 'lazydev', 'snippets' },
        providers = {
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
