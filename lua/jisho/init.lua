local M = {}

M.jisho_api = require("jisho.jisho")
M.formatter = require("jisho.format")

---@param query string
function M.test(query)
    ---@type JishoWord
    local word = M.jisho_api:request(query)
    return M.formatter:format(word, M.formatter.def_opts)
end

return M
