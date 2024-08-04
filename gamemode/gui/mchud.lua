AddCSLuaFile()
include("gmc/gamemode/shared.lua")
include("gmc/gamemode/modules.lua")


function draw.Circle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

function HUD()
	local client = LocalPlayer()
	
	if !client:Alive() then return end
	local pteam = client:Team()
	
	draw.RoundedBox( 5, ScrW()/192, ScrH()/108, ScrW()/6.4, ScrH()/27, Color(0,0,0,80))
	draw.RoundedBox( 5, ScrW()/192, ScrH()/108, (ScrW()/6.4/(client:GetNWInt("plyEXPtoLevel")/client:GetNWInt("plyEXP"))), ScrH()/27, Color(230,207,40,255))
	draw.SimpleTextOutlined( "Level: " .. client:GetNWInt("plyLevel"), "HudSelectionText", ScrW()/132, ScrH()/51.4, Color(230,207,40,255), nil, nil, 1, Color(0,0,0,200))
	draw.SimpleTextOutlined( "Exp: " .. client:GetNWInt("plyEXP") .. "/" .. client:GetNWInt("plyEXPtoLevel"), "HudSelectionText", ScrW()/19.2, ScrH()/51.4, Color(230,207,40,200), nil, nil, 1, Color(0,0,0,255))
	
	draw.RoundedBox( 4, ScrW()/56, ScrH()/1.025, (ScrW()/8.3), 20, Color(0,0,0,80))
	if client:GetNWInt("auxpower") >= client:GetNWInt("maxauxpower") * 0.4 then
		draw.RoundedBox( 4, ScrW()/56, ScrH()/1.025, ((ScrW()/8.3)/(client:GetNWInt("maxauxpower")/client:GetNWInt("auxpower"))), 20, Color(230,207,40,200))
	end
	if client:GetNWInt("auxpower") < client:GetNWInt("maxauxpower") * 0.4 then
		draw.RoundedBox( 4, ScrW()/56, ScrH()/1.025, ((ScrW()/8.3)/(client:GetNWInt("maxauxpower")/client:GetNWInt("auxpower"))), 20, Color(230,0,0,150))
	end
	draw.SimpleTextOutlined( "AUX: " .. math.Round(client:GetNWInt("auxpower")), "HudSelectionText", ScrW()/17.2, ScrH()/1.023, Color(230,207,40,255), nil, nil, 1, Color(0,0,0,200))
	
	if team != TEAM_FFA && team != TEAM_COOP then
		surface.SetDrawColor(client:GetPlayerColor():ToColor())
		draw.NoTexture()
		
		local TC = team.GetColor(pteam)
		local textx = ScrW()/35
		local texty = ScrH()/1.08
		if pteam == TEAM_RED then
			draw.SimpleText( "RED", "HudSelectionText", textx, texty, TC, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		elseif pteam == TEAM_BLUE then
			draw.SimpleText( "BLUE", "HudSelectionText", textx, texty, TC, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		elseif pteam == TEAM_GREEN then
			draw.SimpleText( "GREEN", "HudSelectionText", textx, texty, TC, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		elseif pteam == TEAM_PURPLE then
			draw.SimpleText( "PURPLE", "HudSelectionText", textx, texty, TC, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
		end
	end
	
	-- Max times of each status, otherwise the timer doesn't work.
	local MAX_TIMES = {
		10,
		client:GetNWInt("shieldamp"),
		30
	}
	
	for k,status in pairs(statuses) do
		local plystat = client:GetNWInt(status)
		local timeRemaining = client:GetNWInt(status .. "Timer")
		if (timeRemaining > 0 && timeRemaining != nil) && k <= 5 then
			local x = ScrW() - 120
			local y = k * 35
			local text = status .. ": " .. math.Round(timeRemaining)
			draw.RoundedBox(4, x, y, 110, 20, Color(0,0,0,200))
			draw.RoundedBox(4, x, y, 110 * (timeRemaining/MAX_TIMES[k]), 20, Color(230,207,40,255))
			surface.SetDrawColor(0, 0, 0, 200)
			draw.NoTexture()
			draw.Circle( x-14, y+10, 15, 20 )
			draw.SimpleText(plystat, "HudSelectionText", x-19, y+1, Color(230,207,40), TEXT_ALIGN_LEFT)
			draw.SimpleTextOutlined( text, "HudSelectionText", x+1, y+1, Color(230,207,40,255), nil, nil, 1, Color(0,0,0,200))
		end
	end
end
hook.Add("HUDPaint", "MCHUD", HUD)