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
tinkerToolType   = 7864
ingotType        = 7154
bigOreType       = 6585 
diamondType      = 3878
emeraldType      = 3856
rubyType         = 3859
tourmalineType   = 3885
amberType        = 3877
starSapphireType = 3873
amethystType     = 3862
citrineType      = 3861
sapphireType     = 3865

ironValue        = 8
dullCopperValue  = 15
shadowValue      = 20
copperValue      = 25
bronzeValue      = 35
goldenValue      = 40
agapiteValue     = 45
veriteValue      = 50
valoriteValue    = 60  


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

function SmeltOre(forgeID)
  oreFound = FindType(6585, UO.BackpackID, 1)
  UO.LObjectID = oreFound
  UO.Macro(17, 0)
end

function DepositIngotsToIngotContainer(contID, color, x, y)
    x = x or 0
    y = y or 0
    print("Depositing ingots..")
    cnt = ItemTypeCount(ingotType, UO.BackpackID)                                   
    for i = 1, 2 do
      MoveTypeWithColor(ingotType, UO.BackpackID, contID, cnt, color, x, y)       
      wait(800)
      cnt = ItemTypeCount(ingotType, UO.BackpackID)
      if cnt == 0 then
        break
      end
    end  
    print("Finished Deposit.")          
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

function GetIsHidden()
    if UO.CharStatus == nil then 
	    return false 
	end
    if string.match(UO.CharStatus, "H") ~= nil then
	    return true
	end
	return false
end

function GuardCheck()
	if UO.Hits ~= UO.MaxHits then
		UO.Macro(1, 0, "Guards")
	end
end

function WaitForTarget(timeout)
	local step = math.ceil(timeout / 5)
	for i = 1, step do
		wait(5)
		if UO.TargCurs == true then
			return true
		end
	end
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
    local itemList = ScanItems(false)
	local t = FindItems(itemList,{Type=itemType, ContID=source, Col=0})
	if #t > 0 then
		UO.Drag(t[1].ID, amount)
		UO.DropG(x, y, UO.CharPosZ)
		return true
	else
		t = FindItems(itemList,{Type=itemType, ContID=source})
		if #t > 0 then
			UO.Drag(t[1].ID, amount)
			UO.DropG(x, y, UO.CharPosZ)
			return true
		end   
	end
	return false
end

function FindTypeGround(itemType, dist)
    local itemList = ScanItems(false)
	local t = FindItems(itemList,{Type=itemType, Dist=dist}, {ContID=UO.BackpackID})
	if #t > 0 then
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

function RecallFromRunebook(runebookID, spot, right)
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
	if FindType(tinkerToolType, UO.BackpackID, 1) == 0 then
		print("ERROR: No tinker tools found at all, game over!")
	end
	
	if FindType(tinkerToolType, UO.BackpackID, 2) == 0 then
		print("Need more tinker tools, Making now.")
	else
		print("Tinker supply good." .. "(" .. ItemTypeCount(tinkerToolType, UO.BackpackID) .. ")")
		return
	end
	wait(700)
	while FindType(tinkerToolType, UO.BackpackID, 2) == 0 do 
		UseType(tinkerToolType, UO.BackpackID)
		OffsetGumpClick( 30, 110, 4756)
		wait(200)
		OffsetGumpClick(230, 130, 4756)
		wait(1800)
		GuardCheck()
	end
	OffsetGumpClick(30, 410, 4756) --Exit Button
	wait(400)
end


function PickaxeCheck(pickaxeCnt)
	if FindTypeAny(pickaxeType, UO.BackpackID) == 0 then
		--print("Need more pickaxes, Making now.")
		print("ERROR: Need pickaxe!")
		stop()
		wait(1000)
		while FindType(pickaxeType, UO.BackpackID, pickaxeCnt) == 0 do
			UseType(tinkerToolType, UO.BackpackID)
			wait(715)
			OffsetGumpClick( 30, 110, 4756)
			wait(200)
			OffsetGumpClick(380, 270, 4756)
			wait(200)
			OffsetGumpClick(235, 195, 4756)
			wait(2000)
			GuardCheck()
		end
	    OffsetGumpClick(30, 410, 4756) --Exit Button
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

function DepositOreToBank(crateID)
	print("Depositing Ore...")
	for i = 1, 20 do
		UO.Macro(1, 0, "Bank Guards")
		wait(500)
		if UO.ContType == 3708 then
			break
		end
	end
	UO.LObjectID = crateID
	UO.Macro(17, 0)
	for i = 1, 100 do
	    wait(100)
		if UO.ContID == crateID then
			break
		end
	end
	wait(715)
	--Iron
	while MoveTypeWithColor(bigOreType, UO.BackpackID, crateID, 30, 0x0, 0, 0) do
		wait(715)
	end
	--Dull Copper
	while MoveTypeWithColor(bigOreType, UO.BackpackID, crateID, 30, 0x415, 20, 120) do
		wait(715)
	end
	--Shadow
	while MoveTypeWithColor(bigOreType, UO.BackpackID, crateID, 30, 0x455, 0, 40) do
		wait(715)
	end
	--Bronze
	while MoveTypeWithColor(bigOreType, UO.BackpackID, crateID, 30, 0x6d8, 0, 60) do
		wait(715)
	end
	--Copper
	while MoveTypeWithColor(bigOreType, UO.BackpackID, crateID, 30, 0x45f, 0, 80) do
		wait(715)
	end
	--Valorite
	while MoveTypeWithColor(bigOreType, UO.BackpackID, crateID, 30, 0x544, 0, 100) do
		wait(715)
	end
	--Verite
	while MoveTypeWithColor(bigOreType, UO.BackpackID, crateID, 30, 0x7d2, 100, 0) do
		wait(715)
	end
	--Agapite
	while MoveTypeWithColor(bigOreType, UO.BackpackID, crateID, 30, 0x97e, 100, 40) do
		wait(715)
	end
	--Gold
	while MoveTypeWithColor(bigOreType, UO.BackpackID, crateID, 30, 0x6b7, 100, 100) do
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

end

function ReagentCheck(bankID)
	if FindType(bloodmossType, bankID, 32) == 0 then
		print("ERROR: Not enough Bloodmoss found in bank, game over!")
		stop()
	end
	if FindType(mandrakeRootType, bankID, 32) == 0 then
		print("ERROR: Not enough Mandrake Root found in bank, game over!")
		stop()
	end
	if FindType(blackPearlType, bankID, 32) == 0 then
		print("ERROR: Not enough Black Pearl found in bank, game over!")
		stop()
	end
	
	--Bloodmoss.
	while FindType(bloodmossType, UO.BackpackID, 3) == 0 do
		print("Need more Bloodmoss, stocking now.")
		local cnt = ItemTypeCount(bloodmossType, UO.BackpackID)
		MoveType(bloodmossType, bankID, UO.BackpackID, (32 - cnt), 200, 200)
		wait(715)
	end
	
	--Mandrake Root.
	while FindType(mandrakeRootType, UO.BackpackID, 3) == 0 do
		print("Need more Mandrake Root, stocking now.")
		local cnt = ItemTypeCount(mandrakeRootType, UO.BackpackID)
		MoveType(mandrakeRootType, bankID, UO.BackpackID, (32 - cnt), 200, 200)
		wait(715)
	end
	
	--Black Pearl.
	while FindType(blackPearlType, UO.BackpackID, 3) == 0 do
		print("Need more Black Pearl, stocking now.")
		local cnt = ItemTypeCount(blackPearlType, UO.BackpackID)
		MoveType(blackPearlType, bankID, UO.BackpackID, (32 - cnt), 200, 200)
		wait(715)
	end
end

function IsInBankRange(crateID, bankID)
	UO.Macro(1, 0, "Bank")
	wait(1500)
	if FindID(crateID, bankID) then
		return true
	end
	return false
end

function GetPickaxe(source)
	while FindTypeAny(3718, UO.BackpackID) == 0 do
		MoveType(3718, source, UO.BackpackID, 1, 0, 0)
		wait(900)
	end
end

function DepositPickaxe(dest)
	while FindTypeAny(3718, dest) == 0 do
		MoveType(3718, UO.BackpackID, dest, 1, 0, 0)
		wait(900)
	end
end

function GetGloves(source)
    local foundID = FindTypeAny(5099, source)
	if foundID == 0 then
	    return
	end
	while FindTypeAny(5099, UO.CharID) == 0 do
		UO.Drag(foundID, 1)
		UO.DropPD()
		wait(1000)
	end
end

function DepositGloves(dest)
    local foundID = FindTypeAny(5099, UO.CharID)
	if foundID == 0 then
	    return
	end
	while FindTypeAny(5099, dest) == 0 do
		UO.Drag(foundID, 1)
		UO.DropC(dest)
		wait(1000)
	end
end

function PrintOreDetails(source)
    local itemList = ScanItems(false)
	local goldValue = 0
	local t = FindItems(itemList,{Type=bigOreType, ContID=source})
	print("Ore types found...")
	for i = 1, #t do
	    if t[i].Col == 0        then 
			print(t[i].Type .. " : " .. t[i].Name .. " : " .. "Iron " .. "|Value: (" .. (t[i].Stack * ironValue) .."gp)|") 
			goldValue = goldValue + (t[i].Stack * ironValue)
	    elseif t[i].Col == 1348 then 
			print(t[i].Type .. " : " .. t[i].Name .. " : " .. "Valorite " .. "|Value: (" .. (t[i].Stack * valoriteValue) .."gp)|") 
			goldValue = goldValue + (t[i].Stack * valoriteValue)
	    elseif t[i].Col == 2002 then 
			print(t[i].Type .. " : " .. t[i].Name .. " : " .. "Verite " .. "|Value: (" .. (t[i].Stack * veriteValue) .."gp)|") 
			goldValue = goldValue + (t[i].Stack * veriteValue)
	    elseif t[i].Col == 1719 then 
			print(t[i].Type .. " : " .. t[i].Name .. " : " .. "Golden " .. "|Value: (" .. (t[i].Stack * goldenValue) .."gp)|") 
			goldValue = goldValue + (t[i].Stack * goldenValue)
	    elseif t[i].Col == 1119 then 
			print(t[i].Type .. " : " .. t[i].Name .. " : " .. "Copper " .. "|Value: (" .. (t[i].Stack * copperValue) .."gp)|") 
			goldValue = goldValue + (t[i].Stack * copperValue)
	    elseif t[i].Col == 1045 then 
			print(t[i].Type .. " : " .. t[i].Name .. " : " .. "Dull Copper " .. "|Value: (" .. (t[i].Stack * dullCopperValue) .."gp)|") 
			goldValue = goldValue + (t[i].Stack * dullCopperValue)
	    elseif t[i].Col == 1109 then 
			print(t[i].Type .. " : " .. t[i].Name .. " : " .. "Shadow " .. "|Value: (" .. (t[i].Stack * shadowValue) .."gp)|") 
			goldValue = goldValue + (t[i].Stack * shadowValue)
	    elseif t[i].Col == 1752 then 
			print(t[i].Type .. " : " .. t[i].Name .. " : " .. "Bronze " .. "|Value: (" .. (t[i].Stack * bronzeValue) .."gp)|") 
			goldValue = goldValue + (t[i].Stack * bronzeValue)
	    elseif t[i].Col == 2430 then 
			print(t[i].Type .. " : " .. t[i].Name .. " : " .. "Agapite " .. "|Value: (" .. (t[i].Stack * agapiteValue) .."gp)|") 
			goldValue = goldValue + (t[i].Stack * agapiteValue)
		else 
			print(t[i].Type .. " : " .. t[i].Name .. " : " .. t[i].Col)
		end
	end
	print("Total estimated gold value: " .. goldValue .. "gp")

	return goldValue
end

function Digger()
	local sleepTime = 435
	local tileX     = 0
	local tileY     = 0
	--Hiding
	nNorm, nReal, nCap, nLock = UO.GetSkill("hidi")
	if nReal > 99 then
	  UO.Macro(13, 21)
	end
	--Regular tiles
	for x = -1, 1 do
		for y = -1, 1 do
			tileX = UO.CharPosX + x
			tileY = UO.CharPosY + y
			nCnt = UO.TileCnt(tileX, tileY)
			for i = 1, nCnt do
				nType,tileZ,sName,nFlags = UO.TileGet(tileX, tileY, i)
			
				if string.find(mineabletiles,'_' .. nType ..'_') then
					UO.LTargetKind = 2

					UO.LTargetTile = nType
					UO.LTargetX = tileX
					UO.LTargetY = tileY
					UO.LTargetZ = tileZ
					print("Mining some ore! " .. sName) 
					--Start mining loop.
					while not OverWeight() do
						ScavengeOre()
						GuardCheck()
						--Prospect tools
						if ItemTypeCount(4020, UO.BackpackID) > 0 then
						  UseType(4020, UO.BackpackID)
						else
						  UseType(pickaxeType, UO.BackpackID)
						end	
						WaitForTarget(900)
						TargetLast()
						wait(400)
						local jres = journal:find("Nate", "Alan", "Shane", "Carl", "Jake", "no metal", "be seen.", "mine that.", "mine there.")
						if jres == 1 or jres == 2 or jres == 3 or jres == 4 or jres == 5 then
                            f,e = openfile("gm.ini", 'w')
							f:write("[gm]\n")
							f:write("sound=1\n")
							f:close()
						    UO.Msg("/" .. UO.CharPosX * 2 - 8 .. "zzz" .. string.char(13))
							stop()
						end
						if jres ~= nil then
							break    
						end
						wait(sleepTime)
						wait(10)
					end --endwhile    
					if OverWeight() then
						return
					end
				end
			end
		end
	end
	--Rock tiles
	for x = -1, 1 do
		for y = -1, 1 do
			tileX = UO.CharPosX + x
			tileY = UO.CharPosY + y
			nCnt = UO.TileCnt(tileX, tileY)
			for i = 1, nCnt do
				nType,tileZ,sName,nFlags = UO.TileGet(tileX, tileY, i)
			
				if string.find(mineableGraphics,'_' .. nType ..'_') then
					UO.LTargetKind = 3

					UO.LTargetTile = nType
					UO.LTargetX = tileX
					UO.LTargetY = tileY
					UO.LTargetZ = tileZ
					print("Mining some ore! " .. sName) 
					--Start mining loop.
					while not OverWeight() do
						GuardCheck()
						if ItemTypeCount(4020, UO.BackpackID) > 0 then
						  UseType(4020, UO.BackpackID)
						else
						  UseType(pickaxeType, UO.BackpackID)
						end	
						WaitForTarget(900)
						TargetLast()
						wait(400)
						local jres = journal:find("Nate", "Alan", "Shane", "Carl", "Jake", "no metal", "be seen.", "mine that.", "mine there.")
						if jres == 1 or jres == 2 or jres == 3 or jres == 4 or jres == 5 then
                            f,e = openfile("gm.ini", 'w')
							f:write("[gm]\n")
							f:write("sound=1\n")
							f:close()
						    UO.Msg("/" .. UO.CharPosX * 2 - 8 .. "zzz" .. string.char(13))
							wait(2000)
						end
						if jres ~= nil then
							break    
						end
						wait(sleepTime)
						ScavengeOre()
					end --endwhile    
					if OverWeight() then
						return
					end
				end
			end
		end
	end
end