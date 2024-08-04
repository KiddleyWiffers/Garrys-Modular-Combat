AddCSLuaFile()

include("commands.lua")

local Scoreboard = nil
local PlayerList = nil

function GM:ScoreboardShow()
	if !IsValid(Scoreboard) then
		Scoreboard = vgui.Create("DFrame")
		Scoreboard:SetSize(ScrW()/1.5, ScrH()/1.25) --1280 x 864 on 1920 x 1080 resolution
		Scoreboard:Center()
		Scoreboard:SetTitle("Garry's Modular Combat - Version 0.8")
		Scoreboard:SetDraggable(false)
		Scoreboard:ShowCloseButton(false)
		Scoreboard.Paint = function()
			local ply = LocalPlayer()
			draw.RoundedBox(20, 0, 0, Scoreboard:GetWide(), Scoreboard:GetTall(), Color(0,0,0,230))
			surface.SetDrawColor(230,207,40,255)
			surface.DrawOutlinedRect(0, Scoreboard:GetTall()/10, Scoreboard:GetWide(), Scoreboard:GetTall()/25, 2)
			surface.DrawRect( Scoreboard:GetWide()/3.2, Scoreboard:GetTall()/10, 1, Scoreboard:GetTall()/25 )
			draw.SimpleText( "Player", "GMCScoreboardFont", Scoreboard:GetWide()/6.4, Scoreboard:GetTall()/8.5, Color( 230,207,40,255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			surface.DrawRect( Scoreboard:GetWide()/2.33, Scoreboard:GetTall()/10, 1, Scoreboard:GetTall()/25 )
			draw.SimpleText( "Suit Name", "GMCScoreboardFont", Scoreboard:GetWide()/2.69, Scoreboard:GetTall()/8.5, Color( 230,207,40,255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			surface.DrawRect( Scoreboard:GetWide()/1.96, Scoreboard:GetTall()/10, 1, Scoreboard:GetTall()/25 )
			draw.SimpleText( "Kills", "GMCScoreboardFont", Scoreboard:GetWide()/2.13, Scoreboard:GetTall()/8.5, Color( 230,207,40,255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			surface.DrawRect( Scoreboard:GetWide()/1.75, Scoreboard:GetTall()/10, 1, Scoreboard:GetTall()/25 )
			draw.SimpleText( "NPC Kills", "GMCScoreboardFont", Scoreboard:GetWide()/1.85, Scoreboard:GetTall()/8.5, Color( 230,207,40,255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			surface.DrawRect( Scoreboard:GetWide()/1.6, Scoreboard:GetTall()/10, 1, Scoreboard:GetTall()/25 )
			draw.SimpleText( "Deaths", "GMCScoreboardFont", Scoreboard:GetWide()/1.67, Scoreboard:GetTall()/8.5, Color( 230,207,40,255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			surface.DrawRect( Scoreboard:GetWide()/1.45, Scoreboard:GetTall()/10, 1, Scoreboard:GetTall()/25 )
			draw.SimpleText( "Level", "GMCScoreboardFont", Scoreboard:GetWide()/1.52, Scoreboard:GetTall()/8.5, Color( 230,207,40,255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			surface.DrawRect( Scoreboard:GetWide()/1.3, Scoreboard:GetTall()/10, 1, Scoreboard:GetTall()/25 )
			draw.SimpleText( "Ping", "GMCScoreboardFont", Scoreboard:GetWide()/1.38, Scoreboard:GetTall()/8.5, Color( 230,207,40,255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( "EXP", "GMCScoreboardFont", Scoreboard:GetWide()/1.12, Scoreboard:GetTall()/8.5, Color( 230,207,40,255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end
		Scoreboard.ServerName = vgui.Create( "DLabel", Scoreboard )
		Scoreboard.ServerName:SetPos( Scoreboard:GetWide()/80.2, Scoreboard:GetTall()/25.28 )
		Scoreboard.ServerName:SetText(GetConVar("hostname"):GetString())
		Scoreboard.ServerName:SetFont("GMCTitleFont")
		Scoreboard.ServerName:SetColor(Color(230,207,40,255))
		Scoreboard.ServerName:SizeToContents()
		
		Scoreboard.Mapname = vgui.Create( "DLabel", Scoreboard )
		Scoreboard.Mapname:SetText("Current Map: " .. game.GetMap())
		Scoreboard.Mapname:SetFont("GMCScoreboardFont")
		Scoreboard.Mapname:SetColor(Color(230,207,40,255))
		Scoreboard.Mapname:SizeToContents()
		Scoreboard.Mapname:SetPos( Scoreboard:GetWide()-Scoreboard.Mapname:GetWide() - 5, Scoreboard:GetTall()/14.4 )
		
		Scoreboard.Gamemode = vgui.Create( "DLabel", Scoreboard )
		Scoreboard.Gamemode:SetText("Current Gamemode: " .. GAMEMODE_PRINTNAMES[GetConVar("gmc_gamemode"):GetInt()])
		Scoreboard.Gamemode:SetFont("GMCScoreboardFont")
		Scoreboard.Gamemode:SetColor(Color(230,207,40,255))
		Scoreboard.Gamemode:SizeToContents()
		Scoreboard.Gamemode:SetPos( Scoreboard:GetWide()-Scoreboard.Gamemode:GetWide() - 5, Scoreboard:GetTall()/7.2 )
		
		local PlayerScrollPanel = vgui.Create("DScrollPanel", Scoreboard)
		PlayerScrollPanel:SetSize(Scoreboard:GetWide(), Scoreboard:GetTall()/1.16)
		PlayerScrollPanel:SetPos(0,Scoreboard:GetTall()/7.14)
		
		PlayerList = vgui.Create("DListLayout", PlayerScrollPanel)
		PlayerList:SetSize(PlayerScrollPanel:GetWide(), PlayerScrollPanel:GetTall())
		PlayerList:SetPos(0,0)
	end
	
	if IsValid(Scoreboard) then
		Scoreboard.Gamemode:SetText("Current Gamemode: " .. GAMEMODE_PRINTNAMES[GetConVar("gmc_gamemode"):GetInt()])
		Scoreboard.Gamemode:SizeToContents()
		Scoreboard.Gamemode:SetPos( Scoreboard:GetWide()-Scoreboard.Gamemode:GetWide() - 5, 30 )
		PlayerList:Clear()
		for k,v in pairs(player.GetAll()) do
			local PlayerPanel = vgui.Create("DPanel", PlayerList)
			PlayerPanel:SetSize(PlayerList:GetWide(), 50)
			PlayerPanel:SetPos(0,0)
			PlayerPanel.Paint = function()
				draw.RoundedBox(0, 0, 49, PlayerPanel:GetWide(), 1, Color(230,207,40,255))
				surface.SetDrawColor(230,207,40,255)
				surface.DrawRect( Scoreboard:GetWide()/3.2, 0, 1, PlayerPanel:GetTall() )
				draw.SimpleText( v:GetName(), "GMCScoreboardFont", Scoreboard:GetWide()/6, 25, Color( 230,207,40,255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				surface.DrawRect( Scoreboard:GetWide()/2.33, 0, 1, PlayerPanel:GetTall() )
				draw.SimpleText( v:GetNWString("ActiveSuitName"), "GMCScoreboardFont", Scoreboard:GetWide()/2.69, 25, Color( 230,207,40,255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				surface.DrawRect( Scoreboard:GetWide()/1.96, 0, 1, PlayerPanel:GetTall() )
				draw.SimpleText( v:Frags(), "GMCScoreboardFont", Scoreboard:GetWide()/2.13, 25, Color( 230,207,40,255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				surface.DrawRect( Scoreboard:GetWide()/1.75, 0, 1, PlayerPanel:GetTall() )
				draw.SimpleText( v:GetNWInt("plyNPCKills"), "GMCScoreboardFont", Scoreboard:GetWide()/1.85, 25, Color( 230,207,40,255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				surface.DrawRect( Scoreboard:GetWide()/1.6, 0, 1, PlayerPanel:GetTall() )
				draw.SimpleText( v:Deaths(), "GMCScoreboardFont", Scoreboard:GetWide()/1.67, 25, Color( 230,207,40,255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				surface.DrawRect( Scoreboard:GetWide()/1.45, 0, 1, PlayerPanel:GetTall() )
				draw.SimpleText( v:GetNWInt("plyLevel"), "GMCScoreboardFont", Scoreboard:GetWide()/1.52, 25, Color( 230,207,40,255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				surface.DrawRect( Scoreboard:GetWide()/1.3, 0, 1, PlayerPanel:GetTall() )
				draw.SimpleText( v:Ping(), "GMCScoreboardFont", Scoreboard:GetWide()/1.38, 25, Color( 230,207,40,255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				draw.SimpleText( v:GetNWInt("plyEXP") .. "/" .. v:GetNWInt("plyEXPtoLevel"), "GMCScoreboardFont", Scoreboard:GetWide()/1.12, 25, Color( 230,207,40,255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end
			local Avatar = vgui.Create( "AvatarImage", PlayerPanel )
			Avatar:SetSize( 47, 47 )
			Avatar:SetPos( 2, 1 )
			Avatar:SetPlayer( v, 64 )
		end
	
		Scoreboard:Show()
		Scoreboard:MakePopup()
	end
end

function GM:ScoreboardHide()
	if IsValid(Scoreboard) then
		Scoreboard:Hide()
	end
end