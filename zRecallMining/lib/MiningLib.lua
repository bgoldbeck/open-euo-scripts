dofile("FindItems.lua")



function round(x)
  if x%2 ~= 0.5 then
    return math.floor(x+0.5)
  end
  return x-0.5
end

bloodmossType    = 3963
blackPearlType   = 3962
mandrakeRootType = 3974
pickaxeType      = 3718
tinkerToolType   = 7865
ingotType        = 7154

bigOreType       = 6585 
smallOreType     = 6584
scatterOreType   = 6586
crapOreType      = 6583 

diamondType      = 3878
emeraldType      = 3856
rubyType         = 3859
tourmalineType   = 3885
amberType        = 3877
starSapphireType = 3873
amethystType     = 3862
citrineType      = 3861
sapphireType     = 3865

ironValue        = 10
dullCopperValue  = 13
shadowValue      = 19
copperValue      = 22
bronzeValue      = 25
goldenValue      = 30
agapiteValue     = 40
veriteValue      = 49
valoriteValue    = 55 


local mineabletiles = "_221_222_223_224_225_226_227_228_229_230_231_236_237_238_239_240_241_242_243_244_245_246_247_252_253_254_255_256_257_258_259_260_261_262_263_268_269_270_271_272_273_274_275_276_277_278_279_286_287_288_289_290_291_292_293_294_296_296_297_321_322_323_324_467_468_469_470_471_472_473_474_476_477_478_479_480_481_482_483_484_485_486_487_492_493_494_495_543_544_545_546_547_548_549_550_551_552_553_554_555_556_557_558_559_560_561_562_563_564_565_566_567_568_569_570_571_572_573_574_575_576_577_578_579_581_582_583_584_585_586_587_588_589_590_591_592_593_594_595_596_597_598_599_600_601_610_611_612_613_1741_1742_1743_1744_1745_1746_1747_1748_1749_1750_1751_1752_1753_1754_1755_1756_1757_1771_1772_1773_1774_1775_1776_1777_1778_1779_1780_1781_1782_1783_1784_1785_1786_1787_1788_1789_1790_1801_1802_1803_1804_1805_1806_1807_1808_1809_1811_1812_1813_1814_1815_1816_1817_1818_1819_1820_1821_1822_1823_1824_1831_1832_1833_1834_1835_1836_1837_1838_1839_1840_1841_1842_1843_1844_1845_1846_1847_1848_1849_1850_1851_1852_1853_1854_1861_1862_1863_1864_1865_1866_1867_1868_1869_1870_1871_1872_1873_1874_1875_1876_1877_1878_1879_1880_1881_1882_1883_1884_1981_1982_1983_1984_1985_1986_1987_1988_1989_1990_1991_1992_1993_1994_1995_1996_1997_1998_1999_2000_2001_2002_2003_2004_2028_2029_2030_2031_2032_2033_2100_2101_2102_2103_2104_2105_1339_1340_1341_1342_1343_1344_1345_1346_1347_1348_1349_1350_1351_1352_1353_1354_1355_1356_1357_1358_1359_"
local mineableGraphics = "_6007_6010_6011_6003_6012_6004_6008_6002_"


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

function PickRandom(...)
	local r = math.random(1, 100)
	if arg.n == 2 then
		if r > 50 then
			return arg[1] 
		else      
			return arg[2]
		end
	end
	if arg.n == 3 then
		if r < 33 then
			return arg[1] 
		end
		if (r >= 33 and r < 66) then      
			return arg[2]
		end
		if (r >= 66 and r <= 100) then
			return arg[3]
		end
	end
	if arg.n == 4 then
		if r < 25 then
			return arg[1] 
		end
		if (r >= 25 and r < 50) then      
			return arg[2]
		end
		if (r >= 50 and r < 75) then
			return arg[3]
		end
		if (r >= 75 and r <= 100) then
			return arg[4]
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

function TargetSelf()
	UO.Macro(23, 0)
end

function Meditate()
    UO.Macro(13, 46)
end

function TargetLast()
	UO.Macro(22, 0)
end

function OverWeight()
	if UO.Weight  > ( UO.MaxWeight - 8 ) then
		return true
	end
	return false
end

function FindTypeWithColor(itemType, source, amount, col)
	if amount == 0 then
	    return 0
	end
    local itemList = ScanItems(false)
	local t = FindItems(itemList,{Type=itemType, ContID=source, Col=col})
	local total = 0
	
	for i = 1, #t do
		total = total + t[i].Stack
	end
	
	if total >= amount then
	    return t[1].ID
	end
	
	return 0
end

function FindID(id, source)
    local itemList = ScanItems(false)
	local t = FindItems(itemList,{ID=id, ContID=source})
	for i = 1, #t do
		return true
	end
	return false
end

function FindType(itemType, source, amount)
    local itemList = ScanItems(false)
	local t = FindItems(itemList,{Type=itemType, ContID=source})
	local total = 0
	
	for i = 1, #t do
		total = total + t[i].Stack
	end
	
	if total >= amount then
	    return t[1].ID
	end
	
	return 0
end

function FindTypeAny(itemType, source)
    local itemList = ScanItems(false)
	local t = FindItems(itemList,{Type=itemType, ContID=source})
	
	for i = 1, #t do
		return t[i].ID
	end
	
	return 0
end

function FindTypeAnyWithColor(itemType, source, col)
    local itemList = ScanItems(false)
	local t = FindItems(itemList,{Type=itemType, ContID=source, Col=col})
	
	for i = 1, #t do
		return t[i].ID
	end
	
	return 0
end

function ItemTypeCount(itemType, source)
	local total = 0
    local itemList = ScanItems(false)
	local t = FindItems(itemList,{Type=itemType, ContID=source})
	
	for i = 1, #t do
		total = total + t[i].Stack
		if t[i].Stack == 0 then
			total = total + 1
		end
	end
	
	return total
end

function ItemTypeCountWithColor(itemType, source, col)
	local total = 0
    local itemList = ScanItems(false)
	local t = FindItems(itemList,{Type=itemType, ContID=source, Col=col})
	for i = 1, #t do
		total = total + t[i].Stack
	end
	
	return total
end

function MoveType(itemType, source, dest, amount, x, y)
    if amount < 1 then
	    return false
	end
	x = x or 100
	y = y or 0
    local itemList = ScanItems(false)
	local t = FindItems(itemList,{Type=itemType, ContID=source})
	if #t > 0 then
		local foundID = FindTypeAny(itemType, dest)
		if foundID == 0 then
			UO.Drag(t[1].ID, amount)
			UO.DropC(dest, x, y)
		else
			UO.Drag(t[1].ID, amount)
			UO.DropC(foundID)
		end
		return true
	end    
	return false
end

function MoveTypeWithColor(itemType, source, dest, amount, col, x, y)
    if amount < 1 then
	    return false
	end
	x = x or 100
	y = y or 0
    local itemList = ScanItems(false)
	local t = FindItems(itemList,{Type=itemType, ContID=source, Col=col})
	if #t > 0 then
		local foundID = FindTypeAnyWithColor(itemType, dest, col)
		if foundID == 0 then
			UO.Drag(t[1].ID, amount)
			UO.DropC(dest, x, y)
		else
			UO.Drag(t[1].ID, amount)
			UO.DropC(foundID)
		end
		return true
	end    
	return false
end

function FindItemTypeColor(itemType, source)
	local col = nil
    local itemList = ScanItems(false)
	local t = FindItems(itemList,{Type=itemType, ContID=source})
	for i = 1, #t do
		col = t[i].Col
		break
	end
	
	return col
end

function FindItemTypeCountWithColor(itemType, source, col)
	local total = 0
    local itemList = ScanItems(false)
	local t = FindItems(itemList,{Type=itemType, Col=col ,ContID=source})
	for i = 1, #t do
		total = total + t[i].Stack
	end
	
	return total
end

function MoveTypeGround(itemType, source, amount, x, y)
    if amount < 1 then
	    return false
	end
	x = x or UO.CharPosX - 1
	y = y or UO.CharPosY
    local itemList = ScanItems(true)
	local t = FindItems(itemList,{Type=itemType, ContID=source, Col=0})
	for i = 1, #t do
	    if t[i].Col == 0 then
			UO.Drag(t[i].ID, amount)
			UO.DropG(x, y, UO.CharPosZ)
			return true
		end
		
	end
	
	return false
end

function FindColorOreGround(dist)
	itemType = bigOreType
    local itemList = ScanItems(false)
	local t = FindItems(itemList,{Type=itemType, Dist=dist}, {ContID=UO.BackpackID, Col=0})
	
	if #t > 0 then
		if t[1].Col == 0 then return 0 end
		return t[1].ID
	end    
	return 0
end

function FindTypeGround(itemType, dist)
    local itemList = ScanItems(false)
	local t = FindItems(itemList,{Type=itemType, Dist=dist}, {ContID=UO.BackpackID})
	if #t > 0 then
		if t[1].Col == 0 then return 0 end
		return t[1].ID
	end    
	return 0
end

function MoveItem(id, dest, amount)
	UO.Drag(id, amount)
	UO.DropC(dest)
end

function ScavengeOre()
	if OverWeight() then
		return
	end
	foundID = FindTypeGround(bigOreType, 2)
	if foundID ~= 0 then
		print("Scavenging some ore..")
		MoveItem(foundID, UO.BackpackID, 1)
		wait(815)
	end
end

function Dismount()
	UO.LObjectID = UO.CharID
	UO.Macro(17, 0)
end

function Mount(id)
	UO.LObjectID = id
	UO.Macro(17, 0)
end

function TargetByID(id)
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

function UseType(tType, source)
	local itemList = ScanItems(false)
	local t = FindItems(itemList,{Type=tType, ContID=source})
	if #t == 0 then
	    return false
	end
	for i = 1, #t do
		UO.LObjectID = t[i].ID
		UO.Macro(17, 0)
		break
	end
	return true
end

function RecallFromRune(runeID)
	while UO.Mana < 12 do
	    wait(1000)
	end
	UO.Macro(15, 31) -- Recall
	wait(500)
	TargetByID(runeID)
	
end

function UseObject(id)
  UO.LobjectID = id
  UO.Macro(17, 0)
end

function RecallFromRunebook(runebookID, spot, right)
	local xPageClick = 0
    if spot > 3 then
	    xPageClick = spot * 35 + 175
	else
	    xPageClick = spot * 35 + 140 
	end
	
	local runeBookContKind = 39724
	local xRecallClick = 140
	if right == 1 then
	    xRecallClick = 300
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
	    if OffsetGumpClick(xRecallClick, 142, runeBookContKind) == true then
		    wait(250)
	        return true
		end
	end
	return false
end

function ErrorStatusBar()
    if UO.Sex == -1 then   
        print("ERROR: Is Character status bar not open?")    
        UO.ExMsg(UO.CharID, 0, 55, "Halting" )
        stop()
    end
end

function IngotCheck(bankID, ingotCnt)
	if FindTypeWithColor(ingotType, UO.BackpackID, ingotCnt, 0) == 0 then
		print("Need more ingots.")
	else
		print("Ingot supply good. " .. "(" .. ItemTypeCountWithColor(ingotType, UO.BackpackID, 0) .. ")")
		return
	end
	wait(500)
	while UO.ContType ~= 3708 do
		UO.Macro(1, 0, "Bank Guards")
		wait(1000)
	end
	
	success = MoveTypeWithColor(ingotType, bankID, UO.BackpackID, ingotCnt, 0, 50, 0)
	if success == false then
		print("ERROR: Bank supply of ingots is empty. game over.")
		stop()
	else
		print("Restocking ingots from bank now.")
	end
end

function TinkerToolCheck()
	if (ItemTypeCount(tinkerToolType, UO.BackpackID) == 0) then
		print("ERROR: No tinker tools found at all, game over!")
		stop()
	end
		
	if ItemTypeCount(tinkerToolType, UO.BackpackID) == 1 then
		print("Need more tinker tools, Making now.")
	else
		return
	end
	
	while ItemTypeCount(tinkerToolType, UO.BackpackID) < 2 do 
		UseType(tinkerToolType, UO.BackpackID)
		OffsetGumpClick(35, 129, 39724) -- Tools
		wait(400)
		OffsetGumpClick(234, 129, 39724) -- Tinker tools
		wait(1800)
	end
	OffsetGumpClick(25, 450, 39724) --Exit Button
	wait(400)
	print("Tinker supply good." .. "(" .. ItemTypeCount(tinkerToolType, UO.BackpackID) .. ")")
end


function PickaxeCheck()
	if ItemTypeCount(pickaxeType, UO.BackpackID) == 0 then
		
		print("Making pickaxe")
		for i = 0, 2 do
			UseType(tinkerToolType, UO.BackpackID)
			wait(715)
			OffsetGumpClick(35, 129, 39724) -- Tools
			wait(200)
			OffsetGumpClick(375, 275, 39724) -- Next Page
			wait(200)
			OffsetGumpClick(230, 190, 39724) -- Pickaxe
			wait(2000)
		end
		print("Done making pickaxe")
		OffsetGumpClick(25, 450, 39724) --Exit Button
	    wait(400)
		return
	end
	
end

function PlayerPaused()
	local jres = journal:find(UO.CharName .. ": p")
	if jres ~= nil then
		jres = nil
		UO.ExMsg(UO.CharID, 0, 300, "Paused." )  
		while jres == nil do
			--Hiding
			nNorm, nReal, nCap, nLock = UO.GetSkill("hidi")
			if nReal > 249 then
			  if GetIsHidden() == false then
				UO.Macro(13, 21)
				wait(1000)
			  end
			end
		    jres = journal:find(UO.CharName .. ": c")  
			wait(100)
			
		end		
		UO.ExMsg(UO.CharID, 0, 300, "Continue..." )  
	end
end

function RecallDefaultBankRunebook(id)
	UO.Macro(15, 31)
	wait(1000)
	WaitForTarget(3000)
	UO.LTargetID = id
	UO.LTargetKind = 1
	TargetLast()
	wait(1000)
end

function DepositToCrate(crateID)
	print("Depositing Ore...")
	
	UO.LObjectID = crateID
	UO.Macro(17, 0)
	
	for i = 1, 100 do
	    wait(100)
		if UO.ContID == crateID then
			break
		end
	end
	
	wait(715)
	-- That shitty ore
	while MoveType(crapOreType, UO.BackpackID, crateID, 30, 0x0, 0, 0) do
		wait(715)
	end
	
	
	
	--Dull Copper
	while MoveTypeWithColor(ingotType, UO.BackpackID, crateID, 30, 2419, 20, 120) do
		wait(715)
	end
	--Shadow
	while MoveTypeWithColor(ingotType, UO.BackpackID, crateID, 30, 2406, 0, 40) do
		wait(715)
	end
	--Bronze
	while MoveTypeWithColor(ingotType, UO.BackpackID, crateID, 30, 2418, 0, 60) do
		wait(715)
	end
	--Copper
	while MoveTypeWithColor(ingotType, UO.BackpackID, crateID, 30, 2413, 0, 80) do
		wait(715)
	end
	--Valorite
	while MoveTypeWithColor(ingotType, UO.BackpackID, crateID, 30, 2219, 0, 100) do
		wait(715)
	end
	--Verite
	while MoveTypeWithColor(ingotType, UO.BackpackID, crateID, 30, 2207, 100, 0) do
		wait(715)
	end
	--Agapite
	while MoveTypeWithColor(ingotType, UO.BackpackID, crateID, 30, 2425, 100, 40) do
		wait(715)
	end
	--Gold
	while MoveTypeWithColor(ingotType, UO.BackpackID, crateID, 30, 2213, 100, 100) do
		wait(715)
	end
	--Diamond
	while MoveType(diamondType, UO.BackpackID, crateID, 20, 0, 20) do
		wait(715)
	end
	--Emerald
	while MoveType(emeraldType, UO.BackpackID, crateID, 20, 20, 0) do
		wait(715)
	end
	--Ruby
	while MoveType(rubyType, UO.BackpackID, crateID, 20, 40, 0) do
		wait(715)
	end
	--Tourmaline
	while MoveType(tourmalineType, UO.BackpackID, crateID, 20, 40, 0) do
		wait(715)
	end
	--Amber
	while MoveType(amberType, UO.BackpackID, crateID, 20, 60, 0) do
		wait(715)
	end
	--Star Sapphire
	while MoveType(starSapphireType, UO.BackpackID, crateID, 40, 40, 0) do
		wait(715)
	end
	--Amethyst
	while MoveType(amethystType, UO.BackpackID, crateID, 60, 60, 0) do
		wait(715)
	end
	--Citrine
	while MoveType(citrineType, UO.BackpackID, crateID, 60, 100, 0) do
		wait(715)
	end
	--Sapphire
	while MoveType(sapphireType, UO.BackpackID, crateID, 60, 140, 0) do
		wait(715)
	end
	-- Ecru Citrine
	while MoveType(12693, UO.BackpackID, crateID, 60, 140, 0) do
		wait(715)
	end
	-- Turqoise
	while MoveType(12691, UO.BackpackID, crateID, 60, 140, 0) do
		wait(715)
	end	
	-- Blackrock
	while MoveType(3880, UO.BackpackID, crateID, 60, 140, 0) do
		wait(715)
	end
		-- Blackrock
	while MoveType(3882, UO.BackpackID, crateID, 60, 140, 0) do
		wait(715)
	end
    -- Perfect Emerald
	while MoveType(12692, UO.BackpackID, crateID, 60, 140, 0) do
		wait(715)
	end
    -- Fire Ruby
	while MoveType(12695, UO.BackpackID, crateID, 60, 140, 0) do
		wait(715)
	end
    -- Dark Sapphire
	while MoveType(12690, UO.BackpackID, crateID, 60, 140, 0) do
		wait(715)
	end
    -- Blue Diamond
	while MoveType(12696, UO.BackpackID, crateID, 60, 140, 0) do
		wait(715)
	end
	
	-- Iron Ingots
	local ironIngotCount = ItemTypeCount(ingotType, UO.BackpackID)
	if ironIngotCount > 12 then
	    wait(700)
		MoveType(ingotType, UO.BackpackID, crateID, ironIngotCount - 12, 0x0, 0, 0)
		wait(700)
	end
end

function PrintIngotDetails(source)
    local itemList = ScanItems(false)
	local goldValue = 0
	local t = FindItems(itemList,{Type=ingotType, ContID=source})
	print("Ingot types found...")
	for i = 1, #t do
	    if t[i].Col == 0        then 
			print(t[i].Type .. " : " .. t[i].Stack .. " " .. t[i].Name .. " : " .. "Iron " .. "|Value: (" .. (t[i].Stack * ironValue) .."gp)|") 
			goldValue = goldValue + (t[i].Stack * ironValue)
	    elseif t[i].Col == 2219 then 
			print(t[i].Type .. " : " .. t[i].Stack .. " "  .. t[i].Name .. " : " .. "Valorite " .. "|Value: (" .. (t[i].Stack * valoriteValue) .."gp)|") 
			goldValue = goldValue + (t[i].Stack * valoriteValue)
	    elseif t[i].Col == 2207 then 
			print(t[i].Type .. " : " .. t[i].Stack .. " " .. t[i].Name .. " : " .. "Verite " .. "|Value: (" .. (t[i].Stack * veriteValue) .."gp)|") 
			goldValue = goldValue + (t[i].Stack * veriteValue)
	    elseif t[i].Col == 2213 then 
			print(t[i].Type .. " : " .. t[i].Stack  .. " " .. t[i].Name .. " : " .. "Golden " .. "|Value: (" .. (t[i].Stack * goldenValue) .."gp)|") 
			goldValue = goldValue + (t[i].Stack * goldenValue)
	    elseif t[i].Col == 2413 then 
			print(t[i].Type .. " : " .. t[i].Stack  .. " " .. t[i].Name .. " : " .. "Copper " .. "|Value: (" .. (t[i].Stack * copperValue) .."gp)|") 
			goldValue = goldValue + (t[i].Stack * copperValue)
	    elseif t[i].Col == 2419 then 
			print(t[i].Type .. " : " .. t[i].Stack  .. " " .. t[i].Name .. " : " .. "Dull Copper " .. "|Value: (" .. (t[i].Stack * dullCopperValue) .."gp)|") 
			goldValue = goldValue + (t[i].Stack * dullCopperValue)
	    elseif t[i].Col == 2406 then 
			print(t[i].Type .. " : " .. t[i].Stack .. " "  .. t[i].Name .. " : " .. "Shadow " .. "|Value: (" .. (t[i].Stack * shadowValue) .."gp)|") 
			goldValue = goldValue + (t[i].Stack * shadowValue)
	    elseif t[i].Col == 2418 then 
			print(t[i].Type .. " : " .. t[i].Stack .. " " .. t[i].Name .. " : " .. "Bronze " .. "|Value: (" .. (t[i].Stack * bronzeValue) .."gp)|") 
			goldValue = goldValue + (t[i].Stack * bronzeValue)
	    elseif t[i].Col == 2425 then 
			print(t[i].Type .. " : " .. t[i].Stack .. " "  .. t[i].Name .. " : " .. "Agapite " .. "|Value: (" .. (t[i].Stack * agapiteValue) .."gp)|") 
			goldValue = goldValue + (t[i].Stack * agapiteValue)
		else 
			print(t[i].Type .. " : " .. t[i].Name .. " : " .. t[i].Col)
		end
	end
	print("Total estimated gold value: " .. goldValue .. "gp")

	return goldValue
end

function InRange(id, range)
	local t = ScanItems(true, {ID=id, Dist=range})
	return #t ~= 0
end

function BeetleSmelt(oreType, beetleID)
	local t = FindTypeAny(oreType, UO.BackpackID)
	if t ~= 0  and not InRange(beetleID, 1) then
		UO.Macro(1, 0, "All Follow Me")
		UO.Macro(1, 0, "All Guard Me")
	end
	while (t ~= 0) do
		UO.LObjectID = t
		UO.Macro(17, 0)
		wait(200)
		UO.LTargetKind = 1
		UO.LTargetID = beetleID
		UO.Macro(22, 0)
		t = FindTypeAny(oreType, UO.BackpackID)
		wait(700)
	end
	
end

function MineTiles(tileKind, beetleID) 
	print("Digger tilekind == " .. tileKind)
	local sleepTime = 435
	local tileX     = 0
	local tileY     = 0
	
	for x = -1, 1 do
		for y = -1, 1 do
			tileX = UO.CharPosX + x
			tileY = UO.CharPosY + y
			nCnt = UO.TileCnt(tileX, tileY)
			--print("count " .. nCnt)
			for i = 1, nCnt do
				nType,tileZ,sName,nFlags = UO.TileGet(tileX, tileY, i)
				--print("type " .. nType)
				if string.find(mineabletiles,'_' .. nType ..'_') then
				
					print("Mining some ore! " .. sName) 
					--Start mining loop.
					
					while not OverWeight() do
						--print("Mining some ore! " .. sName) 
						--ScavengeOre()
						UseType(pickaxeType, UO.BackpackID)

						UO.LTargetKind = tileKind
						UO.LTargetTile = nType
						UO.LTargetX = tileX
						UO.LTargetY = tileY
						UO.LTargetZ = tileZ
						TargetLast()
						wait(700)
						local jres = journal:find("too far away", "that location", "no metal", "be seen.", "mine that.", "mine there.")
						if jres ~= nil then
							break    
						end
						TinkerPickaxeCheck()
					end
					
					BeetleSmelt(bigOreType, beetleID)
					BeetleSmelt(smallOreType, beetleID)
					BeetleSmelt(scatterOreType, beetleID)
					
					
					if OverWeight() then
					    print("overweight, stop digging")
						return
					end
				end
			end
		end
	end
end

function TinkerPickaxeCheck()
	TinkerToolCheck()
	PickaxeCheck()
end

function Digger(beetleID)
	Dismount()
	MineTiles(2, beetleID)
	MineTiles(3, beetleID)
end

function Dismount()
  UO.LObjectID = UO.CharID
  UO.Macro(17, 0)
end

function Mount(id)
  UO.LObjectID = id
  UO.Macro(17, 0)
end