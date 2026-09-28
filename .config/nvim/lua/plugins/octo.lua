return {
  'pwntester/octo.nvim',
  cmd = 'Octo',
  opts = {
    -- or "fzf-lua" or "snacks" or "default"
    picker = 'telescope',
    -- bare Octo command opens picker of commands
    enable_builtin = true,
    -- use real on-disk files on the right side of review diffs (needs PR checked out)
    use_local_fs = true,
    mappings = {
      -- move comment "add"/"reply" off ca/cr, which collide with global
      -- <leader>ca (code action) and <leader>cr (rename) on the real-file
      -- right diff buffer. cd (delete) / ce (edit history) stay as defaults.
      review_diff = {
        add_review_comment = { lhs = '<localleader>cc', desc = 'add a new review comment', mode = { 'n', 'x' } },
      },
      review_thread = {
        add_comment = { lhs = '<localleader>cc', desc = 'add comment' },
        add_reply = { lhs = '<localleader>cR', desc = 'add reply' },
      },
      pull_request = {
        add_comment = { lhs = '<localleader>cc', desc = 'add comment' },
        add_reply = { lhs = '<localleader>cR', desc = 'add reply' },
      },
      -- <C-a> is the tmux prefix, so it never reaches nvim; move approve to <C-y> ("yes").
      submit_win = {
        approve_review = { lhs = '<C-y>', desc = 'approve review', mode = { 'n' } },
      },
    },
  },
  config = function(_, opts)
    require('octo').setup(opts)

    -- Step through PR commits during a review with ]C / [C (no wrap).
    -- octo has no native next/prev-commit map; <localleader>C only opens
    -- the commit picker. This walks the ordered commit list (plus the
    -- synthetic "entire PR" stop) and re-focuses the review layout.
    local function step_commit(dir)
      local reviews = require 'octo.reviews'
      local review = reviews.get_current_review()
      if not review then
        vim.notify('Not in an Octo review', vim.log.levels.WARN)
        return
      end
      local gh = require 'octo.gh'
      gh.api.get {
        '/repos/{repo}/pulls/{number}/commits',
        format = { repo = review.pull_request.repo, number = review.pull_request.number },
        paginate = true,
        opts = {
          cb = gh.create_callback {
            success = function(output)
              local commits = vim.json.decode(output)

              -- ordered stops: each commit, then the whole-PR view last
              local stops = {}
              for _, c in ipairs(commits) do
                stops[#stops + 1] = { right = c.sha, left = c.parents[1].sha, msg = c.commit.message }
              end
              stops[#stops + 1] = {
                right = review.pull_request.right.commit,
                left = review.pull_request.left.commit,
                msg = '[[ENTIRE PULL REQUEST]]',
              }

              -- where are we now?
              local cur_right = review.layout.right.commit
              local cur_left = review.layout.left.commit
              local idx = #stops -- default to whole-PR if unmatched
              for i, s in ipairs(stops) do
                if s.right == cur_right and s.left == cur_left then
                  idx = i
                  break
                end
              end

              local nidx = idx + dir
              if nidx < 1 or nidx > #stops then
                vim.notify('Octo: no more commits', vim.log.levels.INFO)
                return
              end

              local s = stops[nidx]
              review:focus_commit(s.right, s.left)
              vim.notify(
                ('Octo: commit %d/%d  %s'):format(nidx, #stops, vim.split(s.msg, '\n')[1]),
                vim.log.levels.INFO
              )
            end,
          },
        },
      }
    end

    vim.keymap.set('n', ']C', function()
      step_commit(1)
    end, { desc = 'Octo: next review commit' })
    vim.keymap.set('n', '[C', function()
      step_commit(-1)
    end, { desc = 'Octo: previous review commit' })
  end,
  keys = {
    {
      '<leader>oo',
      '<CMD>Octo actions<CR>',
      desc = 'Octo: all commands (telescope)',
    },
    {
      '<leader>oi',
      '<CMD>Octo issue list<CR>',
      desc = 'List GitHub Issues',
    },
    {
      '<leader>op',
      '<CMD>Octo pr list<CR>',
      desc = 'List GitHub PullRequests',
    },
    {
      '<leader>od',
      '<CMD>Octo discussion list<CR>',
      desc = 'List GitHub Discussions',
    },
    {
      '<leader>on',
      '<CMD>Octo notification list<CR>',
      desc = 'List GitHub Notifications',
    },
    {
      '<leader>os',
      function()
        require('octo.utils').create_base_search_command { include_current_repo = true }
      end,
      desc = 'Search GitHub',
    },
  },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'nvim-tree/nvim-web-devicons', -- optional if file_panel.icons is a function
  },
}
