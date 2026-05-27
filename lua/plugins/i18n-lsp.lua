local env = require 'env'
if not env.is_hubspot then
  return {}
end

vim.lsp.config('i18n_lsp', {
  cmd = { 'i18n_lsp' },
  filetypes = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
  root_markers = { '.blazar-enabled', 'package.json', '.git' },
})

vim.lsp.enable 'i18n_lsp'

return {}
