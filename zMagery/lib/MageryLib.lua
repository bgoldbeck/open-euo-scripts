dofile("FindItems.lua")


bloodmossType    = 3963
blackPearlType   = 3962
mandrakeRootType = 3974
spiderSilkType   = 3981
sulfAshType      = 3980
nightShadeType   = 3976

bandageType      = 3617

fireball         = 17
manaDrain        = 30
lightning        = 29
energyBolt       = 41
invisibility     = 43
manaVampire      = 52
flamestrike      = 50

 journal = {}
journal.new = function()
        local state = {}
        local mt = {__index = journal}
        setmetatable(state,mt)
        state:clear()
        return state
end

journal.get = function(state)
        state.ref,state.lines = UO.ScanJournal(state.ref)
        state.index = 0
        for i=0,state.lines-1 do
                local text,col = UO.GetJournal(state.lines-i-1)
                state[i+1] = "|"..tostring(col).."|"..text.."|"
        end
end

journal.next = function(state)
        if state.index == state.lines then
                state:get()
                if state.index == state.lines then
                        return nil
                end
        end
        state.index = state.index + 1
        return state[state.index]
end

journal.last = function(state)
        return state[state.index]
end

journal.find = function(state,...)
        local arg = {...}
        if type(arg[1]) == "table" then
                arg = arg[1]
        end
        while true do
                local text = state:next()
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

journal.wait = function(state,TimeOUT,...)
        TimeOUT = getticks() + TimeOUT
        repeat
                local result = state:find(...)
                if result ~= nil then
                        return result
                end
                wait(1)
        until getticks() >= TimeOUT
        return nil
end

journal.clear = function(state)
        state.ref = UO.ScanJournal(0)
        state.lines = 0
        state.index = 0
end

function GetHP(n)
  local i,nID,nHP,_ = 0
  repeat
   _,_,_,_,_,_,nID,_,nHP = UO.GetCont(i)
   i = i + 1
  until nID==n or nID==nil
  return nHP
end

function FindItemID(tType, cont)
    local id = 0
	local itemList = ScanItems(false)
	local t = FindItems(itemList,{Type=tType, ContID=cont})
	for i = 1, #t do
	   id = t[i].ID
	   break
	end
	return id
end

function UseObjectByType(tType, source)
	local itemList = ScanItems(false)
	local t = FindItems(itemList,{Type=tType, ContID=source})
	if #t == 0 then
	    return false
	end
	for i = 1, #t do
		UO.LObjectID = t[i].ID
		UO.Macro(17, 0)
		wait(700)
		break
	end
	return true
end

function MoveStackByType(tType, source, dest)
	local itemList = ScanItems(false)
	local t = FindItems(itemList,{Type=tType, ContID=source})
	if #t == 0 then
	    print("Couldn't find item stack!")
	    return
	end
	for i = 1, #t do
		wait(700)
		print("dropping to container: " .. dest)
		local idOfTypeInDest = FindItemID(tType, dest)
		if  idOfTypeInDest ~= 0 then
			UO.Drag(t[i].ID, t[i].Stack)
			wait(1)
			UO.DropC(idOfTypeInDest)
		else
			UO.Drag(t[i].ID, t[i].Stack)
			wait(1)
			UO.DropC(dest)
		end
		wait(700)
		break
	end
	return true
end

function TargetSelf()
	UO.Macro(23, 0)
end

function CastManaVampire()
   UO.Macro(15, 52)
end

function Meditate()
    UO.Macro(13, 46)
end

function Target(id)
	for i = 1, 100 do
		wait(100)
		if UO.TargCurs == true then
			break
		end
	end
	UO.LTargetID = id
	UO.LTargetKind = 1
	UO.Macro(22, 0)
end

function GetCountOfItemOnSelf(itemType)
	local count = 0
	t = ScanItems(true,{ Type=itemType, ContID=UO.BackpackID})
	for i=1, #t do
		count = count + t[i].Stack
	end
	return count
end

function GetIDOfItemOnSelf(itemType)
    local id = 0
	t = ScanItems(true,{ Type=itemType, ContID=UO.BackpackID})
	for i=1, #t do
		id = t[i].ID
	end
	return id
end

function RestockStackableItem(bagID, tType, rCnt)
	local regDropX = 200
	local regDropY = 200
	local itemList = ScanItems(false)
	local t = FindItems(itemList,{Type=tType, ContID=bagID}, {ContID=UO.BackpackID})
	if #t == 0 then
		local continue = false
		for i = 1, 9 do
			wait(3000)
			if i == 2 then
				UO.Macro(1, 0, "Bank")
				UO.LObjectID = bagID
				wait(800)
				UO.Macro(17, 0)
				wait(800)
			end
			print("Checking again for reagent..")
			itemList = ScanItems(false)
			t = FindItems(itemList,{Type=tType, ContID=bagID}, {ContID=UO.BackpackID})
			if #t > 0 then
				continue = true
				break
			end
		end
		if continue == false then
			print("Could not find item to restock")
			stop()
		end

	end
	for i = 1, #t do
		local nRegOnSelf = GetCountOfItemOnSelf(tType)

		if nRegOnSelf > rCnt then
			print("We have too much of a reg on hand!")
			MoveStackByType(tType, UO.BackpackID, bagID)
		end
		--Recount!
		nRegOnSelf = GetCountOfItemOnSelf(tType)
		if nRegOnSelf < rCnt then
			local restockCnt = rCnt - nRegOnSelf
			UO.SysMessage("  --Restocked: ".. restockCnt.."   -"..tType.. " Type.", 30)
			if nRegOnSelf == 0 then
				UO.Drag(t[i].ID, restockCnt)
				UO.DropC(UO.BackpackID, regDropX, regDropY)
			else
				UO.Drag(t[i].ID, restockCnt)
				UO.DropC(GetIDOfItemOnSelf(tType))
			end
			break
		else
			UO.SysMessage("We have enough already.", 30)
		end
	end
end

function CastSpell(isMed, spell, rCnt, targetID, containerID)
    UO.LTargetKind = 1
	while UO.Mana < UO.MaxMana do
		if UO.Mana > 40 then
			break
		end
		Meditate()
		wait(1000) 
    end
	if spell == fireball then
		RestockReagent(containerID, rCnt, blackPearlType)
	end
	-- Mana Drain fourth circle
	if spell == manaDrain then
		RestockReagent(containerID, rCnt, mandrakeRootType)
		RestockReagent(containerID, rCnt, spiderSilkType)
		RestockReagent(containerID, rCnt, blackPearlType)
	end
	
	if spell == lightning then
		RestockReagent(containerID, rCnt, mandrakeRootType)
		RestockReagent(containerID, rCnt, sulfAshType)
	end
	
	-- Invisibility sixth circle
	if spell == invisibility then
		RestockReagent(containerID, rCnt, bloodmossType)
		RestockReagent(containerID, rCnt, nightShadeType)
		UO.SysMessage("Casting Spell.", 65)
		UO.Macro(15, invisibility)
		Target(UO.CharID) --Cast this on self only
		return
	end
	
	if spell == energyBolt then
		RestockReagent(containerID, rCnt, blackPearlType)
		RestockReagent(containerID, rCnt, nightShadeType)

	end
	
	if spell == flamestrike then 
		RestockReagent(containerID, rCnt, sulfAshType)
		RestockReagent(containerID, rCnt, spiderSilkType)
	end
	
	if spell == manaVampire then
		RestockReagent(containerID, rCnt, bloodmossType)
		RestockReagent(containerID, rCnt, blackPearlType)
		RestockReagent(containerID, rCnt, mandrakeRootType)
		RestockReagent(containerID, rCnt, spiderSilkType)
	end
	
	UO.SysMessage("Casting Spell.", 65)
	UO.Macro(15, spell)
	Target(targetID)
	return
end

function RestockReagent(cont, cnt, type)
	while GetCountOfItemOnSelf(type) < 1 do
		RestockStackableItem(cont, type, cnt)
		wait(720)
	end	
end

function BandageSelf(containerID)
	local itemList = ScanItems(false)
	local t = FindItems(itemList,{Type=bandageType, ContID=UO.BackpackID})
	if #t == 0 then
	    RestockStackableItem(containerID, bandageType, 1)
	end

	UO.SysMessage("Bandaging self.", 55)
	itemList = ScanItems(false)
	t = FindItems(itemList,{Type=bandageType, ContID=UO.BackpackID})
	for i = 1, #t do
	    UO.LObjectID = t[i].ID
		UO.Macro(17, 0)
		wait(100)
		for i = 1, 100 do
		    wait(100)
			if UO.TargCurs == true then
		        break
			end
		end
		UO.LTargetID = UO.CharID
		UO.LTargetKind = 1
		UO.Macro(22, 0)
		break
	end
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

function FindOBjectByType(tType, source)
	local itemList = ScanItems(false)
	local ret = nil
	local t = FindItems(itemList,{Type=tType, ContID=source})
	if #t == 0 then
	    return ret
	end
	for i = 1, #t do
		ret = t[i].ID
		break
	end
	return ret
end


function UseObjectByID(id, source)
	local itemList = ScanItems(false)
	local t = FindItems(itemList,{ID=id, ContID=source})
	if #t == 0 then
	    return false
	end
	for i = 1, #t do
		UO.LObjectID = t[i].ID
		UO.Macro(17, 0)
		wait(700)
		break
	end
	return true
end


function EatFood(contID)
	print("Eating Food!")
	UO.LTargetKind = 1
	UseObjectByID(FindOBjectByType(2452, contID), contID) --Pears
	UseObjectByID(FindOBjectByType(2512, contID), contID) --Apples 
	UseObjectByID(FindOBjectByType(5640, contID), contID) --Chicken Legs 
	--if UseObjectByID(FindOBjectByType(4086, contID), contID) then --Fill Water 
		--Target(FindOBjectByType(2881, nil))
		--wait(1500)
	--end
	--UseObjectByID(FindOBjectByType(8093, contID), contID) --Drink Water
	--Target(UO.CharID)
	
end
