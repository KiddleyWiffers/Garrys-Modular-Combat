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
include( "savedata.lua" )

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

util.AddNetworkString("ChangeSuits")
util.AddNetworkString("RenameSuit")
util.AddNetworkString("ResetSuit")
util.AddNetworkString("UpdateModules")
util.AddNetworkString("BindModules")
util.AddNetworkString("SendSuitInfoToClient")

function GM:Initialize()
	spawnpoints = LoadSpawnConfigurationFromFile()
end

-- Create a table to store damage information
local playerDamageToEnemy = {}

function GM:EntityTakeDamage(target, dmg)
	local player
	local enemy
	local damage
    if IsValid(target) and IsValid(dmg:GetAttacker()) and dmg:GetAttacker():IsPlayer() then
        player = dmg:GetAttacker()
        enemy = target
        damage = dmg:GetDamage()
		
		if player:Team() != TEAM_FFA && target:IsPlayer() && player:Team() == target:Team() then
			return true
		end
		
		if !target:IsPlayer() && !target:IsNPC() then
			return
		end
		
		if target == player then
			return
		end
		
        -- Initialize the damage record for the player if not present
        playerDamageToEnemy[player] = playerDamageToEnemy[player] or {}
        playerDamageToEnemy[player][enemy] = (playerDamageToEnemy[player][enemy] or 0) + damage

        -- Make sure the accumulated damage is fairly calculated.
		if enemy:Health() < damage then
			local overdamage = enemy:Health() - damage
			playerDamageToEnemy[player][enemy] = playerDamageToEnemy[player][enemy] + overdamage
		end
    end

	
	--Suppress regenerative abilities for a few seconds after taking damage.
	if IsValid(target) then
		
	end
	
	-- Set damage for NPCs
	if IsValid(target) and IsValid(dmg:GetAttacker()) and dmg:GetAttacker():IsNPC() then
		local attacker = dmg:GetAttacker()
		local damage = dmg:GetDamage()
		
		dmg:SetDamage(math.Round(damage * attacker.Damage))
	end
end

function GetPlayerDamageToEnemy(player, enemy)
    if playerDamageToEnemy[player] and playerDamageToEnemy[player][enemy] then
        return playerDamageToEnemy[player][enemy]
    else
        return 0
    end
end

function GM:OnNPCKilled(victim, attacker, inflictor)
    -- Check for valid attacker and NPC
    if not IsValid(attacker) or not IsValid(victim) or not attacker:IsPlayer() or attacker == victim then
        return
    end
	
	attacker:SetNWInt("plyNPCKills", attacker:GetNWInt("plyNPCKills") + 1)
	
    local expkill = victim.EXP or npc:GetMaxHealth()
    local vicname = victim.Name or "Invalid NPC"
    local viclvl = victim.Level or 0
    local lvldiff = GetConVar("gmc_exp_lvldifference_multiplier"):GetFloat()
	
	GetPlayerDamageToEnemy(player, enemy)
	
	local dmgPercent = {}
	local totalDmg = 0
	
	for player, damage in pairs(playerDamageToEnemy) do
		if damage[victim] and damage[victim] > 0 then
			totalDmg = totalDmg + damage[victim]
		end
	end
	
	for player, damage in pairs(playerDamageToEnemy) do
		if damage[victim] and damage[victim] > 0 then
			dmgPercent[player] = damage[victim]/totalDmg
			local atklvl = player:GetNWInt("plyLevel")
			
			local expEarned = math.Round((expkill + (expkill * (lvldiff * (viclvl-atklvl)))) * (dmgPercent[player]))
			
			player:SetNWInt("plyEXP", player:GetNWInt("plyEXP") + expEarned)
			player:ChatPrint("You earned " .. expEarned .. " EXP for doing " .. math.Round(dmgPercent[player] * 100) .. "% damage to " .. vicname .. " (Level: " .. viclvl .. ").")
		end
	end
	
	for player, damage in pairs(playerDamageToEnemy) do
		if damage[victim] then
			playerDamageToEnemy[player][victim] = nil
		end
	end
	
	if GetConVar("gmc_npc_weapon_drop"):GetInt() == 0 then
		if IsValid(victim:GetActiveWeapon()) then
			victim:GetActiveWeapon():Remove()
		end
	end
end

function GM:PlayerDeath(victim, attacker, inflictor)
	-- Check for valid attacker and NPC
    if not IsValid(attacker) or not IsValid(victim) or not attacker:IsPlayer() or attacker == victim then
        return
    end
	
	local vicname = victim:Nick() or "Invalid Player"
	local viclvl = victim:GetNWInt("plyLevel") or 1
	local expkill = GetConVar("gmc_exp_playerkills"):GetInt()
	local lvldiff = GetConVar("gmc_exp_lvldifference_multiplier"):GetFloat()
	
	GetPlayerDamageToEnemy(player, enemy)
	
	local dmgPercent = {}
	local totalDmg = 0
	
	for player, damage in pairs(playerDamageToEnemy) do
		if damage[victim] and damage[victim] > 0 then
			totalDmg = totalDmg + damage[victim]
		end
	end
	
	for player, damage in pairs(playerDamageToEnemy) do
		if damage[victim] and damage[victim] > 0 then
			dmgPercent[player] = damage[victim]/totalDmg
			local atklvl = player:GetNWInt("plyLevel")
			
			local expEarned = math.Round((expkill + (expkill * (lvldiff * (viclvl-atklvl)))) * (dmgPercent[player]))
			
			player:SetNWInt("plyEXP", player:GetNWInt("plyEXP") + expEarned)
			player:ChatPrint("You earned " .. expEarned .. " EXP for doing " .. math.Round(dmgPercent[player] * 100) .. "% damage to " .. vicname .. " (Level: " .. viclvl .. ").")
		end
	end
	
	for player, damage in pairs(playerDamageToEnemy) do
		if damage[victim] then
			playerDamageToEnemy[player][victim] = nil
		end
	end
end

function GM:PlayerDisconnected(ply)
	SavePlayerData(ply)
	
	for player, damage in pairs(playerDamageToEnemy) do
		-- Remove the killed NPC from the playerDamageToEnemy table
		for player, damage in pairs(playerDamageToEnemy) do
			if damage[victim] then
				playerDamageToEnemy[player][victim] = nil
			end
		end
	end
end

function GM:ShutDown(ply)
	for k,v in pairs(player.GetAll()) do
		SavePlayerData(v)
	end
	
	for player, damage in pairs(playerDamageToEnemy) do
		-- Remove the killed NPC from the playerDamageToEnemy table
		for player, damage in pairs(playerDamageToEnemy) do
			if damage[victim] then
				playerDamageToEnemy[player][victim] = nil
			end
		end
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

--Timer that runs every 0.1 seconds to optimize functions
timer.Create("FractionTimer", 0.1, 0, function()
	for k,ply in pairs(player.GetAll()) do
		if(ply:GetNWInt("plyEXP") >= ply:GetNWInt("plyEXPtoLevel") && ply:GetNWInt("plyEXPtoLevel") > 0) then
			ply:SetNWInt("plyLevel", ply:GetNWInt("plyLevel") + 1)
			ply:SetNWInt("plyEXP", ply:GetNWInt("plyEXP") - ply:GetNWInt("plyEXPtoLevel"))
			ply:SetNWInt("plyEXPtoLevel", (lvlexpscale * ply:GetNWInt("plyLevel")) * lvlexppower)
			ply:SetNWInt("plySkillPoints", ply:GetNWInt("plySkillPoints") + GetConVar( "gmc_points_per_level"):GetInt())
		end
		
		for id,ammo in pairs(ply:GetAmmo()) do
			local ammomax =  math.floor(game.GetAmmoMax(id) + (game.GetAmmoMax(id) * (ply:GetNWInt("ammoreserve") * MOD_AMMORES)))
			if ply:GetAmmoCount(id) > ammomax then
				ply:SetAmmo(ammomax, id)
			end
		end
	end
	
	
end)

function GM:PlayerInitialSpawn ( ply )
	LoadPlayerData(ply)
	ply:SetTeam( TEAM_FFA )
end

function GM:PlayerSpawn(ply)
    ply.SpawnCooldown = t

	-- Get the values of the convars
	local weapons = GetConVar("gmc_loadout_weapon"):GetString()
	local ammoTypes = GetConVar("gmc_loadout_ammotypes"):GetString()
	local ammoAmounts = GetConVar("gmc_loadout_ammoamount"):GetString()

	-- Set the players loadout based on the convars
	local loadout = string.Explode(" ", weapons)
	local ammo = string.Explode(" ", ammoTypes)
	local amount = string.Explode(" ", ammoAmounts)

	-- Grant the player their loadout
    for i = 1, #loadout do
        ply:Give(loadout[i], false)
    end

    for i = 1, #ammo do
		if isnumber(tonumber(amount[i])) then
			ply:GiveAmmo(amount[i] + (game.GetAmmoMax(game.GetAmmoID(ammo[i])) * (ply:GetNWInt("ammoreserve") * MOD_AMMORES)), ammo[i])
		end
    end

    SetAUX(ply)
    ply:SetDuckSpeed(0.3)
    ply:SetUnDuckSpeed(0.4)
    ply:SetCrouchedWalkSpeed(0.4)
    ply:AllowFlashlight(true)
    ply:SetupHands()
	
    -- Use the spawnpoints
    self:SelectPlayerSpawn(ply)

    ply:GodEnable()
    ply:SetMaterial("models/wireframe")
    timer.Simple(5, function()
        ply:SetMaterial("")
        ply:GodDisable()
		ply:SetColor(Color(255, 255, 255))
    end)
end

function GM:SelectPlayerSpawn(ply)
    if not spawnpoints then return end

    local potentialspawns = {}
    local team = ply:Team()

    for _, spawnpointData in pairs(spawnpoints) do
        local position = spawnpointData.Position
		local angle = spawnpointData.Angle
        local category = spawnpointData.Category
        local spawntype = spawnpointData.Type

        if category == "Players" then
            local spawnteam = nil

            if spawntype == "Red" then
                spawnteam = TEAM_RED
            elseif spawntype == "Blue" then
                spawnteam = TEAM_BLUE
            elseif spawntype == "Green" then
                spawnteam = TEAM_GREEN
            elseif spawntype == "Purple" then
                spawnteam = TEAM_PURPLE
			else
				spawnteam = "No Team"
            end

            local entitiesNearSpawn = ents.FindInSphere(position, 50)

            local isBlocked = false

            for _, entity in pairs(entitiesNearSpawn) do
                if IsValid(entity) and (entity:IsPlayer() or entity:IsNPC()) then
                    isBlocked = true
                    break
                end
            end

            -- Only add potential spawns if not blocked and the conditions are met
            if not isBlocked then
                if (team ~= TEAM_FFA and team ~= TEAM_COOP) or (spawnteam == team || spawnteam == "No Team") then
                    table.insert(potentialspawns, {position, angle})
                elseif (team == TEAM_FFA or team == TEAM_COOP) then
                    table.insert(potentialspawns, {position, angle})
                end
            end
        end
    end

    if ply:Alive() and #potentialspawns > 0 then
		local pickedspawn = table.Random(potentialspawns)
        ply:SetPos(Vector(pickedspawn[1]))
		if angle then
			ply:SetEyeAngles(pickedspawn[2])
		end
    end
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
		ply:SetPlayerColor(team.GetColor( TEAM_RED ):ToVector())
		ply:SetColor(team.GetColor( TEAM_RED ))
	elseif ply:Team() == TEAM_BLUE then
		ply:SetPlayerColor(team.GetColor( TEAM_BLUE ):ToVector())
		ply:SetColor(team.GetColor( TEAM_BLUE ))
	elseif ply:Team() == TEAM_GREEN then
		ply:SetPlayerColor(team.GetColor( 2 ):ToVector())
		ply:SetColor(team.GetColor( TEAM_GREEN ))
	elseif ply:Team() == TEAM_PURPLE then
		ply:SetPlayerColor(team.GetColor( TEAM_PURPLE ):ToVector())
		ply:SetColor(team.GetColor( TEAM_PURPLE ))
	elseif ply:Team() == TEAM_COOP || ply:Team() == TEAM_FFA then
		ply:SetColor(Color(r, g, b))
		ply:SetPlayerColor(Vector(r / 255, g / 255, b / 255))
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
        print("Failed to load spawn configuration, no config found.")
    end
	
    return spawnpoints
end