local SerDes = {}

function SerDes.serialize(value: any)
	if typeof(value) == "Vector3" then
		return { _type = "Vector3", x = value.X, y = value.Y, z = value.Z }
	elseif typeof(value) == "Vector2" then
		return { _type = "Vector2", x = value.X, y = value.Y }
	elseif typeof(value) == "CFrame" then
		local components = {value:GetComponents()}
		return { _type = "CFrame", components = components }
	elseif typeof(value) == "Color3" then
		return { _type = "Color3", r = value.R, g = value.G, b = value.B }
	elseif typeof(value) == "UDim2" then
		return { _type = "UDim2", xScale = value.X.Scale, xOffset = value.X.Offset,
			yScale = value.Y.Scale, yOffset = value.Y.Offset }
	elseif typeof(value) == "table" then
		local new = {}
		for k, v in value do
			new[k] = SerDes.serialize(v)
		end
		return new
	else
		return value
	end
end

-- Deserialize back into Roblox types
function SerDes.deserialize(value: any)
	if type(value) == "table" and value._type then
		if value._type == "Vector3" then
			return Vector3.new(value.x, value.y, value.z)
		elseif value._type == "Vector2" then
			return Vector2.new(value.x, value.y)
		elseif value._type == "CFrame" then
			return CFrame.new(unpack(value.components))
		elseif value._type == "Color3" then
			return Color3.new(value.r, value.g, value.b)
		elseif value._type == "UDim2" then
			return UDim2.new(value.xScale, value.xOffset, value.yScale, value.yOffset)
		end
	end

	if type(value) == "table" then
		local new = {}
		for k, v in value do
			new[k] = SerDes.deserialize(v)
		end
		return new
	else
		return value
	end
end
return SerDes
