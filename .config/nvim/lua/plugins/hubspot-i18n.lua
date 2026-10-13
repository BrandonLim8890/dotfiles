local env = require 'env'
if not env.is_hubspot then
  return {}
end

return {
  url = 'git@github.com:HubSpotShare/hubspot-i18n-nvim.git',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'saghen/blink.cmp',
  },
  config = function()
    require('hubspot-i18n').setup {
      keys = {
        hover = 'K',
        -- gd is handled in search.lua: i18n key jump with Telescope fallback
        goto_definition = false,
      },
    }
  end,
}
