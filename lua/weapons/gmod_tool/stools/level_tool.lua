TOOL.Category = "Construction"
TOOL.Name = "Level props"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar = {
	maxpush = "2048",
}

if CLIENT then
	language.Add("Tool_level_tool_name", "Level tool")
	language.Add("Tool_level_tool_desc", "Moves one prop's face to the level of second 2nd prop's face.")
	language.Add("Tool_level_tool_0",    "Primary: Level prop face 1 to face 2, Secondary: Level to a face below it, Reload: Level to a face above it")
	language.Add("Tool_level_tool_1",    "Now click another props face or a world face to level to. Press Reload to cancel.")
end

local function level_props(first_trace, trace)
	local normal = first_trace.HitNormal
	local offset = normal*normal:DotProduct(trace.HitPos-first_trace.HitPos)
	
	local ent = first_trace.Entity
	ent:SetPos(ent:GetPos()+offset)
end

function TOOL:LeftClick(trace)
	if self:GetStage() == 0 then
		if trace.HitWorld then return false end
		
		self.first_trace = trace
		self:SetStage(1)
		return true
	elseif self:GetStage() == 1 then
		level_props(self.first_trace, trace)
		
		self.first_trace = nil
		self:SetStage(0)
		return true
	end
end

function TOOL:RightClick(first_trace)
	if self:GetStage() == 0 then
		if first_trace.HitWorld then return false end
		tracedata = {
			start = first_trace.HitPos,
			endpos = first_trace.HitPos - first_trace.HitNormal*self:GetClientNumber("maxpush"),
			filter = { first_trace.Entity }
		}
		trace = util.TraceLine(tracedata)
		level_props(first_trace, trace)
		return true
	elseif self:GetStage() == 1 then
		return false
	end
end

function TOOL:Reload(first_trace)
	if self:GetStage() == 0 then
		if first_trace.HitWorld then return false end
		tracedata = {
			start = first_trace.HitPos,
			endpos = first_trace.HitPos + first_trace.HitNormal*self:GetClientNumber("maxpush"),
			filter = { first_trace.Entity }
		}
		trace = util.TraceLine(tracedata)
		level_props(first_trace, trace)
		return true
	elseif self:GetStage() == 1 then
		self.first_trace = nil
		self:SetStage(0)
		return true
	end
end

function TOOL.BuildCPanel(panel)
	-- TODO: add options:
	-- max push/pull distance for right-click/reload
end
