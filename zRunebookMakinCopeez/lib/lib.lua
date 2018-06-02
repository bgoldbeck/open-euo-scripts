dofile("FindItems.lua")

runebookType = 8901
runeType     = 7956
 
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

j = journal:new()

function GetIDOfItemOnSelf(itemType)	
    local id = 0
	t = ScanItems(true,{ Type=itemType, ContID=UO.BackpackID})
	for i=1, #t do
		id = t[i].ID
	end	
	return id
end

function GetCountOfItemOnSelf(itemType)
	local count = 0
	t = ScanItems(true,{ Type=itemType, ContID=UO.BackpackID})
	for i=1, #t do
		count = count + t[i].Stack
	end	
	return count
end

function GetCurrentRuneCount()
	local count = 0
	t = ScanItems(true,{ Type=runeType, ContID=UO.BackpackID})
	for i=1, #t do
		count = count + t[i].Stack
	end	
	return count
end

function GetCurrentRunebookCount()
	local count = 0
	t = ScanItems(true,{ Type=runebookType, ContID=UO.BackpackID})
	for i=1, #t do
		count = count + 1
	end	
	return count
end

function SetTarget(msg)
	UO.TargCurs = false
	UO.TargCurs = true
	UO.SysMessage(msg, 75)
	while UO.TargCurs == true do
		wait(1)          
	end
	return UO.LTargetID
end

function RestockRunes(contID)
	UO.SysMessage("Restocking Runes...", 55)
	UO.LObjectID = contID
	UO.Macro(17, 0)
	wait(700)
	local itemList = ScanItems(false)
	local t = FindItems(itemList,{Type=runeType, ContID=contID}, {ContID=UO.BackpackID})
	for i = 1, #t do
		local nRunesOnSelf = GetCountOfItemOnSelf(runeType)
		if nRunesOnSelf < 16 then
			print("Taking Rune.")
			UO.Drag(t[i].ID, 1)
			UO.DropC(UO.BackpackID, 125, 0)
			wait(700)
		else
			print("We have enough Runes already.")
			break
		end
	end
end

function RestockStackableItem(itemType, count, contID)
	UO.LObjectID = contID
	UO.Macro(17, 0)
	wait(700)
    local itemList = ScanItems(false)
	local t = FindItems(itemList,{Type=itemType, ContID=contID}, {ContID=UO.BackpackID})
	for i = 1, #t do
		local nItemsOnSelf = GetCountOfItemOnSelf(itemType)
		if nItemsOnSelf < count then
			local restockCnt = count - nItemsOnSelf
			print("Restocked: ".. restockCnt.." ItemType: " .. itemType)
			if nItemsOnSelf == 0 then
				UO.Drag(t[i].ID, restockCnt)
				UO.DropC(UO.BackpackID, 200, 200)
			else
				UO.Drag(t[i].ID, restockCnt)
				UO.DropC(GetIDOfItemOnSelf(itemType))
			end
			wait(900)
		else
			print("We have enough of that item already.")
		end
	end    
end

function OffsetGumpClick(x, y, kind, dbl)
	dbl = dbl or false
	for i = 1, 30 do
	    wait(100)
		if UO.ContKind == kind then
		    --Click the position.
			UO.Click(math.abs(UO.ContPosX + x), math.abs(UO.ContPosY + y), true, true, true, false)
			if dbl == true then
				wait(20)
				UO.Click(math.abs(UO.ContPosX + x), math.abs(UO.ContPosY + y), true, true, true, false)
			end
			return true
		end
	end
	return false
end

function WorldSaveCheck(jrnl)
    local jres = jrnl:find("world is saving")
    if jres ~= nil then    
        UO.ExMsg(UO.CharID, 0, 55, "World Saving..." )  
        print("World is saving.")
        jrnl:clear()
        jres = jrnl:find("save complete")
        while jres == nil do
            jres = jrnl:find("save complete")
            wait(500)
        end     
        print("World save complete.")

    end
end

function LocationBlockedChecked(jrnl)
    local jres = jrnl:find("location")
    if jres ~= nil then    
		return true
    end
	return false
end

function MarkRune()
	wait(1000)
    local rID = nil
	local spellbookID = nil
    local itemList = ScanItems(true)
	local t = FindItems(itemList,{Type=runeType, ContID=UO.BackpackID})
	for i = 1, #t do
	    if t[i].Type == runeType then
			rID = t[i].ID
			break
		end
	end	

	while UO.Mana < 40 do
		wait(1000)
		UO.Macro(13, 46) --Meditation
	end

	UO.Macro(15, 44)
	while UO.TargCurs == false do
		wait(100)
	end
	UO.LTargetID = rID
	UO.LTargetKind = 1
	wait(10)
	UO.Macro(22, 0)
	wait(100)
	return rID
end

function DragRuneToRunebook(runeID, runebookID)
	UO.Drag(runeID, 1)
    UO.DropC(runebookID)
	wait(1000)
end

function RenameRune(runeID, name)
    UO.LObjectID = runeID
	UO.Macro(17, 0)
	wait(1600)
	UO.Msg(name .. string.char(13))
	wait(1000)
end

function RecallToSpot(runebookID, spot, right)
	local xPageClick = 0
    if spot > 3 then
	    xPageClick = spot * 35 + 175
	else
	    xPageClick = spot * 35 + 140 
	end
	
	local runeBookContKind = 4756
	local xRecallClick = 155
	if right == 1 then
	    xRecallClick = 315
	end

	UO.LObjectID = runebookID
	UO.Macro(17, 0)
	wait(1000)
	while UO.ContKind ~= runeBookContKind do
	    UO.LObjectID = runebookID
		UO.Macro(17, 0)
		wait(1000)
	end
	while UO.Mana < 12 do
	    wait(1000)
	end
	--Click page
    if OffsetGumpClick(xPageClick, 200, runeBookContKind) == true then
	    wait(250)
	    --Click recall
	    if OffsetGumpClick(xRecallClick, 160, runeBookContKind) == true then
		    wait(250)
	        return true
		end
	end
	return false
end