include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

net.Receive("OpenSpawnGUIMenu", function()
	entity = net:ReadEntity()
	OpenSpawnGUI()
end)

local selectorMenu = nil

function OpenSpawnGUI()
	if !IsValid(selectorMenu) then
		-- Create the main selectorMenu
		selectorMenu = vgui.Create("DFrame")
		selectorMenu:SetSize(400, 300)
		selectorMenu:Center()
		selectorMenu:SetTitle("")
		selectorMenu:MakePopup()
		selectorMenu:SetDeleteOnClose( true )
		selectorMenu.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 80))
		end

		-- Create checkboxes
		local checkboxPanel = vgui.Create("DPanel", selectorMenu)
		checkboxPanel:SetPos(10, 30)
		checkboxPanel:SetSize(380, 30)

		local checkboxPlayerSpawns = vgui.Create("DCheckBoxLabel", checkboxPanel)
		checkboxPlayerSpawns:SetText("Player Spawns")
		checkboxPlayerSpawns:SetPos(0, 0)
		checkboxPlayerSpawns:SetValue(0)
		checkboxPlayerSpawns:SizeToContents()
		checkboxPlayerSpawns.Label:SetTextColor(Color(0, 0, 0, 255))
		checkboxPlayerSpawns.Button:SetTextColor(Color(0, 0, 0, 255))

		local checkboxWeaponSpawns = vgui.Create("DCheckBoxLabel", checkboxPanel)
		checkboxWeaponSpawns:SetText("Entity Spawns")
		checkboxWeaponSpawns:SetPos(120, 0)
		checkboxWeaponSpawns:SetValue(0)
		checkboxWeaponSpawns:SizeToContents()
		checkboxWeaponSpawns.Label:SetTextColor(Color(0, 0, 0, 255))
		checkboxWeaponSpawns.Button:SetTextColor(Color(0, 0, 0, 255))

		local checkboxNPCSpawns = vgui.Create("DCheckBoxLabel", checkboxPanel)
		checkboxNPCSpawns:SetText("NPC Spawns")
		checkboxNPCSpawns:SetPos(240, 0)
		checkboxNPCSpawns:SetValue(0)
		checkboxNPCSpawns:SizeToContents()
		checkboxNPCSpawns.Label:SetTextColor(Color(0, 0, 0, 255))
		checkboxNPCSpawns.Button:SetTextColor(Color(0, 0, 0, 255))
		
		-- Create dropdown menus
		local dropdownPanel = vgui.Create("DPanel", selectorMenu)
		dropdownPanel:SetPos(10, 70)
		dropdownPanel:SetSize(380, 220)
		dropdownPanel.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 80))
		end

		local playerspawns = {
			"No Team",
			"Red",
			"Blue",
			"Green",
			"Purple"
		}
		
		local dropdown1 = vgui.Create("DComboBox", dropdownPanel)
		dropdown1:SetPos(0, 0)
		dropdown1:SetSize(380, 30)
		for _, choice in ipairs(playerspawns) do
			dropdown1:AddChoice(choice)
		end
		dropdown1:SetVisible(false)
		dropdown1:SetTextColor(Color(0, 0, 0, 255))
		dropdown1:SetValue(entity:GetNWString("SpawnType"))

		-- Create a table to store weapon choices
		local weaponChoices = {}

		-- Loop through available weapons and add them to the weaponChoices table
		for _, weapon in pairs(weapons.GetList()) do
			local class = weapon.ClassName
			--table.insert(weaponChoices, class)
		end
		
		-- Include Half-Life 2 weapons
		local extraents = {
			"weapon_357",
			"weapon_smg1",
			"weapon_pistol",
			"weapon_ar2",
			"weapon_shotgun",
			"weapon_crossbow",
			"weapon_rocket_launcher",
			"weapon_grenade",
			"weapon_slam",
			"gmc_smallhealthpack",
			"gmc_mediumhealthpack",
			"gmc_largehealthpack",
		}
		
		for _, weapon in ipairs(extraents) do
			table.insert(weaponChoices, weapon)
		end

		local dropdown2 = vgui.Create("DComboBox", dropdownPanel)
		dropdown2:SetPos(0, 0)
		dropdown2:SetSize(380, 30)
		for _, choice in ipairs(weaponChoices) do
			dropdown2:AddChoice(choice)
		end
		dropdown2:SetVisible(false)
		dropdown2:SetTextColor(Color(0, 0, 0, 255))
		dropdown2:SetValue(entity:GetNWString("SpawnType"))
		
		local ammoTypes = {}
		
		for _, ammo in pairs(game.GetAmmoTypes()) do
			table.insert(ammoTypes, ammo)
		end
		
		local ammoTypeDropdown = vgui.Create("DComboBox", dropdownPanel)
		ammoTypeDropdown:SetPos(0, 40)
		ammoTypeDropdown:SetSize(380, 30)
		for _, choice in ipairs(ammoTypes) do
			ammoTypeDropdown:AddChoice(choice)
		end
		ammoTypeDropdown:SetVisible(false)
		ammoTypeDropdown:SetValue(entity:GetNWString("ExtraOption1"))
		
		 -- Create Ammo slider
        local ammoSlider = vgui.Create("DNumSlider", dropdownPanel)
        ammoSlider:SetPos(3, 80)
        ammoSlider:SetSize(300, 30)
        ammoSlider:SetText("Ammo Amount:")
        ammoSlider:SetMin(0)
        ammoSlider:SetMax(100)
        ammoSlider:SetDecimals(0)
        ammoSlider:SetVisible(false)
        ammoSlider:SetValue(entity:GetNWString("ExtraOption2"))

        -- Create Respawn Time slider
        local respawnSlider = vgui.Create("DNumSlider", dropdownPanel)
        respawnSlider:SetPos(3, 120)
        respawnSlider:SetSize(300, 30)
        respawnSlider:SetText("Respawn Time:")
        respawnSlider:SetMin(1)
        respawnSlider:SetMax(60)
        respawnSlider:SetDecimals(0)
        respawnSlider:SetVisible(false)
        respawnSlider:SetValue(entity:GetNWString("ExtraOption3"))

		local NPCSpawns = {
			"Normal",
			"Large",
			"Boss"
		}

		local dropdown3 = vgui.Create("DComboBox", dropdownPanel)
		dropdown3:SetPos(0, 0)
		dropdown3:SetSize(380, 30)
		for _, choice in ipairs(NPCSpawns) do
			dropdown3:AddChoice(choice)
		end
		dropdown3:SetVisible(false)
		dropdown3:SetTextColor(Color(0, 0, 0, 255))
		dropdown3:SetValue(entity:GetNWString("SpawnType"))
		
		local saveButton = vgui.Create("DButton", dropdownPanel)
        saveButton:SetText("Save")
        saveButton:SetPos(10, 180)  -- Adjust the position as needed
        saveButton:SetSize(360, 30)
        saveButton:SetTextColor(Color(230,207,40,255))
        saveButton.Paint = function(self, w, h)
			surface.SetDrawColor(Color(230,207,40,255))
			surface.DrawOutlinedRect(0, 0, w, h, 1)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 80))  -- Button background color
        end
		
		 saveButton.DoClick = function()
            -- Save settings here
            local spawnCategory = entity:GetNWString("SpawnCategory")
            local spawnType = entity:GetNWString("SpawnType")
            local extraOption1 = entity:GetNWString("ExtraOption1")
            local extraOption2 = entity:GetNWString("ExtraOption2")
			local extraOption3 = entity:GetNWString("ExtraOption3")

            if checkboxPlayerSpawns:GetChecked() then
                spawnCategory = "Players"
                if spawnType != nil then
					spawnType = dropdown1:GetOptionText(dropdown1:GetSelectedID())
				end
            elseif checkboxWeaponSpawns:GetChecked() then
                spawnCategory = "Weapons"
                spawnType = dropdown2:GetOptionText(dropdown2:GetSelectedID())
                extraOption1 = ammoTypeDropdown:GetOptionText(ammoTypeDropdown:GetSelectedID())
                extraOption2 = tostring(math.Round(ammoSlider:GetValue()))
				extraOption3 = tostring(math.Round(respawnSlider:GetValue()))
            elseif checkboxNPCSpawns:GetChecked() then
                spawnCategory = "NPCs"
                spawnType = dropdown3:GetOptionText(dropdown3:GetSelectedID())
            end
			
            if spawnCategory != nil then
				entity:SetNWString("SpawnCategory", spawnCategory)
			end
			if spawnType != nil then
				entity:SetNWString("SpawnType", spawnType)
			end
			if extraOption1 != nil then
				entity:SetNWString("ExtraOption1", extraOption1)
			end
			if extraOption2 != nil then
				entity:SetNWString("ExtraOption2", extraOption2)
			end
			if extraOption3 != nil then
				entity:SetNWString("ExtraOption3", extraOption3)
			end
			
            net.Start("SendUserInputToWeaponSpawner")
                net.WriteString(entity:GetNWString("SpawnCategory"))
                net.WriteString(entity:GetNWString("SpawnType"))
				net.WriteString(entity:GetNWString("ExtraOption1"))
                net.WriteString(entity:GetNWString("ExtraOption2"))
				net.WriteString(entity:GetNWString("ExtraOption3"))
                net.WriteEntity(entity)
            net.SendToServer()
        end
		
		local function UpdateVisibility()
			dropdown1:SetVisible(checkboxPlayerSpawns:GetChecked())
			dropdown2:SetVisible(checkboxWeaponSpawns:GetChecked())
			dropdown3:SetVisible(checkboxNPCSpawns:GetChecked())
			ammoTypeDropdown:SetVisible(checkboxWeaponSpawns:GetChecked())
			ammoSlider:SetVisible(checkboxWeaponSpawns:GetChecked())
			respawnSlider:SetVisible(checkboxWeaponSpawns:GetChecked())
		end
		
		if entity:GetNWString("SpawnCategory") == "Players" then
			checkboxPlayerSpawns:SetChecked(true)
			checkboxWeaponSpawns:SetChecked(false)
			checkboxNPCSpawns:SetChecked(false)
			UpdateVisibility()
		elseif entity:GetNWString("SpawnCategory") == "Weapons" then
			checkboxPlayerSpawns:SetChecked(false)
			checkboxWeaponSpawns:SetChecked(true)
			checkboxNPCSpawns:SetChecked(false)
			UpdateVisibility()
		elseif entity:GetNWString("SpawnCategory") == "NPCs" then
			checkboxPlayerSpawns:SetChecked(false)
			checkboxWeaponSpawns:SetChecked(false)
			checkboxNPCSpawns:SetChecked(true)
			UpdateVisibility()
		end
		
		checkboxPlayerSpawns.OnChange = function(self)
			if checkboxPlayerSpawns:GetChecked() then
				checkboxWeaponSpawns:SetChecked(false)
				checkboxNPCSpawns:SetChecked(false)
				UpdateVisibility()
			end
		end

		checkboxWeaponSpawns.OnChange = function(self)
			if checkboxWeaponSpawns:GetChecked() then
				checkboxPlayerSpawns:SetChecked(false)
				checkboxNPCSpawns:SetChecked(false)
				UpdateVisibility()
			end
		end

		checkboxNPCSpawns.OnChange = function(self)
			if checkboxNPCSpawns:GetChecked() then
				checkboxPlayerSpawns:SetChecked(false)
				checkboxWeaponSpawns:SetChecked(false)
				UpdateVisibility()
			end
		end
	end
end