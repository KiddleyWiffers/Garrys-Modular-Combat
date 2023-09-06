AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.Model = "models/items/medkit_medium.mdl"

-- Initialize the entity
function ENT:Initialize()
    
	self:SetModel(self.Model)
	
	self:PhysicsInit( SOLID_NONE )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	
end

function ENT:Think()
    -- Detect when a player walks onto this item.
	local touchRadius = 20 -- Adjust this radius as needed

	local startPos = self:GetPos()
	local endPos = startPos + Vector(0, 0, 20) -- Straight upwards from the entity

	local entitiesInSphere = ents.FindInSphere(startPos, touchRadius)

	for _, entity in pairs(entitiesInSphere) do
		if IsValid(entity) and entity:IsPlayer() then
			local healthIncrease = entity:Health() + (entity:GetMaxHealth() / 2)

			if entity:Health() < entity:GetMaxHealth() then
				if healthIncrease <= entity:GetMaxHealth() then
					entity:SetHealth(healthIncrease)
				else
					entity:SetHealth(entity:GetMaxHealth())
				end
				entity:EmitSound("gmc/medkit.wav", 50, 100, 1, CHAN_AUTO)
				if engine.ActiveGamemode() != "gmc" then
					self:Remove()
				else
					local position = self:GetPos()
					
					timer.Simple(10, function()
						local newEntity = ents.Create("gmc_mediumhealthpack")
						newEntity:SetPos(position)
						newEntity:Spawn()
						newEntity:EmitSound( "items/pumpkin_drop.wav", 70, 100, 0.7, CHAN_AUTO )
					end)
					
					self:Remove()
				end
			end
		end
	end
end