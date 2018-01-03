local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins");

--Cache global variables
--Lua functions
local _G = _G
--WoW API / Variables

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.petition ~= true then return end

	E:StripTextures(PetitionFrame, true)
	E:CreateBackdrop(PetitionFrame, "Transparent")
	PetitionFrame.backdrop:SetPoint("TOPLEFT", 12, -17)
	PetitionFrame.backdrop:SetPoint("BOTTOMRIGHT", -28, 65)

	S:HandleButton(PetitionFrameSignButton)
	S:HandleButton(PetitionFrameRequestButton)
	S:HandleButton(PetitionFrameRenameButton)
	S:HandleButton(PetitionFrameCancelButton)
	S:HandleCloseButton(PetitionFrameCloseButton)

	PetitionFrameCharterTitle:SetTextColor(1, 1, 0)
	PetitionFrameCharterName:SetTextColor(1, 1, 1)
	PetitionFrameMasterTitle:SetTextColor(1, 1, 0)
	PetitionFrameMasterName:SetTextColor(1, 1, 1)
	PetitionFrameMemberTitle:SetTextColor(1, 1, 0)

	for i = 1, 9 do
		_G["PetitionFrameMemberName"..i]:SetTextColor(1, 1, 1)
	end

	PetitionFrameInstructions:SetTextColor(1, 1, 1)

	PetitionFrameRenameButton:SetPoint("LEFT", PetitionFrameRequestButton, "RIGHT", 3, 0)
	PetitionFrameRenameButton:SetPoint("RIGHT", PetitionFrameCancelButton, "LEFT", -3, 0)
end

S:AddCallback("Petition", LoadSkin)