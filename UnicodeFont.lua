-- version: 1.4.2
-- code inspired by CLEARFONT BY KIRKBURN

UnicodeFontFrame = CreateFrame("Frame", "UnicodeFontFrame")

UNICODEFONT = "Interface\\AddOns\\UnicodeFont\\WarSansTT-Bliz-500.ttf"

-- Font scale - e.g. if you want all fonts at 80% scale, change '1' to '0.8'
local SCALE = 1

local function CanSetFont(object)
	return (type(object)=="table" and object.SetFont and object.IsObjectType and not object:IsObjectType("SimpleHTML"))
end

local function ApplyFont(object, defaultSize)
	if not CanSetFont(object) then return end

	local _, size, flags
	if object.GetFont then
		_, size, flags = object:GetFont()
	end

	object:SetFont(UNICODEFONT, (size or defaultSize) * SCALE, flags)
end

function UnicodeFontFrame:ApplySystemFonts()
	-- Chat bubbles
	NAMEPLATE_FONT = UNICODEFONT;
	-- chat font
	ApplyFont(ChatFontNormal, 14)
	-- quest detail fonts
	ApplyFont(QuestLogQuestTitle, 16)
	ApplyFont(QuestLogObjectivesText, 13)
	ApplyFont(QuestLogQuestDescription, 13)
	ApplyFont(QuestInfoTitleHeader, 16)
	ApplyFont(QuestInfoObjectivesText, 13)
	ApplyFont(QuestInfoDescriptionText, 13)
end

UnicodeFontFrame:SetScript("OnEvent",
	function(self, event, addonName)
		if (event == "ADDON_LOADED" and addonName == "UnicodeFont") or event == "PLAYER_ENTERING_WORLD" then
			UnicodeFontFrame:ApplySystemFonts()
		end
	end);

UnicodeFontFrame:RegisterEvent("ADDON_LOADED");
UnicodeFontFrame:RegisterEvent("PLAYER_ENTERING_WORLD");

UnicodeFontFrame:ApplySystemFonts()
