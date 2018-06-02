
--Leave alone! (unless you know what to do.)
dofile("lib/BrandonsPvPLib.lua")   

local isNewCharacter = true  
if UO.Sex ~= -1 then  
  if not ExistsFile("../chars/" .. UO.CharName .. ".lua") then
     isNewCharacter = true
  else    
     isNewCharacter = false  
  end
else    
   print("Exiting! : Is status bar opened?")
  stop()
end                                                                              

local start = StartMenu(isNewCharacter)
if start == false then
   print("Exiting!")
   stop()
end     
--Door section              
local lastDoorX = 0
local lastDoorY = 0
local doorWasOpened = false
--/Doors
local restock = Restock:new(meatRestockCnt, bangageRestockCnt, regRestockCnt, pouchRestockCnt, strPotRestockCnt, agilPotRestockCnt, curePotRestockCnt, healPotRestockCnt, explPotRestockCnt, refrPotRestockCnt, healPotBagID, curePotBagID, exploPotBagID, pouchesBagID, generalItemsBagID, refreshPotBagID, strPotBagID, agilPotBagID)    
journal = journal:new()      
    
print("Starting...")

while 1 do
    if UO.Sex == -1 then   
        print("ERROR: Is Character status bar not open?")    
        UO.ExMsg(UO.CharID, 0, 55, "Halting" )
        stop()
    end
    --Check target nearest human key
    local isTargetNearestHumanButtonPressed = getkey(targetNearestHumanKey)
    if(isTargetNearestHumanButtonPressed) then
        TargetNearestHuman(aUONextHumanKey)
        isTargetNearestHumanButtonPressed = false
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
        --Pretend as if items were used as to not screw things up with saves.  
        ItemWasUsed(getticks() + useAnyItemDelay)
        HealPotionUsed(getticks() + healPotionDelay)
    end

    if CanUseAnotherItem(getticks()) == true then
        --Door section
        if isOpeningDoors == true then
            if doorWasOpened == true then
                --Make sure the character moves 2 tiles before opening a door again.
                if math.abs( lastDoorX - UO.CharPosX ) >= 2 then
                    doorWasOpened = false
                end
                if math.abs( lastDoorY - UO.CharPosY) >= 2 then
                    doorWasOpened = false
                end
            else 
                --Open door and check if one was opened
                if OpenNearestDoor() == true then  
                    lastDoorX = UO.CharPosX
                    lastDoorY = UO.CharPosY
                    doorWasOpened = true          
                    ItemWasUsed(getticks() + useAnyItemDelay)
                    UO.SysMessage("Opening Door...", 80)
                end
            end
         end
         --/Doors
     
         --Paralyzed?
         if GetIsParalyzed() == true then
             if UseParalyzePouch() == true then
                 ItemWasUsed(getticks() + useAnyItemDelay)
             end
         end    
         
         --Poisoned?          
         if isChugCureOnPoison == true then 
             if GetIsPoisoned() == true then
                 if isVerbose == true then
	             UO.ExMsg(UO.CharID, 0, 55, "Cured!")
                 end
                 --Chug Cure Potion   
                 ItemWasUsed(getticks() + useAnyItemDelay)
              end
         end
         
         --Low HP? 
         if isChugHealOnLow == true then  
             local hp = GetHP(UO.CharID) 
             if hp ~= nil then  
                 if hp < chugHealPotHealth then 
                     if CanUseHealPotion(getticks()) == true then
                         if isVerbose == true then
	                     UO.ExMsg(UO.CharID, 0, 55, "Healed!")
                         end                          
                         --Chug Heal Potion         
                         ItemWasUsed(getticks() + useAnyItemDelay)
                         HealPotionUsed(getticks() + healPotionDelay)
                     end
                 end
             end
         end 
         --Low Stamina?
         if isChugRefreshPotion == true then
             if UO.Stamina < chugRefreshPotOnStamina then
                 if isVerbose == true then
	             UO.ExMsg(UO.CharID, 0, 55, "Refreshed!")
                 end           
                 --Chug Refresh Potion         
                 ItemWasUsed(getticks() + useAnyItemDelay)
             end
         end 
    end
    
    
end                                    

                 