dofile("FindItems.lua")


bloodmossType    = 3963
blackPearlType   = 3962
mandrakeRootType = 3974
spiderSilkType   = 3981

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

function TargetSelf()
	UO.Macro(23, 0)
end

function CastManaVampire()
   UO.Macro(15, 52)
end

function Meditate()
    UO.Macro(13, 46)
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

function RestockManaVampireRegs(regBagID, rCnt)
	local regDropX = 200
	local regDropY = 200
	--Spider Silk
	local itemList = ScanItems(false)
	local t = FindItems(itemList,{Type=spiderSilkType, ContID=regBagID}, {ContID=UO.BackpackID})
	for i = 1, #t do
		local nSpiderSilkOnSelf = GetCountOfItemOnSelf(spiderSilkType)
		if nSpiderSilkOnSelf < rCnt then
			local restockCnt = rCnt - nSpiderSilkOnSelf
			UO.SysMessage("  --Restocked: ".. restockCnt.." Spider Silk.", 30)
			if nSpiderSilkOnSelf == 0 then
				UO.Drag(t[i].ID, restockCnt)
				UO.DropC(UO.BackpackID, regDropX, regDropY)
			else
				UO.Drag(t[i].ID, restockCnt)
				UO.DropC(GetIDOfItemOnSelf(spiderSilkType))
			end
			wait(700)
		else
			UO.SysMessage("We have enough Spider Silk already.", 30)
		end
	end
	--Mandrake
	t = FindItems(itemList,{Type=mandrakeRootType, ContID=regBagID}, {ContID=UO.BackpackID})
	for i = 1, #t do
		local nMandrakeRootOnSelf = GetCountOfItemOnSelf(mandrakeRootType)
		if nMandrakeRootOnSelf < rCnt then
			local restockCnt = rCnt - nMandrakeRootOnSelf
			UO.SysMessage("  --Restocked: ".. restockCnt.." Mandrake Root.", 30)
			if nMandrakeRootOnSelf == 0 then
				UO.Drag(t[i].ID, restockCnt)
				UO.DropC(UO.BackpackID, regDropX, regDropY)
			else
				UO.Drag(t[i].ID, restockCnt)
				UO.DropC(GetIDOfItemOnSelf(mandrakeRootType))
			end
			wait(700)
		else
			UO.SysMessage("We have enough Mandrake Root already.", 30)
		end
	end
	--Black Pearl
	t = FindItems(itemList,{Type=blackPearlType, ContID=regBagID}, {ContID=UO.BackpackID})
	for i = 1, #t do
		local nBlackPearlOnSelf = GetCountOfItemOnSelf(blackPearlType)
		if nBlackPearlOnSelf < rCnt then
			local restockCnt = rCnt - nBlackPearlOnSelf
			UO.SysMessage("  --Restocked: ".. restockCnt.." Black Pearl.", 30)
			if nBlackPearlOnSelf == 0 then
				UO.Drag(t[i].ID, restockCnt)
				UO.DropC(UO.BackpackID, regDropX, regDropY)
			else
				UO.Drag(t[i].ID, restockCnt)
				UO.DropC(GetIDOfItemOnSelf(blackPearlType))
			end
			wait(700)
		else
			UO.SysMessage("We have enough Black Pearl already.", 30)
		end
	end
	--Bloodmoss
	t = FindItems(itemList,{Type=bloodmossType, ContID=regBagID}, {ContID=UO.BackpackID})
	for i = 1, #t do
		local nBloodmossOnSelf = GetCountOfItemOnSelf(bloodmossType)
		if nBloodmossOnSelf < rCnt then
			local restockCnt = rCnt - nBloodmossOnSelf
			UO.SysMessage("  --Restocked: ".. restockCnt.." Bloodmoss.", 30)
			if nBloodmossOnSelf == 0 then
				UO.Drag(t[i].ID, restockCnt)
				UO.DropC(UO.BackpackID, regDropX, regDropY)
			else
				UO.Drag(t[i].ID, restockCnt)
				UO.DropC(GetIDOfItemOnSelf(bloodmossType))
			end
			wait(700)
		else
			UO.SysMessage("We have enough Bloodmoss already.", 30)
		end
	end
end
