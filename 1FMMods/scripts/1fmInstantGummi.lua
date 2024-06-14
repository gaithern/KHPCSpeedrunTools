LUAGUI_NAME = "1fmInstantGummi"
LUAGUI_AUTH = "denhonator"
LUAGUI_DESC = "Instantly arrive at gummi destination"

local offset = 0x3A0606
local worldWarpBase = 0x50ECD0
local cutsceneFlagBase = 0x2DE9F60-0x200 - offset
--local djProgressFlag = 0x2DE79D0+0x6C+0x40 UNUSED
--local neverlandProgressFlag = 0x2DE79D0+0x6C+0xED UNUSED

local canExecute = false

function _OnInit()
	if GAME_ID == 0xAF71841E and ENGINE_TYPE == "BACKEND" then
		canExecute = true
		ConsolePrint("KH1 detected, running script")
	else
		ConsolePrint("KH1 not detected, not running script")
	end
end

function _OnFrame()
	if not canExecute then
		goto done
	end

	local selection = ReadInt(0x50707C-offset)
	local realSelection = selection
	local realWorld = ReadByte(0x506F94-offset)
	local soraWorld = ReadByte(0x233FE84-offset)
	local room = ReadByte(0x233FE8C-offset)
	
	local monstroOpen = ReadByte(0x2DEB25A-offset) > 1
	local neverlandState = ReadByte(cutsceneFlagBase+0xB0D) < 0x14
	local deepJungleState = ReadByte(cutsceneFlagBase+0xB05) < 0x10

	WriteByte(worldWarpBase+0x2A-offset, deepJungleState and 0 or 0xE)
	WriteByte(worldWarpBase+0x2C-offset, deepJungleState and 0 or 0x2D)
	WriteByte(worldWarpBase+0x9A-offset, neverlandState and 6 or 0x7)
	WriteByte(worldWarpBase+0x9C-offset, neverlandState and 0x18 or 0x25)

	if room > 0 and soraWorld ~= selection then
		WriteInt(0x50707C-offset, soraWorld)
	end
	
	-- Replace HT and Atlantica with Monstro at first
	if not monstroOpen and (selection == 10 or selection == 9) then
		selection = selection == 9 and 18 or 17
		--WriteInt(0x503CEC-offset, selection)
	end
	-- Change warp to Hollow Bastion
	if selection == 25 then 
		selection = 15
		WriteInt(0x50707C-offset, selection)
	end
	-- Change warp to Agrabah
	if selection == 21 then
		selection = 8
		WriteInt(0x50707C-offset, selection)
	end
	
	-- Go directly to location
	local curDest = ReadInt(0x507580-offset)
	if curDest < 40 then
		selection = selection > 20 and 0 or selection
		WriteInt(0x507580-offset, selection)
		WriteInt(0x506F90-offset, selection)
		WriteInt(0x268987C-offset, 0)
	else
		WriteInt(0x506F90-offset, realSelection)
	end
	
	::done::
end