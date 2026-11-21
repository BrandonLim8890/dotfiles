local env = require 'env'

-- Metals 2 (MBT mode) gives Java completion + diagnostics by importing the repo's
-- pom.xml. Generated classes (Immutables, CHIRP) only exist after a build, so:
--   mvn compile  →  :MetalsImportBuild
-- Adapted from https://github.com/jacobtie/dotfiles/blob/main/.config/nvim/lua/plugins/lsp.lua
if not env.is_hubspot then return {} end

-- Run `mvn compile` from the repo root so generated sources exist for Metals.
-- Doesn't re-import; follow up with :MetalsImportBuild (<leader>mb) when generated code changed.
local function mvn_compile()
  local buf = vim.api.nvim_get_current_buf()
  -- Prefer the git root's pom (the aggregator with <modules>) over a module's own pom.
  local git_root = vim.fs.root(buf, '.git') or vim.fn.getcwd()
  local root = vim.uv.fs_stat(git_root .. '/pom.xml') and git_root or vim.fs.root(buf, 'pom.xml')
  if not root then
    vim.notify('MvnCompile: no pom.xml found', vim.log.levels.WARN)
    return
  end

  local log = vim.fn.stdpath 'cache' .. '/mvn-compile.log'
  vim.notify('MvnCompile: mvn compile in ' .. vim.fs.basename(root), vim.log.levels.INFO)
  local started = vim.uv.now()
  vim.system({ 'mvn', 'compile' }, { cwd = root, text = true }, function(result)
    local f = io.open(log, 'w')
    if f then
      f:write((result.stdout or '') .. (result.stderr or ''))
      f:close()
    end
    local secs = math.floor((vim.uv.now() - started) / 1000)
    vim.schedule(function()
      if result.code == 0 then
        vim.notify(('✓ mvn compile (%ds) — run <leader>mb if generated code changed'):format(secs), vim.log.levels.INFO)
      else
        vim.notify(('✗ mvn compile failed (exit %d, %ds). Log: %s'):format(result.code, secs, log), vim.log.levels.ERROR)
      end
    end)
  end)
end

return {
  {
    'scalameta/nvim-metals',
    ft = { 'java' },
    -- init runs at startup, so :MvnCompile works before any Java file has loaded Metals.
    init = function()
      vim.api.nvim_create_user_command('MvnCompile', mvn_compile, { desc = 'Run `mvn compile` at the repo root' })
      vim.keymap.set('n', '<leader>mm', mvn_compile, { desc = '[M]vn co[M]pile repo' })
    end,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'saghen/blink.cmp',
    },
    opts = function()
      local metals_config = require('metals').bare_config()

      metals_config.capabilities = require('blink.cmp').get_lsp_capabilities()

      metals_config.settings = {
        metals = {
          -- MBT + Maven import only exists on the 2.x line; stable 1.x won't do Java this way.
          serverVersion = '2.0.0-RC1',
          serverProperties = { '-Xmx4g' },
          preferredBuildServer = 'MBT',
          autoImportBuild = 'initial',
          superMethodLensesEnabled = true,
          excludedPackages = {},
        },
      }

      metals_config.init_options = {
        statusBarProvider = 'off',
      }

      metals_config.on_attach = function(_, bufnr)
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'Metals: ' .. desc })
        end

        map('<leader>mc', '<cmd>MetalsCompileCascade<cr>', '[M]etals [C]ompile cascade')
        map('<leader>mb', '<cmd>MetalsImportBuild<cr>', '[M]etals import [B]uild')
        map('<leader>mi', '<cmd>MetalsInfo<cr>', '[M]etals [I]nfo')
        map('<leader>md', '<cmd>MetalsRunDoctor<cr>', '[M]etals [D]octor')
        map('<leader>mo', '<cmd>MetalsOrganizeImports<cr>', '[M]etals [O]rganize imports')
      end

      return metals_config
    end,
    config = function(self, metals_config)
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('nvim-metals', { clear = true }),
        pattern = self.ft,
        callback = function()
          require('metals').initialize_or_attach(metals_config)
        end,
      })
    end,
  },
}
