
--Leave alone! (unless you know what to do.)
dofile("lib/RestockLib.lua")   

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

    
    --Check Restock key
    local isRestockKeyPressed = getkey(restockPVPItemsKey)
    if(isRestockKeyPressed) then    
        TheBigRestock(restock)
        isRestockKeyPressed = false
    end
    
    --Check Restock from corpse key
    local isRestockFromCorpseKeyPressed = getkey(restockFromCorpseKey)
    if(isRestockFromCorpseKeyPressed) then
        TheBigRestockFromCorpse(restock)
        isRestockFromCorpseKeyPressed = false
    end      
    
    --Check Un-Restock key
    local isUnRestockKeyPressed = getkey(unRestockPVPItemsKey)
    if(isUnRestockKeyPressed) then    
        InversedRestock()
        isUnRestockKeyPressed = false
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
        --ItemWasUsed(getticks() + useAnyItemDelay)
        --HealPotionUsed(getticks() + healPotionDelay)
    end
    
end                                    

                 