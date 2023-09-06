AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

weaponChoices = {}

extraents = {
	"weapon_357",
	"weapon_smg1",
	"weapon_pistol",
	"weapon_ar2",
	"weapon_shotgun",
	"weapon_crossbow",
	"weapon_rocket_launcher",
	"weapon_grenade",
	"weapon_slam",
	"gmc_smallhealthpack",
	"gmc_mediumhealthpack",
	"gmc_largehealthpack",
}

-- Add this function definition
util.AddNetworkString("SendUserInputToWeaponSpawner")

net.Receive( "SendUserInputToWeaponSpawner", function() 
	SC = net.ReadString()
	ST = net.ReadString()
	EO1 = net.ReadString()
	EO2 = net.ReadString()
	EO3 = net.ReadString()
	enti = net:ReadEntity()
	enti:SetNWString("SpawnCategory", SC)
	enti:SetNWString("SpawnType", ST)
	enti:SetNWString("ExtraOption1", EO1)
	enti:SetNWString("ExtraOption2", EO2)
	enti:SetNWString("ExtraOption3", EO3)
end)

-- Initialize the entity
function ENT:Initialize()
	self:SetModel("models/props_combine/combine_mine01.mdl")
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS)
	self:SetSolid( SOLID_VPHYSICS )
	
	self:SetNWString("SpawnCategory", "Players")
	self:SetNWString("SpawnType", "No Team")
	
	self.display = ents.Create("prop_physics")
	self.display:PhysicsInit( SOLID_VPHYSICS )
	self.display:SetMoveType( MOVETYPE_NONE )
	self.display:SetSolid( SOLID_NONE )
	self.display:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self.display:SetPos(self:GetPos())
	self.display:SetParent(self)
	self.display.StartTime = CurTime()
    self.display.RotationDuration = 3  -- 3 seconds to complete a full rotation
    self.display.InitialAngle = self:GetAngles().y

	-- Loop through available weapons and add them to the weaponChoices table
	for _, weapon in pairs(weapons.GetList()) do
		local class = weapon.ClassName
		table.insert(weaponChoices, class)
	end
	
	for _, weapon in ipairs(extraents) do
		table.insert(weaponChoices, weapon)
	end
end

-- Spin the entity
function ENT:Think()
	SC = self:GetNWString("SpawnCategory")
	ST = self:GetNWString("SpawnType")
    if SC == "Players" then
		self.display:SetPos(Vector(self:GetPos().x, self:GetPos().y, self:GetPos().z + 20))
		self.display:SetModel("models/editor/playerstart.mdl")
		self.display:SetMaterial("models/debug/debugwhite")
		if ST == "No Team" then
			self.display:SetColor(Color(255, 255, 255, 255))
		elseif ST == "Red" then
			self.display:SetColor(Color(200, 0, 0, 255))
		elseif ST == "Blue" then
			self.display:SetColor(Color(0, 0, 200, 255))
		elseif ST == "Green" then
			self.display:SetColor(Color(0, 200, 0, 255))
		elseif ST == "Purple" then
			self.display:SetColor(Color(200, 0, 200, 255))
		end
	elseif SC == "Weapons" then
		self.display:SetPos(Vector(self:GetPos().x, self:GetPos().y, self:GetPos().z + 20))
		self.display:SetMaterial("")
		self.display:SetColor(Color(255, 255, 255, 255))
		local wep = weapons.GetStored( ST )
		if wep then
			self.display:SetModel(wep.WorldModel)
		else
			for _, weapon in ipairs(extraents) do
				if ST == weapon then
					if util.IsValidModel( "models/weapons/w_" .. string.sub(ST, 8) .. ".mdl" ) then
						self.display:SetModel("models/weapons/w_" .. string.sub(ST, 8) .. ".mdl")
					elseif ST == "weapon_ar2" then
						self.display:SetModel("models/weapons/w_irifle.mdl")
					elseif ST == "gmc_smallhealthpack" then
						self.display:SetModel("models/items/medkit_small.mdl")
					elseif ST == "gmc_mediumhealthpack" then
						self.display:SetModel("models/items/medkit_medium.mdl")
					elseif ST == "gmc_largehealthpack" then
						self.display:SetModel("models/items/medkit_large.mdl")
					end
				end
			end
		end
	elseif SC == "NPCs" then
		self.display:SetPos(Vector(self:GetPos().x, self:GetPos().y, self:GetPos().z + 40))
		self.display:SetMaterial("")
		self.display:SetColor(Color(255, 255, 255, 255))
		if ST == "Normal" then
			self.display:SetModel("models/AntLion.mdl")
		end
		if ST == "Large" then
			self.display:SetModel("models/antlion_guard.mdl")
		end
		if ST == "Boss" then
			self.display:SetModel("models/Zombie/Classic.mdl")
		end
	end
	
	Spiiin(self.display)
	self:NextThink(CurTime() + 0.15)
    return true
end

-- Add this function definition
util.AddNetworkString("OpenSpawnGUIMenu")

-- Handle interaction
function ENT:Use(activator, caller)
	local entity = self:EntIndex()
	if IsValid(activator) and activator:IsPlayer() then
		net.Start("OpenSpawnGUIMenu")
			net.WriteEntity(Entity(entity))
		net.Send(activator)
	end
end

function Spiiin(ent)
	local currentTime = CurTime()
    local elapsedTime = currentTime - ent.StartTime
    local progress = elapsedTime / ent.RotationDuration
    
    -- Calculate the target angle based on progress
    local targetAngle = ent.InitialAngle + 360 * progress
    
    -- Set the entity's angles
    local newAngles = ent:GetAngles()
    newAngles.y = targetAngle
    ent:SetAngles(newAngles)
end