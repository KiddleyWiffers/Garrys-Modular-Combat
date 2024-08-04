AddCSLuaFile()

include("modules.lua")

local lvlexpbase = GetConVar( "gmc_levelexp_base" ):GetInt()
local lvlexpscale = GetConVar( "gmc_levelexp_scale" ):GetInt()
local lvlexppower = GetConVar( "gmc_levelexp_power" ):GetInt()

 local defaultSuit = {
	SuitName = "New Suit",
	plyEXP = 0,
	plyLevel = 1,
	plySkillPoints = GetConVar("gmc_points_per_level"):GetInt(),
	tech = {},
	keybinds = {}
}

concommand.Add("reloadsuitdata", function(ply, cmd, args) LoadPlayerData(ply) end)

function MergeTables(target, source)
    for key, value in pairs(source) do
        if type(value) == "table" and type(target[key]) == "table" then
            MergeTables(target[key], value)
        else
            target[key] = value
        end
    end
end

function LoadPlayerData(ply)
    local dataPath = "gmc/players/" .. ply:SteamID64() .. ".txt"
	
    if file.Exists(dataPath, "DATA") then
        local existingData = util.JSONToTable(file.Read(dataPath, "DATA"))
        if existingData then
			if ply:GetNWString("ActiveSuit") == "" then
				ply:SetNWString("ActiveSuit", existingData.activeSuit)
				print("Overriding Active Suit")
			end
			local suit = ply:GetNWString("ActiveSuit")
            for k, data in pairs(existingData.suits) do
				if suit == tostring(k) then
					print(k)
					ply:SetNWInt("plyEXP", data.plyEXP)
					ply:SetNWInt("plyLevel", data.plyLevel)
					ply:SetNWInt("plySkillPoints", data.plySkillPoints)
					for mod, lvl in pairs(data.tech) do
						ply:SetNWInt(mod, lvl)
					end
				end
            end
			net.Start("SendSuitInfoToClient")
				net.WriteTable( existingData )
			net.Send(ply)
			ply:SetNWString("ActiveSuitName", existingData.suits[suit].SuitName)
			ply:SetNWInt("plyEXPtoLevel", (lvlexpscale * ply:GetNWInt("plyLevel")) * lvlexppower)
            print("Loaded data for " .. ply:Nick())
        else
            print("Failed to load data for " .. ply:Nick() ", creating new save.")
			CreateNewData(ply)
			LoadPlayerData(ply)
        end
    else
        print("No data found for " .. ply:Nick() .. ", creating new save.")
        CreateNewData(ply)
		LoadPlayerData(ply)
    end
end

function CreateNewData(ply)
    local steamID64 = ply:SteamID64()
    if not steamID64 then
        return
    end

    local dataPath = "gmc/players/" .. steamID64 .. ".txt"

    if not file.Exists("gmc/players/", "DATA") then
        file.CreateDir("gmc/players/")
    end

    local datatable = {
        Player = ply:Nick(),
        activeSuit = "suit1", -- Set the active suit to "suit1"
        suits = {}
    }

    -- Create and initialize suits
    for i = 1, 5 do
        local suitKey = "suit" .. i
        local suitData = table.Copy(defaultSuit)

        -- Initialize tech for all suits
        for k, mod in pairs(modules) do
            suitData.tech[mod.id] = 0
        end
		
		suitData.keybinds = {}
		suitData.keybinds["prev"] = 36
		suitData.keybinds["next"] = 13
		suitData.keybinds["selected"] = 34

        -- Set NWInt values only for "suit1"
        if suitKey == "suit1" then
            ply:SetNWInt("plyEXP", suitData.plyEXP)
            ply:SetNWInt("plyLevel", suitData.plyLevel)
            ply:SetNWInt("plySkillPoints", suitData.plySkillPoints)
			ply:SetNWString("ActiveSuit", suitData.activeSuit)
			ply:SetNWString("ActiveSuitName", suitData.SuitName)
			ply:SetNWInt("plyEXPtoLevel", (lvlexpscale * ply:GetNWInt("plyLevel")) * lvlexppower)
        end

        -- Add the suit data to the datatable
        datatable.suits[suitKey] = suitData
    end
	
    file.Write(dataPath, util.TableToJSON(datatable, true))
end

function SavePlayerData(ply)
    local dataPath = "gmc/players/" .. ply:SteamID64() .. ".txt"

    if file.Exists(dataPath, "DATA") then
        local existingData = util.JSONToTable(file.Read(dataPath, "DATA"))
        if existingData then
            local suit = ply:GetNWString("ActiveSuit")
			
            -- Find the active suit's data
			existingData.activeSuit = suit
            local activeSuitData = existingData.suits[suit]

            if activeSuitData then
                -- Update the active suit's properties
                activeSuitData.plyEXP = ply:GetNWInt("plyEXP")
                activeSuitData.plyLevel = ply:GetNWInt("plyLevel")
                activeSuitData.plySkillPoints = ply:GetNWInt("plySkillPoints")
				activeSuitData.SuitName = ply:GetNWString("ActiveSuitName")

				-- Check for new tech modules and add them to the suit data
                for _, mod in pairs(modules) do
                    local modID = mod.id
                    if activeSuitData.tech[modID] == nil then
                        activeSuitData.tech[modID] = ply:GetNWInt(modID)
                    end
                end
				
				-- Update tech for the active suit
                for mod, _ in pairs(activeSuitData.tech) do
                    activeSuitData.tech[mod] = ply:GetNWInt(mod)
                end
				
				table.sort(existingData)
                -- Save updated data back to the file
                file.Write(dataPath, util.TableToJSON(existingData, true))
                print("Saved data for " .. ply:Nick())
            else
                print("Failed to save data for " .. ply:Nick() .. " - Active suit data not found.")
            end
        else
            print("Failed to save data for " .. ply:Nick() .. " - Existing data is invalid.")
        end
    else
        print("Failed to save data for " .. ply:Nick() .. " - Data file not found.")
    end
end

net.Receive("ChangeSuits", function(len, ply)
	RecieveSecurity(ply)
	local newSuit = net.ReadString()
	SavePlayerData(ply)
	ply:SetNWString("ActiveSuit", newSuit)
	LoadPlayerData(ply)
	
	local dataPath = "gmc/players/" .. ply:SteamID64() .. ".txt"
	local existingData = util.JSONToTable(file.Read(dataPath, "DATA"))
	
	net.Start("SendSuitInfoToClient")
		net.WriteTable( existingData )
	net.Send(ply)

	SavePlayerData(ply)
	
	local d = DamageInfo()
	d:SetDamage( ply:Health() * 100 )
	d:SetAttacker( ply )
	d:SetDamageType( DMG_DISSOLVE ) 
	
	ply:EmitSound("ambient/machines/teleport4.wav", 75, 100, 1, CHAN_AUTO)
	ply:GodDisable()
	ply:TakeDamageInfo( d )
end)

function ResetActiveSuitData(ply)
    local suit = ply:GetNWString("ActiveSuit")
    local dataPath = "gmc/players/" .. ply:SteamID64() .. ".txt"

    if file.Exists(dataPath, "DATA") then
        local existingData = util.JSONToTable(file.Read(dataPath, "DATA"))

        if existingData and existingData.suits[suit] then

            local activeSuitData = existingData.suits[suit]

            -- Reset active suit's properties to default values
            activeSuitData.SuitName = defaultSuit.SuitName
            activeSuitData.plyEXP = defaultSuit.plyEXP
            activeSuitData.plyLevel = defaultSuit.plyLevel
            activeSuitData.plySkillPoints = defaultSuit.plySkillPoints
			
			
			ply:SetNWInt("plyEXP", defaultSuit.plyEXP)
            ply:SetNWInt("plyLevel", defaultSuit.plyLevel)
            ply:SetNWInt("plySkillPoints", defaultSuit.plySkillPoints)
			ply:SetNWString("ActiveSuitName", defaultSuit.SuitName)
			ply:SetNWInt("plyEXPtoLevel", (lvlexpscale * ply:GetNWInt("plyLevel")) * lvlexppower)
			
            for mod, _ in pairs(activeSuitData.tech) do
                activeSuitData.tech[mod] = 0
				ply:SetNWInt(mod, 0)
            end
			
			for mod, bind in pairs(activeSuitData.keybinds) do
				if mod != "prev" && mod != "next" && mod != "selected" then
					activeSuitData.keybinds[mod] = 0
				elseif mod == "prev" then
					activeSuitData.keybinds[mod] = 36
				elseif mod == "next" then
					activeSuitData.keybinds[mod] = 13
				elseif mod == "selected" then
					activeSuitData.keybinds[mod] = 34
				elseif !IsValid(mod) then
					activeSuitData.keybinds["prev"] = 36
					activeSuitData.keybinds["next"] = 13
					activeSuitData.keybinds["selected"] = 34
				end
            end
			
            -- Save the updated active suit data back to the file
            SavePlayerData(ply)
            print("Reset active suit data for " .. ply:Nick())
        else
            print("Failed to reset active suit data for " .. ply:Nick() .. " - Active suit data not found.")
        end
    else
        print("Failed to reset active suit data for " .. ply:Nick() .. " - Data file not found.")
    end
end

net.Receive("ResetSuit", function(len, ply)
	RecieveSecurity(ply)
	ResetActiveSuitData(ply)
end)

net.Receive("BindModules", function(len, ply)
	RecieveSecurity(ply)
	local mod = net.ReadString()
	local key = net.ReadInt(9)
	local dataPath = "gmc/players/" .. ply:SteamID64() .. ".txt"
	local existingData = util.JSONToTable(file.Read(dataPath, "DATA"))
	
	if existingData then
		local suit = ply:GetNWString("ActiveSuit")
			
		-- Find the active suit's data
		existingData.activeSuit = suit
		local activeSuitData = existingData.suits[suit]
		
		activeSuitData.keybinds[mod] = key
	end
	
	file.Write(dataPath, util.TableToJSON(existingData, true))
	
	net.Start("SendSuitInfoToClient")
		net.WriteTable( existingData )
	net.Send(ply)
end)

net.Receive("RenameSuit", function(len,ply)
	RecieveSecurity(ply)
	local curSuit = net.ReadString()
	local newName = net.ReadString()
	local dataPath = "gmc/players/" .. ply:SteamID64() .. ".txt"
	
	ply:SetNWString("ActiveSuitName", newName)
	SavePlayerData(ply)
	
    local existingData = util.JSONToTable(file.Read(dataPath, "DATA"))
	net.Start("SendSuitInfoToClient")
		net.WriteTable( existingData )
	net.Send(ply)
end)