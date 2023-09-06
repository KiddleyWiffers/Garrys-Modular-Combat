include("shared.lua")

local spawnableNPCs = {}

local npcDataDirectory = "gmc/npcs/"
local npcFiles = file.Find(npcDataDirectory .. "*", "DATA")

for _, filename in ipairs(npcFiles) do
	-- Construct the full file path
	local filePath = npcDataDirectory .. filename

	-- Read the contents of the file
	local fileContents = file.Read(filePath, "DATA")

	-- Process the file contents (you might want to parse it if it's in a specific format)
	fileContents = util.JSONToTable(fileContents)
	
	table.insert(spawnableNPCs, fileContents)
end

timer.Create( "RegisterNewNPCs", 10, 0, function()
	for _, filename in ipairs(npcFiles) do
		-- Construct the full file path
		local filePath = npcDataDirectory .. filename

		-- Read the contents of the file
		local fileContents = file.Read(filePath, "DATA")

		-- Process the file contents (you might want to parse it if it's in a specific format)
		fileContents = util.JSONToTable(fileContents)
		
		table.insert(spawnableNPCs, fileContents)
	end
end)

timer.Create( "NPCSpawner", 10, 0, function()
	for _, spawnpoint in ipairs(spawnpoints) do
		local position = spawnpoint.Position
		local category = spawnpoint.Category
		local spawntype = spawnpoint.Type
		
		local totalNPCs = GetConVar( "gmc_monsters_base" ):GetInt() + (GetConVar( "gmc_monsters_scale" ):GetInt() * table.Count(player.GetHumans()))
		local maxNPCs = GetConVar( "gmc_monsters_max" ):GetInt()
		local allEnts = ents.GetAll()
		local activeNPCs = 0
		
		local npcData = table.Random(spawnableNPCs)
		
		local npclevel = 0
		for _, ply in pairs(player.GetHumans()) do
			npclevel = npclevel + ply:GetNWInt("plylevel")
		end
		
		npclevel = math.Round(npclevel/(table.Count(player.GetHumans())))
		
		local BossCooldown = 0
		
		local potentialspawns = {}
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
			if (category == "NPCs" && spawntype == "Boss" && tobool(npcData.isboss)) then
				table.insert(potentialspawns, position)
			elseif (category == "NPCs" && spawntype == "Large" && tobool(npcData.islarge)) then
				table.insert(potentialspawns, position)
			elseif (category == "NPCs" && spawntype == "Normal") then
				table.insert(potentialspawns, position)
			end
		end
		
		local function SpawnNPC()
			if #potentialspawns > 0 then
				local enemy = ents.Create(npcData.class)
				enemy.Level = npclevel
				enemy.EXP = ((npcData.baseexp + (npcData.explvl * enemy.Level)) * npcData.exppower)
				enemy.Name = npcData.name
				enemy.Team = "Monsters"
				enemy.Damage = ((npcData.basedamage + (npcData.damagelvl * enemy.Level)) * npcData.damagepower)
				enemy:SetPos(table.Random(potentialspawns))
				enemy:SetModelScale(npcData.scale, 0)
				enemy:SetColor(Color(npcData.color.red, npcData.color.blue, npcData.color.green, npcData.color.alpha))
				enemy:Spawn()
				enemy:SetHealth((npcData.basehealth + (npcData.healthlvl * enemy.Level)) * npcData.healthpower)
				enemy:SetMaxHealth((npcData.basehealth + (npcData.healthlvl * enemy.Level)) * npcData.healthpower)
				enemy:SetNWInt("NPCLevel", enemy.Level)
				enemy:SetNWString("NPCName", enemy.Name)
			end
		end
		
		for _, ent in pairs(allEnts) do
			if ent:IsNPC() then
				activeNPCs = activeNPCs+1
			end
		end
		
		if (activeNPCs < totalNPCs and activeNPCs < maxNPCs) then
			if category == "NPCs" && spawntype == "Boss" && tobool(npcData.isboss) && tobool(npcData.islarge) == false && tobool(npcData.isminion) == false && BossCooldown < 1 then
				SpawnNPC()
			elseif category == "NPCs" && spawntype == "Large" && tobool(npcData.islarge) == true && tobool(npcData.isboss) == false && tobool(npcData.isminion) == false then
				SpawnNPC()
			elseif category == "NPCs" && spawntype == "Normal" && tobool(npcData.isboss) == false && tobool(npcData.islarge) == false && tobool(npcData.isminion) == false then
				SpawnNPC()
			end
		end
	end
end)

function GM:Initialize()
	spawnpoints = LoadSpawnConfigurationFromFile()
	if GetConVar( "gmc_levelexp_base" ):GetInt() > 3 then
		timer.Stop("NPCSpawner")
	end
end

cvars.AddChangeCallback("gmc_gamemode", function(convar, old, new)
    if tonumber(new) < 3 then
		if timer.Exists("NPCSpawner") then
			timer.Start("NPCSpawner")
		end
	else
		if timer.Exists("NPCSpawner") then
			timer.Stop("NPCSpawner")
			local allEnts = ents.GetAll()
			for _, ent in pairs(allEnts) do
				if ent:IsNPC() && ent.Team == "Monsters" then
					ent:Remove()
				end
			end
		end
	end
end)

hook.Add("OnEntityCreated", "MyEntityCreatedHook", function(entity)
    if IsValid(entity) and entity:IsNPC() then
		if entity:GetOwner():IsNPC() then
			local creator = entity:GetOwner()
			entity.Level = creator.Level
			entity.EXP = (math.Round(creator.EXP/2))
			entity.Name = "NPC Summon"
		end
		entity:SetNWString("NPCName", entity.Name)
		entity:SetNWInt("NPCLevel", entity.Level)

		local allEnts = ents.GetAll()
		for _, ent in pairs(allEnts) do
			if ent:IsNPC() && ent.Team == "Monsters" then
				entity:AddEntityRelationship( ent, D_LI, 99 )
				ent:AddEntityRelationship( entity, D_LI, 99 )
			elseif ent:IsNPC() then
				entity:AddEntityRelationship( ent, D_HT, 99 )
				ent:AddEntityRelationship( entity, D_HT, 99 )
			end
		end
    end
end)