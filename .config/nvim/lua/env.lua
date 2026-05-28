-- Centralized environment detection for this nvim config.
--
-- `is_hubspot` is true when the laptop has been provisioned with the HubSpot
-- toolchain (the `~/.hubspot` marker directory). Any HubSpot-specific plugin,
-- LSP config, autocmd, or user command must gate behind this flag so the same
-- config works on a personal machine.
--
-- The convention is: `local env = require 'env'` and then either
-- `if env.is_hubspot then ... end` for guarded side effects, or
-- `if not env.is_hubspot then return {} end` for entirely HubSpot-only plugins.

return {
  is_hubspot = vim.uv.fs_stat(vim.env.HOME .. '/.hubspot') ~= nil,
}
