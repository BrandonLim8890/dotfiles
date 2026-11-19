local env = require 'env'

-- Cirque is HubSpot's Mill-backed Java LSP (navigation only). Installed and updated
-- via `bpx cirque-lsp-neovim` into ~/.hubspot/.cirque/neovim, not by lazy.
if not env.is_hubspot then return {} end

-- Cirque gives no diagnostics, so compile errors come from Mill instead.
-- Mill prints each error as:
--   NNN] [error] <path-from-repo-root>:<line>:<col>
--   NNN] <source line>
--   NNN] <caret line>
--   NNN] <message>
local function parse_mill_errors(output, root)
  local items = {}
  local pending = nil -- { item = ..., skip = n } while waiting for the message line
  for line in output:gmatch '[^\n]+' do
    local body = line:gsub('^[%d/, A-Z]*%] ', '', 1)
    local path, lnum, col = body:match '^%[error%] (.-):(%d+):(%d+)$'
    if path then
      pending = {
        item = { filename = root .. '/' .. path, lnum = tonumber(lnum), col = tonumber(col), type = 'E', text = '' },
        skip = 2, -- source line + caret line
      }
      table.insert(items, pending.item)
    elseif pending then
      if pending.skip > 0 then
        pending.skip = pending.skip - 1
      else
        pending.item.text = body
        pending = nil
      end
    end
  end
  return items
end

local function mill_compile(opts)
  local buf = vim.api.nvim_get_current_buf()
  local root = vim.fs.root(buf, 'build.mill.yaml')
  if not root then
    vim.notify('MillCompile: no build.mill.yaml above this buffer', vim.log.levels.WARN)
    return
  end

  -- Explicit arg wins; otherwise the module owning this buffer; otherwise everything.
  local target = opts.args ~= '' and opts.args or nil
  if not target then
    local module_root = vim.fs.root(buf, 'package.mill.yaml')
    if module_root and module_root ~= root then
      target = module_root:sub(#root + 2):gsub('/', '.') .. '.compile'
    else
      target = '__.compile'
    end
  end
  if not target:find '%.compile$' then target = target .. '.compile' end

  vim.notify('MillCompile: ' .. target, vim.log.levels.INFO)
  vim.system({ 'mill', target }, { cwd = root, text = true }, function(result)
    local items = parse_mill_errors((result.stdout or '') .. (result.stderr or ''), root)
    vim.schedule(function()
      vim.fn.setqflist({}, 'r', { title = 'MillCompile ' .. target, items = items })
      if #items > 0 then
        vim.notify('✗ ' .. #items .. ' error(s) in ' .. target, vim.log.levels.ERROR)
        local ok, trouble = pcall(require, 'trouble')
        if ok then trouble.open 'qflist' else vim.cmd 'copen' end
      elseif result.code ~= 0 then
        vim.notify('MillCompile failed with no parseable errors (exit ' .. result.code .. ')', vim.log.levels.ERROR)
      else
        vim.notify('✓ ' .. target .. ' compiled', vim.log.levels.INFO)
      end
    end)
  end)
end

return {
  {
    dir = vim.fn.expand '~/.hubspot/.cirque/neovim',
    name = 'cirque',
    lazy = false,
    config = function()
      require('cirque').setup()
      vim.api.nvim_create_user_command('MillCompile', mill_compile, {
        nargs = '?',
        desc = 'Run `mill <module>.compile` and send errors to the quickfix list',
      })

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('mill-compile-keymap', { clear = true }),
        pattern = 'java',
        callback = function(event)
          vim.keymap.set('n', '<leader>mc', '<cmd>MillCompile<cr>', { buffer = event.buf, desc = '[M]ill [C]ompile module' })
        end,
      })
    end,
  },
}
