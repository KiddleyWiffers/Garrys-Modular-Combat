include("shared.lua")

local spawnableNPCs = {}

local npcDataDirectory = "gmc/npcs/"
local npcFiles = file.Find(npcDataDirectory .. "*", "DATA")

local GAMEMODE_MONSTER_THRESHOLD = 3

table.Empty(spawnableNPCs)
for _, filename in ipairs(npcFiles) do
	-- Construct the full file path
	local filePath = npcDataDirectory .. filename

	
	-- Read the contents of the file
	local fileContents = file.Read(filePath, "DATA")

	-- Process the file contents (you might want to parse it if it's in a specific format)
	fileContents = util.JSONToTable(fileContents)
		
	if fileContents.isminion == "false" then
		table.insert(spawnableNPCs, fileContents)
	end
			
	npcsRegistered = true
end

if GetConVar("gmc_gamemode"):GetInt() < GAMEMODE_MONSTER_THRESHOLD then
	timer.Create( "NPCSpawner", GetConVar("gmc_spawnwave_time"):GetFloat(), 0, function()
		for i = 0, GetConVar("gmc_spawnwave_size"):GetInt() do
			local activeNPCs = 0
			local totalNPCs = GetConVar( "gmc_monsters_base" ):GetInt() + (GetConVar( "gmc_monsters_scale" ):GetInt() * table.Count(player.GetHumans()))
			local maxNPCs = GetConVar( "gmc_monsters_max" ):GetInt()
			local allEnts = ents.GetAll()
			
			for _, ent in pairs(allEnts) do
				if ent:IsNPC() then
					activeNPCs = activeNPCs+1
				end
			end
			
			if (activeNPCs < totalNPCs and activeNPCs < maxNPCs) then
				local totalWeight = 1
				local npcData
				
				for k, npc in pairs(spawnableNPCs) do
					npc.minWin = totalWeight
					totalWeight = totalWeight + npc.weight
					npc.maxWin = totalWeight
				end
				
				local pickedNPC = math.random(1, totalWeight)
				
				for k, npc in pairs(spawnableNPCs) do
					if pickedNPC > npc.minWin && pickedNPC < npc.maxWin then
						npcData = npc
					end
				end
				
				local npclevel = 0
				for _, ply in pairs(player.GetHumans()) do
					npclevel = npclevel + ply:GetNWInt("plyLevel")
				end
					
				npclevel = math.Round(npclevel/(table.Count(player.GetHumans())))
				
				local potentialspawns = {}
				
				for _, spawnpoint in ipairs(spawnpoints) do
					local position = spawnpoint.Position
					local category = spawnpoint.Category
					local spawntype = spawnpoint.Type
				
					local entitiesNearSpawn = ents.FindInSphere(position, 50)
						
					local isBlocked = false
						
					for _, entity in pairs(entitiesNearSpawn) do
						if IsValid(entity) and (entity:IsPlayer() || entity:IsNPC()) then
							isBlocked = true
							break 
						end
					end
						
					-- Only add potential spawns if not blocked and the conditions are met
					if not isBlocked && npcData != nil then
						if (category == "NPCs" && spawntype == "Boss" && tobool(npcData.isboss)) then
							table.insert(potentialspawns, position)
						elseif (category == "NPCs" && spawntype == "Large" && tobool(npcData.islarge)) then
							table.insert(potentialspawns, position)
						elseif (category == "NPCs" && spawntype == "Normal" && tobool(npcData.islarge) == false && tobool(npcData.isboss) == false) then
							table.insert(potentialspawns, position)
						end
					end
				end
				if #potentialspawns > 0 && npcData != nil then
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
					if npcData.weapon then
						enemy:Give(npcData.weapon)
					end
					enemy:SetHealth((npcData.basehealth + (npcData.healthlvl * enemy.Level)) * npcData.healthpower)
					enemy:SetMaxHealth((npcData.basehealth + (npcData.healthlvl * enemy.Level)) * npcData.healthpower)
					enemy:SetNWInt("NPCLevel", enemy.Level)
					enemy:SetNWString("NPCName", enemy.Name)
				end	
			end
		end
	end)
end

function GM:Initialize()
	spawnpoints = LoadSpawnConfigurationFromFile()
end

cvars.AddChangeCallback("gmc_gamemode", function(convar, old, new)
    if tonumber(new) < GAMEMODE_MONSTER_THRESHOLD then
		if timer.Exists("NPCSpawner") then
			timer.Start("NPCSpawner")
		end
	else
		if timer.Exists("NPCSpawner") then
			timer.Stop("NPCSpawner")
			local allEnts = ents.GetAll()
			for _, ent in pairs(allEnts) do
				if ent:IsNPC() && ent.Team == "Monsters" then
					local d = DamageInfo()
					d:SetDamage( ent:Health() * 100 )
					d:SetDamageType( DMG_DISSOLVE )
					ent:TakeDamageInfo( d )
				end
			end
		end
	end
end)

hook.Add("OnEntityCreated", "NPCStats", function(entity)
	if IsValid(entity) and entity:IsNPC() then
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
		
		local possibleNPCs = {}
		timer.Simple(0.01, function()
			local npclevel = 0
			for _, ply in pairs(player.GetHumans()) do
				npclevel = npclevel + ply:GetNWInt("plyLevel")
			end

			npclevel = math.Round(npclevel / (table.Count(player.GetHumans())))

			-- Check if the entity and its owner are both valid
			if IsValid(entity) and IsValid(entity:GetOwner()) then
				for _, npc in pairs(spawnableNPCs) do
					if npc.class == entity:GetClass() then
						table.insert(possibleNPCs, npc)
					end
				end

				if #possibleNPCs == 0 then
					entity:Remove()
					print("Something just attempted to create an NPC that isn't accounted for by your NPC list. Please add " .. entity:GetClass() .. " to the spawn pool. If you don't want it to spawn naturally, set spawn weight to 0")
				else
					local npcData = table.Random(possibleNPCs)
					entity.Level = npclevel
					entity.EXP = ((npcData.baseexp + (npcData.explvl * entity.Level)) * npcData.exppower)
					entity.Name = npcData.name
					entity.Team = "Monsters"
					entity.Damage = ((npcData.basedamage + (npcData.damagelvl * entity.Level)) * npcData.damagepower)
					entity:SetModelScale(npcData.scale, 0)
					entity:SetColor(Color(npcData.color.red, npcData.color.blue, npcData.color.green, npcData.color.alpha))
					entity:SetHealth((npcData.basehealth + (npcData.healthlvl * entity.Level)) * npcData.healthpower)
					entity:SetMaxHealth((npcData.basehealth + (npcData.healthlvl * entity.Level)) * npcData.healthpower)
					entity:SetNWInt("NPCLevel", entity.Level)
					entity:SetNWString("NPCName", entity.Name)
				end
			end
		end)
	end
end)