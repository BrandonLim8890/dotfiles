local env = require 'env'
if not env.is_hubspot then
  return {}
end

-- Disabled: hubspot-i18n-nvim (see hubspot-i18n.lua) now provides hover,
-- diagnostics, and completion for translation keys. Flip this to true to
-- bring the Rust `i18n_lsp` server back.
local enabled = false

vim.lsp.config('i18n_lsp', {
  cmd = { 'i18n_lsp' },
  filetypes = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
  root_markers = { '.blazar-enabled', 'package.json', '.git' },
})

if enabled then
  vim.lsp.enable 'i18n_lsp'
end

return {}
