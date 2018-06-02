dofile("../lib/RLib.lua")

local goldCoinsType = 3821
local corpseType = 8198
local lootGold = true

while UO.Hits > 0 do
  Pause(10)
            
  local corpse = FindType(corpseType, nil, nil, nil, 2)  	      
  if #corpse > 0 then
                                                                              
    HeadMsg("Opening Corpse.", 65, corpse[1].ID)    
    UseObject(corpse[1].ID)  
    Pause(690)    
    if not journal:Find("Looting this") then
      if lootGold == true then
        -- Loot the gold coins
        while MoveType(goldCoinsType, corpse[1].ID, UO.BackpackID) do
          Pause(690)
        end
      end
    end
            
    HeadMsg("Ignoring Corpse.", 65, corpse[1].ID)
    ignoreobject:Push(corpse[1].ID)
  end
end






