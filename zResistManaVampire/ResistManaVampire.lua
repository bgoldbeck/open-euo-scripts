dofile("lib/ResistLib.lua")

--Where all my regs at?
myReagentBagID        = 1076066609

--How many regs to keep on hand. Value: Low 1 - 3 Recommended
numReagentsKeptOnSelf = 3

--Using meditation?
isMeditating = true
       
--Leave alone!           
lastResistValue = nil
if lastResistValue == nil then   
    local norm, real, cap, lock = UO.GetSkill("resi")
    lastResistValue = norm 
end
journal = journal:new()
UO.LObjectID = myReagentBagID
UO.Macro(17, 0)
wait(700)     

while 1 do      
    --Make sure status bar is open.
    if UO.Sex == -1 then
        print("ERROR: Is Character status bar not open?")
        UO.ExMsg(UO.CharID, 0, 55, "Halting" )
        stop()
    end

    --Call guards if under attack?
    if UO.Hits ~= UO.MaxHits then
        UO.Macro(1, 0, "Guards")
        wait(1000)
    end

    --World save.
    local jres = journal:find("world is saving")
    if jres ~= nil then
        UO.ExMsg(UO.CharID, 0, 55, "World Saving..." )
        journal:clear()
        while jres == nil do
            jres = journal:find("save complete.")
            wait(1)
        end
        print("World save complete.")
    end

    local mandrakeCnt = GetCountOfItemOnSelf(mandrakeRootType)
    local bloodMCnt   = GetCountOfItemOnSelf(bloodmossType)
    local spiderSCnt  = GetCountOfItemOnSelf(spiderSilkType)
    local blackPCnt   = GetCountOfItemOnSelf(blackPearlType)
    --Restock regs if any are out.
    if mandrakeCnt == 0 or bloodMCnt == 0 or spiderSCnt == 0 or blackPCnt == 0 then
    
        local norm, real, cap, lock = UO.GetSkill("resi")
        local currentSkillResistRealValue = norm
        if currentSkillResistRealValue ~= lastResistValue then
            --Print time of gain.
            local nHour, nMinute, nSecond, nMillisec = gettime()
            print("Gained 0.1 @ " .. nHour .. "h " .. nMinute .. "m " .. nSecond .. "secs")
            --Update last resist value.
            lastResistValue = currentSkillResistRealValue
        end
        if currentSkillResistRealValue == 1000 then
            print("Grandmaster Warder!")
            stop()
        end
        
        UO.LObjectID = myReagentBagID
        UO.Macro(17, 0)
        wait(700)
        RestockManaVampireRegs(myReagentBagID, numReagentsKeptOnSelf)
    end
    --Cast because we have enough mana now.
    if UO.Mana > 39 and UO.TargCurs == false then
        --Cast Mana Vampire.
        UO.TargCurs = false
        repeat
            CastManaVampire()
            for i = 1, 80 do 
                wait(100)
                if UO.TargCurs == true then
                    break
                end
            end
        until UO.TargCurs == true
        --Target Self.
        TargetSelf()
	else
	    if isMeditating == true then
			--Need some mana.
			Meditate()
		end
    end
    wait(1000)
end