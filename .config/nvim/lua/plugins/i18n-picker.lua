local env = require 'env'
if not env.is_hubspot then
  return {}
end

-- Telescope picker + lyaml helpers built on top of hubspot-i18n-nvim.
-- Required lazily: this spec file is evaluated before plugins are on the rtp.

local function i18n()
  return require 'hubspot-i18n'
end

local static_archive = vim.env.HOME .. '/.hubspot/static-archive'

---@return table<string, { value: string, file: string|nil, row: integer|nil, col: integer|nil }>
local function get_entries()
  local translations = i18n().get_translations()
  local path = i18n().get_app_or_lib_dir()

  if path ~= nil and translations[path] and next(translations[path]) ~= nil then
    return translations[path]
  end

  local merged = {}
  for _, entries in pairs(translations) do
    for key, entry in pairs(entries) do
      merged[key] = entry
    end
  end
  return merged
end

---@return { [1]: string, [2]: table }[]
local function get_rows()
  local rows = {}
  for key, entry in pairs(get_entries()) do
    table.insert(rows, { key, entry })
  end
  table.sort(rows, function(a, b)
    return a[1] < b[1]
  end)
  return rows
end

local function open_entry(key, entry)
  if not (entry and entry.file and entry.row) then
    vim.notify('[i18n] No source location for key: ' .. key, vim.log.levels.WARN)
    return
  end
  vim.cmd.edit(vim.fn.fnameescape(entry.file))
  vim.api.nvim_win_set_cursor(0, { entry.row + 1, entry.col or 0 })
  if entry.file:find(static_archive, 1, true) then
    vim.bo.readonly = true
    vim.bo.modifiable = false
  end
end

local function find_translation(opts)
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local previewers = require 'telescope.previewers'
  local conf = require('telescope.config').values
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'

  local rows = get_rows()
  if #rows == 0 then
    vim.notify('[i18n] No translations cached yet, parsing...', vim.log.levels.INFO)
    i18n().parse_and_cache_translations(function()
      if #get_rows() > 0 then
        find_translation(opts)
      else
        vim.notify('[i18n] No translations found', vim.log.levels.WARN)
      end
    end)
    return
  end

  local path = i18n().get_app_or_lib_dir()

  local previewer = previewers.new_buffer_previewer {
    define_preview = function(self, entry)
      if self.state.winid ~= -1 then
        vim.api.nvim_set_option_value('wrap', true, { win = self.state.winid })
      end
      if entry.value ~= nil then
        vim.api.nvim_buf_set_lines(self.state.bufnr, 0, 0, false, { entry.value[2].value })
      end
    end,
  }

  local function copy_selected(prompt_bufnr)
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()
    if selection and selection.value then
      vim.fn.setreg('+', selection.value[1])
      print('Copied to clipboard: ' .. selection.value[1])
    end
  end

  opts = opts or {}
  pickers
    .new(opts, {
      prompt_title = path and 'Translations for ' .. path:match '([^/]+)$' or 'All Translations',
      previewer = previewer,
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection and selection.value then
            open_entry(selection.value[1], selection.value[2])
          end
        end)

        map('i', '<C-y>', function()
          copy_selected(prompt_bufnr)
        end)
        map('n', '<C-y>', function()
          copy_selected(prompt_bufnr)
        end)

        return true
      end,
      finder = finders.new_table {
        results = rows,
        entry_maker = function(row)
          return {
            value = row,
            display = row[1],
            ordinal = row[1] .. ' ' .. row[2].value,
          }
        end,
      },
    })
    :find()
end

---Extract the YAML key path (without the leading `en.`) under the cursor.
---@return string|nil
local function extract_yaml_key_path()
  local current_line_num = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local current_line = lines[current_line_num]
  if not current_line then
    return nil
  end

  local key_match = current_line:match '^%s*([%w_%-%.]+)%s*:'
  if not key_match then
    return nil
  end

  local current_indent = #(current_line:match '^%s*' or '')
  local path_parts = { key_match }

  for i = current_line_num - 1, 1, -1 do
    local line = lines[i]
    local line_indent = #(line:match '^%s*' or '')
    if line:match '%S' and not line:match '^%s*#' and line_indent < current_indent then
      local parent_key = line:match '^%s*([%w_%-%.]+)%s*:'
      if parent_key then
        table.insert(path_parts, 1, parent_key)
        current_indent = line_indent
      end
    end
  end

  return table.concat(path_parts, '.')
end

local function copy_yaml_key()
  local key_path = extract_yaml_key_path()
  if not key_path then
    vim.notify('[i18n] No valid YAML key found under cursor', vim.log.levels.WARN)
    return
  end

  local clean_key = key_path:gsub('^en%.', '')
  vim.fn.setreg('+', clean_key)
  vim.notify('Copied to clipboard: ' .. clean_key, vim.log.levels.INFO)
end

vim.api.nvim_create_user_command('I18nPicker', function()
  find_translation()
end, { desc = 'Open i18n translation picker' })

-- hubspot-i18n-nvim maps `.lyaml` to the `yaml` filetype, so match on the file name.
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'yaml', 'lyaml', 'conf' },
  callback = function(args)
    if vim.api.nvim_buf_get_name(args.buf):match '%.lyaml$' or vim.bo[args.buf].filetype ~= 'yaml' then
      vim.keymap.set('n', '<leader>iy', copy_yaml_key, { buffer = args.buf, desc = 'Copy i18n key path' })
    end
  end,
})

return {}
