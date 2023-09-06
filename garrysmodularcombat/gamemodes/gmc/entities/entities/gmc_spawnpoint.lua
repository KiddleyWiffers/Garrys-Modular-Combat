AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "anim"
ENT.PrintName = "GMC Spawnpoint"
ENT.Author = "Kiddley"
ENT.Purpose = "These get placed around the map automatically by GMC to place the various entities around the map."
ENT.Instructions = "You shouldn't be using this, only GMC."
ENT.StartTime = CurTime()
ENT.RotationDuration = 3  -- 3 seconds to complete a full rotation
ENT.Spawnable = true
ENT.AdminSpawnable = true

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

function ENT:Initialize()
	self:DrawShadow(false)
	spawntype = self.SpawnType
	
	local wep = weapons.GetStored( spawntype )
	if wep then
		self:SetModel(wep.WorldModel)
		self:SetPos(Vector(self:GetPos().x, self:GetPos().y, self:GetPos().z+30))
	else
		for _, weapon in ipairs(extraents) do
			if spawntype == weapon then
				if util.IsValidModel( "models/weapons/w_" .. string.sub(weapon, 8) .. ".mdl" ) then
					self:SetModel("models/weapons/w_" .. string.sub(weapon, 8) .. ".mdl")
					self:DrawShadow(true)
					self:SetPos(Vector(self:GetPos().x, self:GetPos().y, self:GetPos().z+30))
				elseif spawntype == "weapon_ar2" then
					self:SetModel("models/weapons/w_irifle.mdl")
					self:DrawShadow(true)
					self:SetPos(Vector(self:GetPos().x, self:GetPos().y, self:GetPos().z+30))
				end
			end
		end
	end
	
	self:PhysicsInit( SOLID_NONE )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
end

function ENT:Draw()

    self:DrawModel()
	
	local currentTime = CurTime()
	local elapsedTime = currentTime - self.StartTime
	local progress = elapsedTime / self.RotationDuration
		
	-- Calculate the target angle based on progress
	local targetAngle = 360 * progress
		
	-- Set the entity's angles
	local newAngles = self:GetAngles()
	newAngles.y = targetAngle
	self:SetAngles(newAngles)
end

function ENT:Think()
	if SERVER then
		-- Detect when a player walks onto this item.
		local touchRadius = 20 -- Adjust this radius as needed
		local startPos = self:GetPos()

		local entitiesInSphere = ents.FindInSphere(startPos, touchRadius)
		local position = Vector(self:GetPos().x, self:GetPos().y, self:GetPos().z-30)
		local spawntype = self.SpawnType
		local option1 = tostring(self.ExtraOption1)
		local option2 = tonumber(self.ExtraOption2)
		local option3 = tostring(self.ExtraOption3)
				
		for _, entity in pairs(entitiesInSphere) do
			if IsValid(entity) and entity:IsPlayer() then
			local function AmmoGiver()
				local ammoType = game.GetAmmoID(option1)
				local maxAmmo = game.GetAmmoMax(ammoType)
				local currentAmmo = entity:GetAmmoCount(ammoType)
				local ammoToAdd = option2

				if currentAmmo < maxAmmo then
					local ammoSpace = maxAmmo - currentAmmo
					ammoToAdd = math.min(ammoToAdd, ammoSpace)
					entity:GiveAmmo(ammoToAdd, ammoType, false)
					timer.Simple(tonumber(option3), function()					
						local newEntity = ents.Create("gmc_spawnpoint")
						newEntity.SpawnType = spawntype
						newEntity.ExtraOption1 = option1
						newEntity.ExtraOption2 = option2
						newEntity.ExtraOption3 = option3
						newEntity:SetPos(position)
						newEntity:Spawn()
						newEntity:EmitSound( "items/pumpkin_drop.wav", 70, 100, 0.7, CHAN_AUTO )
					end)
				
					self:Remove()
				else
					return false
				end
			end
				local wep = weapons.GetStored( spawntype )
				if wep then
					if entity:GetWeapon(spawntype) then
						entity:GiveAmmo( tonumber(option2), game.GetAmmoID(option1), false )
					else
						entity:Give(spawntype)
					end
				else
					for _, weapon in ipairs(extraents) do
						if spawntype == weapon then
							if spawntype != "weapon_rocket_launcher" && spawntype != "weapon_grenade" then
								if entity:HasWeapon(spawntype) then
									AmmoGiver()
								else
									entity:Give(spawntype)	
									AmmoGiver()
								end
							elseif spawntype == "weapon_rocket_launcher" then
								if entity:HasWeapon("weapon_rpg") then
									AmmoGiver()
								else
									AmmoGiver()
									entity:Give("weapon_rpg")
								end
							elseif spawntype == "weapon_grenade" then
								if entity:HasWeapon("weapon_frag") then
									AmmoGiver()
								else
									entity:Give("weapon_frag")
									AmmoGiver()
								end
							end
						end
					end
				end
			end
		end
	end
end