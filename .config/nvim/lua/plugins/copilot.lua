return {
  'zbirenbaum/copilot.lua',
  cmd = 'Copilot',
  build = ':Copilot auth',
  event = 'BufReadPost',
  opts = {
    suggestion = {
      enabled = not vim.g.ai_cmp,
      auto_trigger = true,
      hide_during_completion = vim.g.ai_cmp,
      trigger_on_accept = false,
      keymap = {
        accept = '<C-f>',
        dismiss = '<C-x>',
      },
    },
  },
}
