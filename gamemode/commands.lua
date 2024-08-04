AddCSLuaFile()

-- Clientside=================================================================================================================================
CreateClientConVar( "gmc_color", "255 255 255", true, true, "Pick your color for PvM and free for all. You can use any RGB value (0 0 0) in this format.")
CreateClientConVar( "gmc_model", "Rebels", true, true, "Pick your Playermodel.")
-- Gamemode===================================================================================================================================
CreateConVar( "gmc_gamemode", "0", FCVAR_NOTIFY, "Change the Gamemode, valid options are 0 = PvM, 1 = Chaos Mode(FFA PvM), 2 = TvM, 3-Deathmatch, 4-Team Deathmatch", 0, 4)

GAMEMODE_PRINTNAMES = {
	[0] = "Players VS Monsters",
	[1] = "Chaos Mode",
	[2] = "Teams VS Monsters",
	[3] = "Deathmatch",
	[4] = "Team Deathmatch",
}

CreateConVar( "gmc_aux_base", "100", FCVAR_NOTIFY, "What should the base AUX be for all players.", 0)
-- Loadout convars default values
local defaultWeapons = "weapon_crowbar weapon_physcannon weapon_pistol weapon_smg1"
local defaultAmmoTypes = "pistol smg1"
local defaultAmmoAmounts = "150 200"

-- Loadout convars
CreateConVar("gmc_loadout_weapon", defaultWeapons, FCVAR_ARCHIVE, "Which weapons should the players spawn with? (Default: " .. defaultWeapons .. ")")
CreateConVar("gmc_loadout_ammotypes", defaultAmmoTypes, FCVAR_ARCHIVE, "What ammotypes should we give the player when they spawn? (Default: " .. defaultAmmoTypes .. ")")
CreateConVar("gmc_loadout_ammoamount", defaultAmmoAmounts, FCVAR_ARCHIVE, "How much of each ammo type should we give the player when they spawn? (This must have the same amount of arguments as ammotypes and will also grant the ammo in the same order as ammotypes.) (Default: " .. defaultAmmoAmounts .. ")")
-- EXP=================================================================================================================================
CreateConVar( "gmc_levelexp_base", "1000", FCVAR_NOTIFY, "Base amount of XP required to level.", 0)
CreateConVar( "gmc_levelexp_scale", "1000", FCVAR_NOTIFY, "Increase XP required to level by this * level", 0)
CreateConVar( "gmc_levelexp_power", "1", FCVAR_NOTIFY, "Multiply (gmc_levelexp_base + gmc_levelexp_scale) by this number.", 0.01)
CreateConVar( "gmc_points_per_level", "2", FCVAR_NOTIFY, "How many skill points do players get per level up?", 1)
CreateConVar( "gmc_exp_playerkills", "100", FCVAR_NOTIFY, "How much EXP should we reward players for killing another player.", 1)
CreateConVar( "gmc_exp_lvldifference_multiplier", "0.05", FCVAR_NOTIFY, "How much should we multiply the XP by per level difference.", 0.01)

-- PVM=======================================================================================================================================
CreateConVar( "gmc_monsters_base", "10", FCVAR_NOTIFY, "The base amount of monsters to spawn in PvM Gamemodes", 1)
CreateConVar( "gmc_monsters_scale", "2", FCVAR_NOTIFY, "The amount of monsters to spawn per player in PvM Gamemodes", 0)
CreateConVar( "gmc_monsters_max", "20", FCVAR_NOTIFY, "The amount of monsters that can exist at once.", 1)
CreateConVar( "gmc_largemonsters_max", "2", FCVAR_NOTIFY, "The amount of large monsters that can exist at once.", 0)
CreateConVar( "gmc_spawnwave_size", "3", FCVAR_NOTIFY, "How many NPCs should spawn per wave.", 1)
CreateConVar( "gmc_spawnwave_time", "10", FCVAR_NOTIFY, "The time between spawn waves.", 1)
CreateConVar( "gmc_boss_max", "1", FCVAR_NOTIFY, "The amount of bosses that can exist at once.", 0)
CreateConVar( "gmc_boss_cooldown", "600", FCVAR_NOTIFY, "The minimum time between the boss spawns.", 0)
CreateConVar( "gmc_boss_window", "300", FCVAR_NOTIFY, "A random number between 0 and this will be added to the spawn cooldown for less predicatble bosses.", 0)
CreateConVar( "gmc_npc_weapon_drop", "0", FVAR_NOTIFY, "If 0, will prevent NPCs from dropping weapons when they die.", 0, 1)

-- Debug=====================================================================================================================================
concommand.Add("gmc_debug_set_exp", GMCCheatSetEXP, nil, "Set EXP on your current character.", 16384)
concommand.Add("gmc_debug_set_lvl", GMCCheatSetLVL, nil, "Set LVLs on your current character.", 16384)
concommand.Add("gmc_debug_set_sp", GMCCheatSetSP, nil, "Set skill points on your current character.", 16384)
concommand.Add("gmc_debug_printweapons", GMCCheatPrintWeapons, nil, "Prints a list of weapons on the server for testing.", 0)

function GMCCheatSetEXP(ply, cmd, args)
	ply:SetNWInt("plyEXP", tonumber(args[1]))
end

function GMCCheatSetLVL(ply, cmd, args)
	local lvlexpbase = GetConVar( "gmc_levelexp_base" ):GetInt()
	local lvlexpscale = GetConVar( "gmc_levelexp_scale" ):GetInt()
	local lvlexppower = GetConVar( "gmc_levelexp_power" ):GetInt()
	ply:SetNWInt("plyLevel", tonumber(args[1]))
	ply:SetNWInt("plyEXPtoLevel", (lvlexpscale * ply:GetNWInt("plyLevel")) * lvlexppower)
end

function GMCCheatSetSP(ply, cmd, args)
	ply:SetNWInt("plySkillPoints", tonumber(args[1]))
end

function GMCCheatPrintWeapons(ply, cmd, args)
	for k,weptable in pairs(weapons.GetList()) do
		local name = weptable.PrintName or "NULL"
		print(name .. " - " .. weptable.ClassName)
	end
end
-- Modules====================================================================================================================================
CreateConVar( "gmc_mod_vitality_enable", "1", FCVAR_NOTIFY, "Should we enable the Vitality module?", 0)
CreateConVar( "gmc_mod_vitality_increase", "10", FCVAR_NOTIFY, "How much health should Vitalty grant?", 1)

CreateConVar( "gmc_mod_shield_enable", "1", FCVAR_NOTIFY, "Should we enable the Shield Integrity module?", 0)
CreateConVar( "gmc_mod_shield_increase", "10", FCVAR_NOTIFY, "How much shield should Shield Integrity grant?", 1)

CreateConVar( "gmc_mod_battery_enable", "1", FCVAR_NOTIFY, "Should we enable the AUX Battery module?", 0)
CreateConVar( "gmc_mod_battery_increase", "10", FCVAR_NOTIFY, "How much shield should AUX Battery grant?", 1)

CreateConVar( "gmc_mod_shieldrecharge_enable", "1", FCVAR_NOTIFY, "Should we enable the Shield Recharge module?", 0)
CreateConVar( "gmc_mod_shieldrecharge_increase", "1", FCVAR_NOTIFY, "How much shield should Shield Recharge grant?", 1)
CreateConVar( "gmc_mod_shieldrecharge_delay", "1", FCVAR_NOTIFY, "How long should it take for Shield Recharge to proc?.", 0.1)
CreateConVar( "gmc_mod_shieldrecharge_drain", "2", FCVAR_NOTIFY, "How much AUX should Shield Recharge drain per shield?", 0)
CreateConVar( "gmc_mod_shieldrecharge_minaux", "30", FCVAR_NOTIFY, "What percent of AUX should the player have to allow recharge?", 0, 100)

CreateConVar( "gmc_mod_batteryrecharge_enable", "1", FCVAR_NOTIFY, "Should we enable the AUX Battery module?", 0)
CreateConVar( "gmc_mod_batteryrecharge_increase", "0.01", FCVAR_NOTIFY, "How much AUX should AUX Recharge grant?", 1)

-- Active Modules==============================================================================================================================
concommand.Add("gmc_cast", GMCCast, nil, "Cast a module based on its ID. You can either bind this or set the controls in the game menu.")