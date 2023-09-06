local MCNPCMenu = nil;

local npcSelectorDropdown
local npcNameTextEntry
local npcScaleTextEntry
local npcColorPicker
local npcSpawnWeightTextEntry
local npcSkinTextEntry
local npcBodygroupTextEntry
local npcBaseHealthTextEntry
local npcHealthPerLevelTextEntry
local npcHealthPowerTextEntry
local npcBaseDamageTextEntry
local npcDamagePerLevelTextEntry
local npcDamagePowerTextEntry
local npcWeaponComboBox
local npcBaseExpTextEntry
local npcExpPerLevelTextEntry
local npcExpPowerTextEntry
local npcBossCheckbox
local npcLargeCheckbox
local npcMinionCheckbox

function NPCMenu()
	MCNPCMenu = vgui.Create("DFrame")
	MCNPCMenu:SetSize(300, 850)
	MCNPCMenu:Center()
	MCNPCMenu:SetTitle("Garry's Modular Combat - NPC Creator")
	MCNPCMenu:SetDraggable(true)
	MCNPCMenu:ShowCloseButton(true)
	MCNPCMenu:SetDeleteOnClose(false)
	MCNPCMenu:MakePopup(true)
	NPCMcreateNPCCreator()
end
concommand.Add("gmc_npccreator", NPCMenu)

function NPCMcreateNPCCreator()
	local npcSelectorLabel = vgui.Create("DLabel", MCNPCMenu)
	npcSelectorLabel:SetText("NPC Class:")
	npcSelectorLabel:SetPos(10, 70)
	npcSelectorLabel:SizeToContents()
	
	npcSelectorDropdown = vgui.Create("DComboBox", MCNPCMenu)
	npcSelectorDropdown:SetPos(10, 90)
	npcSelectorDropdown:SetSize(280, 20)

	-- Populate the dropdown with available NPC classes
	local npcClasses = list.Get("NPC")
	for class, _ in pairs(npcClasses) do
		npcSelectorDropdown:AddChoice(class)
	end
	
	-- Create a TextEntry for NPC Name
	local npcNameLabel = vgui.Create("DLabel", MCNPCMenu)
	npcNameLabel:SetText("NPC Name:")
	npcNameLabel:SetPos(10, 110)
	npcNameLabel:SizeToContents()

	npcNameTextEntry = vgui.Create("DTextEntry", MCNPCMenu)
	npcNameTextEntry:SetPos(10, 130)
	npcNameTextEntry:SetSize(280, 20)
	
	-- Create a TextEntry for NPC Scale
	local npcScaleLabel = vgui.Create("DLabel", MCNPCMenu)
	npcScaleLabel:SetText("NPC Scale:")
	npcScaleLabel:SetPos(10, 160)
	npcScaleLabel:SizeToContents()

	npcScaleTextEntry = vgui.Create("DTextEntry", MCNPCMenu)
	npcScaleTextEntry:SetPos(10, 180)
	npcScaleTextEntry:SetSize(40, 20)
	npcScaleTextEntry:SetText("1")
	
	-- Create a TextEntry for NPC Color
	local npcColorLabel = vgui.Create("DLabel", MCNPCMenu)
	npcColorLabel:SetText("NPC Color:")
	npcColorLabel:SetPos(10, 200)
	npcColorLabel:SizeToContents()

	npcColorPicker = vgui.Create("DColorMixer", MCNPCMenu)
	npcColorPicker:SetPos(10, 220)
	npcColorPicker:SetSize(200, 200)
	npcColorPicker:SetPalette(true) -- Display palette on the right side
	
	-- Create a TextEntry for NPC Spawn Weight
	local npcSpawnWeightLabel = vgui.Create("DLabel", MCNPCMenu)
	npcSpawnWeightLabel:SetText("NPC Spawn Weight:")
	npcSpawnWeightLabel:SetPos(80, 160)
	npcSpawnWeightLabel:SizeToContents()

	npcSpawnWeightTextEntry = vgui.Create("DTextEntry", MCNPCMenu)
	npcSpawnWeightTextEntry:SetPos(80, 180)
	npcSpawnWeightTextEntry:SetSize(40, 20)
	npcSpawnWeightTextEntry:SetText("1")
	
	-- Create a TextEntry for NPC Skin
	local npcSkinLabel = vgui.Create("DLabel", MCNPCMenu)
	npcSkinLabel:SetText("NPC Skin:")
	npcSkinLabel:SetPos(10, 440)
	npcSkinLabel:SizeToContents()

	npcSkinTextEntry = vgui.Create("DTextEntry", MCNPCMenu)
	npcSkinTextEntry:SetPos(10, 460)
	npcSkinTextEntry:SetSize(40, 20)

	-- Create a TextEntry for Bodygroups
	local npcBodygroupLabel = vgui.Create("DLabel", MCNPCMenu)
	npcBodygroupLabel:SetText("Bodygroups:")
	npcBodygroupLabel:SetPos(80, 440)
	npcBodygroupLabel:SizeToContents()

	npcBodygroupTextEntry = vgui.Create("DTextEntry", MCNPCMenu)
	npcBodygroupTextEntry:SetPos(80, 460)
	npcBodygroupTextEntry:SetSize(60, 20)

	-- Create TextEntries for NPC Health
	local npcHealthLabel = vgui.Create("DLabel", MCNPCMenu)
	npcHealthLabel:SetText("Health Configuration:")
	npcHealthLabel:SetPos(10, 490)
	npcHealthLabel:SizeToContents()

	local npcBaseHealthLabel = vgui.Create("DLabel", MCNPCMenu)
	npcBaseHealthLabel:SetText("Base:")
	npcBaseHealthLabel:SetPos(10, 510)
	npcBaseHealthLabel:SizeToContents()

	npcBaseHealthTextEntry = vgui.Create("DTextEntry", MCNPCMenu)
	npcBaseHealthTextEntry:SetPos(120, 510)
	npcBaseHealthTextEntry:SetSize(50, 20)

	local npcHealthPerLevelLabel = vgui.Create("DLabel", MCNPCMenu)
	npcHealthPerLevelLabel:SetText("Per Level:")
	npcHealthPerLevelLabel:SetPos(10, 530)
	npcHealthPerLevelLabel:SizeToContents()

	npcHealthPerLevelTextEntry = vgui.Create("DTextEntry", MCNPCMenu)
	npcHealthPerLevelTextEntry:SetPos(120, 530)
	npcHealthPerLevelTextEntry:SetSize(50, 20)

	local npcHealthPowerLabel = vgui.Create("DLabel", MCNPCMenu)
	npcHealthPowerLabel:SetText("Power:")
	npcHealthPowerLabel:SetPos(10, 550)
	npcHealthPowerLabel:SizeToContents()

	npcHealthPowerTextEntry = vgui.Create("DTextEntry", MCNPCMenu)
	npcHealthPowerTextEntry:SetPos(120, 550)
	npcHealthPowerTextEntry:SetSize(50, 20)

	-- Create TextEntries for NPC Damage
	local npcDamageLabel = vgui.Create("DLabel", MCNPCMenu)
	npcDamageLabel:SetText("Damage Configuration:")
	npcDamageLabel:SetPos(10, 580)
	npcDamageLabel:SizeToContents()

	local npcBaseDamageLabel = vgui.Create("DLabel", MCNPCMenu)
	npcBaseDamageLabel:SetText("Base Damage:")
	npcBaseDamageLabel:SetPos(10, 600)
	npcBaseDamageLabel:SizeToContents()

	npcBaseDamageTextEntry = vgui.Create("DTextEntry", MCNPCMenu)
	npcBaseDamageTextEntry:SetPos(120, 600)
	npcBaseDamageTextEntry:SetSize(50, 20)

	local npcDamagePerLevelLabel = vgui.Create("DLabel", MCNPCMenu)
	npcDamagePerLevelLabel:SetText("Damage per Level:")
	npcDamagePerLevelLabel:SetPos(10, 620)
	npcDamagePerLevelLabel:SizeToContents()

	npcDamagePerLevelTextEntry = vgui.Create("DTextEntry", MCNPCMenu)
	npcDamagePerLevelTextEntry:SetPos(120, 620)
	npcDamagePerLevelTextEntry:SetSize(50, 20)

	local npcDamagePowerLabel = vgui.Create("DLabel", MCNPCMenu)
	npcDamagePowerLabel:SetText("Damage Power:")
	npcDamagePowerLabel:SetPos(10, 640)
	npcDamagePowerLabel:SizeToContents()

	npcDamagePowerTextEntry = vgui.Create("DTextEntry", MCNPCMenu)
	npcDamagePowerTextEntry:SetPos(120, 640)
	npcDamagePowerTextEntry:SetSize(50, 20)
	
	-- Create a ComboBox for Weapon Configuration
	local npcWeaponLabel = vgui.Create("DLabel", MCNPCMenu)
	npcWeaponLabel:SetText("Weapon Configuration: ()")
	npcWeaponLabel:SetPos(10, 660)
	npcWeaponLabel:SizeToContents()

	npcWeaponComboBox = vgui.Create("DComboBox", MCNPCMenu)
	npcWeaponComboBox:SetPos(10, 675)
	npcWeaponComboBox:SetSize(280, 20)

	-- Populate the weapon ComboBox with available weapons
	for _, weaponClass in pairs(list.Get("Weapon")) do
		npcWeaponComboBox:AddChoice(weaponClass.ClassName)
	end
	
	local npcExpLabel = vgui.Create("DLabel", MCNPCMenu)
	npcExpLabel:SetText("EXP Configuration:")
	npcExpLabel:SetPos(10, 700)
	npcExpLabel:SizeToContents()

	local npcBaseExpLabel = vgui.Create("DLabel", MCNPCMenu)
	npcBaseExpLabel:SetText("Base EXP:")
	npcBaseExpLabel:SetPos(10, 720)
	npcBaseExpLabel:SizeToContents()

	npcBaseExpTextEntry = vgui.Create("DTextEntry", MCNPCMenu)
	npcBaseExpTextEntry:SetPos(120, 720)
	npcBaseExpTextEntry:SetSize(50, 20)

	local npcExpPerLevelLabel = vgui.Create("DLabel", MCNPCMenu)
	npcExpPerLevelLabel:SetText("EXP per Level:")
	npcExpPerLevelLabel:SetPos(10, 740)
	npcExpPerLevelLabel:SizeToContents()

	npcExpPerLevelTextEntry = vgui.Create("DTextEntry", MCNPCMenu)
	npcExpPerLevelTextEntry:SetPos(120, 740)
	npcExpPerLevelTextEntry:SetSize(50, 20)

	local npcExpPowerLabel = vgui.Create("DLabel", MCNPCMenu)
	npcExpPowerLabel:SetText("EXP Power:")
	npcExpPowerLabel:SetPos(10, 760)
	npcExpPowerLabel:SizeToContents()

	npcExpPowerTextEntry = vgui.Create("DTextEntry", MCNPCMenu)
	npcExpPowerTextEntry:SetPos(120, 760)
	npcExpPowerTextEntry:SetSize(50, 20)
	
	-- Create Checkboxes for Boss, Large NPC, and Minion
	npcBossCheckbox = vgui.Create("DCheckBoxLabel", MCNPCMenu)
	npcBossCheckbox:SetText("Boss")
	npcBossCheckbox:SetPos(10, 790)
	npcBossCheckbox:SizeToContents()

	npcLargeCheckbox = vgui.Create("DCheckBoxLabel", MCNPCMenu)
	npcLargeCheckbox:SetText("Large")
	npcLargeCheckbox:SetPos(80, 790)
	npcLargeCheckbox:SizeToContents()

	npcMinionCheckbox = vgui.Create("DCheckBoxLabel", MCNPCMenu)
	npcMinionCheckbox:SetText("Minion")
	npcMinionCheckbox:SetPos(150, 790)
	npcMinionCheckbox:SizeToContents()
	
	-- Add a "Save Configuration" button
	local saveButton = vgui.Create("DButton", MCNPCMenu)
	saveButton:SetText("Save Spawn Data")
	saveButton:SetPos(10, 810)
	saveButton:SetSize(280, 30)
	saveButton.DoClick = function()
		SaveNPCConfigurationToFile(
			npcSelectorDropdown,
			npcNameTextEntry,
			npcScaleTextEntry,
			npcColorPicker,
			npcSpawnWeightTextEntry,
			npcSkinTextEntry,
			npcBodygroupTextEntry,
			npcBaseHealthTextEntry,
			npcHealthPerLevelTextEntry,
			npcHealthPowerTextEntry,
			npcBaseDamageTextEntry,
			npcDamagePerLevelTextEntry,
			npcDamagePowerTextEntry,
			npcWeaponComboBox,
			npcBaseExpTextEntry,
			npcExpPerLevelTextEntry,
			npcExpPowerTextEntry,
			npcBossCheckbox,
			npcLargeCheckbox,
			npcMinionCheckbox
		)
	end

	-- Callback for when an NPC class is selected
	npcSelectorDropdown.OnSelect = function(self, index, value, data)
		local selectedNPCClass = value
		npcNameTextEntry:SetText("") -- Clear the text entry when selecting a new NPC class
		npcScaleTextEntry:SetText("1") -- Clear the text entry when selecting a new NPC class
		npcColorPicker:SetColor(Color(255, 255, 255)) -- Reset color picker when selecting a new NPC class
		npcSpawnWeightTextEntry:SetText("1") -- Reset the text entry when selecting a new NPC class
		npcSkinTextEntry:SetText("") -- Clear the text entry when selecting a new NPC class
		npcBodygroupTextEntry:SetText("") -- Clear the text entry for bodygroups
		npcBaseHealthTextEntry:SetText("100") -- Clear the text entry when selecting a new NPC class
		npcHealthPerLevelTextEntry:SetText("5") -- Clear the text entry for health per level
		npcHealthPowerTextEntry:SetText("1") -- Clear the text entry for health power
		npcBaseDamageTextEntry:SetText("1") -- Clear the text entry when selecting a new NPC class
		npcDamagePerLevelTextEntry:SetText("1") -- Clear the text entry for damage per level
		npcDamagePowerTextEntry:SetText("1") -- Clear the text entry for damage power
		npcWeaponComboBox:Clear() -- Clear the weapon ComboBox when selecting a new NPC class
		npcBaseExpTextEntry:SetText("10") -- Clear the text entry when selecting a new NPC class
		npcExpPerLevelTextEntry:SetText("1") -- Clear the text entry for EXP per level
		npcExpPowerTextEntry:SetText("1") -- Clear the text entry for EXP power
		npcBossCheckbox:SetValue(false) -- Clear the boss checkbox
		npcLargeCheckbox:SetValue(false) -- Clear the large NPC checkbox
		npcMinionCheckbox:SetValue(false) -- Clear the minion checkbox
		for _, weaponClass in pairs(list.Get("Weapon")) do
			npcWeaponComboBox:AddChoice(weaponClass.ClassName)
		end
	end
end

-- Callback for saving NPC configuration to a file
function SaveNPCConfigurationToFile(npcSelectorDropdown, npcNameTextEntry, npcScaleTextEntry, npcColorPicker, npcSpawnWeightTextEntry, npcSkinTextEntry, npcBodygroupTextEntry, npcBaseHealthTextEntry, npcHealthPerLevelTextEntry, npcHealthPowerTextEntry, npcBaseDamageTextEntry, npcDamagePerLevelTextEntry, npcDamagePowerTextEntry, npcWeaponComboBox, npcBaseExpTextEntry, npcExpPerLevelTextEntry, npcExpPowerTextEntry, npcBossCheckbox, npcLargeCheckbox, npcMinionCheckbox)
    local npcName = npcNameTextEntry:GetValue()
	local folderName = "gmc/npcs"
    local filename = folderName .. "/" .. npcName .. ".txt"
    local fileContent = ""

	local npcData = {
        ["class"] = npcSelectorDropdown:GetValue(),
        ["name"] = npcNameTextEntry:GetValue(),
        ["scale"] = npcScaleTextEntry:GetValue(),
        ["color"] = {
			["red"] = npcColorPicker:GetColor().r,
			["green"] = npcColorPicker:GetColor().g, 
			["blue"] = npcColorPicker:GetColor().b,
			["alpha"] = npcColorPicker:GetColor().a,
		},
        ["weight"] = npcSpawnWeightTextEntry:GetValue(),
        ["skin"] = npcSkinTextEntry:GetValue(),
        ["bodygroups"] = npcBodygroupTextEntry:GetValue(),
        ["basehealth"] = npcBaseHealthTextEntry:GetValue(),
        ["healthlvl"] = npcHealthPerLevelTextEntry:GetValue(),
        ["healthpower"] = npcHealthPowerTextEntry:GetValue(),
        ["basedamage"] = npcBaseDamageTextEntry:GetValue(),
        ["damagelvl"] = npcDamagePerLevelTextEntry:GetValue(),
        ["damagepower"] = npcDamagePowerTextEntry:GetValue(),
        ["weapon"] = npcWeaponComboBox:GetSelected(),
        ["baseexp"] = npcBaseExpTextEntry:GetValue(),
        ["explvl"] = npcExpPerLevelTextEntry:GetValue(),
        ["exppower"] = npcExpPowerTextEntry:GetValue(),
        ["isboss"] = tostring(npcBossCheckbox:GetChecked()),
        ["islarge"] = tostring(npcLargeCheckbox:GetChecked()),
        ["isminion"] = tostring(npcMinionCheckbox:GetChecked())
    }

    -- Construct the line with the NPC configuration
    local line = util.TableToJSON( npcData, true )

	-- Create the folder if it doesn't exist
    if not file.IsDir(folderName, "DATA") then
        file.CreateDir(folderName)
    end
	
    -- Write the line to the specific NPC's file
    file.Write(filename, line)

    print("NPC Configuration saved to file:", filename)
	print(table.ToString( npcData, npcData.name, true ))
end