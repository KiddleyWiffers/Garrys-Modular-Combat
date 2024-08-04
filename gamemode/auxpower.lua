AddCSLuaFile()
include("modules.lua")

function SetAUX(ply)
	ply:SetNWInt("auxpower", GetConVar( "gmc_aux_base" ):GetInt() + (MOD_AUX * ply:GetNWInt("auxamount")))
	ply:SetNWInt("maxauxpower", GetConVar( "gmc_aux_base" ):GetInt() + (MOD_AUX * ply:GetNWInt("auxamount")))
end

timer.Create("AUXLogic", 0.1, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        local plyAUX = ply:GetNWInt("auxpower") -- Get the current AUX power
        local plyMaxAUX = ply:GetNWInt("maxauxpower")
        
        -- Drain AUX while sprinting
		if ply:IsSprinting() then
			plyAUX = math.max(0, plyAUX - 0.2) -- Ensure AUX doesn't go below 0
		end
		
		-- Regen AUX power over time
		if plyAUX < plyMaxAUX && !ply:IsSprinting() then
			plyAUX = math.min(plyMaxAUX, plyAUX + 0.1 + (MOD_AUXR * ply:GetNWInt("auxregen")))
		end
		
		-- Drain AUX while using Jetpack
		if ply:GetNWBool("jetpackActive") then
			local jetpackdrain = (MOD_JETPACK - ply:GetNWInt("jetpack"))
			plyAUX = math.max(0, plyAUX - (jetpackdrain*0.1))
		end
		
		ply:SetNWInt("auxpower", plyAUX)
    end
end)

hook.Add( "SetupMove", "SprintLimit", function( ply, mv, usrcmd )
	local plyWalkSpeed = ply:GetWalkSpeed()
	local plyRunSpeed = ply:GetRunSpeed()
	
	local plyAUX = ply:GetNWInt("auxpower") -- Get the current AUX power
	
	-- Disable Sprinting if AUX power goes below or equal to 0
	if plyAUX <= 0 then
		mv:SetMaxClientSpeed(plyWalkSpeed)
		usrcmd:RemoveKey(131072)
		if ply:GetNWBool("jetpackActive") then
			ply:StopSound("gmc/jetpack.wav")
			ply:EmitSound("weapons/flame_thrower_bb_end.wav", 100, 100, 0.2)
			ply:SetNWBool("jetpackActive", false)
		end
	elseif plyAUX > 0 then
		-- Re-enable sprinting if the AUX goes over 1
		mv:SetMaxClientSpeed(plyRunSpeed)
		local jpa = ply:GetNWBool("jetpackActive")
		
		-- Jetpack Functionality
		
		if ply:GetNWInt("jetpack") > 0 then
			if ply:KeyPressed(IN_JUMP) && !ply:OnGround() && !jpa then
				ply:SetNWBool("jetpackActive", true)
			end
			
			if usrcmd:KeyDown(IN_JUMP) && !ply:OnGround() && jpa then
				ply:StartLoopingSound("gmc/jetpack.wav")
				local jetpackdrain = (MOD_JETPACK - ply:GetNWInt("jetpack"))
				
				-- Apply the jetpack force over time
				local newVelocity = mv:GetVelocity() + Vector(0,0,15)

				-- Cap the upward velocity to a maximum value
				local maxUpwardVelocity = 250
				if newVelocity.z > maxUpwardVelocity then
					newVelocity.z = maxUpwardVelocity
				end
				
				if plyAUX > jetpackdrain then
					mv:SetVelocity(newVelocity)
				end
			elseif (!usrcmd:KeyDown(IN_JUMP) && jpa) || (ply:OnGround() && jpa) then
				for _, p in ipairs(player.GetAll()) do
					ply:StopSound("gmc/jetpack.wav")
				end
				ply:EmitSound("weapons/flame_thrower_bb_end.wav")
				ply:SetNWBool("jetpackActive", false)
			end
		end
	end
end )