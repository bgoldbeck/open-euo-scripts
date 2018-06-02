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
doors = {1769, 1657, 1659, 1709, 1755, 1711, 1703, 1655, 8175, 1687, 1719, 1751, 1767, 2086, 2107, 2126, 2152, 806, 822, 838, 854, 1735, 790, 1671, 1663, 8183, 1695, 1711, 1727, 1759, 1775, 2094, 2115, 2134, 2160, 814, 830, 846, 848, 864, 1743, 798, 1679, 1653, 8173, 1685, 1701, 1717, 1749, 1765, 2084, 2124, 2150, 804, 820, 836, 852, 1733, 788, 1669}

--/Doors

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

function UseParalyzePouch()
    t = ScanItems(true, {Type=pouchType, ContID=UO.BackpackID})
    for i = 1, #t do
		if t[i].Col == 38 then
            wait(math.random(300))
		    UO.LObjectID = t[i].ID 
			UO.Macro(17, 0)
			return true
		end
    end
	return false
end

function OpenNearestDoor()
    if doorWasOpened == true then
	   
		if doorWasOpened == true then
			return
		end
	end
    t = ScanItems(true,{Type=doors,Dist=2})    
	for i = 1, #t do
		if not (t[i].Z > UO.CharPosZ + 7) or not (t[i].Z > UO.CharPosZ - 7) then
		    UO.LObjectID = t[i].ID
			UO.Macro(17, 0)
			return true
		end
    end
	return false
end

function GetIsParalyzed()
   
	local res = j:find("You cannot move!")
	if (res ~= nil) then
	    j:clear()
		return true
	end

	return false
end

function GetNearestHuman()
    t = ScanItems(true,{Type={400,401},Dist=10})
    local nearestDist = 99
    local nearestID = 0
    for i = 1, #t do
        if (t[i].Dist < nearestDist) then
			if (t[i].ID ~= UO.CharID) and (t[i].Rep ~= 7) and (t[i].Rep ~= 2) then
				nearestDist = t[i].Dist
				nearestID   = t[i].ID
			end
        end
        --print("Type "..t[i].Type )
        --print("Distance away "..t[i].Dist)
        --print("ID "..t[i].ID)
        --print("Rep "..t[i].Rep)
    end
    return nearestID
end

function TargetNearestHuman(aUOTargetNextHumanKey)
	local nearestID = GetNearestHuman()
	if nearestID ~= 0 then
		for i = 1, 20, 1 do
		    --The aUOTargetNextHumanKey key is assist uo bound to macro for get enemy target nearest humanoid.
			--getenemy 'innocent' 'gray' 'murderer' 'criminal' 'humanoid'
			--if findalias 'enemy' and inrange 'enemy' 10
				--setalias 'last' 'enemy'
			--endif

			UO.Key(aUOTargetNextHumanKey)
			wait(2)
			if (nearestID == UO.EnemyID) then
			    UO.LTargetKind = 1
			    break
			end
		end
	end
end

function GetIsPoisoned()
    if UO.CharStatus == nil then 
	    return false 
	end
    if string.match(UO.CharStatus, "C") ~= nil then
	    return true
	end
	return false
end

function GetHP(n) 
  local i,nID,nHP,_ = 0 
  repeat 
   _,_,_,_,_,_,nID,_,nHP = UO.GetCont(i) 
   i = i + 1 
  until nID==n or nID==nil 
  return nHP 
end 

function ItemWasUsed(nextTimeCanUse)
    itemReuseTimer = nextTimeCanUse 
end

function CanUseAnotherItem(currentTime)
    if currentTime < itemReuseTimer then
		return false
    end	
	return true
end

function HealPotionUsed(nextTimeCanUse)
    healPotionReuseTimer = nextTimeCanUse 
end

function CanUseHealPotion(currentTime)
    if currentTime < healPotionReuseTimer then
		return false
    end	
	return true
end

function GetCurrentBandageCount()
	local count = 0
	t = ScanItems(true,{ Type=bandageType, ContID=UO.BackpackID})
	for i=1, #t do
		count = count + t[i].Stack
	end	
	return count
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
	form.Height = 480
	form.Width = 350
	form.FormStyle = 2
	form.Color = 65000
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
	okayBtn.Caption = "Okay"
	okayBtn.Left = 100
	okayBtn.Width = 100
	okayBtn.Top = 400
	okayBtn.Height = 30
	okayBtn.Parent = form
	freeObjList[#freeObjList + 1] = okayBtn
	
	--Is Verbose
	--Labels
	local isVerboseLabel = Obj.Create("TLabel")
	isVerboseLabel.Caption = "Make script verbose."
	isVerboseLabel.Height = 25
	isVerboseLabel.Width = 200
	isVerboseLabel.Left = 65
	isVerboseLabel.Top = top
	isVerboseLabel.Font.Color = 0
	isVerboseLabel.Font.Size = 12
	isVerboseLabel.Parent = form
	freeObjList[#freeObjList + 1] = isVerboseLabel
	--CheckBoxes
	local isVerboseCkBx = Obj.Create("TCheckBox")
	if isVerbose == true then
	    isVerboseCkBx.Checked = true
	else
	    isVerboseCkBx.Checked = false
	end
	isVerboseCkBx.Height = 15
	isVerboseCkBx.Width = 10
	isVerboseCkBx.Top = top
	isVerboseCkBx.Left = 0
	isVerboseCkBx.Parent = form
	freeObjList[#freeObjList + 1] = isVerboseCkBx
	--/Is Verbose
	
	top = top + 25
	
	--Item Delay
	--Labels
	local itemDelayLabel = Obj.Create("TLabel")
	itemDelayLabel.Caption = "Item usage delay."
	itemDelayLabel.Height = 25
	itemDelayLabel.Width = 200
	itemDelayLabel.Left = 65
	itemDelayLabel.Top = top
	itemDelayLabel.Font.Color = 0
	itemDelayLabel.Font.Size = 12
	itemDelayLabel.Parent = form
	freeObjList[#freeObjList + 1] = itemDelayLabel
  	
	--Edits
	local itemDelayEdit = Obj.Create("TEdit")
	itemDelayEdit.Text = tostring(useAnyItemDelay)
	itemDelayEdit.Height = 25
	itemDelayEdit.Width = 55
	itemDelayEdit.Top = top
	itemDelayEdit.Left = 0
	itemDelayEdit.Parent = form
	freeObjList[#freeObjList + 1] = itemDelayEdit
	--/Item Delay
	
	top = top + 25
	
    --Doors
	--Labels
	local isDoorsLabel = Obj.Create("TLabel")
	isDoorsLabel.Caption = "Auto Open Doors?"
	isDoorsLabel.Height = 25
	isDoorsLabel.Width = 200
	isDoorsLabel.Left = 65
	isDoorsLabel.Top = top
	isDoorsLabel.Font.Color = 0
	isDoorsLabel.Font.Size = 12
	isDoorsLabel.Parent = form
	freeObjList[#freeObjList + 1] = isDoorsLabel
	--CheckBoxes
	local isDoorsCkBx = Obj.Create("TCheckBox")
	if isOpeningDoors == true then
	    isDoorsCkBx.Checked = true
	else
	    isDoorsCkBx.Checked = false
	end
	isDoorsCkBx.Height = 15
	isDoorsCkBx.Width = 10
	isDoorsCkBx.Top = top
	isDoorsCkBx.Left = 0
	isDoorsCkBx.Parent = form
	freeObjList[#freeObjList + 1] = isDoorsCkBx
	--/Doors
	
	top = top + 25

	--Next Human Key
	--Labels
	local nextHumanLabel = Obj.Create("TLabel")
	nextHumanLabel.Caption = "AssistUO Target Next Human Key"
	nextHumanLabel.Height = 25
	nextHumanLabel.Width = 200
	nextHumanLabel.Left = 65
	nextHumanLabel.Top = top
	nextHumanLabel.Font.Color = 0
	nextHumanLabel.Font.Size = 12
	nextHumanLabel.Parent = form
	freeObjList[#freeObjList + 1] = nextHumanLabel
  	
	--Edits
	local nextHumanEdit = Obj.Create("TEdit")
	nextHumanEdit.Text = tostring(aUONextHumanKey)
	nextHumanEdit.Height = 25
	nextHumanEdit.Width = 55
	nextHumanEdit.Top = top
	nextHumanEdit.Left = 0
	nextHumanEdit.Parent = form
	freeObjList[#freeObjList + 1] = nextHumanEdit
	--/Next Human Key
	
	top = top + 25
	
	--Nearest Human Key
	--Labels
	local nearHumanLabel = Obj.Create("TLabel")
	nearHumanLabel.Caption = "Target Nearest Human Key"
	nearHumanLabel.Height = 25
	nearHumanLabel.Width = 200
	nearHumanLabel.Left = 65
	nearHumanLabel.Top = top
	nearHumanLabel.Font.Color = 0
	nearHumanLabel.Font.Size = 12
	nearHumanLabel.Parent = form
	freeObjList[#freeObjList + 1] = nearHumanLabel
  	
	--Edits
	local nearHumanEdit = Obj.Create("TEdit")
	nearHumanEdit.Text = tostring(targetNearestHumanKey)
	nearHumanEdit.Height = 25
	nearHumanEdit.Width = 55
	nearHumanEdit.Top = top
	nearHumanEdit.Left = 0
	nearHumanEdit.Parent = form
	freeObjList[#freeObjList + 1] = nearHumanEdit
	--/Nearest Human Key
	
	top = top + 25	
	
	--Chugging Heal?
	--Labels
	local isChugHealLabel = Obj.Create("TLabel")
	isChugHealLabel.Caption = "Is Chugging Heal potions?"
	isChugHealLabel.Height = 25
	isChugHealLabel.Width = 200
	isChugHealLabel.Left = 65
	isChugHealLabel.Top = top
	isChugHealLabel.Font.Color = 0
	isChugHealLabel.Font.Size = 12
	isChugHealLabel.Parent = form
	freeObjList[#freeObjList + 1] = isChugHealLabel
	--CheckBoxes
	local isChugHealCkBx = Obj.Create("TCheckBox")
	if isChugHealOnLow == true then
	    isChugHealCkBx.Checked = true
	else
	    isChugHealCkBx.Checked = false
	end
	isChugHealCkBx.Height = 15
	isChugHealCkBx.Width = 10
	isChugHealCkBx.Top = top
	isChugHealCkBx.Left = 0
	isChugHealCkBx.Parent = form
	freeObjList[#freeObjList + 1] = isChugHealCkBx
	--/Chugging Heal?
	
	top = top + 25	
	
	--Heal potion hp %
	--Labels
	local healPotHPLabel = Obj.Create("TLabel")
	healPotHPLabel.Caption = "Heal potion usage %"
	healPotHPLabel.Height = 25
	healPotHPLabel.Width = 200
	healPotHPLabel.Left = 65
	healPotHPLabel.Top = top
	healPotHPLabel.Font.Color = 0
	healPotHPLabel.Font.Size = 12
	healPotHPLabel.Parent = form
	freeObjList[#freeObjList + 1] = healPotHPLabel
  	
	--Edits
	local healPotHPEdit = Obj.Create("TEdit")
	healPotHPEdit.Text = tostring(chugHealPotHealth)
	healPotHPEdit.Height = 25
	healPotHPEdit.Width = 55
	healPotHPEdit.Top = top
	healPotHPEdit.Left = 0
	healPotHPEdit.Parent = form
	freeObjList[#freeObjList + 1] = healPotHPEdit
	--/--Heal potion hp %
	
	top = top + 25	
	
	--Chugging Cure potions?
	--Labels
	local isChugCureLabel = Obj.Create("TLabel")
	isChugCureLabel.Caption = "Auto cure poison?"
	isChugCureLabel.Height = 25
	isChugCureLabel.Width = 200
	isChugCureLabel.Left = 65
	isChugCureLabel.Top = top
	isChugCureLabel.Font.Color = 0
	isChugCureLabel.Font.Size = 12
	isChugCureLabel.Parent = form
	freeObjList[#freeObjList + 1] = isChugCureLabel
  	
	--CheckBoxes
	local isChugCureCkBx = Obj.Create("TCheckBox")
	if isChugCureOnPoison == true then
	    isChugCureCkBx.Checked = true
	else
	    isChugCureCkBx.Checked = false
	end
	isChugCureCkBx.Height = 15
	isChugCureCkBx.Width = 10
	isChugCureCkBx.Top = top
	isChugCureCkBx.Left = 0
	isChugCureCkBx.Parent = form
	freeObjList[#freeObjList + 1] = isChugCureCkBx
	--/Chugging Cure potions?	

	top = top + 25	
	
	--Chugging Refresh potions?
	--Labels
	local isChugRefreshLabel = Obj.Create("TLabel")
	isChugRefreshLabel.Caption = "Auto refresh stamina?"
	isChugRefreshLabel.Height = 25
	isChugRefreshLabel.Width = 200
	isChugRefreshLabel.Left = 65
	isChugRefreshLabel.Top = top
	isChugRefreshLabel.Font.Color = 0
	isChugRefreshLabel.Font.Size = 12
	isChugRefreshLabel.Parent = form
	freeObjList[#freeObjList + 1] = isChugRefreshLabel
  	
	--CheckBoxes
	local isChugRefreshCkBx = Obj.Create("TCheckBox")
	if isChugRefreshPotion == true then
	    isChugRefreshCkBx.Checked = true
	else
	    isChugRefreshCkBx.Checked = false
	end
	isChugRefreshCkBx.Height = 15
	isChugRefreshCkBx.Width = 10
	isChugRefreshCkBx.Top = top
	isChugRefreshCkBx.Left = 0
	isChugRefreshCkBx.Parent = form
	freeObjList[#freeObjList + 1] = isChugRefreshCkBx
	--/Chugging Refresh potions?	
	
	top = top + 25
	
	--Refresh potion stamina usage
	--Labels
	local refreshPotUsageLabel = Obj.Create("TLabel")
	refreshPotUsageLabel.Caption = "Refresh potion usage value."
	refreshPotUsageLabel.Height = 25
	refreshPotUsageLabel.Width = 200
	refreshPotUsageLabel.Left = 65
	refreshPotUsageLabel.Top = top
	refreshPotUsageLabel.Font.Color = 0
	refreshPotUsageLabel.Font.Size = 12
	refreshPotUsageLabel.Parent = form
	freeObjList[#freeObjList + 1] = refreshPotUsageLabel
  	
	--Edits
	local RefreshPotUsageEdit = Obj.Create("TEdit")
	RefreshPotUsageEdit.Text = tostring(chugRefreshPotOnStamina)
	RefreshPotUsageEdit.Height = 25
	RefreshPotUsageEdit.Width = 55
	RefreshPotUsageEdit.Top = top
	RefreshPotUsageEdit.Left = 0
	RefreshPotUsageEdit.Parent = form
	freeObjList[#freeObjList + 1] = RefreshPotUsageEdit
	--/Refresh potion stamina usage
	
	top = top + 25
		
	--Auto para pouch?
	--Labels
	local isParaPouchingLabel = Obj.Create("TLabel")
	isParaPouchingLabel.Caption = "Auto para pouch?"
	isParaPouchingLabel.Height = 25
	isParaPouchingLabel.Width = 200
	isParaPouchingLabel.Left = 65
	isParaPouchingLabel.Top = top
	isParaPouchingLabel.Font.Color = 0
	isParaPouchingLabel.Font.Size = 12
	isParaPouchingLabel.Parent = form
	freeObjList[#freeObjList + 1] = isParaPouchingLabel
  	
	--CheckBoxes
	local isParaPouchingCkBx = Obj.Create("TCheckBox")
	if isAutoParaPouch == true then
	    isParaPouchingCkBx.Checked = true
	else
	    isParaPouchingCkBx.Checked = false
	end
	isParaPouchingCkBx.Height = 15
	isParaPouchingCkBx.Width = 10
	isParaPouchingCkBx.Top = top
	isParaPouchingCkBx.Left = 0
	isParaPouchingCkBx.Parent = form
	freeObjList[#freeObjList + 1] = isParaPouchingCkBx
	--/Auto para pouch?
	
	
	 
	okayBtn.OnClick = function()
		isVerbose = isVerboseCkBx.Checked
		useAnyItemDelay = tonumber(itemDelayEdit.Text)
		isOpeningDoors = isDoorsCkBx.Checked
		aUONextHumanKey = nextHumanEdit.Text
		targetNearestHumanKey = nearHumanEdit.Text
		isChugHealOnLow = isChugHealCkBx.Checked
		chugHealPotHealth = tonumber(healPotHPEdit.Text)
		isChugCureOnPoison = isChugCureCkBx.Checked
		isChugRefreshPotion = isChugRefreshCkBx.Checked
		chugRefreshPotOnStamina = tonumber(RefreshPotUsageEdit.Text)
		isAutoParaPouch = isParaPouchingCkBx.Checked
		--unRestockPVPItemsKey = unRestockKeyEdit.Text
		--restockPVPItemsKey = restockKeyEdit.Text
		--restockFromCorpseKey = restockCorpseKeyEdit.Text
		--meatRestockCnt = tonumber(restockMeatEdit.Text)
		--bangageRestockCnt = tonumber(restockBandageEdit.Text)
		--regRestockCnt = tonumber(restockRegsEdit.Text)
		--pouchRestockCnt = tonumber(restockPouchesEdit.Text)
		--strPotRestockCnt = tonumber(restockStrPotEdit.Text)
		--agilPotRestockCnt = tonumber(restockAgilPotEdit.Text)
		--curePotRestockCnt = tonumber(restockCurePotEdit.Text)
		--healPotRestockCnt = tonumber(restockHealPotEdit.Text)
		--explPotRestockCnt = tonumber(restockExplPotEdit.Text)
		--refrPotRestockCnt = tonumber(restockRefrPotEdit.Text)
		--healPotBagID = tonumber(healPotBagIDEdit.Text)
		--curePotBagID = tonumber(curePotBagIDEdit.Text)
		--exploPotBagID = tonumber(exploPotBagIDEdit.Text)
		--pouchesBagID = tonumber(pouchesBagIDEdit.Text)
		--generalItemsBagID = tonumber(generalItemsBagIDEdit.Text)
		--refreshPotBagID = tonumber(refreshPotBagIDEdit.Text)
		--agilPotBagID = tonumber(agilPotBagIDEdit.Text)
        
		local f,e = openfile("../chars/" .. UO.CharName .. ".lua", 'w')
		
		f:write("isVerbose = " .. tostring(isVerbose) .. "\n")
		f:write("useAnyItemDelay = " .. tostring(useAnyItemDelay) .. "\n")
		f:write("isOpeningDoors = " .. tostring(isOpeningDoors) .. "\n")
		f:write("aUONextHumanKey = \"" .. tostring(aUONextHumanKey) .. "\"\n")
		f:write("targetNearestHumanKey = \"" .. tostring(targetNearestHumanKey) .. "\"\n")
		f:write("isChugHealOnLow = " .. tostring(isChugHealOnLow) .. "\n")
		f:write("chugHealPotHealth = " .. tostring(chugHealPotHealth) .. "\n")
		f:write("isChugCureOnPoison = " .. tostring(isChugCureOnPoison) .. "\n")
		f:write("isChugRefreshPotion = " .. tostring(isChugRefreshPotion) .. "\n")
		f:write("chugRefreshPotOnStamina = " .. tostring(chugRefreshPotOnStamina) .. "\n")
		f:write("isAutoParaPouch = " .. tostring(isAutoParaPouch) .. "\n")
		--f:write("unRestockPVPItemsKey = \"" .. tostring(unRestockPVPItemsKey) .. "\"\n")
		--f:write("restockPVPItemsKey = \"" .. tostring(restockPVPItemsKey) .. "\"\n")
		--f:write("restockFromCorpseKey = \"" .. tostring(restockFromCorpseKey) .. "\"\n")
		--f:write("meatRestockCnt = " .. tostring(meatRestockCnt) .. "\n")
		--f:write("bangageRestockCnt = " .. tostring(bangageRestockCnt) .. "\n")
		--f:write("regRestockCnt = " .. tostring(regRestockCnt) .. "\n")
		--f:write("pouchRestockCnt = " .. tostring(pouchRestockCnt) .. "\n")
		--f:write("strPotRestockCnt = " .. tostring(strPotRestockCnt) .. "\n")
		--f:write("agilPotRestockCnt = " .. tostring(agilPotRestockCnt) .. "\n")
		--f:write("curePotRestockCnt = " .. tostring(curePotRestockCnt) .. "\n")
		--f:write("healPotRestockCnt = " .. tostring(healPotRestockCnt) .. "\n")
		--f:write("explPotRestockCnt = " .. tostring(explPotRestockCnt) .. "\n")
		--f:write("refrPotRestockCnt = " .. tostring(refrPotRestockCnt) .. "\n")
		--f:write("healPotBagID = " .. tostring(healPotBagID) .. "\n")
		--f:write("curePotBagID = " .. tostring(curePotBagID) .. "\n")
		--f:write("exploPotBagID = " .. tostring(exploPotBagID) .. "\n")
		--f:write("pouchesBagID = " .. tostring(pouchesBagID) .. "\n")
		--f:write("generalItemsBagID = " .. tostring(generalItemsBagID) .. "\n")
		--f:write("strPotBagID = " .. tostring(strPotBagID) .. "\n")
		--f:write("refreshPotBagID = " .. tostring(refreshPotBagID) .. "\n")
		--f:write("agilPotBagID = " .. tostring(agilPotBagID) .. "\n")
		f:close()
	    print("Settings Saved")
	    --Save
		Obj.Exit()
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
