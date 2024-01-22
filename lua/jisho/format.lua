local T = {}


---@class FormatOpts
---@field max_word_entries number --def 5  max is 20
---@field max_english_definitions number  --def  1 max ?
---@field show_opts ShowOpts

---@class ShowOpts
---@field show_slug boolean
---@field show_tags boolean
---@field show_jlpt boolean
---@field show_is_common boolean
---@field show_transations boolean
---@field show_part_of_speach boolean
---@field show_japanese boolean

---@type FormatOpts
T.def_opts = {
	max_word_entries = 5,
	max_english_definitions  = 1,
	---@type ShowOpts
	show_opts = {
		show_slug = true,
		show_tags = true,
		show_jlpt = true,
		show_is_common = true,
		show_transations = true,
		show_part_of_speach = true,
		show_japanese = true,
	}
}
--- convinent functino to concat string if c_if true
---@param str string
---@param fun function() string
---@param c_if boolean
---@param delimiter string|nil
---@return string
local function concat_if(str, fun, c_if, delimiter)
	local d = delimiter or " "
	if c_if then
		str = str .. d .. fun()
	end
	return str
end


--- formats header data  [word] [is_common] [tags] [jlpt]
---@param data Data
---@param format_opts FormatOpts
---@return string
function T:header(data, format_opts)
	local opts = format_opts.show_opts
	local final = ""
	final = concat_if(final, function() return data.slug end, opts.show_slug)
	final = concat_if(final, function() return "common word" end, opts.show_is_common and data.is_common)
	final = concat_if(final, function() return table.concat(data.tags) end, opts.show_tags and #data.tags ~= 0)
	final = concat_if(final, function() return table.concat(data.jlpt) end, opts.show_jlpt and #data.jlpt ~= 0)
	return final
end

---comment
---@param senses Senses[]
---@param format_opts FormatOpts
---@return string
local function format_senses(senses, format_opts)
	local final = ""
	---@type Senses
	for index, value in ipairs(senses) do
		if format_opts.show_opts.show_part_of_speach then
		 final = table.concat({ final, "\t", table.concat(value.parts_of_speech, ","), "\n"}, "")
		end
		for i, v in ipairs(value.english_definitions) do
			final = table.concat({final, "\t", i, "." , v, "\n"}, "")
		if i == format_opts.max_english_definitions then break end
		end
		final = table.concat({final, "\n"}, "")
	end
	return final
end
--- formats all the data
---@param data Data
---@param format_opts FormatOpts
---@return string
function T:detail(data, format_opts)
	local opts = format_opts.show_opts
	local final = ""
	final = concat_if(final, function()
		local f = "\t"
		local w = function()
			for _, value in pairs(data.japanese) do
			--	if not value.word then
				return string.format("[%s]", value.reading)
			--	else
			--		return string.format("[%s/%s]",
			--			value.word, value.reading)
			--	end
			end
		end
		return f .. w() .. "\n"
	end, opts.show_japanese and #data.japanese ~= 0)
	final = concat_if(final, function()
		return format_senses(data.senses, format_opts)
	end, opts.show_transations and #data.senses ~= 0)
	return final
end

--- takes word and format_opts and returns string
--- FIX: for now its not returning anything run some tests
---@param word JishoWord
---@param format_opts FormatOpts
---@return string
function T:format(word, format_opts)
	local final = ""
	if #word.data == 0 then
		final = "no data for current_word"
	else
		for index, value in ipairs(word.data) do
			final = final .. self:header(value, format_opts) .. "\n" .. self:detail(value, format_opts)
			if index == format_opts.max_word_entries  then break end
		end
	end
	return final
end

return T
