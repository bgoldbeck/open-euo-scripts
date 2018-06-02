dofile("FindItems.lua")

self = UO.CharID
-- Door Types
doors = {1769, 1657, 1659, 1709, 1755, 1711, 1703, 1655, 8175, 1687, 1719, 1751, 1767, 2086, 2107, 2126, 2152, 806, 822, 838, 854, 1735, 790, 1671, 1663, 8183, 1695, 1711, 1727, 1759, 1775, 2094, 2115, 2134, 2160, 814, 830, 846, 848, 864, 1743, 798, 1679, 1653, 8173, 1685, 1701, 1717, 1749, 1765, 2084, 2124, 2150, 804, 820, 836, 852, 1733, 788, 1669}

Journal = {}
 
Journal.New = function()
        local state = {}
        local mt = {__index = Journal}
        setmetatable(state,mt)
        state:Clear()
        return state
end
 
Journal.Get = function(state)
        state.ref,state.lines = UO.ScanJournal(state.ref)
        state.index = 0
        for i=0,state.lines-1 do
                local text,col = UO.GetJournal(state.lines-i-1)
                state[i+1] = "|"..tostring(col).."|"..text.."|"
        end
end
 
Journal.Next = function(state)
        if state.index == state.lines then
                state:Get()
                if state.index == state.lines then
                        return nil
                end
        end
        state.index = state.index + 1
        return state[state.index]
end
 
Journal.Last = function(state)
        return state[state.index]
end
 
Journal.Find = function(state,...)
        local arg = {...}
        if type(arg[1]) == "table" then
                arg = arg[1]
        end
        while true do
                local text = state:Next()
                if text == nil then
                        break
                end
                for i=1,#arg do
                        if string.find(text,tostring(arg[i]),1,true) ~= nil then
                                return i
                        end
                end
        end
        return nil
end
 
Journal.Wait = function(state,TimeOUT,...)
        TimeOUT = getticks() + TimeOUT
        repeat
                local result = state:Find(...)
                if result ~= nil then
                        return result
                end
                wait(1)
        until getticks() >= TimeOUT
        return nil
end
 
Journal.Clear = function(state)
        state.ref = UO.ScanJournal(0)
        state.lines = 0
        state.index = 0
end

journal = Journal:New()

List = {}
List.CreateList = function()
	local state = {}
	local mt = {__index = List}
	setmetatable(state, mt)
	state:Clear()
	return state
end

List.Push = function(state, value)
	state.index = (state.index + 1)
	state[state.index] = value
	return nil
end

List.Pop = function(state)
	state[state.index] = nil
	state.index = state.index - 1
	return nil
end

List.Top = function(state)
	return state[state.index]
end

List.Count = function(state)
	return state.index
end

List.Get = function(state, ind)
	return state[ind]
end

List.Clear = function(state)
    state.index = 0
	return nil
end

ignoretile = List:CreateList()
ignoretile:Push({X=0, Y=0, Z=0})

ignoreobject = List:CreateList()
ignoreobject:Push(0)

function WorldSaveCheck()
	local jres = journal:Find("world is saving")
	if jres ~= nil then    
		UO.ExMsg(UO.CharID, 0, 55, "World Saving..." )
		journal:Clear()
		while jres == nil do
			jres = journal:Find("save complete.")
		end     
		print("World save complete.")
		return true
	end
	return false
end

function Stop()
	stop()
end

function Exit()
	stop()
end

function Poisoned()
	local i, j = string.find("C", UO.CharStatus, 1)
    if j ~= 0 then
		return true
	end
	return false
end

function Paralyzed()
	local res = journal:Find("You cannot move!")
	if (res ~= nil) then
	    journal:Clear()
		return true
	end
	return false
end

function HeadMsg(text, col, id)
	id = id or UO.CharID
	text = text or ""
	col = col or 65
	UO.ExMsg(id, 3, col, text )
end

function Msg(text)
	text = text or ""
	UO.Macro(1, 0, text)
end

function Hits(n)
  local i,nID,nHP,_ = 0
  repeat
   _,_,_,_,_,_,nID,_,nHP = UO.GetCont(i)
   i = i + 1
  until nID==n or nID==nil
  return nHP
end

function Dead(id)
	local found = FindObject(id)
	if #found > 0 then
		if found[1].Type == 400 then
			return false
		end
	end
	return true
end

function FindTileType(tType, range)
	for x = -range, range do
		for y = -range, range do
			local tileX = UO.CharPosX + x
			local tileY = UO.CharPosY + y
			
			local nCnt = UO.TileCnt(tileX, tileY)
			local ignored = false
			for i = 1, nCnt do
				nType, tileZ, sName, nFlags = UO.TileGet(tileX, tileY, i)
				for j = 1, ignoretile:Count() do
					if ignoretile[j].X == tileX and ignoretile[j].Y == tileY and ignoretile[j].Z == tileZ then
						ignored = true
						break
					elseif nType == tType and ignored == false then
						return tileX, tileY, tileZ
					end
				end
				
			end
			if (ignored == true) then
				break
			end
		end
	end
	return nil
end

function CountType(tType, color, source)
	if (tType == nil) then return 0 end
	color = color or nil
	source = source or nil
	local count = 0
	
	t = ScanItems(false, {Type=tType, Col=color, ContID=source})
	for i = 1, #t do
		count = count + t[i].Stack
	end
		
	return count
end

function FindType(tType, color, source, amount, range)
	if (tType == nil) then return nil end
	color = color or nil
	source = source or nil
	amount = amount or 0
	range = range or 12
	
	local r = {}
	
	t = ScanItems(false, {Type=tType, Col=color, ContID=source})
	
	for i = 1, #t do
		local continue = false
		for j = 1, ignoreobject:Count() do
			if t[i].ID == ignoreobject[j] then
				continue = true
				break
			end
		end
		
		if continue == false then
			if t[i].Stack >= amount then
				if t[i].Dist ~= nil then
					if t[i].Dist <= range then
						r[(#r + 1)] = {Rep=t[i].Rep, Details=t[i].Details, Kind=t[i].Kind, Name=t[i].Name, Type=t[i].Type, ContID=t[i].ContID, ID=t[i].ID, Stack=t[i].Stack, Dist=t[i].Dist, Col=t[i].Col, X=t[i].X, Y=t[i].Y, Z=t[i].Z}
					end
				else
					r[(#r + 1)] = {Rep=t[i].Rep, Details=t[i].Details, Kind=t[i].Kind, Name=t[i].Name, Type=t[i].Type, ContID=t[i].ContID, ID=t[i].ID, Stack=t[i].Stack, Dist=t[i].Dist, Col=t[i].Col, X=t[i].X, Y=t[i].Y, Z=t[i].Z}

				end
			end
		end
	end
	
	return r
end

function MoveTypeGround(tType, source, x, y, z, color, amount, range)
	if (tType == nil or source == nil or x == nil or y == nil) then return false end
	z = z or UO.CharPosZ
	color = color or nil
	amount = amount or 1
	range = range or 2
	
	local found = FindType(tType, color, source, amount, range)
	
	if found ~= nil then
		if #found > 0 then
			UO.Drag(found[1].ID, amount)
			UO.DropG(x, y, z)
			return true
		end
	end
	return false
end

function Print(text)
	print(text)
end

function MoveItem(id, destination, x, y, amount)
	amount = amount or 60000
	
	if x == nil and y == nil then
		UO.Drag(id, amount)
		UO.DropC(destination)
	else
		UO.Drag(id, amount)
		UO.DropC(destination, x, y)
	end
	return
end

function MoveType(tType, source, destination, x, y, color, amount, range)
	if (tType == nil or source == nil or destination == nil) then return nil end
	--x = x or math.random(-200,200)
	--y = y or math.random(-200,200)
	color = color or nil
	amount = amount or nil
	range = range or 12
	
	local found = FindType(tType, color, source, amount, range)
    
	if #found > 0 then
		--print("found")
		if amount == nil then
			amount = found[1].Stack
		end
		--local other = FindType(tType, color, destination, amount, range)
		--if #other > 0 then
		--    Print("OTHER")
		--	UO.Drag(found[1].ID, amount)
		--	UO.DropC(other[1].ID)
		if x == nil and y == nil then
		    --Print("PACK")
			UO.Drag(found[1].ID, amount)
			UO.DropC(destination)
		else
		    --Print("PACK X Y")
			UO.Drag(found[1].ID, amount)
			UO.DropC(destination, x, y)
		end
		return true
	end
	
	return false
end

function FindObject(id, color, source, amount, range)
	r = {}
	if (id == nil) then return r end
	color = color or nil
	source = source or nil
	amount = amount or 1
	range = range or 12
	t = ScanItems(true,{ContID=source, ID=id, Col=color, Dist=range})
	if #t > 0 then
		r[(#r + 1)] = {Rep=t[1].Rep, Details=t[1].Details, Kind=t[1].Kind, Name=t[1].Name, Type=t[1].Type, ContID=t[1].ContID, ID=t[1].ID, Stack=t[1].Stack, Dist=t[1].Dist, Col=t[1].Col, X=t[1].X, Y=t[1].Y, Z=t[1].Z}
	end
	return r
end

function UseObject(id)
	UO.LObjectID = id
	UO.Macro(17, 0)
end

function UseType(tType, color, source, range)
	targetKind = targetKind or 1
	local found = FindType(tType, color, source, range)
	if (#found > 0) then
		UseObject(found[1].ID)
	end
end

function TargetType(tType, color, source, range, targetKind)
	if (tType == nil) then return nil end
	color = color or nil
	source = source or nil
	range = range or 12
	targetKind = targetKind or 1
	local found = FindType(tType, color, source, 0, range)
	
	if found ~= nil then
		if (#found > 0) then
			Target(found[1].ID)
		end
	end
	return nil
end

function EquipType(tType, color, source)
	local found = FindType(tType, color, source, nil, nil)
	if found ~= nil then
		if #found > 0 then
			UO.Drag(found[1].ID, 1)
			UO.DropPD()
			return true
		end
	end
	return false
end

function Target(id, targetKind)
	if (id == "Last") then
		UO.Macro(22, 0)
		return
	end
	if (id == "Self") then
		UO.Macro(23, 0)
		return
	end
	
	targetKind = targetKind or 1
	UO.LTargetID = id
	UO.LTargetKind = targetKind
	UO.Macro(22, 0)
end

function TargetTile(tType, x, y, z, targetKind)
	if (tType == nil) then return end
	x = x or 0
	y = y or 0
	z = z or o
	targetKind = targetKind or 2
	
	UO.LTargetKind = targetKind
	UO.LTargetTile = tType
	UO.LTargetX = x
	UO.LTargetY = y
	UO.LTargetZ = z
	UO.Macro(22, 0)
	return
end

function WaitForTarget(timeout)
	timeout = timeout or 3000
	local i = 0
	repeat
		if UO.TargCurs == true then
			return true
		end
		Pause(10)
		i = i + 10
	until i >= timeout
	return false
end

function Pause(time)
	wait(time)
end

function Rename(id, name)
	RenamePet(id, name)
end

function X(id)
	t = ScanItems(true, {ID=id})
	if #t > 0 then
		return t[1].X
	end
	return nil
end

function Y(id)
	t = ScanItems(true, {ID=id})
	if #t > 0 then
		return t[1].Y
	end
	return nil
end

function Z(id)
	t = ScanItems(true, {ID=id})
	if #t > 0 then
		return t[1].Z
	end
	return nil
end

function Cast(spell)
	UO.TargCurs = false
	if (spell == "Clumsy") then
		UO.Macro(15, 0)
	elseif (spell == "Create Food") then
		UO.Macro(15, 1)
	elseif (spell == "Feeblemind") then
		UO.Macro(15, 2)
	elseif (spell == "Heal") then
		UO.Macro(15, 3)
	elseif (spell == "Magic Arrow") then
		UO.Macro(15, 4)
	elseif (spell == "Night Sight") then
		UO.Macro(15, 5)
	elseif (spell == "Reactive Armor") then
		UO.Macro(15, 6)
	elseif (spell == "Weaken") then
		UO.Macro(15, 7)
	elseif (spell == "Agility") then
		UO.Macro(15, 8)
	elseif (spell == "Cunning") then
		UO.Macro(15, 9)
	elseif (spell == "Cure") then
		UO.Macro(15, 10)
	elseif (spell == "Harm") then
		UO.Macro(15, 11)
	elseif (spell == "Magic Trap") then
		UO.Macro(15, 12)
	elseif (spell == "Magic Untrap") then
		UO.Macro(15, 13)
	elseif (spell == "Protection") then
		UO.Macro(15, 14)
	elseif (spell == "Strength") then
		UO.Macro(15, 15)
	elseif (spell == "Bless") then
		UO.Macro(15, 16)
	elseif (spell == "Fireball") then
		UO.Macro(15, 17)
	elseif (spell == "Magic Lock") then
		UO.Macro(15, 18)
	elseif (spell == "Poison") then
		UO.Macro(15, 19)
	elseif (spell == "Telekinesis") then
		UO.Macro(15, 20)
	elseif (spell == "Teleport") then
		UO.Macro(15, 21)
	elseif (spell == "Unlock") then
		UO.Macro(15, 22)
	elseif (spell == "Wall Of Stone") then
		UO.Macro(15, 23)
	elseif (spell == "Arch Cure") then
		UO.Macro(15, 24)
	elseif (spell == "Arch Protection") then
		UO.Macro(15, 25)
	elseif (spell == "Curse") then
		UO.Macro(15, 26)
	elseif (spell == "Fire Field") then
		UO.Macro(15, 27)
	elseif (spell == "Greater Heal") then
		UO.Macro(15, 28)
	elseif (spell == "Lightning") then
		UO.Macro(15, 29)
	elseif (spell == "Mana Drain") then
		UO.Macro(15, 30)
	elseif (spell == "Recall") then
		UO.Macro(15, 31)
	elseif (spell == "Blade Spirits") then
		UO.Macro(15, 32)
	elseif (spell == "Dispel Field") then
		UO.Macro(15, 33)
	elseif (spell == "Incognito") then
		UO.Macro(15, 34)
	elseif (spell == "Magic Reflection") then
		UO.Macro(15, 35)
	elseif (spell == "Mind Blast") then
		UO.Macro(15, 36)
	elseif (spell == "Paralyze") then
		UO.Macro(15, 37)
	elseif (spell == "Poison Field") then
		UO.Macro(15, 38)
	elseif (spell == "Summon Creature") then
		UO.Macro(15, 39)
	elseif (spell == "Dispel") then
		UO.Macro(15, 40)
	elseif (spell == "Energy Bolt") then
		UO.Macro(15, 41)
	elseif (spell == "Explosion") then
		UO.Macro(15, 42)
	elseif (spell == "Invisibility") then
		UO.Macro(15, 43)
	elseif (spell == "Mark") then
		UO.Macro(15, 44)
	elseif (spell == "Mass Curse") then
		UO.Macro(15, 45)
	elseif (spell == "Paralyze Field") then
		UO.Macro(15, 46)
	elseif (spell == "Reveal") then
		UO.Macro(15, 47)
	elseif (spell == "Chain Lightning") then
		UO.Macro(15, 48)
	elseif (spell == "Energy Field") then
		UO.Macro(15, 49)
	elseif (spell == "Flame Strike") then
		UO.Macro(15, 50)
	elseif (spell == "Gate Travel") then
		UO.Macro(15, 51)
	elseif (spell == "Mana Vampire") then
		UO.Macro(15, 52)
	elseif (spell == "Mass Dispel") then
		UO.Macro(15, 53)
	elseif (spell == "Meteor Swarm") then
		UO.Macro(15, 54)
	elseif (spell == "Polymorph") then
		UO.Macro(15, 55)
	elseif (spell == "Earthquake") then
		UO.Macro(15, 56)
	elseif (spell == "Energy Vortex") then
		UO.Macro(15, 57)
	elseif (spell == "Resurrection") then
		UO.Macro(15, 58)
	elseif (spell == "Air Elemental") then
		UO.Macro(15, 59)
	elseif (spell == "Summon Daemon") then
		UO.Macro(15, 60)
	elseif (spell == "Earth Elemental") then
		UO.Macro(15, 61)
	elseif (spell == "Fire Elemental") then
		UO.Macro(15, 62)
	elseif (spell == "Water Elemental") then
		UO.Macro(15, 63)
	
	
	end

end

function UseSkill(skill)
	if skill == "Anatomy" then
		UO.Macro(13, 1)
	elseif skill == "Animal Lore" then
		UO.Macro(13, 2)
	elseif skill == "Animal Taming" then
		UO.Macro(13, 35)
	elseif skill == "Arms Lore" then
		UO.Macro(13, 4)		
	elseif skill == "Begging" then
		UO.Macro(13, 6)		
	elseif skill == "Cartography" then
		UO.Macro(13, 12)		
	elseif skill == "Detecting Hidden" then
		UO.Macro(13, 14)		
	elseif skill == "Discordance" then
		UO.Macro(13, 15)		
	elseif skill == "Evaluating Intelligence" then
		UO.Macro(13, 16)		
	elseif skill == "Forensic Evaluation" then
		UO.Macro(13, 19)		
	elseif skill == "Hiding" then
		UO.Macro(13, 21)		
	elseif skill == "Inscription" then
		UO.Macro(13, 23)		
	elseif skill == "Item Identification" then
		UO.Macro(13, 3)		
	elseif skill == "Meditation" then
		UO.Macro(13, 46)		
	elseif skill == "Peacemaking" then
		UO.Macro(13, 9)		
	elseif skill == "Poisoning" then
		UO.Macro(13, 30)		
	elseif skill == "Provocation" then
		UO.Macro(13, 22)		
	elseif skill == "Remove Trap" then
		UO.Macro(13, 48)		
	elseif skill == "Spirit Speak" then
		UO.Macro(13, 32)		
	elseif skill == "Stealing" then
		UO.Macro(13, 33)		
	elseif skill == "Stealth" then
		UO.Macro(13, 47)		
	elseif skill == "Taste Identification" then
		UO.Macro(13, 36)		
	elseif skill == "Tracking" then
		UO.Macro(13, 38)		
	elseif skill == "Last Skill" then
		UO.Macro(14, 0)		
	elseif skill == "Last" then
		UO.Macro(14, 0)	
	end
end

function Run(direction)
	if direction == "Northeast" then
		UO.Macro(5, 2)
	elseif direction == "Northwest" then
		UO.Macro(5, 0)
	elseif direction == "Southeast" then
		UO.Macro(5, 4)
	elseif direction == "Southwest" then
		UO.Macro(5, 6)
	elseif direction == "East" then	
		UO.Macro(5, 3)
	elseif direction == "West" then
		UO.Macro(5, 7)
	elseif direction == "North" then
		UO.Macro(5, 1)
	elseif direction == "South" then
		UO.Macro(5, 5)
	end
end

function WaitForContKind(kind, timeout)
	timeout = getticks() + timeout
	repeat
		if UO.ContKind == kind then
			return true
		end
	until getticks() >= timeout
	return false
end



function YesNoBox(default, prompt, title)
	-- Function By Traegon's, Link: http://www.easyuo.com/forum/viewtopic.php?p=376784#376784
	if icon == nil then icon = 2 end
	if default == true then default = 1 else default = 0 end

	ConfirmDialog = Obj.Create("TMessageBox")
	ConfirmDialog.Title = title
	ConfirmDialog.Button = 4
	ConfirmDialog.Icon = icon
	ConfirmDialog.Default = default
	local ret = ConfirmDialog.Show(prompt)
	if ret == 6 then
	    --Yes was clicked.
		return true
	end
	return false
end