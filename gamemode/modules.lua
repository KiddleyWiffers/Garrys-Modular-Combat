AddCSLuaFile()
include("commands.lua")

local baseMaxHealth = 100
local baseMaxArmor = 100
local baseWalkSpeed = 220
local baseRunSpeed = 280
local baseAUX = 100

MOD_VIT = GetConVar( "gmc_mod_vitality_increase" ):GetInt()
MOD_VIT_DESC = ("The Cellular Fortification Nanites Module deploys microscopic machines that reinforce the structural integrity of the user's cells granting " .. MOD_VIT .. " additional health.")

MOD_ARM = GetConVar( "gmc_mod_shield_increase" ):GetInt()
MOD_ARM_DESC = ("The Reinforced Shield Generator Module incorporates more robust energy generation components into the shield's design. This results in a shield that can create and maintain a stronger protective field, granting an additional " .. MOD_ARM .. " points of shield capacity")

MOD_AUX = GetConVar( "gmc_mod_battery_increase" ):GetInt()
MOD_AUX_DESC = ("The Energy Cell Efficiency Module represents a series of subtle but effective optimizations to the suit's energy cell granting the user " .. MOD_AUX .. " more AUX power.")

MOD_ARMR = GetConVar( "gmc_mod_shieldrecharge_increase" ):GetInt()
MOD_ARMR_DELAY = GetConVar( "gmc_mod_shieldrecharge_delay" ):GetInt()
MOD_ARMR_DRAIN = GetConVar( "gmc_mod_shieldrecharge_drain" ):GetInt()
MOD_ARMR_MINAUX = GetConVar( "gmc_mod_shieldrecharge_minaux" ):GetInt()
MOD_ARMR_DESC = ("The Shield Resurgance module recharges shield at a rate of " .. MOD_ARMR .. " per " .. MOD_ARMR_DELAY .. " seconds. This drains " .. MOD_ARMR_DRAIN .. " per armor restored, but won't drain less than " .. MOD_ARMR_MINAUX .. "% max AUX power.")

MOD_AUXR = math.Round(GetConVar( "gmc_mod_batteryrecharge_increase" ):GetFloat(), 2)
MOD_AUXR_DESC = ("The Subspace Energy Amplifier Module enhances the suit's SEC by fine-tuning its connection to the alternate dimension. This augmentation accelerates the rate at AUX recharges by " .. MOD_AUXR .. " per tick.")

MOD_DMG = 0.05
MOD_DMG_DESC = ("The Magnetic Flux Catalyst Module enhances weapon performance by utilizing advanced magnetic field manipulation to increase projectile speed and energy, resulting in a " .. MOD_DMG * 100 .. "% higher damage output.")

MOD_BLUNT = 0.1
MOD_BLUNT_BUFF = 0.05
MOD_BLUNT_TIME = 10	
MOD_BLUNT_DESC = ("The Psi-Blade Augmentation Suite enhances the user's melee weapon with advanced energy manipulation, giving a ".. (MOD_BLUNT * 100) .. "% increase to melee damage. After a melee kill, the suite harnesses residual energy to empower all equipped weapons, granting a " .. (MOD_BLUNT_BUFF * 100) .. "% damage increase for " .. (MOD_BLUNT_TIME) .. " seconds.")

MOD_AMMORES = 0.2
MOD_AMMORES_DESC = ("The Smart Ammo Rack System employs intelligent sorting and storage algorithms to maximize the number of rounds that can be carried by ".. (MOD_AMMORES * 100) .. "% without any increase in the suit's bulk.")

MOD_SPD = 0.1
MOD_SPD_DESC = ("The Hyper-Dynamic Locomotion Module employs advanced micro-thrusters and AI-assisted motion prediction to optimize the wearer's stride and balance. This results in the user moving " .. (MOD_SPD * 100) .. "% faster.")

MOD_HEAL = 10
MOD_HEAL_TIME = 5
MOD_HEAL_DESC = ("The Trauma Response Nanite Swarm can be released to provide " .. MOD_HEAL .. " health over " .. MOD_HEAL_TIME .. " seconds.")
MOD_HEAL_COST = MOD_HEAL/2

MOD_JETPACK = 7
MOD_JETPACK_DESC = ("The jetpack allows you to fly by holding your jump button, this expends AUX over time. Press your jump button while in the air to active it.")

MOD_SHAMP = 1
MOD_SHAMP_COST = 20
MOD_SHAMP_COOLDOWN = 30
MOD_SHAMP_DESC = ("The Shield Overcharge module will increase a targets shield to 200 for " .. MOD_SHAMP .. " seconds. This overloads the shield, causing it to completely drain after the effect ends. The module will have to recharge and cool down, so it cannot be used for " .. MOD_SHAMP_COOLDOWN .. " seconds after the effect ends.")

MOD_CONFUSE = 5
MOD_CONFUSE_PLAYERS = 2
MOD_CONFUSE_DESC = ("The Neuro-Havoc Module scrambles the brain of a monster, compelling them to target any entity within their vicinity for " .. MOD_CONFUSE .. " seconds. For creatures with higher intelligence, it induces only slight motor dysfunction, inverting their controls for " .. MOD_CONFUSE_PLAYERS .. " seconds.")
MOD_CONFUSE_COST = 10
modules = {
	--Passive Modules================================================================================================================================================================================================================================================
    -- Increases max health
	{
        id = "vitality",
        PrintName = "Max Health",
        Description = MOD_VIT_DESC,
        Category = "Passive",
        Icon = "vgui/gui/gmc/modules/vitality",
        MAXLEVEL = 10,
		BASE = 100,
        STAT = {
			{MOD_VIT, "Health"}
		}
    },
    -- Increase max shield
    {
        id = "shieldamount",
        PrintName = "Shield Integrity",
        Description = MOD_ARM_DESC,
        Category = "Passive",
        Icon = "vgui/gui/gmc/modules/armoramount",
        MAXLEVEL = 10,
		BASE = 100,
        STAT = {
			{MOD_ARM, "Shield"}
		}
    },
    -- Regenerates Shield
    {
        id = "shieldregen",
        PrintName = "Shield Recharge",
        Description = MOD_ARMR_DESC,
        Category = "Passive",
        Icon = "vgui/gui/gmc/modules/armorregen.vtf",
        MAXLEVEL = 10,
		BASE = 0,
        STAT = {
            {MOD_ARMR, "Regen"},
            {MOD_ARMR_DRAIN, "Drain"}
        }
    },
    -- Increases max AUX
    {
        id = "auxamount",
        PrintName = "AUX Batteries",
        Description = MOD_AUX_DESC,
        Category = "Passive",
        Icon = "vgui/gui/gmc/modules/auxamount",
        MAXLEVEL = 10,
		BASE = GetConVar( "gmc_aux_base" ):GetInt(),
        STAT = {
            {MOD_AUX, "AUX"}
        }
    },
    -- Regenerates additional AUX
    {
        id = "auxregen",
        PrintName = "AUX Recharge",
        Description = MOD_AUXR_DESC,
        Category = "Passive",
        MAXLEVEL = 10,
		BASE = 0.1,
        Icon = "vgui/gui/gmc/modules/auxregen",
        STAT = {
            {MOD_AUXR, "Regen"}
        }
    },
	-- Increases movement speed
	{
        id = "movespeed",
        PrintName = "Base Speed",
        Description = MOD_SPD_DESC,
        Category = "Passive",
        MAXLEVEL = 10,
		BASE = 0,
        Icon = "vgui/gui/gmc/modules/movespeed",
        STAT = {
            {baseWalkSpeed * MOD_SPD, "Walk"},
			{baseRunSpeed * MOD_SPD, "Run"}
        }
    },
	-- Weapon Modules=====================================================================================================================
    -- Increases weapon damage
    {
        id = "weapondmg",
        PrintName = "Damage",
        Description = MOD_DMG_DESC,
        Category = "Weapons",
        Icon = "vgui/gui/gmc/modules/weapondmg",
        MAXLEVEL = 10,
		BASE = 0,
        STAT = {
            {MOD_DMG * 100, "Damage"}
        }
    },
	{
        id = "meleedamage",
        PrintName = "Melee Damage",
        Description = MOD_BLUNT_DESC,
        Category = "Weapons",
        Icon = "vgui/gui/gmc/modules/bluntforce",
        MAXLEVEL = 10,
		BASE = 0,
        STAT = {
            {MOD_BLUNT * 100, "Damage"},
			{MOD_BLUNT_BUFF * 100, "Buff"}
        }
    },
	{
        id = "ammoreserve",
        PrintName = "Ammo Reserve",
        Description = MOD_AMMORES_DESC,
        Category = "Weapons",
        Icon = "vgui/gui/gmc/modules/ammoreserve",
        MAXLEVEL = 10,
		BASE = 1,
        STAT = {
            {MOD_AMMORES, "Multiplier"}
        }
    },
	-- Target Modules=====================================================================================================================
	{
		id = "restorehp",
		PrintName = "Heal",
		Description = MOD_HEAL_DESC,
		Category = "Target",
		Icon = "vgui/gui/gmc/modules/heal",
		Active = true,
		MAXLEVEL = 10,
		BASE = 0,
		STAT = {
			{MOD_HEAL, "Heal"},
			{MOD_HEAL/2, "Cost"}
		}
	},
	{
		id = "shieldamp",
		PrintName = "Shield Overload",
		Description = MOD_SHAMP_DESC,
		Category = "Target",
		Icon = "vgui/gui/gmc/modules/heal",
		Active = true,
		MAXLEVEL = 10,
		BASE = 0,
		STAT = {
			{MOD_SHAMP, "Time"},
		}
	},
	-- Movement Modules==================================================================================================================
	{
		id = "jetpack",
		PrintName = "Jetpack",
		Description = MOD_JETPACK_DESC,
		Category = "Movement",
		Icon = "vgui/gui/gmc/modules/jetpack",
		Active = false,
		MAXLEVEL = 5,
		BASE = 7,
		INVERTED = true,
		STAT = {
			{1, "Cost"},
		}
	}
}

-- Module logic goes here
-- Passive modules
timer.Create("Armor Regen", 1, 0, function()
	for k,ply in pairs(player.GetAll()) do
		local armreg = ply:GetNWInt("shieldregen")
		local plyAUX = ply:GetNWInt("auxpower")
		local plyMaxAUX = ply:GetNWInt("maxauxpower")
		if SERVER && (armreg > 0 && !(ply:Armor() >= ply:GetMaxArmor())) then
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
	
-- Modules to apply on spawn (Speed, Health, Armor, ect.)
hook.Add( "PlayerSpawn", "SetStats", function(ply)
	ply:SetMaxHealth(ply:GetMaxHealth() + (ply:GetNWInt("vitality") * MOD_VIT))
	ply:SetHealth(ply:Health() + (ply:GetNWInt("vitality") * MOD_VIT))
	ply:SetMaxArmor(ply:GetMaxArmor() + (ply:GetNWInt("shieldamount") * MOD_ARM))
	ply:SetWalkSpeed(baseWalkSpeed)
	ply:SetRunSpeed(baseRunSpeed)
	ply:SetWalkSpeed(ply:GetWalkSpeed() + (ply:GetWalkSpeed() * (ply:GetNWInt("movespeed") * (MOD_SPD))))
	ply:SetRunSpeed(ply:GetRunSpeed() + (ply:GetRunSpeed() * (ply:GetNWInt("movespeed") * (MOD_SPD))))
end)
	
statuses = {
	"Bluntforce",
	"Shield Amp",
	"SA Cooldown"
}

-- Quick timer to simulate a think function but not as resource heavy.
timer.Create("ModuleThink", 0.1, 0, function()
	for k,ply in pairs(player.GetAll()) do
		for k,status in pairs(statuses) do
			-- So for some reason doing an else statement to set the timer makes the screen flash rapidly. So we just gotta do that in the modules.
			if timer.Exists(status .. "_" .. ply:SteamID64()) then
				ply:SetNWInt(status .. "Timer", timer.TimeLeft(status .. "_" .. ply:SteamID64()))
			end
		end
	end
end)

-- Slightly Slower timer for even more optimization
timer.Create("SlowThink", 0.5, 0, function()
	for k,ply in pairs(player.GetAll()) do
		
	end
end)
	
-- Damage modifier implmentation
hook.Add( "EntityTakeDamage", "DamageModules", function(target, dmg)
	if IsValid(target) and IsValid(dmg:GetAttacker()) and dmg:GetAttacker():IsPlayer() then
		local player = dmg:GetAttacker()
		local enemy = target
		local damage = dmg:GetDamage()
		
		if(player:GetNWInt("weapondmg") > 0) then
			dmg:SetDamage(math.Round(damage + (damage * (MOD_DMG * player:GetNWInt("weapondmg")))))
			damage = dmg:GetDamage()
		end
		
		-- List of extra weapons that aren't registered by the find function.
		-- We can also use false on this list to set non-melee weapons that are being registered as melee.
		local meleeweaponlist = {
			weapon_crowbar = true,
		}
		
		-- Apply meleedamage damage
		if(player:GetNWInt("meleedamage") > 0) then
			if meleeweaponlist[player:GetActiveWeapon():GetClass()] then
				dmg:SetDamage(math.Round(damage + (damage * (MOD_BLUNT * player:GetNWInt("meleedamage")))))
				damage = dmg:GetDamage()
				player:SetNWBool("LastAttackWasMelee", true)
			elseif !(dmg:IsBulletDamage() && dmg:IsExplosionDamage()) && (dmg:GetInflictor() == player:GetActiveWeapon()) && (player:GetPos():Distance(target:GetPos()) < 100) && (meleeweaponlist[player:GetActiveWeapon():GetClass()] != false) then
				dmg:SetDamage(math.Round(damage + (damage * (MOD_BLUNT * player:GetNWInt("meleedamage")))))
				damage = dmg:GetDamage()
				player:SetNWBool("LastAttackWasMelee", true)
			else
				player:SetNWBool("LastAttackWasMelee", false)
			end
		end
		
		-- Apply Bluntforce damage
		if(player:GetNWInt("Bluntforce") > 0) then
			dmg:SetDamage(math.Round(damage + (damage * (MOD_BLUNT_BUFF * player:GetNWInt("Bluntforce")))))
			damage = dmg:GetDamage()
		end
	end
end)
	
-- On Kill effects
hook.Add( "OnNPCKilled", "NPCKillEffect", function(victim, attacker, inflictor)
	if IsValid(attacker) and IsValid(victim) then
		if attacker:GetNWInt("meleedamage") > 0 && attacker:GetNWBool("LastAttackWasMelee") == true then
			if timer.Exists("Bluntforce_" .. attacker:SteamID64()) then
				timer.Start("Bluntforce_" .. attacker:SteamID64())
			else
				timer.Create("Bluntforce_" .. attacker:SteamID64(), MOD_BLUNT_TIME, 1, function()
					attacker:SetNWInt("Bluntforce", 0)
					attacker:SetNWInt("BluntforceTimer", 0)
				end)
			end
			attacker:SetNWInt("Bluntforce", attacker:GetNWInt("Bluntforce") + 1)
		end
	end
end)
	
hook.Add( "PlayerDeath", "PlayerKillEffect", function(victim, attacker, inflictor)
	if IsValid(attacker) and IsValid(victim) then
		if attacker:GetNWInt("meleedamage") > 0 && attacker:GetNWBool("LastAttackWasMelee") == true then
			if timer.Exists("Bluntforce_" .. attacker:SteamID64()) then
				timer.Start("Bluntforce_" .. attacker:SteamID64())
			else
				timer.Create("Bluntforce_" .. attacker:SteamID64(), MOD_BLUNT_TIME, 1, function()
					attacker:SetNWInt("Bluntforce", 0)
					attacker:SetNWInt("BluntforceTimer", 0)
				end)
			end
			attacker:SetNWInt("Bluntforce", attacker:GetNWInt("Bluntforce") + 1)
		end
	end
end)
	
--Active Modules casting
function GMCCast(ply, cmd, args)
	if args then
		local modid = args[1]
		
		if ply:GetNWInt(modid) > 0 then
		-- Heal Module
			if modid == "restorehp" then
				local tr = ply:GetEyeTraceNoCursor()
				local ent = tr.Entity
				local hitDistance = tonumber((ply:EyePos() - tr.HitPos):Length())
				local maxRange = 200
				
				if (hitDistance < maxRange && ent:IsPlayer() && (ply:Team() == ent:Team())) then
					local enthp = ent:Health()
					local entmaxhp = ent:GetMaxHealth()
					
					if(enthp < entmaxhp && ply:GetNWInt("auxpower") > (MOD_HEAL/2)) then
						timer.Create("Heal_" .. ent:SteamID64(), 1, MOD_HEAL_TIME, function()
							local plyAUX = ply:GetNWInt("auxpower")
							if plyAUX > (MOD_HEAL/2) then
								ply:SetNWInt("auxpower", plyAUX - (MOD_HEAL/2))
							else
								timer.Remove("Heal_" .. ent:SteamID64())
								return
							end
							if (ent:Health() + MOD_HEAL) < ent:GetMaxHealth() then
								ent:SetHealth(ent:Health() + math.Round((MOD_HEAL/MOD_HEAL_TIME) * ply:GetNWInt("restorehp")))
							else
								ent:SetHealth(ent:GetMaxHealth())
								timer.Remove("Heal_" .. ent:SteamID64())
							end
						end)
					end
				elseif (hitDistance < maxRange && ent:IsNPC() && (ent.Team == ply:Team())) then
					-- TODO: Add functionality to heal Minion NPCs on the players team.
				elseif(ply:Health() < ply:GetMaxHealth()) then
					timer.Create("Heal_" .. ply:SteamID64(), 1, MOD_HEAL_TIME, function()
						local plyAUX = ply:GetNWInt("auxpower")
						if plyAUX > (MOD_HEAL/2) then
							ply:SetNWInt("auxpower", plyAUX - (MOD_HEAL/2))
						else
							timer.Remove("Heal_" .. ply:SteamID64())
							return
						end
						if (ply:Health() + MOD_HEAL) < ply:GetMaxHealth() then
							ply:SetHealth(ply:Health() + math.Round((MOD_HEAL/MOD_HEAL_TIME) * ply:GetNWInt("restorehp")))
						else
							ply:SetHealth(ply:GetMaxHealth())
							timer.Remove("Heal_" .. ply:SteamID64())
							ply:SetNWInt("HealTimer", 0)
						end
						ply:SetNWInt("auxpower", plyAUX - (MOD_HEAL/2))
					end)
				end
			elseif modid == "shieldamp" then
				local tr = ply:GetEyeTraceNoCursor()
				local ent = tr.Entity
				local hitDistance = tonumber((ply:EyePos() - tr.HitPos):Length())
				local maxRange = 200
				
				if (hitDistance < maxRange && ent:IsPlayer() && (ply:Team() == ent:Team())) then
					local enthp = ent:Health()
					local entmaxhp = ent:GetMaxHealth()
					
					if(enthp < entmaxhp && plyAUX > (MOD_HEAL/2)) then
						timer.Create("Heal_" .. ent:SteamID64(), 1, MOD_HEAL_TIME, function()
							local plyAUX = ply:GetNWInt("auxpower")
							if plyAUX > (MOD_HEAL/2) then
								ply:SetNWInt("auxpower", plyAUX - (MOD_HEAL/2))
							else
								timer.Remove("Heal_" .. ent:SteamID64())
								return
							end
							if (ent:Health() + MOD_HEAL) < ent:GetMaxHealth() then
								ent:SetHealth(ent:Health() + math.Round((MOD_HEAL/MOD_HEAL_TIME) * ply:GetNWInt("restorehp")))
							else
								ent:SetHealth(ent:GetMaxHealth())
								timer.Remove("Heal_" .. ent:SteamID64())
							end
						end)
					end
				else
					local plyAUX = ply:GetNWInt("auxpower")
					if plyAUX > (MOD_SHAMP_COST) && !timer.Exists("ShampCooldown_" .. ply:SteamID64()) then
						ply:SetNWInt("auxpower", plyAUX - (MOD_SHAMP_COST))
						ply:EmitSound( "npc/scanner/scanner_electric2.wav", 75, 100, 1, CHAN_AUTO)
						timer.Create("Shamp_" .. ply:SteamID64(), 0.2, ply:GetNWInt("shieldamp") * 5, function()
						ply:SetNWInt("Shield AmpTimer", timer.RepsLeft("Shamp_" .. ply:SteamID64())/5)
						ply:SetArmor(1000)
						if timer.RepsLeft("Shamp_" .. ply:SteamID64() < 1) && (timer.RepsLeft("SA Cooldown_" .. ply:SteamID64()) < 1) then
							ply:SetArmor(0)
							ply:EmitSound( "ambient/levels/labs/electric_explosion5.wav", 75, 100, 1, CHAN_AUTO)
							timer.Create("SA Cooldown_" .. ply:SteamID64(), MOD_SHAMP_COOLDOWN, 1, function() 
								ply:SetNWInt("SA CooldownTimer", 0)
								timer.Remove("SA Cooldown_" .. ply:SteamID64())
							end)
						end
					end)
					end
				end
			else
				print("Invalid module id: " .. modid)
			end
		end
	end
end
-- End of module logic

-- Update passive modules when they are upgraded.
net.Receive("UpdateModules", function(len, ply)
	RecieveSecurity(ply)
	local mod = net.ReadString()
	local lvl = net.ReadInt(8)
	local curlvl = ply:GetNWInt(mod)
	
	for _, module in pairs(modules) do
        if module.id == moduleID then
            local maxlvl = module.MAXLEVEL
        end
    end
	
	if lvl != (curlvl + 1) && ply:GetNWInt("plySkillPoints") < 0 && lvl <= maxlvl then
		PrintMessage(HUD_PRINTTALK, "Attempted cheating detected, " .. ply:Nick() .. "(SteamID: " .. ply:SteamID() .. ") attempted to set their modules in an impossible manner.")
	else
		ply:SetNWInt(mod, lvl)
		ply:SetNWInt("plySkillPoints", ply:GetNWInt("plySkillPoints") - 1)
		if mod == "vitality" then
			ply:SetMaxHealth(baseMaxHealth + (ply:GetNWInt("vitality") * MOD_VIT))
			ply:SetHealth(ply:Health() + MOD_VIT)
		end
		if mod == "shieldamount" then
			ply:SetMaxArmor(ply:GetMaxArmor() + (ply:GetNWInt("shieldamount") * MOD_ARM))
		end
		if mod == "movespeed" then
			ply:SetWalkSpeed(baseWalkSpeed + (baseWalkSpeed * (ply:GetNWInt("movespeed") * (MOD_SPD))))
			ply:SetRunSpeed(baseRunSpeed + (baseRunSpeed * (ply:GetNWInt("movespeed") * (MOD_SPD))))
		end
		if mod == "auxamount" then
			ply:SetNWInt("maxauxpower", (baseAUX + (ply:GetNWInt("auxamount") * (MOD_AUX))))
		end
	end
end)

local delay = 0
local antispam = 0

function RecieveSecurity(ply)
	if delay > math.Round(CurTime(), 5) then
		antispam = antispam + 1
		if antispam >= 11 then
			ply:Kick("Sent 11 nets in 0.5 seconds, possibly trying to crash the server.")
		end
	else
		antispam = 0
		delay = math.Round(CurTime() + 1, 5)
	end
end