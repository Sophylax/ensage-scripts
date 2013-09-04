--[[
		Save as VectorOp.lua into Ensage\Scripts\libs.

		Functions:
			vectorOp:Length3D(Vector) : Returns the 3D Length of the vector
			vectorOp:Length2D(Vector) : Returrs the 2D (x,y) Length of the vector
			vectorOp:Clone(Vector) : Returns a copy of the vector
			vectorOp:Unit2D(Vector) : Returns the unit vector of the given vector on XY plane
			vectorOp:Unit3D(Vector) : Returns the unit vector of the given vector
			vectorOp:GetXYAngle(Vector) : Returns the angle of the vector on XY plane
			vectorOp:UnitVectorFromXYAngle(Angle) : Returns a unit vector from given angle
			vectorOp:tostring(Vector) : Returns the coordinates of the vector in string form
--]]

vectorOp = {}

function vectorOp:Length3D(v)
	return math.sqrt(math.pow(v.x,2)+math.pow(v.y,2)+math.pow(v.z,2))
end

function vectorOp:Length2D(v)
	return math.sqrt(math.pow(v.x,2)+math.pow(v.y,2)+math.pow(v.z,2))
end

function vectorOp:Clone(v)
	return Vector(v.x,v.y,v.z)
end

function vectorOp:Unit3D(v)
	return v/vectorOp:Length3D(v)
end

function vectorOp:Unit2D(v)
	local v = v/vectorOp:Length2D(v)
	return Vector(v.x,v.y,0)
end

function vectorOp:GetXYAngle(v)
	return math.atan2(v.y,v.x)
end

function vectorOp:UnitVectorFromXYAngle(alpha)
	return Vector(math.cos(alpha),math.sin(alpha),0)
end

function vectorOp:tostring(v)
	return "("..v.x..","..v.y..","..v.z..")"
end