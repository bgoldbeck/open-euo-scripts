dofile("lib/MageryLib.lua")
--It may take the following regs if you're casting
--Mana Drain --> Invisibility --> Mana Vampire
-- These are over-estimates
--Spiders Silk: 2500
--Nightshade: 1500
--Blood Moss: 2500
--Black Pearl: 2500
--Mandrake Root: 2500
--What Else U need
--[Prefer 49.0 + "fake" magery skill]
--[64 Spells Spellbook]
--[Apples and Food in resources bag]
--[Reagents in resources bag]

-- SETUP
--Skill to stop at
stopAtSkill = 100

--Third circle spell choice : [fireball]
thirdCircleSpell = fireball

--Fourth circle spell choice  : [lightning | manaDrain]
fourthCircleSpell = manaDrain

--Sixth circle spell choice : [energyBolt | invisibility]
sixthCircleSpell = invisibility

--Seventh circle spell choice : [flamestrike, manaVampire]
seventhCircleSpell = manaVampire

--How many regs to keep on hand. Value: Low 1 - 3 Recommended
numReagentsKeptOnSelf = 3
--------------------------------------------------------------------- 
---------------------------------------------------------------------
---------------------------------------------------------------------
stopAtSkill = stopAtSkill * 10                             
print("Running until we reach: ".. ( stopAtSkill / 10 ).. " Magery " .. "(" .. stopAtSkill .. ")")
   
UO.Macro(1, 0, "Bank")

--Where all my regs at? bandages?
UO.SysMessage("Please target bag of Reagents and (Bandages) if necessary (NOW ADD FOOD + WATER! 'Apples and Pears'!", 0)
UO.TargCurs = true
while UO.TargCurs == true do
  wait(50)
end
myContID = UO.LTargetID  
UO.LObjectID = myContID
UO.Macro(17, 0)

UO.SysMessage("Target the person to cast on.", 30)
UO.TargCurs = true
while UO.TargCurs == true do
    wait(1)
  end
mageryTarget = UO.LTargetID


--Leave alone!     
UO.ExMsg(UO.CharID, 0, 55, "Please keep the reagent bag open." )   

lastMageryValue = nil
if lastMageryValue == nil then   
    local norm, real, cap, lock = UO.GetSkill("mage")
    lastMageryValue = norm 
end
journal = journal:new()

 
if mageryTarget == UO.CharID then
  --Using bandages?
  isBandaging = YesNoBox(true, "Are you bandaging yourself?", "Answer..")
else
  isBandaging = false  
end
    

local cntr = 50
    

while 1 do   
  cntr = cntr + 1
  if cntr > 50 then
    EatFood(myContID)
    cntr = 0
  end  

  --Make sure status bar is open.
  if UO.Sex == -1 then
    print("ERROR: Is Character status bar not open?")
    UO.ExMsg(UO.CharID, 0, 55, "Halting" )
    stop()
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

  local norm, real, cap, lock = UO.GetSkill("mage")
  local currentSkillMageryRealValue = norm
  if currentSkillMageryRealValue ~= lastMageryValue then
    --Print time of gain.
    local nHour, nMinute, nSecond, nMillisec = gettime()
    print("Gained 0.1 @ " .. nHour .. "h " .. nMinute .. "m " .. nSecond .. "secs" .. " [" .. norm .. "]")
    --Update last magery value.
    lastMageryValue = currentSkillMageryRealValue
  end
  if currentSkillMageryRealValue == 1000 then
     print("Grandmaster Mage!")
     stop()
  end
  
  --Bandaging
  if isBandaging == true then
    while UO.Hits < (UO.MaxHits - 40 ) do
      BandageSelf(myContID)   
      for i = 1, 200 do
        if isMeditating == true and UO.Mana < UO.MaxMana then
          --Need some mana.
          Meditate()
        end
        local jresult = journal:find("barely help", "finish") 
        if jresult ~= nil then
          journal:clear()           
	  UO.SysMessage("Bandage used.", 55)
          break
        end      
        wait(100)
      end
    end
  end   
  
  --Stop at desired skill level.
  if norm >= stopAtSkill then
    print("Reached desired skill!")
    stop()
  end  
  
 
  while GetHP(mageryTarget) < 55 do
      wait(2500)
  end
  
  --Cast some spells
  if norm < 280 then
    print("Go Buy magery skill!")
    stop()
  end
  if norm >= 280 and norm <= 490 then
    CastSpell(isMeditating, thirdCircleSpell, numReagentsKeptOnSelf, mageryTarget, myContID)  --Third Circle
  end 
  if norm >= 491 and norm <= 620 then   
    CastSpell(isMeditating, fourthCircleSpell, numReagentsKeptOnSelf, mageryTarget, myContID)  --Fourth Circle
  end
  if norm >= 621 and norm <= 800 then 
    CastSpell(isMeditating, sixthCircleSpell, numReagentsKeptOnSelf, mageryTarget, myContID)  --Sixth Circle 
  end
  if norm >= 801 and norm <= 999 then 
    CastSpell(isMeditating, seventhCircleSpell, numReagentsKeptOnSelf, mageryTarget, myContID)  --Seventh Circle 
  end
  wait(3000)
end
