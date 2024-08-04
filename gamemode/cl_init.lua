AddCSLuaFile("gui/mchud.lua")
AddCSLuaFile("gui/mcmenu.lua")
AddCSLuaFile("commands.lua")
AddCSLuaFile("gui/npccreator.lua")

include("gmcscoreboard.lua")
include( "gui/mchud.lua" )
include("gui/mcmenu.lua")
include("gui/npccreator.lua")
include( "commands.lua" )

surface.CreateFont( "GMCTitleFont", {font = "Verdana", extended = false, size = 40, weight = 500, blursize = 0, antialias = true, shadow = true, outline = false,} )
surface.CreateFont( "GMCDescriptionFont", {font = "Verdana", extended = false, size = 25, weight = 500, blursize = 0, antialias = true, shadow = true, outline = false,} )
surface.CreateFont( "GMCSmallFont", {font = "Verdana", extended = false, size = 16, weight = 500, blursize = 0, antialias = false, shadow = true, outline = false,} )
surface.CreateFont( "GMCScoreboardFont", {font = "Verdana", extended = false, size = 18, weight = 500, blursize = 0, antialias = false, shadow = true, outline = false,} )

function GM:HUDDrawTargetID()
	local tr = LocalPlayer():GetEyeTrace()
    local target = tr.Entity
	
	if IsValid(target) && IsEntity( target ) then
        local text = ""
        
        if target:IsPlayer() then
            local level = target:GetNWInt("plyLevel")
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
				draw.DrawText(text, "GMCSmallFont", (ScrW() / 2), (ScrH() / 2) + 50, target:GetPlayerColor():ToColor(), TEXT_ALIGN_CENTER)
			end
		else
			local lines = string.Explode("\n", text)
			for i, line in ipairs(lines) do
				draw.DrawText(text, "GMCSmallFont", ScrW() / 2, ScrH() / 2 + 50, Color(255,255,60), TEXT_ALIGN_CENTER)
			end
		end
    end
end

local delay = CurTime()

function GM:Think()
	for com,bind in pairs(modulebinds) do
		if delay < CurTime() then
			if input.IsKeyDown( bind ) then
				LocalPlayer():ConCommand("gmc_cast " .. com)
				delay = CurTime() + 0.5
			end
		end
	end
end