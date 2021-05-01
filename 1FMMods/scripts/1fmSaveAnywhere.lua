local offset = 0x3A0606
local lasttitle = 0
local addgummi = 0
local lastInput = 0
local revertCode = false
local removeWhite = 0
local soraHUD = 0x280EB1C - offset
local soraHP = 0x2D592CC - offset
local stateFlag = 0x2863958 - offset
local deathCheck = 0x297730 - offset
local whiteFade = 0x233C49C - offset
local deathScreenPointer = 0x23944B8 - offset

function _OnInit()

end

function _OnFrame()
	local input = ReadInt(0x233D034-offset)
	local savemenuopen = ReadByte(0x232A604-offset)
	
	if input == 1793 and savemenuopen~=4 then 
		WriteByte(0x2350CD4-offset, 0x1)
		addgummi = 5
	end
	
	-- Remove white screen on death (it bugs out this way normally)
	if removeWhite > 0 then
		removeWhite = removeWhite - 1
		if ReadByte(whiteFade) == 128 then
			WriteByte(whiteFade, 0)
		end
	end
	
	-- Reverts disabling death condition check (or it crashes)
	if revertCode and ReadLong(deathScreenPointer) == 0x7FF7292F7980 then
		WriteShort(deathCheck, 0x2E74)
		removeWhite = 1000
		revertCode = false
	end
	
	-- R1 R2 L2 Select
	-- Sora HP to 0 (not necessary)
	-- State to combat
	-- Death condition check disable
	if input == 2817 and ReadFloat(soraHUD) > 0 and ReadByte(soraHP) > 0 then
		WriteByte(soraHP, 0)
		WriteByte(stateFlag, 1)
		WriteShort(deathCheck, 0x9090)
		revertCode = true
	end
	
	if savemenuopen == 4 and addgummi==1 then
		WriteByte(0x2E1CC28-offset, 3) --Unlock gummi
		WriteByte(0x2E1CB9C-offset, 5) --Set 5 buttons to save menu
		WriteByte(0x2E8F450-offset, 5) --Set 5 buttons to save menu
		WriteByte(0x2E8F452-offset, 5) --Set 5 buttons to save menu
		for i=0,4 do
			WriteByte(0x2E1CBA0+i*4-offset, i) --Set button types
		end
	end
	
	addgummi = addgummi > 0 and addgummi-1 or addgummi
	
	local titletest = ReadInt(0x7A8EE8-offset)
	if titletest == 0 and lasttitle ~= 0 then 
		print("Remember to type 'reload' after restarting or going to title screen")
	end
	lasttitle = titletest
	lastInput = input
end