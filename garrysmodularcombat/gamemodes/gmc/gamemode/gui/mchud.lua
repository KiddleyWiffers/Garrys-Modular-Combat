AddCSLuaFile()

function HUD()
	local client = LocalPlayer()
	
	if !client:Alive() then return end
	
	draw.RoundedBox( 5, ScrW()/192, ScrH()/108, ScrW()/6.4, ScrH()/27, Color(0,0,0,80))
	draw.RoundedBox( 5, ScrW()/192, ScrH()/108, (ScrW()/6.4/(client:GetNWInt("plyEXPtoLevel")/client:GetNWInt("plyEXP"))), ScrH()/27, Color(230,207,40,255))
	draw.SimpleTextOutlined( "Level: " .. client:GetNWInt("plylevel"), "HudSelectionText", ScrW()/132, ScrH()/51.4, Color(230,207,40,255), nil, nil, 1, Color(0,0,0,200))
	draw.SimpleTextOutlined( "Exp: " .. client:GetNWInt("plyEXP") .. "/" .. client:GetNWInt("plyEXPtoLevel"), "HudSelectionText", ScrW()/19.2, ScrH()/51.4, Color(230,207,40,200), nil, nil, 1, Color(0,0,0,255))
	
	draw.RoundedBox( 4, ScrW()/56, ScrH()/1.025, (ScrW()/8.3), 20, Color(0,0,0,80))
	draw.RoundedBox( 4, ScrW()/56, ScrH()/1.025, ((ScrW()/8.3)/(client:GetNWInt("maxauxpower")/client:GetNWInt("auxpower"))), 20, Color(230,207,40,255))
	draw.SimpleTextOutlined( "AUX: " .. math.Round(client:GetNWInt("auxpower")), "HudSelectionText", ScrW()/17.2, ScrH()/1.023, Color(230,207,40,255), nil, nil, 1, Color(0,0,0,200))
end
hook.Add("HUDPaint", "MCHUD", HUD)