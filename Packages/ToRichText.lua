return function(...)
	local strings = {}

	local fontEnabled = false
	local fontSettings = {}
	local strokeEnabled = false
	local strokeSettings = {}

	local bold = false
	local italic = false
	local underline = false
	local strikethrough = false
	local uppercase = false
	local smallCaps = false

	local autoEscapeChars = true

	for _, element in ipairs(table.pack(...)) do
		if typeof(element) == "table" then
			if element["isRichStylizedText"] then
				table.insert(strings, {
					str = element.str,
					process = false
				})
			else
				if element.font then
					fontEnabled = true
					fontSettings = element.font
				end
				if element.stroke then
					strokeEnabled = true
					strokeSettings = element.stroke
				end

				if element.bold ~= nil or element.b ~= nil then
					bold = element.bold or element.b
				end
				if element.italic ~= nil or element.i ~= nil then
					italic = element.italic or element.i
				end
				if element.underline ~= nil or element.u ~= nil then
					underline = element.underline or element.u
				end
				if element.strikethrough ~= nil or element.s ~= nil then
					strikethrough = element.strikethrough or element.s
				end
				if element.uppercase ~= nil or element.uc ~= nil then
					uppercase = element.uppercase or element.uc
				end
				if element.smallCaps ~= nil or element.sc ~= nil then
					smallCaps = element.smallCaps or element.sc
				end

				if element.autoEscapeChars ~= nil then
					autoEscapeChars = element.autoEscapeChars
				end
			end
		else
			table.insert(strings, {
				str = tostring(element),
				process = true
			})
		end
	end

	local output = ""

	if fontEnabled then
		output = output .. "<font "

		if fontSettings["color"] ~= nil then
			local colorStr

			if typeof(fontSettings.color) == "string" then
				colorStr = fontSettings.color
			elseif typeof(fontSettings.color) == "BrickColor" then
				fontSettings.color = fontSettings.color.Color
			end

			if typeof(fontSettings.color) == "Color3" then
				colorStr = string.format("rgb(%i,%i,%i)", fontSettings.color.R * 255, fontSettings.color.G * 255, fontSettings.color.B * 255)
			end

			if colorStr then
				output = output .. string.format("color=\"%s\" ", colorStr)
			end
		end
		if fontSettings["size"] ~= nil then
			local sizeStr

			if typeof(fontSettings.size) == "EnumItem" and fontSettings.size.EnumType == Enum.FontSize then
				sizeStr = string.sub(fontSettings.size.Name, 5)
			elseif typeof(fontSettings.size) == "string" or typeof(fontSettings.size) == "number" then
				sizeStr = tostring(fontSettings.size)
			end

			if sizeStr then
				output = output .. string.format("size=\"%s\" ", sizeStr)
			end
		end
		if fontSettings["face"] ~= nil then
			local faceStr

			if typeof(fontSettings.face) == "EnumItem" and fontSettings.face.EnumType == Enum.Font then
				faceStr = fontSettings.face.Name
			elseif typeof(fontSettings.face) == "string" then
				faceStr = fontSettings.face
			end

			if faceStr then
				output = output .. string.format("face=\"%s\" ", faceStr)
			end
		end
		if fontSettings["weight"] ~= nil then
			local weightStr

			if typeof(fontSettings.weight) == "EnumItem" and fontSettings.weight.EnumType == Enum.FontWeight then
				weightStr = fontSettings.weight.Name
			elseif typeof(fontSettings.weight) == "string" or typeof(fontSettings.size) == "number" then
				weightStr = tostring(fontSettings.weight)
			end

			if weightStr then
				output = output .. string.format("weight=\"%s\" ", weightStr)
			end
		end
		if fontSettings["transparency"] ~= nil then
			output = output .. string.format("transparency=\"%s\" ", tostring(fontSettings.transparency))
		end

		output = output .. ">"
	end
	if strokeEnabled then
		output = output .. "<stroke "

		if strokeSettings["color"] ~= nil then
			local colorStr

			if typeof(strokeSettings.color) == "string" then
				colorStr = strokeSettings.color
			elseif typeof(strokeSettings.color) == "BrickColor" then
				strokeSettings.color = strokeSettings.color.Color
			end

			if typeof(strokeSettings.color) == "Color3" then
				colorStr = string.format("rgb(%i,%i,%i)", strokeSettings.color.R * 255, strokeSettings.color.G * 255, strokeSettings.color.B * 255)
			end

			if colorStr then
				output = output .. string.format("color=\"%s\" ", colorStr)
			end
		end
		if strokeSettings["joins"] ~= nil then
			local joinsStr

			if typeof(strokeSettings.joins) == "EnumItem" and strokeSettings.joins.EnumType == Enum.LineJoinMode then
				joinsStr = strokeSettings.joins.Name
			elseif typeof(strokeSettings.joins) == "string" then
				joinsStr = strokeSettings.joins
			end

			if joinsStr then
				output = output .. string.format("joins=\"%s\" ", joinsStr)
			end
		end
		if strokeSettings["thickness"] ~= nil then
			output = output .. string.format("thickness=\"%s\" ", tostring(strokeSettings.thickness))
		end
		if strokeSettings["transparency"] ~= nil then
			output = output .. string.format("transparency=\"%s\" ", tostring(strokeSettings.transparency))
		end

		output = output .. ">"
	end
	if bold then
		output = output .. "<b>"
	end
	if italic then
		output = output .. "<i>"
	end
	if underline then
		output = output .. "<u>"
	end
	if strikethrough then
		output = output .. "<s>"
	end
	if uppercase then
		output = output .. "<uc>"
	end
	if smallCaps then
		output = output .. "<sc>"
	end

	for _, strData in ipairs(strings) do
		if autoEscapeChars and strData.process then
			local finalString = strData.str

			finalString = string.gsub(finalString, "&", "&amp;")
			finalString = string.gsub(finalString, "<", "&lt;")
			finalString = string.gsub(finalString, ">", "&gt;")
			finalString = string.gsub(finalString, "\"", "&quot;")
			finalString = string.gsub(finalString, "'", "&apos;")
			finalString = string.gsub(finalString, "\n", "<br />")

			output = output .. finalString
		else
			output = output .. strData.str
		end
	end

	if smallCaps then
		output = output .. "</sc>"
	end
	if uppercase then
		output = output .. "</uc>"
	end
	if strikethrough then
		output = output .. "</s>"
	end
	if underline then
		output = output .. "</u>"
	end
	if italic then
		output = output .. "</i>"
	end
	if bold then
		output = output .. "</b>"
	end
	if strokeEnabled then
		output = output .. "</stroke>"
	end
	if fontEnabled then
		output = output .. "</font>"
	end

	return setmetatable({
		str = output,
		isRichStylizedText = true
	}, {
		__tostring = function(self)
			return self.str
		end,
	})
end