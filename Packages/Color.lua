local Color = {}

function Color:toInteger(color)
	return math.floor(color.r*255)*256^2+math.floor(color.g*255)*256+math.floor(color.b*255)
end

function Color:toHex(color)
    local int = self:toInteger(color)
    
    local current = int
    local final = ""
    
    repeat
        local remainder = current % 16
        local char = string.format("%X", remainder)
        
        current = math.floor(current / 16)
        final = char .. final
    until current <= 0
    
    -- Ensure the hex representation has at least 6 digits (for RGB values)
    while #final < 6 do
        final = "0" .. final
    end
    
    return "#" .. final
end
function Color:GetDarkerColor(Color: Color3, Opacity: number): Color3
	local H, S, V = Color:ToHSV()
	return Color3.fromHSV(H, S, V - (Opacity or 0.2))
end

return Color