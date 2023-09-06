include("shared.lua")

function ENT:Initialize()
	self.StartTime = CurTime()
    self.RotationDuration = 3  -- 3 seconds to complete a full rotation
    self.InitialAngle = self:GetAngles().y
end

function ENT:Draw()
	self:DrawModel()
	
	local currentTime = CurTime()
    local elapsedTime = currentTime - self.StartTime
    local progress = elapsedTime / self.RotationDuration
    
    -- Calculate the target angle based on progress
    local targetAngle = self.InitialAngle + 360 * progress
    
    -- Set the entity's angles
    local newAngles = self:GetAngles()
    newAngles.y = targetAngle
    self:SetAngles(newAngles)
end