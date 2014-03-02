--[[
		Save as VectorOp.lua into Ensage\Scripts\libs.

		Functions:
			Vector:Length3D(Vector) : Returns the 3D Length of the vector
			Vector:Length2D(Vector) : Returrs the 2D (x,y) Length of the vector
			Vector:Clone(Vector) : Returns a copy of the vector
			Vector:Unit2D(Vector) : Returns the unit vector of the given vector on XY plane
			Vector:Unit3D(Vector) : Returns the unit vector of the given vector
			Vector:GetXYAngle(Vector) : Returns the angle of the vector on XY plane
			Vector:UnitVectorFromXYAngle(Angle) : Returns a unit vector from given angle
			Vector:tostring(Vector) : Returns the coordinates of the vector in string form
--]]

VectorOp = {}

function Vector:Length3D()
	return math.sqrt(math.pow(self.x,2)+math.pow(self.y,2)+math.pow(self.z,2))
end

function Vector:Length2D()
	return math.sqrt(math.pow(self.x,2)+math.pow(self.y,2))
end

function Vector2D:Length()
	return math.sqrt(math.pow(self.x,2)+math.pow(self.y,2))
end

function Vector:Clone()
	return Vector(self.x,self.y,self.z)
end

function Vector2D:Clone()
	return Vector2D(self.x,self.y)
end

function Vector:Unit3D()
	return self/self:Length3D(self)
end

function Vector:Unit2D()
	local self = self/Vector:Length2D(self)
	return Vector(self.x,self.y,0)
end

function Vector2D:Unit()
	local self = self/Vector:Length(self)
	return Vector(self.x,self.y)
end

function Vector:GetXYAngle()
	return math.atan2(self.y,self.x)
end

function Vector2D:GetXYAngle()
	return math.atan2(self.y,self.x)
end

function VectorOp.UnitVectorFromXYAngle(alpha)
	return Vector(math.cos(alpha),math.sin(alpha),0)
end

function VectorOp.UnitVector2DFromXYAngle(alpha)
	return Vector2D(math.cos(alpha),math.sin(alpha))
end

function Vector:tostring()
	return "("..self.x..","..self.y..","..self.z..")"
end

function Vector2D:tostring()
	return "("..self.x..","..self.y..")"
end

function Vector:__sub(vec)
	return Vector(self.x - vec.x,self.y - vec.y,self.z - vec.z)
end

function Vector:__add(vec)
	return Vector(self.x + vec.x,self.y + vec.y,self.z + vec.z)
end

function Vector:__mul(vec)
	if GetType(vec) == "Vector" then
		return Vector(self.x * vec.x,self.y * vec.y,self.z * vec.z)
	elseif type(vec) == "number" then
		return Vector(self.x * vec,self.y * vec,self.z * vec)
	else
		return Vector()
	end
end

function Vector:__div(vec)
	if GetType(vec) == "Vector" then
		return Vector(self.x / vec.x,self.y / vec.y,self.z / vec.z)
	elseif type(vec) == "number" then
		return Vector(self.x / vec,self.y / vec,self.z / vec)
	else
		return Vector()
	end
end


function Vector2D:__sub(vec)
	return Vector2D(self.x - vec.x,self.y - vec.y)
end

function Vector2D:__add(vec)
	return Vector2D(self.x + vec.x,self.y + vec.y)
end

function Vector2D:__mul(vec)
	if GetType(vec) == "Vector2D" then
		return Vector(self.x * vec.x,self.y * vec.y)
	elseif type(vec) == "number" then
		return Vector2D(self.x * vec,self.y * vec)
	else
		return Vector2D()
	end
end

function Vector2D:__div(vec)
	if GetType(vec) == "Vector2D" then
		return Vector2D(self.x / vec.x,self.y / vec.y)
	elseif type(vec) == "number" then
		return Vector2D(self.x / vec,self.y / vec)
	else
		return Vector2D()
	end
end

function Vector:GetDistance2D(a)
	assert(GetType(a) == "Vector" or GetType(a) == "LuaEntity" or GetType(a) == "Vector2D" or GetType(a) == "Projectile", "GetDistance2D: Invalid Parameter (Got "..GetType(a)..")")
	if a.x == nil or a.y == nil then
		return self:GetDistance2D(a.position)
	else
		return math.sqrt(math.pow(a.x-self.x,2)+math.pow(a.y-self.y,2))
	end
end

function Vector2D:GetDistance2D(a)
	assert(GetType(a) == "Vector" or GetType(a) == "LuaEntity" or GetType(a) == "Vector2D" or GetType(a) == "Projectile", "GetDistance2D: Invalid Parameter (Got "..GetType(a)..")")
	if a.x == nil or a.y == nil then
		return self:GetDistance2D(a.position)
	else
		return math.sqrt(math.pow(a.x-self.x,2)+math.pow(a.y-self.y,2))
	end
end