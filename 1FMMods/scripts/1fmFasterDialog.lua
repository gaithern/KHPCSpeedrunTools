LUAGUI_NAME = "1fmFasterDialog"
LUAGUI_AUTH = "denhonator (edited by deathofall84)"
LUAGUI_DESC = "Speeds up text boxes"

local lastProg = 0
local textSpeedup = false
local turbo = false

local canExecute = false
local posDebugString = 0x3EB158

function _OnInit()
	if GAME_ID == 0xAF71841E and ENGINE_TYPE == "BACKEND" then
		canExecute = true
		ConsolePrint("KH1 detected, running script")
		if ReadByte(posDebugString) == 0x58 then
			vars = require("EpicGamesGlobal")
		elseif ReadByte(posDebugString - 0x1020) == 0x58 then
			vars = require("EpicGamesJP")
		elseif ReadByte(posDebugString - 0xE40) == 0x58 then
			vars = require("SteamGlobal") -- Global and JP equal
		end
	else
		ConsolePrint("KH1 not detected, not running script")
	end
end

function _OnFrame()
	if canExecute then
		WriteFloat(vars.textTrans, 0) --finishes box transitions
		if ReadShort(vars.textProg) > lastProg and lastProg > 0 and textSpeedup then --1 frame turbo
			WriteFloat(vars.textSpeed, 100.0)
			turbo = true
		elseif turbo then
			WriteFloat(vars.textSpeed, 1.0)
		end
		lastProg = ReadShort(vars.textProg)
	end
end