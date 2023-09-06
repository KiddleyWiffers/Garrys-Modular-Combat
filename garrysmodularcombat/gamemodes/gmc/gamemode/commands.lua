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

-- Expirence=================================================================================================================================
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
CreateConVar( "gmc_boss_max", "1", FCVAR_NOTIFY, "The amount of bosses that can exist at once.", 0)
CreateConVar( "gmc_boss_cooldown", "600", FCVAR_NOTIFY, "The minimum time between the boss spawns.", 0)
CreateConVar( "gmc_boss_window", "300", FCVAR_NOTIFY, "A random number between 0 and this will be added to the spawn cooldown for less predicatble bosses.", 0)

-- Debug=====================================================================================================================================
concommand.Add("gmc_debug_set_exp", MCCheatSetEXP, nil, "Set EXP on your current character.", 16384)
concommand.Add("gmc_debug_set_lvl", MCCheatSetLVL, nil, "Set LVLs on your current character.", 16384)
concommand.Add("gmc_debug_set_sp", MCCheatSetSP, nil, "Set skill points on your current character.", 16384)

function MCCheatSetEXP(ply, cmd, args)
	ply:SetNWInt("plyEXP", tonumber(args[1]))
	print(tonumber(args[1]))
end

function MCCheatSetLVL(ply, cmd, args)
	local lvlexpbase = GetConVar( "gmc_levelexp_base" ):GetInt()
	local lvlexpscale = GetConVar( "gmc_levelexp_scale" ):GetInt()
	local lvlexppower = GetConVar( "gmc_levelexp_power" ):GetInt()
	ply:SetNWInt("plylevel", tonumber(args[1]))
	ply:SetNWInt("plyEXPtoLevel", (lvlexpscale * ply:GetNWInt("plylevel")) * lvlexppower)
end

function MCCheatSetSP(ply, cmd, args)
	ply:SetNWInt("plySkillPoints", tonumber(args[1]))
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

CreateConVar( "gmc_mod_battery_enable", "1", FCVAR_NOTIFY, "Should we enable the AUX Battery module?", 0)
CreateConVar( "gmc_mod_battery_increase", "10", FCVAR_NOTIFY, "How much shield should AUX Battery grant?", 1)