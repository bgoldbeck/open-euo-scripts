dofile("FindItems.lua")
--local to =getticks() + 4000 -- wait up to 4s
--while getticks() < to do
  --if UO.TargCurs == false then break end
  --wait(1)
--end
--function finddist(x,y)
  --dx = math.abs(UO.CharPosX - x)
  --dy = math.abs(UO.CharPosY - y)
  --return math.max(dx, dy)
--end

--Doors


--Others
goldType         = 3821
meatType         = 2545
bandageType      = 3617
bloodmossType    = 3963
blackPearlType   = 3962
mandrakeRootType = 3974
garlicType       = 3972
ginsengType      = 3973
sulfAshType      = 3980
spiderSilkType   = 3981
nightshadeType   = 3976
curePotType      = 3847
strPotType       = 3849
refreshPotType   = 3851
healPotType      = 3852
exploPotType     = 3853
agilPotType      = 3848
pouchType        = 3705
daggerType       = 3922
--/Others

--Timers
healPotionReuseTimer = 0
itemReuseTimer       = 0
healPotionDelay = 10250   --milliseconds

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

Restock = {}
Restock_mt = { __index = restock }

function Restock:new(meatCnt, aidsCnt, regsCnt, pouchesCnt, strCnt, agilCnt, cureCnt, healCnt, exploCnt, refCnt, healPotBagID, curePotBagID, exploPotBagID, pouchesBagID, generalBagID, refPotBagID, strPotBagID, agilPotBagID )
   return setmetatable( { meatCnt=meatCnt, aidsCnt=aidsCnt, regsCnt=regsCnt, pouchesCnt=pouchesCnt, strCnt=strCnt, agilCnt=agilCnt, cureCnt=cureCnt, healCnt=healCnt, exploCnt=exploCnt, refCnt=refCnt,
						 healPotBagID=healPotBagID, curePotBagID=curePotBagID, exploPotBagID=exploPotBagID, pouchesBagID=pouchesBagID, generalBagID=generalBagID, refPotBagID=refPotBagID, strPotBagID=strPotBagID, agilPotBagID=agilPotBagID } , Restock_mt )
end

function CheckContainerInRange(contID)    		
	local itemList = ScanItems(false)
	local t = FindItems(itemList,{ID=contID}, {ContID=UO.BackpackID})
    for i = 1, #t do
	    if t[i].Kind ~= nil then
			if t[i].Kind == 1 then  --Cont on ground
				if t[i].Dist < 3 then
					return true
				end
			end
			if t[i].Kind == 0 then
			    return true
			end
		end
    end
	return false
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

function ExistsFile(path)
    local x, e = openfile(path, 'r')
    if x == nil then
        return false
    else
        x:close()
        return true
    end
end

function TheBigRestock(restock)
	
	--Meat
	UO.ExMsg(UO.CharID, 0, 55, "Restocking!" )
	if restock.meatCnt > 0 then
		UO.SysMessage("Restocking Meat...", 55)
		print("Restocking Meat...")
		UO.LObjectID = restock.generalBagID
		UO.Macro(17, 0)
	    wait(700)
		local itemList = ScanItems(false)
		--Ignore items in backpack (itemsList, True filter, False filter)
		--meat
		
		local t = FindItems(itemList, {Type=meatType, ContID=restock.generalBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
			local nMeatOnSelf = GetCountOfItemOnSelf(meatType)
			if nMeatOnSelf < restock.meatCnt then
				local restockCnt = restock.meatCnt - nMeatOnSelf
				print("Restocked: ".. restockCnt.." Meat.") 
		        UO.SysMessage("  --Restocked: ".. restockCnt.." Meat.", 30)
				local meatDropX = 0
				local meatDropY = 90
				if nMeatOnSelf == 0 then
					UO.Drag(t[i].ID, restockCnt)
					UO.DropC(UO.BackpackID, meatDropX, meatDropY)
				else
					UO.Drag(t[i].ID, restockCnt)
					UO.DropC(GetIDOfItemOnSelf(meatType))
				end
				wait(700)
				
			else
				print("We have enough Meat already")
			end
		end
	end
    --Bandages   
	if restock.aidsCnt > 0 then
		UO.SysMessage("Restocking Bandages...", 55)
		print("Restocking Bandages...")
		UO.LObjectID = restock.generalBagID
		UO.Macro(17, 0)
	    wait(700)
	    local itemList = ScanItems(false)
		--Ignore items in backpack (itemsList, True filter, False filter)
        local t = FindItems(itemList, {Type=bandageType, ContID=restock.generalBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nBandagesOnSelf = GetCountOfItemOnSelf(bandageType)
		    if nBandagesOnSelf < restock.aidsCnt then
			    local restockCnt = restock.aidsCnt - nBandagesOnSelf
				print("Restocked: ".. restockCnt.." Bandages") 
		        UO.SysMessage("  --Restocked: ".. restockCnt.." Bandages.", 30)
				local bandageDropX = 0
				local bandageDropY = 0
				if nBandagesOnSelf == 0 then
				    UO.Drag(t[i].ID, restockCnt)
				    UO.DropC(UO.BackpackID, bandageDropX, bandageDropY)
				else
				    UO.Drag(t[i].ID, restockCnt)
				    UO.DropC(GetIDOfItemOnSelf(bandageType))
				end
				wait(700)
				
			else
			    print("We have enough bandages already")
			end
		end
	end

	--Regs
	if restock.regsCnt > 0 then
		UO.SysMessage("Restocking Regs...", 55)
		print("Restocking Regs...")
		UO.LObjectID = restock.generalBagID
		UO.Macro(17, 0)
	    wait(700)
	    local regDropX = 200
		local regDropY = 200
	    local itemList = ScanItems(false)
		--Ignore items in backpack (itemsList, True filter, False filter)
		--Bloodmoss
        local t = FindItems(itemList,{Type=bloodmossType, ContID=restock.generalBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nBloodmossOnSelf = GetCountOfItemOnSelf(bloodmossType)
		    if nBloodmossOnSelf < restock.regsCnt then
			    local restockCnt = restock.regsCnt - nBloodmossOnSelf
				print("Restocked: ".. restockCnt.." Bloodmoss.")
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
			    print("We have enough Bloodmoss already.")
			end
		end
	    --Black Pearl
        local t = FindItems(itemList,{Type=blackPearlType, ContID=restock.generalBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nBlackPearlOnSelf = GetCountOfItemOnSelf(blackPearlType)
		    if nBlackPearlOnSelf < restock.regsCnt then
			    local restockCnt = restock.regsCnt - nBlackPearlOnSelf
				print("Restocked: ".. restockCnt.." Black Pearl.")
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
			    print("We have enough Black Pearl already.")
			end
		end
	    --Mandrake
        local t = FindItems(itemList,{Type=mandrakeRootType, ContID=restock.generalBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nMandrakeRootOnSelf = GetCountOfItemOnSelf(mandrakeRootType)
		    if nMandrakeRootOnSelf < restock.regsCnt then
			    local restockCnt = restock.regsCnt - nMandrakeRootOnSelf
				print("Restocked: ".. restockCnt.." Mandrake Root.")
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
			    print("We have enough Mandrake Root already.")
			end
		end
	    --Garlic
        local t = FindItems(itemList,{Type=garlicType, ContID=restock.generalBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nGarlicOnSelf = GetCountOfItemOnSelf(garlicType)
		    if nGarlicOnSelf < restock.regsCnt then
			    local restockCnt = restock.regsCnt - nGarlicOnSelf
				print("Restocked: ".. restockCnt.." Garlic.")
		        UO.SysMessage("  --Restocked: ".. restockCnt.." Garlic.", 30)
				if nGarlicOnSelf == 0 then
				    UO.Drag(t[i].ID, restockCnt)
				    UO.DropC(UO.BackpackID, regDropX, regDropY)
				else
				    UO.Drag(t[i].ID, restockCnt)
				    UO.DropC(GetIDOfItemOnSelf(garlicType))
				end
				wait(700)
			else
			    print("We have enough Garlic already.")
			end
		end
	    --Ginseng
        local t = FindItems(itemList,{Type=ginsengType, ContID=restock.generalBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nGinsengOnSelf = GetCountOfItemOnSelf(ginsengType)
		    if nGinsengOnSelf < restock.regsCnt then
			    local restockCnt = restock.regsCnt - nGinsengOnSelf
				print("Restocked: ".. restockCnt.." Ginseng.")
		        UO.SysMessage("  --Restocked: ".. restockCnt.." Ginseng.", 30)
				if nGinsengOnSelf == 0 then
				    UO.Drag(t[i].ID, restockCnt)
				    UO.DropC(UO.BackpackID, regDropX, regDropY)
				else
				    UO.Drag(t[i].ID, restockCnt)
				    UO.DropC(GetIDOfItemOnSelf(ginsengType))
				end
				wait(700)
			else
			    print("We have enough Ginseng already.")
			end
		end
	    --Sulf Ash
        local t = FindItems(itemList,{Type=sulfAshType, ContID=restock.generalBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nSulfAshOnSelf = GetCountOfItemOnSelf(sulfAshType)
		    if nSulfAshOnSelf < restock.regsCnt then
			    local restockCnt = restock.regsCnt - nSulfAshOnSelf
				print("Restocked: ".. restockCnt.." Sulf Ash.")
		        UO.SysMessage("  --Restocked: ".. restockCnt.." Sulf Ash.", 30)
				if nSulfAshOnSelf == 0 then
				    UO.Drag(t[i].ID, restockCnt)
				    UO.DropC(UO.BackpackID, regDropX, regDropY)
				else
				    UO.Drag(t[i].ID, restockCnt)
				    UO.DropC(GetIDOfItemOnSelf(sulfAshType))
				end
				wait(700)
			else
			    print("We have enough Sulf Ash already.")
			end
		end
	    --Spider Silk
        local t = FindItems(itemList,{Type=spiderSilkType, ContID=restock.generalBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nSpiderSilkOnSelf = GetCountOfItemOnSelf(spiderSilkType)
		    if nSpiderSilkOnSelf < restock.regsCnt then
			    local restockCnt = restock.regsCnt - nSpiderSilkOnSelf
				print("Restocked: ".. restockCnt.." Spider Silk.")
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
			    print("We have enough Spider Silk already.")
			end
		end
	    --Nightshade
        local t = FindItems(itemList,{Type=nightshadeType, ContID=restock.generalBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nNightshadeOnSelf = GetCountOfItemOnSelf(nightshadeType)
		    if nNightshadeOnSelf < restock.regsCnt then
			    local restockCnt = restock.regsCnt - nNightshadeOnSelf
				print("Restocked: ".. restockCnt.." Nightshade")
		        UO.SysMessage("  --Restocked: ".. restockCnt.." Nightshade.", 30)
				if nNightshadeOnSelf == 0 then
				    UO.Drag(t[i].ID, restockCnt)
				    UO.DropC(UO.BackpackID, regDropX, regDropY)
				else
				    UO.Drag(t[i].ID, restockCnt)
				    UO.DropC(GetIDOfItemOnSelf(nightshadeType))
				end
				wait(700)
			else
			    print("We have enough Nightshade already.")
			end
		end
	end
	
	--Pouches
	if restock.pouchesCnt > 0 then    
		UO.SysMessage("Restocking Pouches...", 55)
		print("Restocking Pouches...")
		UO.LObjectID = restock.pouchesBagID
		UO.Macro(17, 0)
	    wait(700)
	    local pouchDropX = 0
		local pouchDropY = 175
		
	    local itemList = ScanItems(false)
		local t = FindItems(itemList,{Type=pouchType, ContID=restock.pouchesBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nPouchesOnSelf = GetCountOfItemOnSelf(pouchType)
			
		    if nPouchesOnSelf < restock.pouchesCnt then
				print("Taking Pouch.")
		        UO.SysMessage("  --Taking Pouch.", 30)
				UO.Drag(t[i].ID, 1)
				UO.DropC(UO.BackpackID, pouchDropX, pouchDropY)
				wait(720)
			else
			    print("We have enough Pouches already")
				break
			end
		end
	end
	--Str Pots
	if restock.strCnt > 0 then
		UO.SysMessage("Restocking Str Pots....", 55)
		print("Restocking Str Pots...")
		UO.LObjectID = restock.strPotBagID
		UO.Macro(17, 0)
	    wait(700)
	    local strPotDropX = 125
		local strPotDropY = 0
		
	    local itemList = ScanItems(false)
		local t = FindItems(itemList,{Type=strPotType, ContID=restock.strPotBagID}, {ContID=UO.BackpackID})
		
		for i = 1, #t do
		    local nStrPotsOnSelf = GetCountOfItemOnSelf(strPotType)
		    if nStrPotsOnSelf < restock.strCnt then
				print("Taking Strength Potion.")
		        UO.SysMessage("  --Taking Strength Potion.", 30)
				local nToGrab = ( restock.strCnt - nStrPotsOnSelf)
				if nToGrab > t[i].Stack then
				    nToGrab = t[i].Stack
				end
				UO.Drag(t[i].ID, nToGrab)
				UO.DropC(UO.BackpackID, strPotDropX, strPotDropY)
				wait(720)
			else
			    print("We have enough Strength potions already.")
				break
			end
		end
	end
	--Agil Pots
	if restock.agilCnt > 0 then
		UO.SysMessage("Restocking Agility Pots...", 55)
		print("Restocking Agility Pots...")
		UO.LObjectID = restock.agilPotBagID
		UO.Macro(17, 0)
	    wait(700)
	    local agilePotDropX = 99
		local agilePotDropY = 0
		
	    local itemList = ScanItems(false)
		local t = FindItems(itemList,{Type=agilPotType, ContID=restock.agilPotBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nAgilePotsOnSelf = GetCountOfItemOnSelf(agilPotType)
			
		    if nAgilePotsOnSelf < restock.agilCnt then
				print("Taking Agility Potion.")
		        UO.SysMessage("  --Taking Agility Potion.", 30)
				local nToGrab = ( restock.strCnt - nStrPotsOnSelf)
				if nToGrab > t[i].Stack then
				    nToGrab = t[i].Stack
				end
				UO.Drag(t[i].ID, nToGrab)
				UO.DropC(UO.BackpackID, agilePotDropX, agilePotDropY)
				wait(720)
			else
			    print("We have enough Agility potions already.")
				break
			end
		end
	end
	--Cure Pots
	if restock.cureCnt > 0 then
		UO.SysMessage("Restocking Cure Pots...", 55)
		print("Restocking Cure Pots...")
		UO.LObjectID = restock.curePotBagID
		UO.Macro(17, 0)
	    wait(700)
	    local curePotDropX = 150
		local curePotDropY = 0
		
	    local itemList = ScanItems(false)
		local t = FindItems(itemList,{Type=curePotType, ContID=restock.curePotBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nCurePotsOnSelf = GetCountOfItemOnSelf(curePotType)
			
		    if nCurePotsOnSelf < restock.cureCnt then
				print("Taking Cure Potion.")
		        UO.SysMessage("  --Taking Cure Potion.", 30)
				local nToGrab = ( restock.strCnt - nStrPotsOnSelf)
				if nToGrab > t[i].Stack then
				    nToGrab = t[i].Stack
				end
				UO.Drag(t[i].ID, nToGrab)
				UO.DropC(UO.BackpackID, curePotDropX, curePotDropY)
				wait(720)
			else
			    print("We have enough Cure potions already.")
				break
			end
		end
	end
	--HealPots
	if restock.healCnt > 0 then
		UO.SysMessage("Restocking Heal Pots...", 55)
		print("Restocking Heal Pots...")
		UO.LObjectID = restock.healPotBagID
		UO.Macro(17, 0)
	    wait(700)
	    local healPotDropX = 89
		local healPotDropY = 0
		
	    local itemList = ScanItems(false)
		local t = FindItems(itemList,{Type=healPotType, ContID=restock.healPotBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nHealPotsOnSelf = GetCountOfItemOnSelf(healPotType)
			
		    if nHealPotsOnSelf < restock.healCnt then
				print("Taking Healing Potion.")
		        UO.SysMessage("  --Taking Healing Potion.", 30)
				local nToGrab = ( restock.strCnt - nStrPotsOnSelf)
				if nToGrab > t[i].Stack then
				    nToGrab = t[i].Stack
				end
				UO.Drag(t[i].ID, nToGrab)
				UO.DropC(UO.BackpackID, healPotDropX, healPotDropY)
				wait(720)
			else
			    print("We have enough Healing potions already.")
				break
			end
		end
	end
	--Explosion Pots
	if restock.exploCnt > 0 then
		UO.SysMessage("Restocking Explosion Pots...", 55)
		print("Restocking Explosion Pots...")
		UO.LObjectID = restock.curePotBagID
		UO.Macro(17, 0)
	    wait(700)
	    local exploPotDropX = 109
		local exploPotDropY = 0
		
	    local itemList = ScanItems(false)
		local t = FindItems(itemList,{Type=exploPotType, ContID=restock.curePotBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nExploPotsOnSelf = GetCountOfItemOnSelf(exploPotType)
			
		    if nExploPotsOnSelf < restock.exploCnt then
				print("Taking Explosion Potions.")
		        UO.SysMessage("  --Taking Explosion Potion.", 30)
				UO.Drag(t[i].ID, 1)
				UO.DropC(UO.BackpackID, exploPotDropX, exploPotDropY)
				wait(720)
			else
			    print("We have enough Explosion potions already.")
				break
			end
		end
	end
	--Refresh Pots
	if restock.refCnt > 0 then
		UO.SysMessage("Restocking Refresh Pots...", 55)
		print("Restocking Refresh Pots...")
		UO.LObjectID = restock.refPotBagID
		UO.Macro(17, 0)
	    wait(700)
	    local refPotDropX = 75
		local refPotDropY = 0
		
	    local itemList = ScanItems(false)
		local t = FindItems(itemList,{Type=refreshPotType, ContID=restock.refPotBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nRefPotsOnSelf = GetCountOfItemOnSelf(refreshPotType)
			
		    if nRefPotsOnSelf < restock.refCnt then
				print("Taking Refresh Potions.")
		        UO.SysMessage("  --Taking Refresh Potion.", 30)
				local nToGrab = ( restock.strCnt - nStrPotsOnSelf)
				if nToGrab > t[i].Stack then
				    nToGrab = t[i].Stack
				end
				UO.Drag(t[i].ID, nToGrab)
				UO.DropC(UO.BackpackID, refPotDropX, refPotDropY)
				wait(720)
			else
			    print("We have enough Refresh potions already.")
				break
			end
		end
	end
	UO.SysMessage("Finished", 55)
	print("Done.")

end

function StartMenu(isNewCharacter)
	--Grab variables associated with current character logged in.
	--if character is not known, use default values instead.
    if isNewCharacter == true then
	    print("Loading new character.")
		dofile("../Default.lua")
	else
	    print("Loading : \"" .. UO.CharName .. ".lua\"")
		dofile("../chars/" .. UO.CharName .. ".lua")
	end
	
    local freeObjList = {}
	local form = Obj.Create("TForm")
	form.Caption = "PvP Assist - " .. UO.CharName 
	form.Height = 650
	form.Width = 350
	form.FormStyle = 2
	form.Color = 20000
	form.Font.Color = 255
	local ret = true
	form.OnClose = function()
	    ret = false
		Obj.Exit()
	end
	freeObjList[#freeObjList + 1] = form

	local top = 10
	--Buttons
	local okayBtn = Obj.Create("TButton")
	okayBtn.Caption = "Save/Start"
	okayBtn.Left = 100
	okayBtn.Width = 100
	okayBtn.Top = 580
	okayBtn.Height = 30
	okayBtn.Parent = form
	freeObjList[#freeObjList + 1] = okayBtn
	
	

	--Un-Restock items key.
	--Labels
	local unRestockKeyLabel = Obj.Create("TLabel")
	unRestockKeyLabel.Caption = "Un-Restock key."
	unRestockKeyLabel.Height = 25
	unRestockKeyLabel.Width = 200
	unRestockKeyLabel.Left = 65
	unRestockKeyLabel.Top = top
	unRestockKeyLabel.Font.Color = 0
	unRestockKeyLabel.Font.Size = 12
	unRestockKeyLabel.Parent = form
	freeObjList[#freeObjList + 1] = unRestockKeyLabel
  	
	--Edits
	local unRestockKeyEdit = Obj.Create("TEdit")
	unRestockKeyEdit.Text = tostring(unRestockPVPItemsKey)
	unRestockKeyEdit.Height = 25
	unRestockKeyEdit.Width = 55
	unRestockKeyEdit.Top = top
	unRestockKeyEdit.Left = 0
	unRestockKeyEdit.Parent = form
	freeObjList[#freeObjList + 1] = unRestockKeyEdit
	--/Un-Restock items key.	
	
	top = top + 25
	
	--Restock items key.
	--Labels
	local restockKeyLabel = Obj.Create("TLabel")
	restockKeyLabel.Caption = "Restock key."
	restockKeyLabel.Height = 25
	restockKeyLabel.Width = 200
	restockKeyLabel.Left = 65
	restockKeyLabel.Top = top
	restockKeyLabel.Font.Color = 0
	restockKeyLabel.Font.Size = 12
	restockKeyLabel.Parent = form
	freeObjList[#freeObjList + 1] = restockKeyLabel
  	
	--Edits
	local restockKeyEdit = Obj.Create("TEdit")
	restockKeyEdit.Text = tostring(restockPVPItemsKey)
	restockKeyEdit.Height = 25
	restockKeyEdit.Width = 55
	restockKeyEdit.Top = top
	restockKeyEdit.Left = 0
	restockKeyEdit.Parent = form
	freeObjList[#freeObjList + 1] = restockKeyEdit
	--/Restock items key.	
	
	top = top + 25
	--Restock items key from corpse.
	--Labels
	local restockCorpseKeyLabel = Obj.Create("TLabel")
	restockCorpseKeyLabel.Caption = "Restock from target container key."
	restockCorpseKeyLabel.Height = 25
	restockCorpseKeyLabel.Width = 200
	restockCorpseKeyLabel.Left = 65
	restockCorpseKeyLabel.Top = top
	restockCorpseKeyLabel.Font.Color = 0
	restockCorpseKeyLabel.Font.Size = 12
	restockCorpseKeyLabel.Parent = form
	freeObjList[#freeObjList + 1] = restockCorpseKeyLabel
  	
	--Edits
	local restockCorpseKeyEdit = Obj.Create("TEdit")
	restockCorpseKeyEdit.Text = tostring(restockFromCorpseKey)
	restockCorpseKeyEdit.Height = 25
	restockCorpseKeyEdit.Width = 55
	restockCorpseKeyEdit.Top = top
	restockCorpseKeyEdit.Left = 0
	restockCorpseKeyEdit.Parent = form
	freeObjList[#freeObjList + 1] = restockCorpseKeyEdit
	--/--Restock items key from corpse.	
	
	top = top + 25
	
	
	--Restock meat.
	--Labels
	local restockMeatLabel = Obj.Create("TLabel")
	restockMeatLabel.Caption = "Restock Meat count."
	restockMeatLabel.Height = 25
	restockMeatLabel.Width = 200
	restockMeatLabel.Left = 65
	restockMeatLabel.Top = top
	restockMeatLabel.Font.Color = 0
	restockMeatLabel.Font.Size = 12
	restockMeatLabel.Parent = form
	freeObjList[#freeObjList + 1] = restockMeatLabel
  	
	--Edits
	local restockMeatEdit = Obj.Create("TEdit")
	restockMeatEdit.Text = tostring(meatRestockCnt)
	restockMeatEdit.Height = 25
	restockMeatEdit.Width = 55
	restockMeatEdit.Top = top
	restockMeatEdit.Left = 0
	restockMeatEdit.Parent = form
	freeObjList[#freeObjList + 1] = restockMeatEdit
	--/Restock meat.
		
	top = top + 25
	
	--Restock bandages.
	--Labels
	local restockBandageLabel = Obj.Create("TLabel")
	restockBandageLabel.Caption = "Restock Bandage count."
	restockBandageLabel.Height = 25
	restockBandageLabel.Width = 200
	restockBandageLabel.Left = 65
	restockBandageLabel.Top = top
	restockBandageLabel.Font.Color = 0
	restockBandageLabel.Font.Size = 12
	restockBandageLabel.Parent = form
	freeObjList[#freeObjList + 1] = restockBandageLabel
  	
	--Edits
	local restockBandageEdit = Obj.Create("TEdit")
	restockBandageEdit.Text = tostring(bangageRestockCnt)
	restockBandageEdit.Height = 25
	restockBandageEdit.Width = 55
	restockBandageEdit.Top = top
	restockBandageEdit.Left = 0
	restockBandageEdit.Parent = form
	freeObjList[#freeObjList + 1] = restockBandageEdit
	--/Restock bandages.
	
	top = top + 25
	
	--Restock Regs.
	--Labels
	local restockRegsLabel = Obj.Create("TLabel")
	restockRegsLabel.Caption = "Restock Reagents count."
	restockRegsLabel.Height = 25
	restockRegsLabel.Width = 200
	restockRegsLabel.Left = 65
	restockRegsLabel.Top = top
	restockRegsLabel.Font.Color = 0
	restockRegsLabel.Font.Size = 12
	restockRegsLabel.Parent = form
	freeObjList[#freeObjList + 1] = restockRegsLabel
  	
	--Edits
	local restockRegsEdit = Obj.Create("TEdit")
	restockRegsEdit.Text = tostring(regRestockCnt)
	restockRegsEdit.Height = 25
	restockRegsEdit.Width = 55
	restockRegsEdit.Top = top
	restockRegsEdit.Left = 0
	restockRegsEdit.Parent = form
	freeObjList[#freeObjList + 1] = restockRegsEdit
	--/Restock Regs.
	
	top = top + 25
	
	--Restock Pouches.
	--Labels
	local restockPouchesLabel = Obj.Create("TLabel")
	restockPouchesLabel.Caption = "Restock Pouches count."
	restockPouchesLabel.Height = 25
	restockPouchesLabel.Width = 200
	restockPouchesLabel.Left = 65
	restockPouchesLabel.Top = top
	restockPouchesLabel.Font.Color = 0
	restockPouchesLabel.Font.Size = 12
	restockPouchesLabel.Parent = form
	freeObjList[#freeObjList + 1] = restockPouchesLabel
  	
	--Edits
	local restockPouchesEdit = Obj.Create("TEdit")
	restockPouchesEdit.Text = tostring(pouchRestockCnt)
	restockPouchesEdit.Height = 25
	restockPouchesEdit.Width = 55
	restockPouchesEdit.Top = top
	restockPouchesEdit.Left = 0
	restockPouchesEdit.Parent = form
	freeObjList[#freeObjList + 1] = restockPouchesEdit
	--/Restock Pouches.

	top = top + 25
	
	--Restock StrPot.
	--Labels
	local restockStrPotLabel = Obj.Create("TLabel")
	restockStrPotLabel.Caption = "Restock Str Pot count."
	restockStrPotLabel.Height = 25
	restockStrPotLabel.Width = 200
	restockStrPotLabel.Left = 65
	restockStrPotLabel.Top = top
	restockStrPotLabel.Font.Color = 0
	restockStrPotLabel.Font.Size = 12
	restockStrPotLabel.Parent = form
	freeObjList[#freeObjList + 1] = restockStrPotLabel
  	
	--Edits
	local restockStrPotEdit = Obj.Create("TEdit")
	restockStrPotEdit.Text = tostring(strPotRestockCnt)
	restockStrPotEdit.Height = 25
	restockStrPotEdit.Width = 55
	restockStrPotEdit.Top = top
	restockStrPotEdit.Left = 0
	restockStrPotEdit.Parent = form
	freeObjList[#freeObjList + 1] = restockStrPotEdit
	--/Restock StrPot.

	top = top + 25
	
	--Restock AgilPot
	--Labels
	local restockAgilPotLabel = Obj.Create("TLabel")
	restockAgilPotLabel.Caption = "Restock Agil Pot count."
	restockAgilPotLabel.Height = 25
	restockAgilPotLabel.Width = 200
	restockAgilPotLabel.Left = 65
	restockAgilPotLabel.Top = top
	restockAgilPotLabel.Font.Color = 0
	restockAgilPotLabel.Font.Size = 12
	restockAgilPotLabel.Parent = form
	freeObjList[#freeObjList + 1] = restockAgilPotLabel
  	
	--Edits
	local restockAgilPotEdit = Obj.Create("TEdit")
	restockAgilPotEdit.Text = tostring(agilPotRestockCnt)
	restockAgilPotEdit.Height = 25
	restockAgilPotEdit.Width = 55
	restockAgilPotEdit.Top = top
	restockAgilPotEdit.Left = 0
	restockAgilPotEdit.Parent = form
	freeObjList[#freeObjList + 1] = restockAgilPotEdit
	--/Restock StrPot.
	
	top = top + 25
	
	--Restock CurePot
	--Labels
	local restockCurePotLabel = Obj.Create("TLabel")
	restockCurePotLabel.Caption = "Restock Cure Pot count."
	restockCurePotLabel.Height = 25
	restockCurePotLabel.Width = 200
	restockCurePotLabel.Left = 65
	restockCurePotLabel.Top = top
	restockCurePotLabel.Font.Color = 0
	restockCurePotLabel.Font.Size = 12
	restockCurePotLabel.Parent = form
	freeObjList[#freeObjList + 1] = restockCurePotLabel
  	
	--Edits
	local restockCurePotEdit = Obj.Create("TEdit")
	restockCurePotEdit.Text = tostring(curePotRestockCnt)
	restockCurePotEdit.Height = 25
	restockCurePotEdit.Width = 55
	restockCurePotEdit.Top = top
	restockCurePotEdit.Left = 0
	restockCurePotEdit.Parent = form
	freeObjList[#freeObjList + 1] = restockCurePotEdit
	--/Restock CurePot.
	
	top = top + 25
	
	--Restock HealPot
	--Labels
	local restockHealPotLabel = Obj.Create("TLabel")
	restockHealPotLabel.Caption = "Restock Heal Pot count."
	restockHealPotLabel.Height = 25
	restockHealPotLabel.Width = 200
	restockHealPotLabel.Left = 65
	restockHealPotLabel.Top = top
	restockHealPotLabel.Font.Color = 0
	restockHealPotLabel.Font.Size = 12
	restockHealPotLabel.Parent = form
	freeObjList[#freeObjList + 1] = restockHealPotLabel
  	
	--Edits
	local restockHealPotEdit = Obj.Create("TEdit")
	restockHealPotEdit.Text = tostring(healPotRestockCnt)
	restockHealPotEdit.Height = 25
	restockHealPotEdit.Width = 55
	restockHealPotEdit.Top = top
	restockHealPotEdit.Left = 0
	restockHealPotEdit.Parent = form
	freeObjList[#freeObjList + 1] = restockHealPotEdit
	--/Restock HealPot.	
	
	top = top + 25
	
	--Restock ExplPot
	--Labels
	local restockExplPotLabel = Obj.Create("TLabel")
	restockExplPotLabel.Caption = "Restock Explosion Pot count."
	restockExplPotLabel.Height = 25
	restockExplPotLabel.Width = 200
	restockExplPotLabel.Left = 65
	restockExplPotLabel.Top = top
	restockExplPotLabel.Font.Color = 0
	restockExplPotLabel.Font.Size = 12
	restockExplPotLabel.Parent = form
	freeObjList[#freeObjList + 1] = restockExplPotLabel
  	
	--Edits
	local restockExplPotEdit = Obj.Create("TEdit")
	restockExplPotEdit.Text = tostring(explPotRestockCnt)
	restockExplPotEdit.Height = 25
	restockExplPotEdit.Width = 55
	restockExplPotEdit.Top = top
	restockExplPotEdit.Left = 0
	restockExplPotEdit.Parent = form
	freeObjList[#freeObjList + 1] = restockExplPotEdit
	--/Restock ExplPot.	
		
	top = top + 25
	
	--Restock RefrPot
	--Labels
	local restockRefrPotLabel = Obj.Create("TLabel")
	restockRefrPotLabel.Caption = "Restock Refresh Pot count."
	restockRefrPotLabel.Height = 25
	restockRefrPotLabel.Width = 200
	restockRefrPotLabel.Left = 65
	restockRefrPotLabel.Top = top
	restockRefrPotLabel.Font.Color = 0
	restockRefrPotLabel.Font.Size = 12
	restockRefrPotLabel.Parent = form
	freeObjList[#freeObjList + 1] = restockRefrPotLabel
  	
	--Edits
	local restockRefrPotEdit = Obj.Create("TEdit")
	restockRefrPotEdit.Text = tostring(refrPotRestockCnt)
	restockRefrPotEdit.Height = 25
	restockRefrPotEdit.Width = 55
	restockRefrPotEdit.Top = top
	restockRefrPotEdit.Left = 0
	restockRefrPotEdit.Parent = form
	freeObjList[#freeObjList + 1] = restockRefrPotEdit
	--/Restock RefrPot.	
	
	top = top + 50
	
	--Restock HealPot Bag ID
	--Labels 
	local healPotBagIDLabel = Obj.Create("TLabel")
	healPotBagIDLabel.Caption = "Heal Potion container ID."
	healPotBagIDLabel.Height = 25
	healPotBagIDLabel.Width = 200
	healPotBagIDLabel.Left = 65
	healPotBagIDLabel.Top = top
	healPotBagIDLabel.Font.Color = 0
	healPotBagIDLabel.Font.Size = 12
	healPotBagIDLabel.Parent = form
	freeObjList[#freeObjList + 1] = healPotBagIDLabel
  	
	--Edits
	local healPotBagIDEdit = Obj.Create("TEdit")
	healPotBagIDEdit.Text = tostring(healPotBagID)
	healPotBagIDEdit.Height = 25
	healPotBagIDEdit.Width = 55
	healPotBagIDEdit.Top = top
	healPotBagIDEdit.Left = 0
	healPotBagIDEdit.Parent = form
	freeObjList[#freeObjList + 1] = healPotBagIDEdit
	--/Restock HealPot Bag ID
	
	top = top + 25
	
	--Restock curePotBagID
	--Labels 
	local curePotBagIDLabel = Obj.Create("TLabel")
	curePotBagIDLabel.Caption = "Cure Potion container ID."
	curePotBagIDLabel.Height = 25
	curePotBagIDLabel.Width = 200
	curePotBagIDLabel.Left = 65
	curePotBagIDLabel.Top = top
	curePotBagIDLabel.Font.Color = 0
	curePotBagIDLabel.Font.Size = 12
	curePotBagIDLabel.Parent = form
	freeObjList[#freeObjList + 1] = curePotBagIDLabel
  	
	--Edits
	local curePotBagIDEdit = Obj.Create("TEdit")
	curePotBagIDEdit.Text = tostring(curePotBagID)
	curePotBagIDEdit.Height = 25
	curePotBagIDEdit.Width = 55
	curePotBagIDEdit.Top = top
	curePotBagIDEdit.Left = 0
	curePotBagIDEdit.Parent = form
	freeObjList[#freeObjList + 1] = curePotBagIDEdit
	--/Restock curePotBagID
	
	top = top + 25
	
	--Restock exploPotBagID
	--Labels 
	local exploPotBagIDLabel = Obj.Create("TLabel")
	exploPotBagIDLabel.Caption = "Explosion Potion container ID."
	exploPotBagIDLabel.Height = 25
	exploPotBagIDLabel.Width = 200
	exploPotBagIDLabel.Left = 65
	exploPotBagIDLabel.Top = top
	exploPotBagIDLabel.Font.Color = 0
	exploPotBagIDLabel.Font.Size = 12
	exploPotBagIDLabel.Parent = form
	freeObjList[#freeObjList + 1] = exploPotBagIDLabel
  	
	--Edits
	local exploPotBagIDEdit = Obj.Create("TEdit")
	exploPotBagIDEdit.Text = tostring(exploPotBagID)
	exploPotBagIDEdit.Height = 25
	exploPotBagIDEdit.Width = 55
	exploPotBagIDEdit.Top = top
	exploPotBagIDEdit.Left = 0
	exploPotBagIDEdit.Parent = form
	freeObjList[#freeObjList + 1] = exploPotBagIDEdit
	--/Restock exploPotBagID

	top = top + 25
	
	--Restock refreshPotBagID
	--Labels 
	local refreshPotBagIDLabel = Obj.Create("TLabel")
	refreshPotBagIDLabel.Caption = "Refresh Potion container ID."
	refreshPotBagIDLabel.Height = 25
	refreshPotBagIDLabel.Width = 500
	refreshPotBagIDLabel.Left = 65
	refreshPotBagIDLabel.Top = top
	refreshPotBagIDLabel.Font.Color = 0
	refreshPotBagIDLabel.Font.Size = 12
	refreshPotBagIDLabel.Parent = form
	freeObjList[#freeObjList + 1] = refreshPotBagIDLabel
  	
	--Edits
	local refreshPotBagIDEdit = Obj.Create("TEdit")
	refreshPotBagIDEdit.Text = tostring(refreshPotBagID)
	refreshPotBagIDEdit.Height = 25
	refreshPotBagIDEdit.Width = 55
	refreshPotBagIDEdit.Top = top
	refreshPotBagIDEdit.Left = 0
	refreshPotBagIDEdit.Parent = form
	freeObjList[#freeObjList + 1] = refreshPotBagIDEdit
	--/Restock refreshPotBagID

	top = top + 25
	
	--Restock strPotBagID
	--Labels 
	local strPotBagIDLabel = Obj.Create("TLabel")
	strPotBagIDLabel.Caption = "Str Potion container ID."
	strPotBagIDLabel.Height = 25
	strPotBagIDLabel.Width = 500
	strPotBagIDLabel.Left = 65
	strPotBagIDLabel.Top = top
	strPotBagIDLabel.Font.Color = 0
	strPotBagIDLabel.Font.Size = 12
	strPotBagIDLabel.Parent = form
	freeObjList[#freeObjList + 1] = strPotBagIDLabel
  	
	--Edits
	local strPotBagIDEdit = Obj.Create("TEdit")
	strPotBagIDEdit.Text = tostring(strPotBagID)
	strPotBagIDEdit.Height = 25
	strPotBagIDEdit.Width = 55
	strPotBagIDEdit.Top = top
	strPotBagIDEdit.Left = 0
	strPotBagIDEdit.Parent = form
	freeObjList[#freeObjList + 1] = strPotBagIDEdit
	--/Restock strPotBagID

	top = top + 25
	
	--Restock agilPotBagID
	--Labels 
	local agilPotBagIDLabel = Obj.Create("TLabel")
	agilPotBagIDLabel.Caption = "Agil Potion container ID."
	agilPotBagIDLabel.Height = 25
	agilPotBagIDLabel.Width = 500
	agilPotBagIDLabel.Left = 65
	agilPotBagIDLabel.Top = top
	agilPotBagIDLabel.Font.Color = 0
	agilPotBagIDLabel.Font.Size = 12
	agilPotBagIDLabel.Parent = form
	freeObjList[#freeObjList + 1] = agilPotBagIDLabel
  	
	--Edits
	local agilPotBagIDEdit = Obj.Create("TEdit")
	agilPotBagIDEdit.Text = tostring(agilPotBagID)
	agilPotBagIDEdit.Height = 25
	agilPotBagIDEdit.Width = 55
	agilPotBagIDEdit.Top = top
	agilPotBagIDEdit.Left = 0
	agilPotBagIDEdit.Parent = form
	freeObjList[#freeObjList + 1] = agilPotBagIDEdit
	--/Restock agilPotBagID
	
	top = top + 25
	
	--Restock pouchesBagID
	--Labels 
	local pouchesBagIDLabel = Obj.Create("TLabel")
	pouchesBagIDLabel.Caption = "Pouches container ID."
	pouchesBagIDLabel.Height = 25
	pouchesBagIDLabel.Width = 200
	pouchesBagIDLabel.Left = 65
	pouchesBagIDLabel.Top = top
	pouchesBagIDLabel.Font.Color = 0
	pouchesBagIDLabel.Font.Size = 12
	pouchesBagIDLabel.Parent = form
	freeObjList[#freeObjList + 1] = pouchesBagIDLabel
  	
	--Edits
	local pouchesBagIDEdit = Obj.Create("TEdit")
	pouchesBagIDEdit.Text = tostring(pouchesBagID)
	pouchesBagIDEdit.Height = 25
	pouchesBagIDEdit.Width = 55
	pouchesBagIDEdit.Top = top
	pouchesBagIDEdit.Left = 0
	pouchesBagIDEdit.Parent = form
	freeObjList[#freeObjList + 1] = pouchesBagIDEdit
	--/Restock pouchesBagID	
	
	top = top + 25
	
	--Restock generalItemsBagID
	--Labels 
	local generalItemsBagIDLabel = Obj.Create("TLabel")
	generalItemsBagIDLabel.Caption = "General container ID. (Stackables)"
	generalItemsBagIDLabel.Height = 25
	generalItemsBagIDLabel.Width = 500
	generalItemsBagIDLabel.Left = 65
	generalItemsBagIDLabel.Top = top
	generalItemsBagIDLabel.Font.Color = 0
	generalItemsBagIDLabel.Font.Size = 12
	generalItemsBagIDLabel.Parent = form
	freeObjList[#freeObjList + 1] = generalItemsBagIDLabel
  	
	--Edits
	local generalItemsBagIDEdit = Obj.Create("TEdit")
	generalItemsBagIDEdit.Text = tostring(generalItemsBagID)
	generalItemsBagIDEdit.Height = 25
	generalItemsBagIDEdit.Width = 55
	generalItemsBagIDEdit.Top = top
	generalItemsBagIDEdit.Left = 0
	generalItemsBagIDEdit.Parent = form
	freeObjList[#freeObjList + 1] = generalItemsBagIDEdit
	--/Restock generalItemsBagID
function TheBigRestockFromCorpse(restock)
	UO.TargCurs = true
	UO.SysMessage("Target Corpse or Container", 75)
	local to = getticks() + 10000 -- wait up to 10s
	while getticks() < to do
	  if UO.TargCurs == false then break end
	  wait(1)
	end
	local targetContainer = UO.LTargetID
	UO.LObjectID = targetContainer
	UO.Macro(17, 0)
	wait(700)
	UO.ExMsg(UO.CharID, 0, 55, "Restocking!" )
	--Meat
	if restock.meatCnt > 0 then
		UO.SysMessage("Restocking Meat...", 55)
		print("Restocking Meat...")
		local itemList = ScanItems(false)
		--Ignore items in backpack (itemsList, True filter, False filter)
		local t = FindItems(itemList, {Type=meatType, ContID=targetContainer}, {ContID=UO.BackpackID})
		for i = 1, #t do
			local nMeatOnSelf = GetCountOfItemOnSelf(meatType)
			if nMeatOnSelf < restock.meatCnt then
				local restockCnt = restock.meatCnt - nMeatOnSelf
				print("Restocked: ".. restockCnt.." Meat.") 
				local meatDropX = 0
				local meatDropY = 90
				if nMeatOnSelf == 0 then
					UO.Drag(t[i].ID, restockCnt)
					UO.DropC(UO.BackpackID, meatDropX, meatDropY)
				else
					UO.Drag(t[i].ID, restockCnt)
					UO.DropC(GetIDOfItemOnSelf(meatType))
				end
				wait(700)
				
			else
				print("We have enough Meat already")
			end
		end
	end
	
	--Bandages
	if restock.aidsCnt > 0 then
		UO.SysMessage("Restocking Bandages...", 55)
		print("Restocking Bandages...")
		local itemList = ScanItems(false)
		--Ignore items in backpack (itemsList, True filter, False filter)
		local t = FindItems(itemList, {Type=bandageType, ContID=targetContainer}, {ContID=UO.BackpackID})
		for i = 1, #t do
			local nBandagesOnSelf = GetCountOfItemOnSelf(bandageType)
			if nBandagesOnSelf < restock.aidsCnt then
				local restockCnt = restock.aidsCnt - nBandagesOnSelf
				print("Restocked: ".. restockCnt.." Bandages") 
				local bandageDropX = 0
				local bandageDropY = 0
				if nBandagesOnSelf == 0 then
					UO.Drag(t[i].ID, restockCnt)
					UO.DropC(UO.BackpackID, bandageDropX, bandageDropY)
				else
					UO.Drag(t[i].ID, restockCnt)
					UO.DropC(GetIDOfItemOnSelf(bandageType))
				end
				wait(700)
				
			else
				print("We have enough bandages already")
			end
		end
	end

	--Regs
	if restock.regsCnt  > 0 then
		UO.SysMessage("Restocking Regs...", 55)
		local regDropX = 200
		local regDropY = 200
		print("Restocking Regs...")
		local itemList = ScanItems(false)
		--Ignore items in backpack (itemsList, True filter, False filter)
		--Bloodmoss
		local t = FindItems(itemList,{Type=bloodmossType, ContID=targetContainer}, {ContID=UO.BackpackID})
		for i = 1, #t do
			local nBloodmossOnSelf = GetCountOfItemOnSelf(bloodmossType)
			if nBloodmossOnSelf < restock.regsCnt then
				local restockCnt = restock.regsCnt - nBloodmossOnSelf
				print("Restocked: ".. restockCnt.." Bloodmoss.")
				if nBloodmossOnSelf == 0 then
					UO.Drag(t[i].ID, restockCnt)
					UO.DropC(UO.BackpackID, regDropX, regDropY)
				else
					UO.Drag(t[i].ID, restockCnt)
					UO.DropC(GetIDOfItemOnSelf(bloodmossType))
				end
				wait(700)
			else
				print("We have enough Bloodmoss already.")
			end
		end
		--Black Pearl
		local t = FindItems(itemList,{Type=blackPearlType, ContID=targetContainer}, {ContID=UO.BackpackID})
		for i = 1, #t do
			local nBlackPearlOnSelf = GetCountOfItemOnSelf(blackPearlType)
			if nBlackPearlOnSelf < restock.regsCnt then
				local restockCnt = restock.regsCnt - nBlackPearlOnSelf
				print("Restocked: ".. restockCnt.." Black Pearl.")
				if nBlackPearlOnSelf == 0 then
					UO.Drag(t[i].ID, restockCnt)
					UO.DropC(UO.BackpackID, regDropX, regDropY)
				else
					UO.Drag(t[i].ID, restockCnt)
					UO.DropC(GetIDOfItemOnSelf(blackPearlType))
				end
				wait(700)
			else
				print("We have enough Black Pearl already.")
			end
		end
		--Mandrake
		local t = FindItems(itemList,{Type=mandrakeRootType, ContID=targetContainer}, {ContID=UO.BackpackID})
		for i = 1, #t do
			local nMandrakeRootOnSelf = GetCountOfItemOnSelf(mandrakeRootType)
			if nMandrakeRootOnSelf < restock.regsCnt then
				local restockCnt = restock.regsCnt - nMandrakeRootOnSelf
				print("Restocked: ".. restockCnt.." Mandrake Root.")
				if nMandrakeRootOnSelf == 0 then
					UO.Drag(t[i].ID, restockCnt)
					UO.DropC(UO.BackpackID, regDropX, regDropY)
				else
					UO.Drag(t[i].ID, restockCnt)
					UO.DropC(GetIDOfItemOnSelf(mandrakeRootType))
				end
				wait(700)
			else
				print("We have enough Mandrake Root already.")
			end
		end
		--Garlic
		local t = FindItems(itemList,{Type=garlicType, ContID=targetContainer}, {ContID=UO.BackpackID})
		for i = 1, #t do
			local nGarlicOnSelf = GetCountOfItemOnSelf(garlicType)
			if nGarlicOnSelf < restock.regsCnt then
				local restockCnt = restock.regsCnt - nGarlicOnSelf
				print("Restocked: ".. restockCnt.." Garlic.")
				if nGarlicOnSelf == 0 then
					UO.Drag(t[i].ID, restockCnt)
					UO.DropC(UO.BackpackID, regDropX, regDropY)
				else
					UO.Drag(t[i].ID, restockCnt)
					UO.DropC(GetIDOfItemOnSelf(garlicType))
				end
				wait(700)
			else
				print("We have enough Garlic already.")
			end
		end
		--Ginseng
		local t = FindItems(itemList,{Type=ginsengType, ContID=targetContainer}, {ContID=UO.BackpackID})
		for i = 1, #t do
			local nGinsengOnSelf = GetCountOfItemOnSelf(ginsengType)
			if nGinsengOnSelf < restock.regsCnt then
				local restockCnt = restock.regsCnt - nGinsengOnSelf
				print("Restocked: ".. restockCnt.." Ginseng.")
				if nGinsengOnSelf == 0 then
					UO.Drag(t[i].ID, restockCnt)
					UO.DropC(UO.BackpackID, regDropX, regDropY)
				else
					UO.Drag(t[i].ID, restockCnt)
					UO.DropC(GetIDOfItemOnSelf(ginsengType))
				end
				wait(700)
			else
				print("We have enough Ginseng already.")
			end
		end
		--Sulf Ash
		local t = FindItems(itemList,{Type=sulfAshType, ContID=targetContainer}, {ContID=UO.BackpackID})
		for i = 1, #t do
			local nSulfAshOnSelf = GetCountOfItemOnSelf(sulfAshType)
			if nSulfAshOnSelf < restock.regsCnt then
				local restockCnt = restock.regsCnt - nSulfAshOnSelf
				print("Restocked: ".. restockCnt.." Sulf Ash.")
				if nSulfAshOnSelf == 0 then
					UO.Drag(t[i].ID, restockCnt)
					UO.DropC(UO.BackpackID, regDropX, regDropY)
				else
					UO.Drag(t[i].ID, restockCnt)
					UO.DropC(GetIDOfItemOnSelf(sulfAshType))
				end
				wait(700)
			else
				print("We have enough Sulf Ash already.")
			end
		end
		--Spider Silk
		local t = FindItems(itemList,{Type=spiderSilkType, ContID=targetContainer}, {ContID=UO.BackpackID})
		for i = 1, #t do
			local nSpiderSilkOnSelf = GetCountOfItemOnSelf(spiderSilkType)
			if nSpiderSilkOnSelf < restock.regsCnt then
				local restockCnt = restock.regsCnt - nSpiderSilkOnSelf
				print("Restocked: ".. restockCnt.." Spider Silk.")
				if nSpiderSilkOnSelf == 0 then
					UO.Drag(t[i].ID, restockCnt)
					UO.DropC(UO.BackpackID, regDropX, regDropY)
				else
					UO.Drag(t[i].ID, restockCnt)
					UO.DropC(GetIDOfItemOnSelf(spiderSilkType))
				end
				wait(700)
			else
				print("We have enough Spider Silk already.")
			end
		end
		--Nightshade
		local t = FindItems(itemList,{Type=nightshadeType, ContID=targetContainer}, {ContID=UO.BackpackID})
		for i = 1, #t do
			local nNightshadeOnSelf = GetCountOfItemOnSelf(nightshadeType)
			if nNightshadeOnSelf < restock.regsCnt then
				local restockCnt = restock.regsCnt - nNightshadeOnSelf
				print("Restocked: ".. restockCnt.." Nightshade")
				if nNightshadeOnSelf == 0 then
					UO.Drag(t[i].ID, restockCnt)
					UO.DropC(UO.BackpackID, regDropX, regDropY)
				else
					UO.Drag(t[i].ID, restockCnt)
					UO.DropC(GetIDOfItemOnSelf(nightshadeType))
				end
				wait(700)
			else
				print("We have enough Nightshade already.")
			end
		end
	end
	--Pouches
	if restock.pouchesCnt > 0 then    
		UO.SysMessage("Restocking Pouches...", 55)
		local pouchDropX = 0
		local pouchDropY = 175
		
		local itemList = ScanItems(false)
		local t = FindItems(itemList,{Type=pouchType, ContID=targetContainer}, {ContID=UO.BackpackID})
		for i = 1, #t do
			local nPouchesOnSelf = GetCountOfItemOnSelf(pouchType)
			
			if nPouchesOnSelf < restock.pouchesCnt then
				print("Taking Pouch.")
				UO.Drag(t[i].ID, 1)
				UO.DropC(UO.BackpackID, pouchDropX, pouchDropY)
				wait(800)
			else
				print("We have enough Pouches already")
				break
			end
		end
	end
	--Str Pots
	if restock.strCnt > 0 then
		UO.SysMessage("Restocking Str Pots...", 55)
		local strPotDropX = 125
		local strPotDropY = 0
		
		local itemList = ScanItems(false)
		local t = FindItems(itemList,{Type=strPotType, ContID=targetContainer}, {ContID=UO.BackpackID})
		for i = 1, #t do
			local nStrPotsOnSelf = GetCountOfItemOnSelf(strPotType)
			
			if nStrPotsOnSelf < restock.strCnt then
				print("Taking Strength Potions.")
				UO.Drag(t[i].ID, 1)
				UO.DropC(UO.BackpackID, strPotDropX, strPotDropY)
				wait(800)
			else
				print("We have enough Strength potions already.")
				break
			end
		end
	end
	--Agil Pots
	if restock.agilCnt > 0 then
		UO.SysMessage("Restocking Agility Pots...", 55)
		print("Restocking Agility Pots...")
		local agilePotDropX = 99
		local agilePotDropY = 0
		
		local itemList = ScanItems(false)
		local t = FindItems(itemList,{Type=agilPotType, ContID=targetContainer}, {ContID=UO.BackpackID})
		for i = 1, #t do
			local nAgilePotsOnSelf = GetCountOfItemOnSelf(agilPotType)
			
			if nAgilePotsOnSelf < restock.agilCnt then
				print("Taking Agility Potions.")
				UO.Drag(t[i].ID, 1)
				UO.DropC(UO.BackpackID, agilePotDropX, agilePotDropY)
				wait(800)
			else
				print("We have enough Agility potions already.")
				break
			end
		end
	end
	--Cure Pots
	if restock.cureCnt > 0 then
		UO.SysMessage("Restocking Cure Pots...", 55)
		print("Restocking Cure Pots...")
		local curePotDropX = 150
		local curePotDropY = 0
		
		local itemList = ScanItems(false)
		local t = FindItems(itemList,{Type=curePotType, ContID=targetContainer}, {ContID=UO.BackpackID})
		for i = 1, #t do
			local nCurePotsOnSelf = GetCountOfItemOnSelf(curePotType)
			
			if nCurePotsOnSelf < restock.cureCnt then
				print("Taking Cure Potions.")
				UO.Drag(t[i].ID, 1)
				UO.DropC(UO.BackpackID, curePotDropX, curePotDropY)
				wait(800)
			else
				print("We have enough Cure potions already.")
				break
			end
		end
	end
	--HealPots
	if restock.healCnt > 0 then
		UO.SysMessage("Restocking Heal Pots...", 55)
		print("Restocking Heal Pots...")
		local healPotDropX = 79
		local healPotDropY = 0
		
		local itemList = ScanItems(false)
		local t = FindItems(itemList,{Type=healPotType, ContID=targetContainer}, {ContID=UO.BackpackID})
		for i = 1, #t do
			local nHealPotsOnSelf = GetCountOfItemOnSelf(healPotType)
			
			if nHealPotsOnSelf < restock.healCnt then
				print("Taking Healing Potions.")
				UO.Drag(t[i].ID, 1)
				UO.DropC(UO.BackpackID, healPotDropX, healPotDropY)
				wait(800)
			else
				print("We have enough Healing potions already.")
				break
			end
		end
	end
	--Explosion Pots
	if restock.exploCnt > 0 then
		UO.SysMessage("Restocking Explosion Pots...", 55)
		print("Restocking Explosion Pots...")
		local exploPotDropX = 109
		local exploPotDropY = 0
		
		local itemList = ScanItems(false)
		local t = FindItems(itemList,{Type=exploPotType, ContID=targetContainer}, {ContID=UO.BackpackID})
		for i = 1, #t do
			local nExploPotsOnSelf = GetCountOfItemOnSelf(exploPotType)
			
			if nExploPotsOnSelf < restock.exploCnt then
				print("Taking Explosion Potions.")
				UO.Drag(t[i].ID, 1)
				UO.DropC(UO.BackpackID, exploPotDropX, exploPotDropY)
				wait(800)
			else
				print("We have enough Explosion potions already.")
				break
			end
		end
	end
	--Refresh Pots
	if restock.refCnt > 0 then
		UO.SysMessage("Restocking Refresh Pots...", 55)
		print("Restocking Refresh Pots...")
	    local refPotDropX = 75
		local refPotDropY = 0
		
	    local itemList = ScanItems(false)
		local t = FindItems(itemList,{Type=refreshPotType, ContID=targetContainer}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nRefPotsOnSelf = GetCountOfItemOnSelf(refreshPotType)
			
		    if nRefPotsOnSelf < restock.refCnt then
				print("Taking Refresh Potions.")
		        UO.SysMessage("  --Taking Refresh Potion.", 30)
				UO.Drag(t[i].ID, 1)
				UO.DropC(UO.BackpackID, refPotDropX, refPotDropY)
				wait(800)
			else
			    print("We have enough Refresh potions already.")
				break
			end
		end
	end
	print("Done.")
end

function TheBigRestock(restock)
	
	--Meat
	UO.ExMsg(UO.CharID, 0, 55, "Restocking!" )
	if restock.meatCnt > 0 then
		UO.SysMessage("Restocking Meat...", 55)
		print("Restocking Meat...")
		UO.LObjectID = restock.generalBagID
		UO.Macro(17, 0)
	    wait(700)
		local itemList = ScanItems(false)
		--Ignore items in backpack (itemsList, True filter, False filter)
		--meat
		
		local t = FindItems(itemList, {Type=meatType, ContID=restock.generalBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
			local nMeatOnSelf = GetCountOfItemOnSelf(meatType)
			if nMeatOnSelf < restock.meatCnt then
				local restockCnt = restock.meatCnt - nMeatOnSelf
				print("Restocked: ".. restockCnt.." Meat.") 
		        UO.SysMessage("  --Restocked: ".. restockCnt.." Meat.", 30)
				local meatDropX = 0
				local meatDropY = 90
				if nMeatOnSelf == 0 then
					UO.Drag(t[i].ID, restockCnt)
					UO.DropC(UO.BackpackID, meatDropX, meatDropY)
				else
					UO.Drag(t[i].ID, restockCnt)
					UO.DropC(GetIDOfItemOnSelf(meatType))
				end
				wait(700)
				
			else
				print("We have enough Meat already")
			end
		end
	end
    --Bandages   
	if restock.aidsCnt > 0 then
		UO.SysMessage("Restocking Bandages...", 55)
		print("Restocking Bandages...")
		UO.LObjectID = restock.generalBagID
		UO.Macro(17, 0)
	    wait(700)
	    local itemList = ScanItems(false)
		--Ignore items in backpack (itemsList, True filter, False filter)
        local t = FindItems(itemList, {Type=bandageType, ContID=restock.generalBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nBandagesOnSelf = GetCountOfItemOnSelf(bandageType)
		    if nBandagesOnSelf < restock.aidsCnt then
			    local restockCnt = restock.aidsCnt - nBandagesOnSelf
				print("Restocked: ".. restockCnt.." Bandages") 
		        UO.SysMessage("  --Restocked: ".. restockCnt.." Bandages.", 30)
				local bandageDropX = 0
				local bandageDropY = 0
				if nBandagesOnSelf == 0 then
				    UO.Drag(t[i].ID, restockCnt)
				    UO.DropC(UO.BackpackID, bandageDropX, bandageDropY)
				else
				    UO.Drag(t[i].ID, restockCnt)
				    UO.DropC(GetIDOfItemOnSelf(bandageType))
				end
				wait(700)
				
			else
			    print("We have enough bandages already")
			end
		end
	end

	--Regs
	if restock.regsCnt > 0 then
		UO.SysMessage("Restocking Regs...", 55)
		print("Restocking Regs...")
		UO.LObjectID = restock.generalBagID
		UO.Macro(17, 0)
	    wait(700)
	    local regDropX = 200
		local regDropY = 200
	    local itemList = ScanItems(false)
		--Ignore items in backpack (itemsList, True filter, False filter)
		--Bloodmoss
        local t = FindItems(itemList,{Type=bloodmossType, ContID=restock.generalBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nBloodmossOnSelf = GetCountOfItemOnSelf(bloodmossType)
		    if nBloodmossOnSelf < restock.regsCnt then
			    local restockCnt = restock.regsCnt - nBloodmossOnSelf
				print("Restocked: ".. restockCnt.." Bloodmoss.")
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
			    print("We have enough Bloodmoss already.")
			end
		end
	    --Black Pearl
        local t = FindItems(itemList,{Type=blackPearlType, ContID=restock.generalBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nBlackPearlOnSelf = GetCountOfItemOnSelf(blackPearlType)
		    if nBlackPearlOnSelf < restock.regsCnt then
			    local restockCnt = restock.regsCnt - nBlackPearlOnSelf
				print("Restocked: ".. restockCnt.." Black Pearl.")
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
			    print("We have enough Black Pearl already.")
			end
		end
	    --Mandrake
        local t = FindItems(itemList,{Type=mandrakeRootType, ContID=restock.generalBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nMandrakeRootOnSelf = GetCountOfItemOnSelf(mandrakeRootType)
		    if nMandrakeRootOnSelf < restock.regsCnt then
			    local restockCnt = restock.regsCnt - nMandrakeRootOnSelf
				print("Restocked: ".. restockCnt.." Mandrake Root.")
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
			    print("We have enough Mandrake Root already.")
			end
		end
	    --Garlic
        local t = FindItems(itemList,{Type=garlicType, ContID=restock.generalBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nGarlicOnSelf = GetCountOfItemOnSelf(garlicType)
		    if nGarlicOnSelf < restock.regsCnt then
			    local restockCnt = restock.regsCnt - nGarlicOnSelf
				print("Restocked: ".. restockCnt.." Garlic.")
		        UO.SysMessage("  --Restocked: ".. restockCnt.." Garlic.", 30)
				if nGarlicOnSelf == 0 then
				    UO.Drag(t[i].ID, restockCnt)
				    UO.DropC(UO.BackpackID, regDropX, regDropY)
				else
				    UO.Drag(t[i].ID, restockCnt)
				    UO.DropC(GetIDOfItemOnSelf(garlicType))
				end
				wait(700)
			else
			    print("We have enough Garlic already.")
			end
		end
	    --Ginseng
        local t = FindItems(itemList,{Type=ginsengType, ContID=restock.generalBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nGinsengOnSelf = GetCountOfItemOnSelf(ginsengType)
		    if nGinsengOnSelf < restock.regsCnt then
			    local restockCnt = restock.regsCnt - nGinsengOnSelf
				print("Restocked: ".. restockCnt.." Ginseng.")
		        UO.SysMessage("  --Restocked: ".. restockCnt.." Ginseng.", 30)
				if nGinsengOnSelf == 0 then
				    UO.Drag(t[i].ID, restockCnt)
				    UO.DropC(UO.BackpackID, regDropX, regDropY)
				else
				    UO.Drag(t[i].ID, restockCnt)
				    UO.DropC(GetIDOfItemOnSelf(ginsengType))
				end
				wait(700)
			else
			    print("We have enough Ginseng already.")
			end
		end
	    --Sulf Ash
        local t = FindItems(itemList,{Type=sulfAshType, ContID=restock.generalBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nSulfAshOnSelf = GetCountOfItemOnSelf(sulfAshType)
		    if nSulfAshOnSelf < restock.regsCnt then
			    local restockCnt = restock.regsCnt - nSulfAshOnSelf
				print("Restocked: ".. restockCnt.." Sulf Ash.")
		        UO.SysMessage("  --Restocked: ".. restockCnt.." Sulf Ash.", 30)
				if nSulfAshOnSelf == 0 then
				    UO.Drag(t[i].ID, restockCnt)
				    UO.DropC(UO.BackpackID, regDropX, regDropY)
				else
				    UO.Drag(t[i].ID, restockCnt)
				    UO.DropC(GetIDOfItemOnSelf(sulfAshType))
				end
				wait(700)
			else
			    print("We have enough Sulf Ash already.")
			end
		end
	    --Spider Silk
        local t = FindItems(itemList,{Type=spiderSilkType, ContID=restock.generalBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nSpiderSilkOnSelf = GetCountOfItemOnSelf(spiderSilkType)
		    if nSpiderSilkOnSelf < restock.regsCnt then
			    local restockCnt = restock.regsCnt - nSpiderSilkOnSelf
				print("Restocked: ".. restockCnt.." Spider Silk.")
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
			    print("We have enough Spider Silk already.")
			end
		end
	    --Nightshade
        local t = FindItems(itemList,{Type=nightshadeType, ContID=restock.generalBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nNightshadeOnSelf = GetCountOfItemOnSelf(nightshadeType)
		    if nNightshadeOnSelf < restock.regsCnt then
			    local restockCnt = restock.regsCnt - nNightshadeOnSelf
				print("Restocked: ".. restockCnt.." Nightshade")
		        UO.SysMessage("  --Restocked: ".. restockCnt.." Nightshade.", 30)
				if nNightshadeOnSelf == 0 then
				    UO.Drag(t[i].ID, restockCnt)
				    UO.DropC(UO.BackpackID, regDropX, regDropY)
				else
				    UO.Drag(t[i].ID, restockCnt)
				    UO.DropC(GetIDOfItemOnSelf(nightshadeType))
				end
				wait(700)
			else
			    print("We have enough Nightshade already.")
			end
		end
	end
	
	--Pouches
	if restock.pouchesCnt > 0 then    
		UO.SysMessage("Restocking Pouches...", 55)
		print("Restocking Pouches...")
		UO.LObjectID = restock.pouchesBagID
		UO.Macro(17, 0)
	    wait(700)
	    local pouchDropX = 0
		local pouchDropY = 175
		
	    local itemList = ScanItems(false)
		local t = FindItems(itemList,{Type=pouchType, ContID=restock.pouchesBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nPouchesOnSelf = GetCountOfItemOnSelf(pouchType)
			
		    if nPouchesOnSelf < restock.pouchesCnt then
				print("Taking Pouch.")
		        UO.SysMessage("  --Taking Pouch.", 30)
				UO.Drag(t[i].ID, 1)
				UO.DropC(UO.BackpackID, pouchDropX, pouchDropY)
				wait(800)
			else
			    print("We have enough Pouches already")
				break
			end
		end
	end
	--Str Pots
	if restock.strCnt > 0 then
		UO.SysMessage("Restocking Str Pots....", 55)
		print("Restocking Str Pots...")
		UO.LObjectID = restock.strPotBagID
		UO.Macro(17, 0)
	    wait(700)
	    local strPotDropX = 125
		local strPotDropY = 0
		
	    local itemList = ScanItems(false)
		local t = FindItems(itemList,{Type=strPotType, ContID=restock.strPotBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nStrPotsOnSelf = GetCountOfItemOnSelf(strPotType)
			
		    if nStrPotsOnSelf < restock.strCnt then
				print("Taking Strength Potion.")
		        UO.SysMessage("  --Taking Strength Potion.", 30)
				UO.Drag(t[i].ID, 1)
				UO.DropC(UO.BackpackID, strPotDropX, strPotDropY)
				wait(800)
			else
			    print("We have enough Strength potions already.")
				break
			end
		end
	end
	--Agil Pots
	if restock.agilCnt > 0 then
		UO.SysMessage("Restocking Agility Pots...", 55)
		print("Restocking Agility Pots...")
		UO.LObjectID = restock.agilPotBagID
		UO.Macro(17, 0)
	    wait(700)
	    local agilePotDropX = 99
		local agilePotDropY = 0
		
	    local itemList = ScanItems(false)
		local t = FindItems(itemList,{Type=agilPotType, ContID=restock.agilPotBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nAgilePotsOnSelf = GetCountOfItemOnSelf(agilPotType)
			
		    if nAgilePotsOnSelf < restock.agilCnt then
				print("Taking Agility Potion.")
		        UO.SysMessage("  --Taking Agility Potion.", 30)
				UO.Drag(t[i].ID, 1)
				UO.DropC(UO.BackpackID, agilePotDropX, agilePotDropY)
				wait(800)
			else
			    print("We have enough Agility potions already.")
				break
			end
		end
	end
	--Cure Pots
	if restock.cureCnt > 0 then
		UO.SysMessage("Restocking Cure Pots...", 55)
		print("Restocking Cure Pots...")
		UO.LObjectID = restock.curePotBagID
		UO.Macro(17, 0)
	    wait(700)
	    local curePotDropX = 150
		local curePotDropY = 0
		
	    local itemList = ScanItems(false)
		local t = FindItems(itemList,{Type=curePotType, ContID=restock.curePotBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nCurePotsOnSelf = GetCountOfItemOnSelf(curePotType)
			
		    if nCurePotsOnSelf < restock.cureCnt then
				print("Taking Cure Potion.")
		        UO.SysMessage("  --Taking Cure Potion.", 30)
				UO.Drag(t[i].ID, 1)
				UO.DropC(UO.BackpackID, curePotDropX, curePotDropY)
				wait(800)
			else
			    print("We have enough Cure potions already.")
				break
			end
		end
	end
	--HealPots
	if restock.healCnt > 0 then
		UO.SysMessage("Restocking Heal Pots...", 55)
		print("Restocking Heal Pots...")
		UO.LObjectID = restock.healPotBagID
		UO.Macro(17, 0)
	    wait(700)
	    local healPotDropX = 89
		local healPotDropY = 0
		
	    local itemList = ScanItems(false)
		local t = FindItems(itemList,{Type=healPotType, ContID=restock.healPotBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nHealPotsOnSelf = GetCountOfItemOnSelf(healPotType)
			
		    if nHealPotsOnSelf < restock.healCnt then
				print("Taking Healing Potion.")
		        UO.SysMessage("  --Taking Healing Potion.", 30)
				UO.Drag(t[i].ID, 1)
				UO.DropC(UO.BackpackID, healPotDropX, healPotDropY)
				wait(800)
			else
			    print("We have enough Healing potions already.")
				break
			end
		end
	end
	--Explosion Pots
	if restock.exploCnt > 0 then
		UO.SysMessage("Restocking Explosion Pots...", 55)
		print("Restocking Explosion Pots...")
		UO.LObjectID = restock.curePotBagID
		UO.Macro(17, 0)
	    wait(700)
	    local exploPotDropX = 109
		local exploPotDropY = 0
		
	    local itemList = ScanItems(false)
		local t = FindItems(itemList,{Type=exploPotType, ContID=restock.curePotBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nExploPotsOnSelf = GetCountOfItemOnSelf(exploPotType)
			
		    if nExploPotsOnSelf < restock.exploCnt then
				print("Taking Explosion Potions.")
		        UO.SysMessage("  --Taking Explosion Potion.", 30)
				UO.Drag(t[i].ID, 1)
				UO.DropC(UO.BackpackID, exploPotDropX, exploPotDropY)
				wait(800)
			else
			    print("We have enough Explosion potions already.")
				break
			end
		end
	end
	--Refresh Pots
	if restock.refCnt > 0 then
		UO.SysMessage("Restocking Refresh Pots...", 55)
		print("Restocking Refresh Pots...")
		UO.LObjectID = restock.refPotBagID
		UO.Macro(17, 0)
	    wait(700)
	    local refPotDropX = 75
		local refPotDropY = 0
		
	    local itemList = ScanItems(false)
		local t = FindItems(itemList,{Type=refreshPotType, ContID=restock.refPotBagID}, {ContID=UO.BackpackID})
		for i = 1, #t do
		    local nRefPotsOnSelf = GetCountOfItemOnSelf(refreshPotType)
			
		    if nRefPotsOnSelf < restock.refCnt then
				print("Taking Refresh Potions.")
		        UO.SysMessage("  --Taking Refresh Potion.", 30)
				UO.Drag(t[i].ID, 1)
				UO.DropC(UO.BackpackID, refPotDropX, refPotDropY)
				wait(800)
			else
			    print("We have enough Refresh potions already.")
				break
			end
		end
	end
	UO.SysMessage("Finished", 55)
	print("Done.")

end
	okayBtn.OnClick = function()
		--isVerbose = isVerboseCkBx.Checked
		--useAnyItemDelay = tonumber(itemDelayEdit.Text)
		--isOpeningDoors = isDoorsCkBx.Checked
		--aUONextHumanKey = nextHumanEdit.Text
		--targetNearestHumanKey = nearHumanEdit.Text
		--isChugHealOnLow = isChugHealCkBx.Checked
		--chugHealPotHealth = tonumber(healPotHPEdit.Text)
		--isChugCureOnPoison = isChugCureCkBx.Checked
		--isChugRefreshPotion = isChugRefreshCkBx.Checked
		--chugRefreshPotOnStamina = tonumber(RefreshPotUsageEdit.Text)
		--isAutoParaPouch = isParaPouchingCkBx.Checked
		unRestockPVPItemsKey = unRestockKeyEdit.Text
		restockPVPItemsKey = restockKeyEdit.Text
		restockFromCorpseKey = restockCorpseKeyEdit.Text
		meatRestockCnt = tonumber(restockMeatEdit.Text)
		bangageRestockCnt = tonumber(restockBandageEdit.Text)
		regRestockCnt = tonumber(restockRegsEdit.Text)
		pouchRestockCnt = tonumber(restockPouchesEdit.Text)
		strPotRestockCnt = tonumber(restockStrPotEdit.Text)
		agilPotRestockCnt = tonumber(restockAgilPotEdit.Text)
		curePotRestockCnt = tonumber(restockCurePotEdit.Text)
		healPotRestockCnt = tonumber(restockHealPotEdit.Text)
		explPotRestockCnt = tonumber(restockExplPotEdit.Text)
		refrPotRestockCnt = tonumber(restockRefrPotEdit.Text)
		healPotBagID = tonumber(healPotBagIDEdit.Text)
		curePotBagID = tonumber(curePotBagIDEdit.Text)
		exploPotBagID = tonumber(exploPotBagIDEdit.Text)
		pouchesBagID = tonumber(pouchesBagIDEdit.Text)
		generalItemsBagID = tonumber(generalItemsBagIDEdit.Text)
		refreshPotBagID = tonumber(refreshPotBagIDEdit.Text)
		agilPotBagID = tonumber(agilPotBagIDEdit.Text)
		strPotBagID = tonumber(strPotBagIDEdit.Text)
        local f,e = openfile("../chars/" .. UO.CharName .. ".lua", 'w')
		f:write("isVerbose = " .. tostring(isVerbose) .. "\n")
		--f:write("useAnyItemDelay = " .. tostring(useAnyItemDelay) .. "\n")
		--f:write("isOpeningDoors = " .. tostring(isOpeningDoors) .. "\n")
		--f:write("aUONextHumanKey = \"" .. tostring(aUONextHumanKey) .. "\"\n")
		--f:write("targetNearestHumanKey = \"" .. tostring(targetNearestHumanKey) .. "\"\n")
		--f:write("isChugHealOnLow = " .. tostring(isChugHealOnLow) .. "\n")
		--f:write("chugHealPotHealth = " .. tostring(chugHealPotHealth) .. "\n")
		--f:write("isChugCureOnPoison = " .. tostring(isChugCureOnPoison) .. "\n")
		--f:write("isChugRefreshPotion = " .. tostring(isChugRefreshPotion) .. "\n")
		--f:write("chugRefreshPotOnStamina = " .. tostring(chugRefreshPotOnStamina) .. "\n")
		--f:write("isAutoParaPouch = " .. tostring(isAutoParaPouch) .. "\n")
		f:write("unRestockPVPItemsKey = \"" .. tostring(unRestockPVPItemsKey) .. "\"\n")
		f:write("restockPVPItemsKey = \"" .. tostring(restockPVPItemsKey) .. "\"\n")
		f:write("restockFromCorpseKey = \"" .. tostring(restockFromCorpseKey) .. "\"\n")
		f:write("meatRestockCnt = " .. tostring(meatRestockCnt) .. "\n")
		f:write("bangageRestockCnt = " .. tostring(bangageRestockCnt) .. "\n")
		f:write("regRestockCnt = " .. tostring(regRestockCnt) .. "\n")
		f:write("pouchRestockCnt = " .. tostring(pouchRestockCnt) .. "\n")
		f:write("strPotRestockCnt = " .. tostring(strPotRestockCnt) .. "\n")
		f:write("agilPotRestockCnt = " .. tostring(agilPotRestockCnt) .. "\n")
		f:write("curePotRestockCnt = " .. tostring(curePotRestockCnt) .. "\n")
		f:write("healPotRestockCnt = " .. tostring(healPotRestockCnt) .. "\n")
		f:write("explPotRestockCnt = " .. tostring(explPotRestockCnt) .. "\n")
		f:write("refrPotRestockCnt = " .. tostring(refrPotRestockCnt) .. "\n")
		f:write("healPotBagID = " .. tostring(healPotBagID) .. "\n")
		f:write("curePotBagID = " .. tostring(curePotBagID) .. "\n")
		f:write("exploPotBagID = " .. tostring(exploPotBagID) .. "\n")
		f:write("pouchesBagID = " .. tostring(pouchesBagID) .. "\n")
		f:write("generalItemsBagID = " .. tostring(generalItemsBagID) .. "\n")
		f:write("strPotBagID = " .. tostring(strPotBagID) .. "\n")
		f:write("refreshPotBagID = " .. tostring(refreshPotBagID) .. "\n")
		f:write("agilPotBagID = " .. tostring(agilPotBagID) .. "\n")
		f:close()
	    print("Settings Saved")
		Obj.Exit()
	    --Save
	end	
	form.Show()
	Obj.Loop()
	
    
	for i = 1, #freeObjList do
	    Obj.Free(freeObjList[i])    
	end
	
	return ret

  end

function InversedRestock()
	UO.SysMessage("Un-Restocking...", 55)
    print("Un-Restocking...")
	local stockList = {}
	stockList[#stockList + 1] = {bandageType, generalItemsBagID}
	stockList[#stockList + 1] = {meatType,generalItemsBagID}
	stockList[#stockList + 1] = {bloodmossType,generalItemsBagID}
	stockList[#stockList + 1] = {blackPearlType,generalItemsBagID}
	stockList[#stockList + 1] = {mandrakeRootType,generalItemsBagID}
	stockList[#stockList + 1] = {spiderSilkType,generalItemsBagID}
	stockList[#stockList + 1] = {sulfAshType,generalItemsBagID}
	stockList[#stockList + 1] = {nightshadeType,generalItemsBagID}
	stockList[#stockList + 1] = {garlicType,generalItemsBagID}
	stockList[#stockList + 1] = {ginsengType,generalItemsBagID}
	stockList[#stockList + 1] = {curePotType,curePotBagID}
	stockList[#stockList + 1] = {strPotType,strPotBagID}
	stockList[#stockList + 1] = {refreshPotType,refreshPotBagID}
	stockList[#stockList + 1] = {healPotType,healPotBagID}
	stockList[#stockList + 1] = {exploPotType,exploPotBagID}
	stockList[#stockList + 1] = {agilPotType,agilPotBagID}
	stockList[#stockList + 1] = {pouchType,pouchesBagID}

	for i = 1, #stockList do 
	    local itemList = ScanItems(false)
		local t = FindItems(itemList,{Type=stockList[i][1], ContID=UO.BackpackID})
		while #t > 0 do
		    for j = 1, #t do
			    if CheckContainerInRange(stockList[i][2]) == true then
					print("  --Putting an item away. " .. stockList[i][1])
					UO.SysMessage("  --Putting an item away.", 75)
					UO.Drag(t[j].ID, t[j].Stack)
					UO.DropC(stockList[i][2])
					wait(600)
				else
				    print("Container out of range!")
					UO.SysMessage("Container out of range!", 75)
					wait(700)
					return false
				end
			end
			wait(200)
		    itemList = ScanItems(false)
			t = FindItems(itemList,{Type=stockList[i][1], ContID=UO.BackpackID})
		end
	end
	wait(700)
    print("Finished Un-Restocking.")
	UO.SysMessage("Done.", 55)
	return true
end
