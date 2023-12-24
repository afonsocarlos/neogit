local cli = require("neogit.lib.git.cli")
local util = require("neogit.lib.util")
local Path = require("plenary.path")

local M = {}

---Creates new worktree at path for ref
---@param ref string branch name, tag name, HEAD, etc.
---@param path string absolute path
---@return boolean
function M.add(ref, path)
  local result = cli.worktree.add.args(path, ref).call_sync()
  return result.code == 0
end

---Moves an existing worktree
---@param worktree string absolute path of existing worktree
---@param destination string absolute path for where to move worktree
---@return boolean
function M.move(worktree, destination)
  local result = cli.worktree.move.args(worktree, destination).call_sync()
  return result.code == 0
end

---Removes a worktree
---@param worktree string absolute path of existing worktree
---@param args? table
---@return boolean
function M.remove(worktree, args)
  local result = cli.worktree.remove.args(worktree).arg_list(args).call()
  return result.code == 0
end

---Lists all worktrees for a git repo
---@param opts? table
---@return table
function M.list(opts)
  opts = opts or { include_main = true }
  local list = vim.split(cli.worktree.list.args("--porcelain", "-z").call().stdout_raw[1], "\n\n")

  return util.filter_map(list, function(w)
    local path, head, type, ref = w:match("^worktree (.-)\nHEAD (.-)\n([^ ]+) (.+)$")
    if path then
      local main = Path.new(path, ".git"):is_dir()
      if not opts.include_main and main then
        return nil
      else
        return { main = main, path = path, head = head, type = type, ref = ref }
      end
    end
  end)
end

return M
