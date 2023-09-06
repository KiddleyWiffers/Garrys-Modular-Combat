AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "gui/mchud.lua" )
AddCSLuaFile( "gui/mcmenu.lua" )
AddCSLuaFile( "commands.lua" )
AddCSLuaFile("gmcscoreboard.lua")
AddCSLuaFile("gui/npccreator.lua")

include( "shared.lua" )
include( "auxpower.lua" )
include( "commands.lua" )
include( "npcspawns.lua" )
include( "modules.lua" )

local loadout = { "weapon_crowbar", "weapon_physcannon", "weapon_pistol", "weapon_smg1"}
local ammo = {"pistol", "smg1"}
local amount = {150, 225}

local REBELS = {
	"models/player/group03/male_01.mdl",
	"models/player/group03/male_02.mdl",
	"models/player/group03/male_03.mdl",
	"models/player/group03/male_04.mdl",
	"models/player/group03/male_05.mdl",
	"models/player/group03/male_06.mdl",
	"models/player/group03/male_07.mdl",
	"models/player/group03/male_08.mdl",
	"models/player/group03/male_09.mdl",
	"models/player/group03/female_01.mdl",
	"models/player/group03/female_02.mdl",
	"models/player/group03/female_03.mdl",
	"models/player/group03/female_04.mdl",
	"models/player/group03/female_05.mdl",
	"models/player/group03/female_06.mdl",
}

local RemoveEntities = {
	"item_ammo_357",
	"item_ammo_357_large",
	"item_ammo_ar2_altfire",
	"item_ammo_ar2_large",
	"item_ammo_ar2",
	"item_ammo_crossbow",
	"item_ammo_pistol",
	"item_ammo_pistol_large",
	"item_ammo_smg1_grenade",
	"item_ammo_smg1_large",
	"item_ammo_smg1",
	"item_rpg_round",
	"item_box_buckshot",
	"item_battery",
	"item_healthvial",
	"item_healthkit",
	"weapon_357",
	"weapon_ar2",
	"weapon_crossbow",
	"weapon_crowbar",
	"weapon_frag",
	"weapon_medkit",
	"weapon_physgun",
	"weapon_physcannon",
	"weapon_pistol",
	"weapon_shotgun",
	"weapon_slam",
	"weapon_smg1",
	"weapon_stunstick",
	"weapon_rpg"
}

function GM:Initialize()
	spawnpoints = LoadSpawnConfigurationFromFile()
end

-- Create a table to store damage information
local playerDamageToEnemy = {}

function GM:EntityTakeDamage(target, dmg)
    if IsValid(target) and IsValid(dmg:GetAttacker()) and dmg:GetAttacker():IsPlayer() then
        local player = dmg:GetAttacker()
        local enemy = target
        local damage = dmg:GetDamage()

		if(player:GetNWInt("weapondmg") > 0) then
			dmg:SetDamage(math.Round(damage + (damage * (modules.weapondmg.Stat1 * player:GetNWInt("weapondmg")))))
			damage = dmg:GetDamage()
		end
		
        -- Initialize the damage record for the player if not present
        playerDamageToEnemy[player] = playerDamageToEnemy[player] or {}
        playerDamageToEnemy[player][enemy] = (playerDamageToEnemy[player][enemy] or 0) + damage

        -- Make sure the accumulated damage doesn't exceed the enemy's max health
        local maxHealth = enemy:GetMaxHealth()
        if playerDamageToEnemy[player][enemy] > maxHealth then
            playerDamageToEnemy[player][enemy] = maxHealth
        end
    end
	
	if IsValid(target) and IsValid(dmg:GetAttacker()) and dmg:GetAttacker():IsNPC() then
		
	end
end

function GetPlayerDamageToEnemy(player, enemy)
    if playerDamageToEnemy[player] and playerDamageToEnemy[player][enemy] then
        return playerDamageToEnemy[player][enemy]
    else
        return 0
    end
end

function GM:OnNPCKilled(npc, attacker, inflictor)
    -- Check for valid attacker and NPC
    if not IsValid(attacker) or not IsValid(npc) or not attacker:IsPlayer() or attacker == npc then
        return
    end
	
    local expkill = npc.EXP or npc:GetMaxHealth()
    local vicname = npc.Name or "Invalid NPC"
    local viclvl = npc.Level or 0
    local lvldiff = GetConVar("gmc_exp_lvldifference_multiplier"):GetFloat()

	for player, damage in pairs(playerDamageToEnemy) do
		if damage[npc] and damage[npc] > 0 then
			local atklvl = player:GetNWInt("plylevel")
			local damageDone = GetPlayerDamageToEnemy(player, npc)
			
			local expEarned = math.Round((expkill + (expkill * (lvldiff * (viclvl-atklvl)))) * (npc:GetMaxHealth() / damageDone)) -- Calculate EXP based on damage done
			local dmgPercent = math.Round(100/(npc:GetMaxHealth() / damageDone))

			player:SetNWInt("plyEXP", player:GetNWInt("plyEXP") + expEarned)
			player:ChatPrint("You earned " .. expEarned .. " EXP for doing " .. dmgPercent .. "% damage to " .. vicname .. " (Level: " .. viclvl .. ").")
		else
			player:ChatPrint("You earned no EXP for killing " .. vicname .. " (Level: " .. viclvl .. ").")
		end
	end
end

function GM:PlayerDeath(victim, attacker, inflictor)
	-- Check for valid attacker and NPC
    if not IsValid(attacker) or not IsValid(victim) or not attacker:IsPlayer() or attacker == victim then
        return
    end
	
	local vicname = victim:Nick() or "Invalid Player"
	local viclvl = victim:GetNWInt("plylevel") or 1
	local expkill = GetConVar("gmc_exp_playerkills"):GetInt()
	local lvldiff = GetConVar("gmc_exp_lvldifference_multiplier"):GetFloat()
	
	for player, damage in pairs(playerDamageToEnemy) do
		if damage[victim] and damage[victim] > 0 then
			local atklvl = player:GetNWInt("plylevel")
			local damageDone = GetPlayerDamageToEnemy(player, victim)
			
			local expEarned = math.Round((expkill + (expkill * (lvldiff * (viclvl-atklvl)))) * (victim:GetMaxHealth() / damageDone)) -- Calculate EXP based on damage done
			print(expkill * (lvldiff * (viclvl-atklvl)))
			local dmgPercent = math.Round(100/(victim:GetMaxHealth() / damageDone))

			player:SetNWInt("plyEXP", player:GetNWInt("plyEXP") + expEarned)
			player:ChatPrint("You earned " .. expEarned .. " EXP for doing " .. dmgPercent .. "% damage to " .. vicname .. " (Level: " .. viclvl .. ").")
		else
			player:ChatPrint("You earned no EXP for killing " .. vicname .. " (Level: " .. viclvl .. ").")
		end
	end
end

function GM:PlayerDisconnected(ply)
	ply:SetPData("plylevel", ply:GetNWInt("plylevel"))
	ply:SetPData("plyEXP", ply:GetNWInt("plyEXP"))
	ply:SetPData("plySkillPoints", ply:GetNWInt("plySkillPoints"))
end

function GM:ShutDown(ply)
	for k,v in pairs(player.GetAll()) do
		v:SetPData("plylevel", v:GetNWInt("plylevel"))
		v:SetPData("plyEXP", v:GetNWInt("plyEXP"))
		v:SetPData("plySkillPoints", v:GetNWInt("plySkillPoints"))
	end
end

function GM:InitPostEntity()
	for k,v in pairs(RemoveEntities) do 
		finddelete = ents.FindByClass(v)
		for k,v in pairs(finddelete) do
			v:Remove()
		end
	end
	if spawnpoints then
        for _, spawnpointData in ipairs(spawnpoints) do
            local position = spawnpointData.Position
            local category = spawnpointData.Category
            local spawntype = spawnpointData.Type
			local option1 = spawnpointData.Option1
			local option2 = spawnpointData.Option2
			local option3 = spawnpointData.Option3
			
            -- Create a new entity at the specified position with the saved spawn data
            if category == "Weapons" && (spawntype != "gmc_smallhealthpack" && spawntype != "gmc_mediumhealthpack" && spawntype != "gmc_largehealthpack") then
				local newEntity = ents.Create("gmc_spawnpoint")
				newEntity.SpawnType = spawntype
				newEntity.ExtraOption1 = option1
				newEntity.ExtraOption2 = option2
				newEntity.ExtraOption3 = option3
				newEntity:SetPos(position)
				newEntity:Spawn()
			elseif (spawntype == "gmc_smallhealthpack" || spawntype == "gmc_mediumhealthpack" || spawntype == "gmc_largehealthpack") then
				local newEntity = ents.Create(spawntype)
				newEntity.SpawnType = spawntype
				newEntity:SetPos(position)
				newEntity:Spawn()
			end
        end
    else
        print("No spawn configuration found.")
    end
end

local lvlexpbase = GetConVar( "gmc_levelexp_base" ):GetInt()
local lvlexpscale = GetConVar( "gmc_levelexp_scale" ):GetInt()
local lvlexppower = GetConVar( "gmc_levelexp_power" ):GetInt()

timer.Create("EXPChecker", 0.1, 0, function()
	for k,v in pairs(player.GetAll()) do
		if(v:GetNWInt("plyEXP") >= v:GetNWInt("plyEXPtoLevel")) then
			v:SetNWInt("plylevel", v:GetNWInt("plylevel") + 1)
			v:SetNWInt("plyEXP", v:GetNWInt("plyEXP") - v:GetNWInt("plyEXPtoLevel"))
			v:SetNWInt("plyEXPtoLevel", (lvlexpscale * v:GetNWInt("plylevel")) * lvlexppower)
			v:SetNWInt("plySkillPoints", v:GetNWInt("plySkillPoints") + GetConVar( "gmc_points_per_level"):GetInt())
		end
	end
end)

function GM:PlayerInitialSpawn ( ply )
	if(ply:GetPData("plylevel") == nil) then
		ply:SetNWInt("plylevel", 1)
		ply:SetNWInt("plyEXPtoLevel", GetConVar( "gmc_levelexp_base" ):GetInt())
		ply:SetNWInt("plyEXP", 0)
		ply:SetNWInt("plySkillPoints", GetConVar( "gmc_points_per_level"):GetInt())
	else
		ply:SetNWInt("plylevel", tonumber(ply:GetPData("plylevel")))
		ply:SetNWInt("plyEXPtoLevel", (lvlexpscale * ply:GetNWInt("plylevel")) * lvlexppower)
		ply:SetNWInt("plyEXP", tonumber(ply:GetPData("plyEXP")))
		ply:SetNWInt("plySkillPoints", tonumber(ply:GetPData("plySkillPoints")))
		ply:SetNWInt("plyNPCKills", 0)
	end
	LoadPlayerData(ply)
	ply:SetTeam( TEAM_FFA )
end

hook.Run( "AUXThink" )

function GM:PlayerSpawn(ply)
	ply.SpawnCooldown = t
	for i=1,#loadout do
		ply:Give(loadout[i])
	end
	for i=1,#ammo do
		ply:GiveAmmo(amount[i], ammo[i])
	end
	ply:SetRunSpeed(280)
	ply:SetWalkSpeed(200)
	SetAUX(ply)
	LoadPlayerData(ply)
	ply:SetDuckSpeed( 0.3 )
	ply:SetUnDuckSpeed( 0.4 )
	ply:SetCrouchedWalkSpeed( 0.4 )
	ply:AllowFlashlight( true )
	ply:SetupHands()
	
	if spawnpoints then
		local potentialspawns = {}
		local team = ply:Team()
		
		for _, spawnpointData in ipairs(spawnpoints) do
			local position = spawnpointData.Position
			local category = spawnpointData.Category
			local spawntype = spawnpointData.Type
			local spawnteam = nil
			
			if category == "Players" then
				if spawntype == "Red" then
					spawnteam = TEAM_RED
				elseif spawntype == "Blue" then
					spawnteam = TEAM_BLUE
				elseif spawntype == "Green" then
					spawnteam = TEAM_GREEN
				elseif spawntype == "Purple" then
					spawnteam = TEAM_PURPLE
				end
				
				local entitiesNearSpawn = ents.FindInSphere(position, 50)
				
				local isBlocked = false
				
				for _, entity in pairs(entitiesNearSpawn) do
					if IsValid(entity) and (entity:IsPlayer() || entity:IsNPC()) then
						isBlocked = true
						break 
					end
				end
				
				-- Only add potential spawns if not blocked and the conditions are met
				if not isBlocked then
					if (team ~= TEAM_FFA and team ~= TEAM_COOP) and spawnteam == team then
						table.insert(potentialspawns, position)
					elseif (team == TEAM_FFA or team == TEAM_COOP) then
						table.insert(potentialspawns, position)
					end
				end
			end
		end
		
		if ply:Alive() and #potentialspawns > 0 then
			ply:SetPos(table.Random(potentialspawns))
		end
	end
	ply:GodEnable()
	ply:SetMaterial("models/wireframe")
	timer.Simple(5, function()
		ply:SetMaterial("")
		ply:GodDisable()
	end)
end

hook.Add("PlayerSpawn", "PlayerCosmeticOnSpawn", function(ply)
	if (util.IsValidModel(ply:GetInfo("gmc_model"))) then
		ply:SetModel( ply:GetInfo("gmc_model") )
	else
		ply:SetModel( table.Random(REBELS) )
	end
	
    -- Get the player's desired color from the ConVar
    local colorStr = ply:GetInfo("gmc_color")

    -- Parse the color string (format: "R G B")
    local r, g, b = string.match(colorStr, "(%d+) (%d+) (%d+)")
    
    if r and g and b then
        r = tonumber(r)
        g = tonumber(g)
        b = tonumber(b)
    else
        -- Set default values if parsing fails
        r, g, b = 255, 255, 255
    end
	
	-- Set player color based on team
	if ply:Team() == TEAM_RED then
		--ply:SetPlayerColor(team.GetColor( TEAM_RED ):ToVector())
		ply:SetColor(team.GetColor( TEAM_RED ))
	elseif ply:Team() == TEAM_BLUE then
		--ply:SetPlayerColor(team.GetColor( TEAM_BLUE ):ToVector())
		ply:SetColor(team.GetColor( TEAM_BLUE ))
	elseif ply:Team() == TEAM_GREEN then
		--ply:SetPlayerColor(team.GetColor( 2 ):ToVector())
		ply:SetColor(team.GetColor( TEAM_GREEN ))
	elseif ply:Team() == TEAM_PURPLE then
		--ply:SetPlayerColor(team.GetColor( TEAM_PURPLE ):ToVector())
		ply:SetColor(team.GetColor( TEAM_PURPLE ))
	elseif ply:Team() == TEAM_COOP || ply:Team() == TEAM_FFA then
		ply:SetColor(Color(r / 255, g / 255, b / 255))
	end
end)

function GM:ShowSpare2(ply)
	ply:ConCommand("gmc_gamemenu")
end

function LoadSpawnConfigurationFromFile()
    local spawnpoints = {}
	print("Loading spawn configuration for " .. game.GetMap())

    local data = file.Read("gmc/mapdata/" .. game.GetMap() .. ".txt", "DATA") -- Read the saved data from the file

    if data then
        spawnpoints = util.JSONToTable(data)
		print("Spawn configuration loaded.")
    else
        print("Failed to load spawn configuration.")
    end
	
    return spawnpoints
end