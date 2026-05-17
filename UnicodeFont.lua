-- version: 1.4.2
-- code inspired by CLEARFONT BY KIRKBURN

UnicodeFontFrame = CreateFrame("Frame", "UnicodeFontFrame")

UNICODEFONT = "Interface\\AddOns\\UnicodeFont\\WarSansTT-Bliz-500.ttf"

-- Font scale - e.g. if you want all fonts at 80% scale, change '1' to '0.8'
local SCALE = 1

local defaults = {
	chat = true,
	quest = false,
	unitframes = false,
	overhead = false,
	nameplates = false,
}

local optionLabels = {
	chat = "Chat",
	quest = "Quest text",
	unitframes = "Unit frames",
	overhead = "Overhead names",
	nameplates = "Nameplates",
}

local optionOrder = { "chat", "quest", "unitframes", "overhead", "nameplates" }

local function Print(message)
	DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00UnicodeFont:|r " .. message)
end

local function InitDB()
	if type(UnicodeFontDB) ~= "table" then
		UnicodeFontDB = {}
	end

	for option, value in pairs(defaults) do
		if UnicodeFontDB[option] == nil then
			UnicodeFontDB[option] = value
		end
	end
end

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

local function ApplyFrameFonts(frame, visited)
	if type(frame) ~= "table" or visited[frame] then return end
	visited[frame] = true

	if frame.GetRegions then
		local regions = { frame:GetRegions() }
		for _, region in ipairs(regions) do
			ApplyFont(region, 12)
		end
	end

	if frame.GetChildren then
		local children = { frame:GetChildren() }
		for _, child in ipairs(children) do
			ApplyFrameFonts(child, visited)
		end
	end
end

function UnicodeFontFrame:ApplyUnitFrameFonts()
	local frames = {
		PlayerFrame,
		TargetFrame,
		TargetofTargetFrame,
		PetFrame,
		PartyMemberFrame1,
		PartyMemberFrame2,
		PartyMemberFrame3,
		PartyMemberFrame4,
	}

	local visited = {}
	for _, frame in ipairs(frames) do
		ApplyFrameFonts(frame, visited)
	end
end

function UnicodeFontFrame:ApplySystemFonts()
	InitDB()

	if UnicodeFontDB.overhead then
		UNIT_NAME_FONT = UNICODEFONT
	end

	if UnicodeFontDB.nameplates then
		NAMEPLATE_FONT = UNICODEFONT
	end

	if UnicodeFontDB.chat then
		ApplyFont(ChatFontNormal, 14)
	end

	if UnicodeFontDB.quest then
		ApplyFont(QuestLogQuestTitle, 16)
		ApplyFont(QuestLogObjectivesText, 13)
		ApplyFont(QuestLogQuestDescription, 13)
		ApplyFont(QuestInfoTitleHeader, 16)
		ApplyFont(QuestInfoObjectivesText, 13)
		ApplyFont(QuestInfoDescriptionText, 13)
	end

	if UnicodeFontDB.unitframes then
		UnicodeFontFrame:ApplyUnitFrameFonts()
	end
end

local function ShowStatus()
	Print("options:")
	for _, option in ipairs(optionOrder) do
		local status = UnicodeFontDB[option] and "enabled" or "disabled"
		Print(option .. " - " .. status .. " (" .. optionLabels[option] .. ")")
	end
end

local function ShowHelp()
	Print("/unicodefont list")
	Print("/unicodefont enable <chat|quest|unitframes|overhead|nameplates>")
	Print("/unicodefont disable <chat|quest|unitframes|overhead|nameplates>")
	Print("Some changes may require /reload or a client restart to fully revert.")
end

local function SetOption(option, enabled)
	if UnicodeFontDB[option] == nil then
		Print("unknown option: " .. option)
		ShowHelp()
		return
	end

	UnicodeFontDB[option] = enabled
	Print(option .. " " .. (enabled and "enabled" or "disabled"))

	if enabled then
		UnicodeFontFrame:ApplySystemFonts()
	else
		Print("reload the UI to fully revert fonts already applied in this session.")
	end
end

SLASH_UNICODEFONT1 = "/unicodefont"
SlashCmdList["UNICODEFONT"] = function(msg)
	InitDB()

	msg = string.lower(msg or "")
	local _, _, command, option = string.find(msg, "^(%S*)%s*(%S*)")

	if command == "list" then
		ShowStatus()
	elseif command == "enable" and option ~= "" then
		SetOption(option, true)
	elseif command == "disable" and option ~= "" then
		SetOption(option, false)
	else
		ShowHelp()
	end
end

UnicodeFontFrame:SetScript("OnEvent",
	function()
		if (event == "ADDON_LOADED" and arg1 == "UnicodeFont") or event == "PLAYER_ENTERING_WORLD" then
			UnicodeFontFrame:ApplySystemFonts()
		end
	end);

UnicodeFontFrame:RegisterEvent("ADDON_LOADED");
UnicodeFontFrame:RegisterEvent("PLAYER_ENTERING_WORLD");

UnicodeFontFrame:ApplySystemFonts()
