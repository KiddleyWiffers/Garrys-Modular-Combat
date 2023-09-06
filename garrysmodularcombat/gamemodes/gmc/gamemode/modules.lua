MOD_VIT = 10
MOD_VIT_DESC = ("Increases max health by " .. MOD_VIT)

MOD_ARM = 10
MOD_ARM_DESC = ("Increases max shield by " .. MOD_ARM)

MOD_AUX = 10
MOD_AUX_DESC = ("Increases max AUX by " .. MOD_AUX)

MOD_ARMR = GetConVar( "gmc_mod_shieldrecharge_increase" ):GetInt()
MOD_ARMR_DELAY = GetConVar( "gmc_mod_shieldrecharge_delay" ):GetInt()
MOD_ARMR_DRAIN = GetConVar( "gmc_mod_shieldrecharge_drain" ):GetInt()
MOD_ARMR_MINAUX = GetConVar( "gmc_mod_shieldrecharge_minaux" ):GetInt()
MOD_ARMR_DESC = ("Recharges shield at a rate of " .. MOD_ARMR .. " per " .. MOD_ARMR_DELAY .. " seconds. This drains " .. MOD_ARMR_DRAIN .. " per armor restored, but won't drain less than " .. MOD_ARMR_MINAUX .. "% max AUX power.")

MOD_AUXR = 0.01

MOD_DMG = 0.05

modules = {
	--Passive Modules================================================================================================================================================================================================================================================
    -- Increases max Health by 10 per level
	vitality = {
        PrintName = "Vitality",
        Description = MOD_AUX_DESC,
        Category = "Passive",
        Icon = "gui/gmc/modules/vitality.vtf",
    },
	-- Increases max Armor by 10 per level
    armoramount = {
        PrintName = "Shield Integrity",
        Description = MOD_ARM_DESC,
        Category = "Passive",
        Icon = "gui/gmc/modules/armoramount.vtf",
    },
	-- Increases max AUX by 10 per level
    auxamount = {
        PrintName = "AUX Batteries",
        Description = MOD_AUX_DESC,
        Category = "Passive",
        Icon = "gui/gmc/modules/auxamount.vtf",
    },
	-- Regenerates 2 * LVL armor every 3 seconds.
    armorregen = {
        PrintName = "Shield Recharge",
        Description = MOD_ARMR_DESC,
        Category = "Passive",
        Icon = "gui/gmc/modules/armorregen.vtf",
    },
	-- Regenerates an additional 0.01 AUX per level.
	auxregen = {
        PrintName = "AUX Recharge",
        Description = "Increases AUX Regeneration by {stats} per tick. (Default is 0.05)",
        Category = "Passive",
        Icon = "gui/gmc/modules/auxregen.vtf",
	},
	-- Increases weapon damage by 5% per level
	weapondmg = {
        PrintName = "Impact",
        Description = "Increases weapon damage by {stats}%.",
        Category = "Weapons",
        Icon = "gui/gmc/modules/weapondmg.vtf",
	},
}

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
            for k, lvl in pairs(existingData) do
                ply:SetNWInt(k, lvl)
				print(k .. ", " .. lvl)
            end
            print("Loaded data for " .. ply:Nick())
        else
            print("Failed to load data for " .. ply:Nick() ", creating new save.")
			CreateNewData(ply)
        end
    else
        print("No data found for " .. ply:Nick() .. ", creating new save.")
        CreateNewData(ply)
    end
end

function CreateNewData(ply)
	local dataPath = "gmc/players/" .. ply:SteamID64() .. ".txt"
	if not file.Exists("gmc/players/", "DATA") then
		file.CreateDir("gmc/players/")
	end
			
	local modtable = {}
	
	for k, mod in pairs(modules) do
		modtable[k] = 0
		ply:SetNWInt(k, 0)
	end
			
	file.Write(dataPath, util.TableToJSON(modtable, true))
end

function SavePlayerData(ply)
	local dataPath = "gmc/players/" .. ply:SteamID64() .. ".txt"
	if file.Exists(dataPath, "DATA") then
		local existingData = util.JSONToTable(file.Read(dataPath, "DATA"))
		if existingData then
			for k, mod in pairs(existingData) do
				modules[k].Level = mod.Level
				ply:SetNWInt(k, mod.Level)
			end
            print("Saved data for " .. ply:Nick())
        else
            print("Failed to save data for " .. ply:Nick())
        end
	end
end

timer.Create("Armor Regen", 1, 0, function()
	for k,ply in pairs(player.GetAll()) do
		local armreg = ply:GetNWInt("armorregen")
		local plyAUX = ply:GetNWInt("auxpower")
		local plyMaxAUX = ply:GetNWInt("maxauxpower")
		if armreg > 0 && !(ply:Armor() >= ply:GetMaxArmor()) then
			local armorincrease = ply:Armor() + (MOD_ARMR*armreg)
			if plyAUX > (plyMaxAUX * (MOD_ARMR_MINAUX/100)) then
				if armorincrease < ply:GetMaxArmor() then
					ply:SetArmor(armorincrease)
					ply:SetNWInt("auxpower", plyAUX - (MOD_ARMR * armreg))
				else
					ply:SetArmor(ply:GetMaxArmor())
					ply:SetNWInt("auxpower", plyAUX - (armorincrease - ply:GetMaxArmor()))
				end
			end
		end
	end
end)