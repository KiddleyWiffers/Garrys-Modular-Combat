ENT.Base = "base_gmodentity"
ENT.Type = "anim"
ENT.PrintName = "GMC Spawn Setter"
ENT.Author = "Kiddley"
ENT.Purpose = "Place these around the maps to set spawn points for weapons and for Garry's Modular Combat"
ENT.Instructions = "Use the entity to open the weapon selector GUI"
ENT.Spawnable = true
ENT.Category = "Garry's Modular Combat"

if engine.ActiveGamemode() != "gmc" then
	concommand.Add("gmc_savespawns", function(ply, cmd, args, argStr)
		spawnpointents = ents.FindByClass( "gmc_weselector" )
		local spawnpoints = {}
		if spawnpointents then
			for k,v in pairs(spawnpointents) do
				local spawnpos = v:GetPos()
				local spawnc = v:GetNWString("SpawnCategory")
				local spawnt = v:GetNWString("SpawnType")
				local spawn1 = v:GetNWString("ExtraOption1")
				local spawn2 = v:GetNWString("ExtraOption2")
				local spawn3 = v:GetNWString("ExtraOption3")
				
				local spawnpoint = {
					["Position"] = spawnpos,
					["Category"] = spawnc,
					["Type"] = spawnt,
					["Option1"] = spawn1,
					["Option2"] = spawn2,
					["Option3"] = spawn3
				}
				
				table.insert( spawnpoints, spawnpoint)
			end
			SaveSpawnConfigurationToFile(spawnpoints)
		end
	end)

	concommand.Add("gmc_loadspawns", function(ply, cmd, args, argStr)
		local spawnpoints = LoadSpawnConfigurationFromFile()
		local currentspawns = ents.FindByClass( "gmc_weselector" )
		if currentspawns then
			for k,v in pairs(currentspawns) do
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
				local newEntity = ents.Create("gmc_weselector")
				newEntity:SetPos(position)
				newEntity:Spawn()
				newEntity:SetNWString("SpawnCategory", category)
				newEntity:SetNWString("SpawnType", spawntype)
				newEntity:SetNWString("ExtraOption1", option1)
				newEntity:SetNWString("ExtraOption2", option2)
				newEntity:SetNWString("ExtraOption3", option3)
			end
		else
			print("No spawn configuration found.")
		end
	end)
end

function LoadSpawnConfigurationFromFile()
    local spawnpoints = {}

    local data = file.Read("gmc/mapdata/" .. game.GetMap() .. ".txt", "DATA") -- Read the saved data from the file

    if data then
        spawnpoints = util.JSONToTable(data)
    else
        print("Failed to load spawn configuration.")
    end

    return spawnpoints
end

function SaveSpawnConfigurationToFile(spawnData)
	local folderName = "gmc/mapdata"
    local filename = folderName .. "/" .. game.GetMap() .. ".txt"
    local fileContent = ""

    -- Construct the line with the NPC configuration
    local line = util.TableToJSON( spawnData, true )

	-- Create the folder if it doesn't exist
    if not file.IsDir(folderName, "DATA") then
        file.CreateDir(folderName)
    end
	
    -- Write the line to the specific NPC's file
    file.Write(filename, line)

    print("Spawn Configuration saved to file:", filename)
end