AddCSLuaFile()

function SetAUX(ply)
	ply:SetNWInt("auxpower", 100 + (10 * ply:GetNWInt("auxamount")))
	ply:SetNWInt("maxauxpower", 100 + (10 * ply:GetNWInt("auxamount")))
end

hook.Add("Think", "AUXThink", function()
    for _, ply in ipairs(player.GetAll()) do
        local plyAUX = ply:GetNWInt("auxpower") -- Get the current AUX power
        local plyMaxAUX = ply:GetNWInt("maxauxpower")
        
        -- Drain AUX while sprinting
		if ply:IsSprinting() then
			plyAUX = math.max(0, plyAUX - 0.2) -- Ensure AUX doesn't go below 0
		end
		
		-- Regen AUX power over time
		if plyAUX < plyMaxAUX && !ply:IsSprinting() then
			plyAUX = math.min(plyMaxAUX, plyAUX + 0.05 + (0.01 * ply:GetNWInt("auxregen")))
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
		usrcmd:RemoveKey(IN_SPEED)
	elseif plyAUX < 1 then
		-- Re-enable sprinting if the AUX goes over 1
		mv:SetMaxClientSpeed(plyRunSpeed)
	end
end )