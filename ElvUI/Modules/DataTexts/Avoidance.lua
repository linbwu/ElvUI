local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local DT = E:GetModule("DataTexts");

--Cache global variables
--Lua functions
local find, format, join, match = string.find, string.format, string.join, string.match
local abs = math.abs
--WoW API / Variables
local GetInventoryItemLink = GetInventoryItemLink
local GetInventorySlotInfo = GetInventorySlotInfo
local GetItemInfo = GetItemInfo
local UnitLevel = UnitLevel
local GetDodgeChance = GetDodgeChance
local GetParryChance = GetParryChance
local GetBlockChance = GetBlockChance
local GetBonusBarOffset = GetBonusBarOffset
local BOSS = BOSS
local DODGE_CHANCE = DODGE_CHANCE
local PARRY_CHANCE = PARRY_CHANCE
local BLOCK_CHANCE = BLOCK_CHANCE

DEFENSE = "Defense";
DODGE_CHANCE = "Dodge Chance";
PARRY_CHANCE = "Parry Chance";
BLOCK_CHANCE = "Block Chance";

local displayString, lastPanel
local targetlv, playerlv
local baseMissChance, levelDifference, dodge, parry, block, avoidance, unhittable
local chanceString = "%.2f%%"
local AVD_DECAY_RATE = 0.2

local function IsWearingShield()
	local slotID = GetInventorySlotInfo("SecondaryHandSlot")
	local link = GetInventoryItemLink("player", slotID)
	if link then
		local _, _, itemID = find(link, "(%d+):")

		if itemID then
			return select(9, GetItemInfo(itemID))
		end
	end
end

local function OnEvent(self)
	targetlv, playerlv = UnitLevel("target"), UnitLevel("player")

	baseMissChance = E.myrace == "NightElf" and 7 or 5
	if targetlv == -1 then
		levelDifference = 3
	elseif targetlv > playerlv then
		levelDifference = (targetlv - playerlv)
	elseif targetlv < playerlv and targetlv > 0 then
		levelDifference = (targetlv - playerlv)
	else
		levelDifference = 0
	end

	if levelDifference >= 0 then
		dodge = (GetDodgeChance() - levelDifference * AVD_DECAY_RATE)
		parry = (GetParryChance() - levelDifference * AVD_DECAY_RATE)
		block = (GetBlockChance() - levelDifference * AVD_DECAY_RATE)
		baseMissChance = (baseMissChance - levelDifference * AVD_DECAY_RATE)
	else
		dodge = (GetDodgeChance() + abs(levelDifference * AVD_DECAY_RATE))
		parry = (GetParryChance() + abs(levelDifference * AVD_DECAY_RATE))
		block = (GetBlockChance() + abs(levelDifference * AVD_DECAY_RATE))
		baseMissChance = (baseMissChance+ abs(levelDifference * AVD_DECAY_RATE))
	end

	if dodge <= 0 then dodge = 0 end
	if parry <= 0 then parry = 0 end
	if block <= 0 then block = 0 end

	if E.myclass == "DRUID" and GetBonusBarOffset() == 3 then
		parry = 0
	end

	if IsWearingShield() ~= "INVTYPE_SHIELD" then
		block = 0
	end

	avoidance = (dodge + parry + block + baseMissChance)
	unhittable = avoidance - 102.4

	self.text:SetText(format(displayString, DEFENSE, avoidance))

	lastPanel = self
end

local function OnEnter(self)
	DT:SetupTooltip(self)

	if targetlv > 1 then
		DT.tooltip:AddDoubleLine(L["Avoidance Breakdown"], join("", " (", L["lvl"], " ", targetlv, ")"))
	elseif targetlv == -1 then
		DT.tooltip:AddDoubleLine(L["Avoidance Breakdown"], join("", " (", BOSS, ")"))
	else
		DT.tooltip:AddDoubleLine(L["Avoidance Breakdown"], join("", " (", L["lvl"], " ", playerlv, ")"))
	end

	DT.tooltip:AddLine(" ")
	DT.tooltip:AddDoubleLine(DODGE_CHANCE, format(chanceString, dodge), 1, 1, 1)
	DT.tooltip:AddDoubleLine(PARRY_CHANCE, format(chanceString, parry), 1, 1, 1)
	DT.tooltip:AddDoubleLine(BLOCK_CHANCE, format(chanceString, block), 1, 1, 1)
	DT.tooltip:AddDoubleLine(L["Miss Chance"], format(chanceString, baseMissChance), 1, 1, 1)
	DT.tooltip:AddLine(" ")

	if unhittable > 0 then
		DT.tooltip:AddDoubleLine(L["Unhittable:"], "+" .. format(chanceString, unhittable), 1, 1, 1, 0, 1, 0)
	else
		DT.tooltip:AddDoubleLine(L["Unhittable:"], format(chanceString, unhittable), 1, 1, 1, 1, 0, 0)
	end

	DT.tooltip:Show()
end

local function ValueColorUpdate(hex)
	displayString = join("", "%s: ", hex, "%.2f%%|r")

	if lastPanel ~= nil then
		OnEvent(lastPanel)
	end
end
E.valueColorUpdateFuncs[ValueColorUpdate] = true

DT:RegisterDatatext("Avoidance", {"COMBAT_RATING_UPDATE", "PLAYER_TARGET_CHANGED"}, OnEvent, nil, nil, OnEnter, nil, L["Avoidance Breakdown"])