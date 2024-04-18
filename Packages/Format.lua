local Format = {}

local Suffixes = require(script.Parent:WaitForChild("Suffixes"))

function Format:ToSuffixString(n)
	local i = math.floor(math.log(n, 1e3))
	local v = math.pow(10, i * 3)
	return ("%.1f"):format(n / v):gsub("%.?0+$", "") .. (Suffixes[i] or "")
end

function Format:FromSuffixString(s)
	local n, suffix = string.match(s, "(.*)(%a)$")
	if n and suffix then
		local i = table.find(Suffixes, suffix) or 0
		return tonumber(n) * math.pow(10, i * 3)
	end
	return tonumber(s)
end

function Format:Abbrievate(num)

	-- if tostring(num) then
	-- 	num = self:FromSuffixString(num)
	-- end

	for i = 1, #Suffixes do
		if num < 10 ^ (i * 3) then
			if Suffixes[i] == "∞" then -- Replace 1e308 with your threshold
				return "∞"
			else
				local formattedNumber =
					string.gsub(math.round(num / (10 ^ ((i - 1) * 3)) * 10 ^ 2) / 10 ^ 2, "%.00", "")
				formattedNumber = string.gsub(formattedNumber, "%.$", "")
				return formattedNumber .. Suffixes[i]
			end
		elseif tostring(num) == "inf" then
			return "∞"
		end
	end
end

-- local isNegative = num < 0
-- num = math.abs(num)

-- local Paired = false
-- for Index, Suffix in Suffixes do
-- 	if not (num >= 10 ^ (3 * Index)) then
-- 		num = num / 10 ^ (3 * (Index - 1))
-- 		local isComplex = (string.find(tostring(num), ".") and string.sub(tostring(num), 4, 4) ~= ".")
-- 		num = string.sub(tostring(num), 1, (isComplex and 4) or 3) .. (Suffixes[Index - 1] or "")
-- 		Paired = true
-- 		break
-- 	end
-- end

-- if not Paired then
-- 	local Rounded = math.floor(num)
-- 	num = tostring(Rounded)
-- end

-- if isNegative then
-- 	return "-" .. num
-- end

-- return num
function Format:Comma(num)
	if not num or typeof(num) ~= "string" then
		return warn("Invalid datatype for Comma format, number required; got", num and typeof(num) or "nil")
	end

	return num:reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

return Format
