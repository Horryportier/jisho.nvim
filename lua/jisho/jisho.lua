local HTTP_REQUEST = require "http.request"
local JSON         = require "JSON"

---@type string
local api          = "https://jisho.org/api/v1/search/words?keyword="

---@class JishoApi
---@field request function(query)
local T = {}

---@class JishoWord
---@field meta Meta
---@field data Data[]

---@class Meta
---@field status number

---@class Data
---@field slug string
---@field is_common boolean
---@field tags string[]
---@field jlpt string[]
---@field japanese Japanese[]
---@field senses Senses[]
---@field attribution  Attribution[]

---@class Japanese
---@field word string|nil
---@field reading string

---@class Senses
---@field english_definitions string[]
---@field parts_of_speech string[]
---@field links string[]
---@field tags any[]
---@field restrictions any[]
---@field see_also any[]
---@field antonyms any[]
---@field source any[]
---@field info any[]

---@class Attribution
---@field jmdict boolean
---@field jmnedict boolean
---@field dbpedia boolean

---@param  query string
---@return JishoWord
function T:request(query)
	local headers, stream = assert(HTTP_REQUEST.new_from_uri(api .. query):go())
	local body = assert(stream:get_body_as_string())
	if headers:get ":status" ~= "200" then
		error(body)
	end
	---@type JishoWord
	local data = JSON:decode(body)
	return data
end


return T
