AddCSLuaFile("gui/mchud.lua")
AddCSLuaFile("gui/mcmenu.lua")
AddCSLuaFile("commands.lua")
AddCSLuaFile("gui/npccreator.lua")

include("gmcscoreboard.lua")
include( "gui/mchud.lua" )
include("gui/mcmenu.lua")
include("gui/npccreator.lua")
include( "commands.lua" )

function GM:HUDDrawTargetID()
	local tr = LocalPlayer():GetEyeTrace()
    local target = tr.Entity
	
	if IsValid(target) && IsEntity( target ) then
        local text = ""
        
        if target:IsPlayer() then
            local level = target:GetNWInt("plylevel")
            text = target:Nick() .. "\nLevel: " .. level
        elseif target:IsNPC() then
			local name = target:GetNWString("NPCName")
			local level = target:GetNWInt("NPCLevel")
            text = name .. "\n Level " .. level
        end
        
        -- Draw the additional information
		if target:IsPlayer() then
			local lines = string.Explode("\n", text)
			for i, line in ipairs(lines) do
				draw.DrawText(text, "HudDefault", ScrW() / 2, ScrH() / 2, target:GetPlayerColor():ToColor(), TEXT_ALIGN_CENTER)
			end
		else
			local lines = string.Explode("\n", text)
			for i, line in ipairs(lines) do
				draw.DrawText(text, "HudDefault", ScrW() / 2, ScrH() / 2, Color(255,255,60), TEXT_ALIGN_CENTER)
			end
		end
    end
end