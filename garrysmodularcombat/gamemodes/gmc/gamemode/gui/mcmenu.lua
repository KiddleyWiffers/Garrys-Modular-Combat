AddCSLuaFile()

local Menu

function MCMenu()
	if (!IsValid(Menu)) then
		Menu = vgui.Create("DFrame")
		Menu:SetSize(ScrW()/2, ScrH()/1.5)
		Menu:Center()
		Menu:SetTitle("")
		Menu:SetDraggable(false)
		Menu:ShowCloseButton(false)
		Menu:SetDeleteOnClose(false)
		Menu.Paint = function()
			surface.SetDrawColor(0, 0, 0, 200)
			surface.DrawRect(0, 0, Menu:GetWide(), Menu:GetTall())
			
			surface.SetDrawColor(230,207,40,255)
			surface.DrawRect(0, Menu:GetTall()/30, Menu:GetWide(), 1)
		end
		addButtons(Menu)
		gui.EnableScreenClicker(true)
	else
		if(Menu:IsVisible()) then
			Menu:SetVisible(false)
			gui.EnableScreenClicker(false)
		else
			Menu:SetVisible(true)
			gui.EnableScreenClicker(true)
		end
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
		draw.SimpleText( "Character", "DermaLarge", playerButton:GetWide()/2, playerButton:GetTall()/2, Color( 230,207,40,255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
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
		draw.SimpleText( "Game", "DermaLarge", gameButton:GetWide()/2, gameButton:GetTall()/2, Color( 230,207,40,255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
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
		draw.SimpleText( "Modules", "DermaLarge", moduleButton:GetWide()/2, moduleButton:GetTall()/2, Color( 230,207,40,255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
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
end

function PlayerPanel:Paint(w, h)
	surface.SetDrawColor(230,207,40,255)
	surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall(), 1)
	
	pmicon:SetParent(self)
	pmicon:SetSize(w/4,h/2)
	pmicon:SetModel( LocalPlayer():GetModel() )
	pmicon:SetCamPos(Vector(30, 0, 55))
	pmicon:SetLookAt(Vector(0,0,50))
	function pmicon.Entity:GetPlayerColor() return LocalPlayer():GetPlayerColor() end
	function pmicon:LayoutEntity( Entity ) 
		return
	end -- disables default rotation
	
	surface.SetDrawColor(230,207,40,255)
	surface.DrawRect(0, pmicon:GetTall(), self:GetWide(), 1)
	surface.DrawRect(pmicon:GetWide(), 0, 1, self:GetTall())
	
    -- Draw the player's name, level, and experience
    draw.SimpleText("Name: " .. LocalPlayer():Nick(), "DermaLarge", pmicon:GetWide() + 10, 10, Color(230,207,40,255), TEXT_ALIGN_LEFT)
    draw.SimpleText("Level: " .. LocalPlayer():GetNWInt("plylevel"), "DermaLarge", pmicon:GetWide() + 10, 40, Color(230,207,40,255), TEXT_ALIGN_LEFT)
    draw.SimpleText("Experience: " ..  LocalPlayer():GetNWInt("plyEXP") .. "/" .. LocalPlayer():GetNWInt("plyEXPtoLevel"), "DermaLarge", pmicon:GetWide() + 10, 70, Color(230,207,40,255), TEXT_ALIGN_LEFT)
	
	-- Create the player model dropdown
    if not playerModelDropdown then
        playerModelDropdown = vgui.Create("DComboBox", self)
        playerModelDropdown:SetPos(pmicon:GetWide() + 10, 120)
        playerModelDropdown:SetSize(w - pmicon:GetWide() - 20, 25)
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
end

vgui.Register("PPanel", PlayerPanel, "Panel")
-- End of Player Panel

-- Game Panel
GamePanel = {}

function GamePanel:Init()
	self:SetSize(Menu:GetWide()*0.95, Menu:GetTall() * 0.85)
	self:SetPos(24, Menu:GetTall() * 0.12)
end

function GamePanel:Paint(w, h)
	surface.SetDrawColor(230,207,40,255)
	surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall(), 1)
end

vgui.Register("GPanel", GamePanel, "Panel")
-- End of Game Panel

-- Module Panel
ModulePanel = {}

function ModulePanel:Init()
    self:SetSize(Menu:GetWide() * 0.95, Menu:GetTall() * 0.85)
    self:SetPos(24, Menu:GetTall() * 0.12)

    -- Create the category list
    self.categoryList = vgui.Create("DCategoryList", self)
    self.categoryList:SetPos(0, 0)
    self.categoryList:SetSize(self:GetWide() * 0.25, self:GetTall())

    -- Create the description panel
    self.descriptionPanel = vgui.Create("DPanel", self)
    self.descriptionPanel:SetPos(self:GetWide() * 0.25, 0)
    self.descriptionPanel:SetSize(self:GetWide() * 0.75, self:GetTall())

    -- Store created buttons for each category
    self.categoryButtons = {}

   -- Add content to the category list
	local categories = {
		"Passive",
		"Weapon",
		"Movement",
		"Effects",
		"Projectiles",
		"Defensive"
	}

	for _, category in ipairs(categories) do
		local cat = self.categoryList:Add(category)
		
		local function PopulateMenu(modules)
			for _, item in pairs(modules) do
				print(item)
				local mod = vgui.Create("DButton")
				mod:SetText(item)
				mod:SetSize(self.categoryList:GetWide(), 30)
				mod.DoClick = function()
					-- Handle module click here
					-- Display module description in the description panel
				end
				
				cat.PaintOver = function(self, w, h)
					mod:SetVisible(cat:GetExpanded())
				end
			end
			self.categoryList:AddItem(mod) -- Add to the category contents
		end
	end
end

function ModulePanel:Paint(w, h)
    surface.SetDrawColor(230, 207, 40, 255)
    surface.DrawOutlinedRect(0, 0, self:GetWide(), self:GetTall(), 1)
end

vgui.Register("MPanel", ModulePanel, "Panel")
-- End of Module Panel