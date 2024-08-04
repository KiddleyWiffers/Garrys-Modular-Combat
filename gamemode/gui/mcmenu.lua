AddCSLuaFile()
include("gmc/gamemode/modules.lua")
include("gmc/gamemode/savedata.lua")

local Menu
local existingData
modulebinds = {}

net.Receive("SendSuitInfoToClient", function(len)
	local loadedSuit = net.ReadTable()
	existingData = loadedSuit
	
	for com,bind in pairs(existingData.suits[existingData.activeSuit].keybinds) do
		modulebinds[com] = bind
	end
end)

function MCMenu()
	if (!IsValid(Menu)) then
		Menu = vgui.Create("DFrame")
		Menu:SetSize(ScrW()/2, ScrH()/1.5)
		Menu:Center()
		Menu:SetTitle("")
		Menu:SetDraggable(false)
		Menu:ShowCloseButton(true)
		Menu:SetDeleteOnClose(false)
		Menu:MakePopup()
		Menu.Paint = function()
			surface.SetDrawColor(0, 0, 0, 200)
			surface.DrawRect(0, 0, Menu:GetWide(), Menu:GetTall())
			
			surface.SetDrawColor(230,207,40,255)
			surface.DrawRect(0, Menu:GetTall()/30, Menu:GetWide(), 1)
		end
		
		addButtons(Menu)
	else
		if(Menu:IsVisible()) then
			Menu:SetVisible(false)
			gui.EnableScreenClicker(false)
			
		else
			Menu:SetVisible(true)
			gui.EnableScreenClicker(true)
		end
	end
	Menu.OnClose = function()
		Menu:SetVisible(false)
		Menu:InvalidateLayout(true)
        gui.EnableScreenClicker(false)
    end
end
concommand.Add("gmc_gamemenu", MCMenu)

function addButtons(Menu)
	local gamePanel = Menu:Add("GPanel")
	local playerPanel = Menu:Add("PPanel")
	local modulePanel = Menu:Add("MPanel")
	gamePanel:Hide()
	playerPanel:Show()
	modulePanel:Hide()
	local playerButton = vgui.Create("DButton")
	playerButton:SetParent(Menu)
	playerButton:SetText("")
	playerButton:SetSize(Menu:GetWide()/4, Menu:GetTall()/18)
	playerButton:SetPos(Menu:GetWide()/20,Menu:GetTall()/24)
	playerButton.Paint = function()
		surface.SetDrawColor(0, 0, 0, 200)
		surface.DrawRect(0, 0, playerButton:GetWide(), playerButton:GetTall())
			
		surface.SetDrawColor(230,207,40,255)
		surface.DrawOutlinedRect(0, 0, playerButton:GetWide(), playerButton:GetTall(), 1)
		draw.SimpleText( "Character", "GMCTitleFont", playerButton:GetWide()/2, playerButton:GetTall()/2, Color( 230,207,40,255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	playerButton.DoClick = function()
		gamePanel:Hide()
		playerPanel:Show()
		modulePanel:Hide()
	end
	
	local gameButton = vgui.Create("DButton")
	gameButton:SetParent(Menu)
	gameButton:SetText("")
	gameButton:SetSize(Menu:GetWide()/4, Menu:GetTall()/18)
	gameButton:SetPos((Menu:GetWide()/1.6)-gameButton:GetWide(),Menu:GetTall()/24)
	gameButton.Paint = function()
		surface.SetDrawColor(0, 0, 0, 200)
		surface.DrawRect(0, 0, gameButton:GetWide(), gameButton:GetTall())
			
		surface.SetDrawColor(230,207,40,255)
		surface.DrawOutlinedRect(0, 0, gameButton:GetWide(), gameButton:GetTall(), 1)
		draw.SimpleText( "Game", "GMCTitleFont", gameButton:GetWide()/2, gameButton:GetTall()/2, Color( 230,207,40,255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	-- Last night you were trying to get the panels to close when a new button is pressed.
	gameButton.DoClick = function()
		gamePanel:Show()
		playerPanel:Hide()
		modulePanel:Hide()
	end
	
	local moduleButton = vgui.Create("DButton")
	moduleButton:SetParent(Menu)
	moduleButton:SetText("")
	moduleButton:SetSize(Menu:GetWide()/4, Menu:GetTall()/18)
	moduleButton:SetPos((Menu:GetWide()/1.05)-moduleButton:GetWide(),Menu:GetTall()/24)
	moduleButton.Paint = function()
		surface.SetDrawColor(0, 0, 0, 200)
		surface.DrawRect(0, 0, moduleButton:GetWide(), moduleButton:GetTall())
			
		surface.SetDrawColor(230,207,40,255)
		surface.DrawOutlinedRect(0, 0, moduleButton:GetWide(), moduleButton:GetTall(), 1)
		draw.SimpleText( "Modules", "GMCTitleFont", moduleButton:GetWide()/2, moduleButton:GetTall()/2, Color( 230,207,40,255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end
	moduleButton.DoClick = function()
		gamePanel:Hide()
		playerPanel:Hide()
		modulePanel:Show()
	end
end

-- Player Panel
PlayerPanel = {}
local pmicon = vgui.Create( "DModelPanel", Panel )

function PlayerPanel:Init()
	self:SetSize(Menu:GetWide()*0.95, Menu:GetTall() * 0.85)
	self:SetPos(24, Menu:GetTall() * 0.12)
	
	pmicon:SetParent(self)
	pmicon:SetSize(self:GetWide()/4,self:GetTall()/2)
	pmicon:SetModel( LocalPlayer():GetModel() )
	pmicon:SetCamPos(Vector(30, 0, 55))
	pmicon:SetLookAt(Vector(0,0,50))
	function pmicon.Entity:GetPlayerColor() return LocalPlayer():GetPlayerColor() end
	function pmicon:LayoutEntity( Entity ) 
		return
	end -- disables default rotation
	
	-- Create the player model dropdown
    if not playerModelDropdown then
        playerModelDropdown = vgui.Create("DComboBox", self)
        playerModelDropdown:SetPos(pmicon:GetWide() + 10, 100)
        playerModelDropdown:SetSize(self:GetWide() - pmicon:GetWide() - 20, 25)
        -- Populate the dropdown with player model options
        -- You can replace this with your actual logic to populate the dropdown
		validmodels = player_manager.AllValidModels()
		for k,v in pairs(validmodels) do
			playerModelDropdown:AddChoice(validmodels[k])
		end
        -- Set the initial value to the current player model
        playerModelDropdown:SetValue(LocalPlayer():GetModel())
		playerModelDropdown.OnSelect = function(index, value, data)
            -- Set the player's model
            LocalPlayer():SetModel(data)
            -- Update the model panel's model
            pmicon:SetModel(data)
			-- Update the gmc_model convar
			RunConsoleCommand("gmc_model", data)
        end
    end
    
    -- Create the color picker
    if not colorPicker then
        colorPicker = vgui.Create("DColorMixer", self)
        colorPicker:SetSize(pmicon:GetWide() - 6, pmicon:GetTall() - 10)
		colorPicker:SetPos(3, pmicon:GetTall() + 5)
        -- Set the default color
        colorPicker:SetColor(LocalPlayer():GetPlayerColor():ToColor())
		-- Add an event handler for color change
        colorPicker.ValueChanged = function(picker, newColor)
            -- Convert the newColor to Vector
            local playerColor = Vector(newColor.r / 255, newColor.g / 255, newColor.b / 255)
            -- Set the player color
            LocalPlayer():SetPlayerColor(playerColor)
			-- Convert color to convar format (R G B)
            local convarValue = string.format("%d %d %d", newColor.r, newColor.g, newColor.b)
            -- Set the Clientside convar "gmc_color"
            RunConsoleCommand("gmc_color", convarValue)
			function pmicon.Entity:GetPlayerColor() return LocalPlayer():GetPlayerColor() end
        end
    end
	
	if existingData then
		local curSuit = LocalPlayer():GetNWString("ActiveSuit")
		local buttonIndex = 1
		local numButtons = 5
		local buttonWidth = (self:GetWide() - pmicon:GetWide() - 20) / numButtons

		-- Create a text input for renaming the active suit
		local renameSuitText = vgui.Create("DTextEntry", self)
		renameSuitText:SetPos(pmicon:GetWide() + 10, 210)
		renameSuitText:SetSize((self:GetWide() - pmicon:GetWide() - 20) * 0.7, 25)
		renameSuitText:SetText(existingData.suits[curSuit].SuitName) -- Set the default text to the active suit's name
		renameSuitText:SetMaximumCharCount( 13 )

		local suitButtons = {}

		-- Create buttons for each suit
		for k, data in SortedPairs(existingData.suits) do
			local button = vgui.Create("DButton", self)
			button:SetPos(pmicon:GetWide() + 10 + (buttonIndex - 1) * buttonWidth, 140)
			button:SetSize(buttonWidth, 60)
			button:SetText("")
			
			button.Paint = function()
				surface.SetDrawColor(230, 207, 40, 255)
				surface.DrawOutlinedRect(0, 0, button:GetWide(), button:GetTall())
				
				draw.SimpleText(data.SuitName, "GMCSmallFont", 10, 10, Color(230,207,40,255), TEXT_ALIGN_LEFT)
				draw.SimpleText("Level: " .. data.plyLevel, "GMCSmallFont", 10, 30, Color(230,207,40,255), TEXT_ALIGN_LEFT)
			end

			button.DoClick = function()
				local suit = k
				LocalPlayer():SetNWString("ActiveSuit", suit)
				curSuit = LocalPlayer():GetNWString("ActiveSuit")
				net.Start("ChangeSuits")
					net.WriteString(suit)
				net.SendToServer()
				Menu:SetVisible(false)
				gui.EnableScreenClicker(false)
				renameSuitText:SetText(data.SuitName)
				modulebinds = {}
				for com,bind in pairs(data.keybinds) do
					modulebinds[com] = bind
				end
			end

			-- Store the reference to the button and its corresponding data
			suitButtons[k] = {
				button = button,
				data = data
			}

			buttonIndex = buttonIndex + 1
		end

		-- Create a button to rename the active suit
		local renameSuitButton = vgui.Create("DButton", self)
		renameSuitButton:SetPos(pmicon:GetWide() + 20 + renameSuitText:GetWide(), 210)
		renameSuitButton:SetSize((self:GetWide() - pmicon:GetWide() - 20) * 0.3 - 10, 25)
		renameSuitButton:SetText("Rename Suit")
		renameSuitButton.DoClick = function()
			local newName = renameSuitText:GetValue()
			
			net.Start("RenameSuit")
				net.WriteString(curSuit) -- Send the current suit's identifier
				net.WriteString(newName) -- Send the new suit name
			net.SendToServer()
			renameSuitText:SetText(existingData.suits[curSuit].SuitName)
			
			for k, suitButton in pairs(suitButtons) do
				if k == curSuit then
					local data = suitButton.data
					data.SuitName = newName
					data.plyLevel = LocalPlayer():GetNWInt("plyLevel")
					break
				end
			end
		end

		-- Create a button to reset the active suit
		local resetSuitButton = vgui.Create("DButton", self)
		resetSuitButton:SetPos(pmicon:GetWide() + 10, 245)
		resetSuitButton:SetSize(self:GetWide() - pmicon:GetWide() - 20, 30)
		resetSuitButton:SetText("Reset Suit")
		resetSuitButton.DoClick = function()
			-- Create a confirmation dialog
			local confirmResetPanel = vgui.Create("DPanel", self)
			confirmResetPanel:SetPos((self:GetWide()/4) + 10, self:GetTall()/3)
			confirmResetPanel:SetSize(self:GetWide() - pmicon:GetWide() - 20, 120)
			confirmResetPanel.Paint = function()
				draw.RoundedBox(8, 0, 0, confirmResetPanel:GetWide(), confirmResetPanel:GetTall(), Color(0, 0, 0, 200))
				draw.SimpleText("Are you sure you want to reset your active suit?", "GMCDescriptionFont", confirmResetPanel:GetWide() / 2, 20, Color(230, 207, 40, 255), TEXT_ALIGN_CENTER)
				draw.SimpleText("This action will erase all the progress you've made.", "GMCDescriptionFont", confirmResetPanel:GetWide() / 2, 40, Color(230, 207, 40, 255), TEXT_ALIGN_CENTER)
				draw.SimpleText("This action cannot be undone.", "GMCDescriptionFont", confirmResetPanel:GetWide() / 2, 60, Color(230, 207, 40, 255), TEXT_ALIGN_CENTER)
			end
				local resetButton = vgui.Create("DButton", confirmResetPanel)
			resetButton:SetPos(10, 90)
			resetButton:SetSize(confirmResetPanel:GetWide() / 2 - 15, 20)
			resetButton:SetText("Reset")
			resetButton.DoClick = function()
				net.Start("ResetSuit")
				net.SendToServer()
				confirmResetPanel:Remove()
				
				for k, suitButton in pairs(suitButtons) do
					if k == curSuit then
						local data = suitButton.data
						data.SuitName = "New Suit"
						data.plyLevel = 1
						break
					end
				end
			end
	
		local cancelButton = vgui.Create("DButton", confirmResetPanel)
			cancelButton:SetPos(confirmResetPanel:GetWide() / 2 + 5, 90)
			cancelButton:SetSize(confirmResetPanel:GetWide() / 2 - 15, 20)
			cancelButton:SetText("Cancel")
			cancelButton.DoClick = function()
				confirmResetPanel:Remove()
			end
		end
	end
end

function PlayerPanel:Paint(w, h)
	surface.SetDrawColor(230,207,40,255)
	surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall(), 1)
	
	surface.SetDrawColor(230,207,40,255)
	surface.DrawRect(0, pmicon:GetTall(), self:GetWide(), 1)
	surface.DrawRect(pmicon:GetWide(), 0, 1, self:GetTall())
	
    -- Draw the player's name, level, and experience
    draw.SimpleText("Name: " .. LocalPlayer():Nick(), "GMCDescriptionFont", pmicon:GetWide() + 10, 10, Color(230,207,40,255), TEXT_ALIGN_LEFT)
    draw.SimpleText("Level: " .. LocalPlayer():GetNWInt("plyLevel"), "GMCDescriptionFont", pmicon:GetWide() + 10, 40, Color(230,207,40,255), TEXT_ALIGN_LEFT)
    draw.SimpleText("Experience: " ..  LocalPlayer():GetNWInt("plyEXP") .. "/" .. LocalPlayer():GetNWInt("plyEXPtoLevel"), "GMCDescriptionFont", pmicon:GetWide() + 10, 70, Color(230,207,40,255), TEXT_ALIGN_LEFT)
end

vgui.Register("PPanel", PlayerPanel, "Panel")
-- End of Player Panel

-- Game Panel
GamePanel = {}
function GamePanel:Init()
    self:SetSize(Menu:GetWide()*0.95, Menu:GetTall() * 0.85)
    self:SetPos(24, Menu:GetTall() * 0.12)
	
	if existingData then
		local activesuit = existingData.suits[LocalPlayer():GetNWString("ActiveSuit")]

		-- Create a ScrollPanel for the list of active modules
		local BindScroll = vgui.Create("DScrollPanel", self)
		BindScroll:SetSize(self:GetWide()/3, self:GetTall()-20)
		BindScroll:SetPos((self:GetWide() - BindScroll:GetWide()) - 10, 10)
		
		BindScroll.Paint = function()
			surface.SetDrawColor(230,207,40,255)
			surface.DrawOutlinedRect(0, 0, BindScroll:GetWide(), BindScroll:GetTall(), 1)

			surface.SetDrawColor(0,0,0,255)
			surface.DrawRect(1, 1, BindScroll:GetWide()-2, 18)

			surface.SetDrawColor(230,207,40,255)
			surface.DrawRect(0, 20, BindScroll:GetWide(), 1)
			draw.SimpleText("Active Modules Keybindings", "GMCSmallFont", 3, 2, Color(230,207,40,255), TEXT_ALIGN_LEFT)
		end

		local labelHeight = 20 -- Height of the label
		local buttonSpacing = 0 -- Spacing between module buttons

		local yOffset = labelHeight + buttonSpacing -- Start below the label

		-- Create the "Use Skill" binder
		local UseSkillBinder = vgui.Create("DBinder", BindScroll)
		UseSkillBinder:SetSize(BindScroll:GetWide(), 40)
		UseSkillBinder:SetPos(0, yOffset)
		local usekey = activesuit.keybinds["selected"] or 34
		UseSkillBinder:SetValue(usekey)

		UseSkillBinder.Paint = function()
			if UseSkillBinder:GetValue() != 0 then
				UseSkillBinder:SetText("Use Skill = " .. input.GetKeyName(UseSkillBinder:GetValue()))
			else
				UseSkillBinder:SetText("Use Skill = None")
			end
			UseSkillBinder:SetFont("GMCDescriptionFont")
			UseSkillBinder:SetColor(Color(230,207,40,255))
			surface.SetDrawColor(230,207,40,255)
			surface.DrawOutlinedRect(0, 0, UseSkillBinder:GetWide(), UseSkillBinder:GetTall(), 1)
			surface.SetTexture( surface.GetTextureID( "vgui/gui/gmc/modules/select" ) )
			surface.DrawTexturedRect( 0, 0, 40, 40 )
		end
		
		UseSkillBinder.OnChange = function(_, key)
			modulebinds["selected"] = key
			net.Start("BindModules")
				net.WriteString("use")
				net.WriteInt(key, 9)
			net.SendToServer()
		end

		yOffset = yOffset + UseSkillBinder:GetTall() + buttonSpacing

		-- Create the "Next Skill" binder
		local NextSkillBinder = vgui.Create("DBinder", BindScroll)
		NextSkillBinder:SetSize(BindScroll:GetWide(), 40)
		NextSkillBinder:SetPos(0, yOffset)
		local nextkey = activesuit.keybinds["next"] or 13
		NextSkillBinder:SetValue(nextkey)

		NextSkillBinder.Paint = function()
			if NextSkillBinder:GetValue() != 0 then
				NextSkillBinder:SetText("Next Skill = " .. input.GetKeyName(NextSkillBinder:GetValue()))
			else
				NextSkillBinder:SetText("Next Skill = None")
			end
			NextSkillBinder:SetFont("GMCDescriptionFont")
			NextSkillBinder:SetColor(Color(230,207,40,255))
			surface.SetDrawColor(230,207,40,255)
			surface.DrawOutlinedRect(0, 0, NextSkillBinder:GetWide(), NextSkillBinder:GetTall(), 1)
			surface.SetTexture( surface.GetTextureID( "vgui/gui/gmc/modules/arrow" ) )
			surface.DrawTexturedRect( 0, 0, 40, 40 )
		end

		NextSkillBinder.OnChange = function(_, key)
			modulebinds["next"] = key
			net.Start("BindModules")
				net.WriteString("next")
				net.WriteInt(key, 9)
			net.SendToServer()
		end

		yOffset = yOffset + NextSkillBinder:GetTall() + buttonSpacing

		-- Create the "Previous Skill" binder
		local PrevSkillBinder = vgui.Create("DBinder", BindScroll)
		PrevSkillBinder:SetSize(BindScroll:GetWide(), 40)
		PrevSkillBinder:SetPos(0, yOffset)
		local prevkey = activesuit.keybinds["prev"] or 36
		PrevSkillBinder:SetValue(prevkey)

		PrevSkillBinder.Paint = function()
			if PrevSkillBinder:GetValue() != 0 then
				PrevSkillBinder:SetText("Previous Skill = " .. input.GetKeyName(PrevSkillBinder:GetValue()))
			else
				PrevSkillBinder:SetText("Previous Skill = None")
			end
			PrevSkillBinder:SetFont("GMCDescriptionFont")
			PrevSkillBinder:SetColor(Color(230,207,40,255))
			surface.SetDrawColor(230,207,40,255)
			surface.DrawOutlinedRect(0, 0, PrevSkillBinder:GetWide(), PrevSkillBinder:GetTall(), 1)
			surface.SetTexture( surface.GetTextureID( "vgui/gui/gmc/modules/arrowleft" ) )
			surface.DrawTexturedRect( 0, 0, 40, 40 )
		end

		PrevSkillBinder.OnChange = function(_, key)
			modulebinds["prev"] = PrevSkillBinder:GetValue()
			net.Start("BindModules")
				net.WriteString("prev")
				net.WriteInt(key, 9)
			net.SendToServer()
		end

		yOffset = yOffset + PrevSkillBinder:GetTall() + buttonSpacing

		-- Iterate through modules to find active ones and create binders
		for _, module in pairs(modules) do
			if module.Active then
				local ModuleBinder = vgui.Create("DBinder", BindScroll)
				ModuleBinder:SetSize(BindScroll:GetWide(), 40)
				ModuleBinder:SetPos(0, yOffset)
				
				yOffset = yOffset + ModuleBinder:GetTall() + buttonSpacing
				
				local modkey = activesuit.keybinds[module.id] or 0
				ModuleBinder:SetValue(modkey)
				
				local IsActive = false
				
				ModuleBinder.OnReleased = function()
					IsActive = true
				end
				
				ModuleBinder.Paint = function()
					if ModuleBinder:GetValue() != 0 && IsActive == false then
						ModuleBinder:SetText(module.PrintName .. " = " .. input.GetKeyName(ModuleBinder:GetValue()))
					elseif IsActive == true then
						ModuleBinder:SetText("Press a button...")
					else
						ModuleBinder:SetText(module.PrintName .. " = None")
					end
					ModuleBinder:SetFont("GMCDescriptionFont")
					ModuleBinder:SetColor(Color(230,207,40,255))
					surface.SetDrawColor(230,207,40,255)
					surface.DrawOutlinedRect(0, 0, ModuleBinder:GetWide(), ModuleBinder:GetTall(), 1)
					surface.SetTexture( surface.GetTextureID( module.Icon ) )
					surface.DrawTexturedRect( 0, 0, 40, 40 )
				end
				
				timer.Create(module.id .. "Binder", 1, 0, function()
					activesuit = existingData.suits[LocalPlayer():GetNWString("ActiveSuit")]
					modkey = activesuit.keybinds[module.id] or 0
					if modulebinds[module.id] != modkey then
						ModuleBinder:SetValue(modkey)
					end
				end)

				ModuleBinder.OnChange = function(_, key)
					activesuit = existingData.suits[LocalPlayer():GetNWString("ActiveSuit")]
					modulebinds[module.id] = key
					activesuit.keybinds[module.id] = key
					net.Start("BindModules")
						net.WriteString(module.id)
						net.WriteInt(key, 9)
					net.SendToServer()
					IsActive = false
				end
			end
		end
	end
end

function GamePanel:Paint(w, h)
	surface.SetDrawColor(230,207,40,255)
	surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall(), 1)
end

vgui.Register("GPanel", GamePanel, "Panel")
-- End of Game Panel

-- Define the ModulePanel class
ModulePanel = {}

function ModulePanel:Init()
	self:SetSize(Menu:GetWide() * 0.95, Menu:GetTall() * 0.85)
    self:SetPos(24, Menu:GetTall() * 0.12)

    -- Create the category list
    self.categoryList = vgui.Create("DCategoryList", self)
    self.categoryList:SetPos(0, 0)
    self.categoryList:SetSize(self:GetWide() * 0.25, self:GetTall())
	self.categoryList.Paint = function()
		surface.SetDrawColor( 230,207,40,255 )
		surface.DrawOutlinedRect( 0, 0, self.categoryList:GetWide(), self.categoryList:GetTall(), 1 )
	end

    -- Create the description panel
    self.descriptionPanel = vgui.Create("DPanel", self)
    self.descriptionPanel:SetPos(self:GetWide() * 0.25, 0)
    self.descriptionPanel:SetSize(self:GetWide() * 0.75, self:GetTall())
	self.descriptionPanel.Paint = function()
		surface.SetDrawColor( 230,207,40,255 )
		surface.DrawOutlinedRect( 0, 0, self.descriptionPanel:GetWide(), self.descriptionPanel:GetTall(), 1 )
	end

    -- Store created buttons for each category
    self.categoryButtons = {}

    -- Iterate through the modules table and add modules to categories
	for moduleName, moduleData in pairs(modules) do
		local category = moduleData.Category

		-- Check if the category exists, if not, create it
		if not self.categoryButtons[category] then
			local cat = self.categoryList:Add(category)
			cat.Paint = function()
				surface.SetDrawColor( 230,207,40,255 )
				surface.DrawOutlinedRect( 0, 0, cat:GetWide(), cat:GetTall(), 1 )
			end
			self.categoryButtons[category] = cat
		end

		-- Create a button for the module
		local modLabel = moduleData.PrintName -- Use module's PrintName as the label

		-- Add the module button label to the corresponding category
		local mod = self.categoryButtons[category]:Add(modLabel)  -- Add the label to the category
		mod:SetTextColor(Color(230,207,40,255))
		mod.DoClick = function()
			self:UpdateDescriptionPanel(moduleData)
		end
	end
end

-- Function to update the description panel with module information
function ModulePanel:UpdateDescriptionPanel(moduleData)
	self.descriptionPanel:Clear()
	
	local icon = vgui.Create("DImage", self.descriptionPanel)
    icon:SetPos(10, 10)
    icon:SetSize(self.descriptionPanel:GetWide()/6.84, self.descriptionPanel:GetTall()/6.12)
    icon:SetImage(moduleData.Icon)
	
	local printNameLabel = vgui.Create("DLabel", self.descriptionPanel)
	printNameLabel:SetPos(icon:GetWide() + 20, icon:GetTall()/2)
	printNameLabel:SetText(moduleData.PrintName)
	printNameLabel:SetFont("GMCTitleFont")
	printNameLabel:SizeToContents()
	printNameLabel:SetAutoStretchVertical( true )

	local descriptionLabel = vgui.Create("DLabel", self.descriptionPanel)
	descriptionLabel:SetPos(10, icon:GetTall()+10)
	descriptionLabel:SetAutoStretchVertical( true )
	descriptionLabel:SetWide(self.descriptionPanel:GetWide() - 10)
	descriptionLabel:SetText(moduleData.Description)
	descriptionLabel:SetFont("GMCDescriptionFont")
	descriptionLabel:SetWrap(true)
	
	timer.Simple(0.0001, function() self:CreateStatsTable(moduleData, descriptionLabel) end)
	
    self.descriptionPanel.Paint = function()
        local w, h = self.descriptionPanel:GetWide(), self.descriptionPanel:GetTall()
        surface.SetDrawColor(0, 0, 0, 0)
        surface.DrawRect(0, 0, w, h)
		
        surface.SetMaterial(Material(moduleData.Icon))
        surface.DrawTexturedRect(100, 100, 80, 80)
		
		surface.SetTextColor(230,207,40,255)
		
		draw.SimpleText( "Module Points: " .. LocalPlayer():GetNWInt("plySkillPoints"), "GMCSmallFont", self.descriptionPanel:GetWide() - 140, 10, Color( 230,207,40,255 ), TEXT_ALIGN_LEFT )
    end
end

function ModulePanel:CreateStatsTable(moduleData, descriptionLabel)
    local statsTable = vgui.Create("DPanel", self.descriptionPanel)
    statsTable:SetPos(10, descriptionLabel:GetY() + descriptionLabel:GetTall() + 10)
    statsTable:SetSize(self.descriptionPanel:GetWide() - 20, self.descriptionPanel:GetTall() / 3)
    statsTable.Paint = function()
        
    end

    local maxLevel = moduleData.MAXLEVEL or 1
    local baseValue = moduleData.BASE or 0
	
	local playerLevel = LocalPlayer():GetNWInt(moduleData.id)

    local grid = vgui.Create("DGrid", statsTable)
    grid:SetPos(0, 0)
    grid:SetCols(maxLevel + 1)
    grid:SetColWide(60)
    grid:SetRowHeight(30)
	grid.Paint = function(self, w, h)
        local numRows = math.ceil(#self:GetItems() / self:GetCols())
        for i = 1, self:GetCols() do
            for j = 1, numRows do
                local x = (i - 1) * self.m_iColWide
                local y = (j - 1) * self.m_iRowHeight
                surface.SetDrawColor(230,207,40,255)
                surface.DrawOutlinedRect(x, y, self.m_iColWide, self.m_iRowHeight)
				
				-- Highlight the cell if it corresponds to the player's level
                if j == 1 and i == playerLevel + 1 and playerLevel > 0 then
                    draw.RoundedBox(0, x, y, self.m_iColWide, self.m_iRowHeight*numRows, Color(230,207,40,255))
                end
            end
        end
    end

    -- Add "Level" column
    local headerLabel = vgui.Create("DLabel")
    headerLabel:SetSize(60, 30)
    headerLabel:SetText("Level")
	headerLabel:SetContentAlignment( 5 )
    grid:AddItem(headerLabel)

    for level = 1, maxLevel do
        local label = vgui.Create("DLabel")
        label:SetSize(60, 30)
        label:SetText(tostring(level))
		label:SetContentAlignment( 5 )
		if level == playerLevel then
			label:SetTextColor(Color(0, 0, 0, 255))
        end
        grid:AddItem(label)
    end

    for _, statPair in ipairs(moduleData.STAT) do
        local statValue, statName = statPair[1], statPair[2]

        -- Add stat name to the left of the grid
        local statNameLabel = vgui.Create("DLabel")
        statNameLabel:SetSize(60, 30) -- Adjust the width as needed
        statNameLabel:SetText(statName)
		statNameLabel:SetContentAlignment( 5 )
        grid:AddItem(statNameLabel)

        for level = 1, maxLevel do
            local statValueLabel = vgui.Create("DLabel")
            statValueLabel:SetSize(60, 30)
            if !moduleData.INVERTED then
				statValueLabel:SetText(tostring((statValue * level) + baseValue))
			else
				statValueLabel:SetText(tostring(baseValue - (statValue * level)))
			end
			statValueLabel:SetContentAlignment( 5 )
            if level == playerLevel then
                statValueLabel:SetTextColor(Color(0, 0, 0, 255))
            end
            grid:AddItem(statValueLabel)
        end
    end
	
	-- Create a button to purchase the module
    local purchaseButton = vgui.Create("DButton", self.descriptionPanel)
    purchaseButton:SetSize(self.descriptionPanel:GetWide()/2, 40)
	purchaseButton:SetPos(self.descriptionPanel:GetWide()/2 - purchaseButton:GetWide()/2, self.descriptionPanel:GetTall() - 60)
    purchaseButton:SetText("Purchase")
    purchaseButton.DoClick = function()
        -- Check if the player has enough skill points and is below the max level
        local plySkillPoints = LocalPlayer():GetNWInt("plySkillPoints")
		local moduleValue = LocalPlayer():GetNWInt(moduleData.id, 0)
        if plySkillPoints >= 1 && moduleValue < moduleData.MAXLEVEL then
			playerLevel = playerLevel+1
            net.Start("UpdateModules")
				net.WriteString(moduleData.id)
				net.WriteInt(tonumber(moduleValue) + 1, 8)
			net.SendToServer()
		elseif plySkillPoints >= 1 && moduleValue >= moduleData.MAXLEVEL then
			chat.AddText(Color(255, 0, 0), "This module is at max level!")
        else
            -- Display a message if the player doesn't have enough skill points
            chat.AddText(Color(255, 0, 0), "Not enough skill points to purchase this module!")
        end
    end
end

function ModulePanel:Paint(w, h)
    surface.SetDrawColor(230, 207, 40, 255)
    surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall(), 1)
end

vgui.Register("MPanel", ModulePanel, "Panel")
-- End of Module Panel