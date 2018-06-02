dofile("../lib/RLib.lua")

--//! GLOBALS !//--
local loots = List:CreateList()
local daggerType = 3922     
local scissorType = 3999     
local corpseType = 8198
--//!---------!//--

-- Do you want to skin the corpses?
local isSkinning = false
local isShearSheep = true

loots:Push({ Type = 3821, Name = "Gold Coins"   , Looting = true  })
loots:Push({ Type = 4217, Name = "Hides"        , Looting = true  }) 
loots:Push({ Type = 2545, Name = "Meat"         , Looting = false }) 
loots:Push({ Type = 7121, Name = "Feathers"     , Looting = true  })
loots:Push({ Type = 3966, Name = "Bones"        , Looting = true  })  
loots:Push({ Type = 3903, Name = "Arrows"       , Looting = true  })  
loots:Push({ Type = 7163, Name = "Bolts"        , Looting = true  })
loots:Push({ Type = 3974, Name = "Mandrake Root", Looting = true  })   
loots:Push({ Type = 3980, Name = "Sulfurous Ash", Looting = true  })
loots:Push({ Type = 3962, Name = "Black Pearl"  , Looting = true  }) 
loots:Push({ Type = 3963, Name = "Bloodmoss"    , Looting = true  }) 
loots:Push({ Type = 3976, Name = "Nightshade"   , Looting = true  }) 
loots:Push({ Type = 3972, Name = "Garlic"       , Looting = true  }) 
loots:Push({ Type = 3973, Name = "Ginseng"      , Looting = true  }) 
loots:Push({ Type = 3981, Name = "Spider Silk"  , Looting = true  })  
loots:Push({ Type = 3617, Name = "Bandages"     , Looting = false }) 

---------------------------------------------------------------------
local scissors = FindType(scissorType, nil, UO.BackpackID)
local skinner = FindType(daggerType, nil, UO.BackpackID)

function CutHidesIfExists()
  if UO.Weight >= UO.MaxWeight then
    isSkinning = false
  end
  local hides = FindType(4217, nil, UO.BackpackID)
  if #hides > 0 then
    Print("Cutting up hides.")
    scissors = FindType(scissorType, nil, UO.BackpackID)
    if #skinner == 0 then
      HeadMsg("Cant find scissors, must exit.", 65)
      stop() 	
    end 
    UseObject(scissors[1].ID)
    WaitForTarget(2000)
    Target(hides[1].ID, 1)
    Pause(720)
  end
end

function ShearSheepIfExists()
  local sheep = FindType(207, nil, nil, nil, 2)

  if #sheep > 0 then
    UseObject(skinner[1].ID)
    WaitForTarget(2000)
    Target(sheep[1].ID)
    Pause(720)
    HeadMsg("Baaaaah, Fuck you!", 65, sheep[1].ID) 
  end
end

while UO.Hits > 0 do
  Pause(10)
                  	                  
  local corpse = FindType(corpseType, nil, nil, nil, 2)
  local looted = true                     	      
  if #corpse > 0 then      
    skinner = FindType(daggerType, nil, UO.BackpackID)
    if #skinner == 0 then
      HeadMsg("Cant find skinning tool, must exit.", 65)
      stop() 	
    end  
                             	   
    HeadMsg("Opening Corpse.", 65, corpse[1].ID)
    Print("Opening Corpse.")  
    UseObject(corpse[1].ID)  
    Pause(720)
    if not journal:Find("Looting this") then
      if isSkinning == true then
        Print("Skinning Corpse.")
        HeadMsg("Skinning Corpse.", 65, corpse[1].ID)
        UseObject(skinner[1].ID)
        WaitForTarget(2000)
        Target(corpse[1].ID, 1)
        Pause(720)
      end
                                                      
      for i = 1, loots:Count() do
        Pause(1)        
        if loots[i].Looting == true then
          while MoveType(loots[i].Type, corpse[1].ID, UO.BackpackID) do
            if journal:Find("That container cannot") then
              HeadMsg("Overweight, Halting.", 65)
              Stop()
            end 
            HeadMsg("Taking " .. loots[i].Name .. ".", 65, corpse[1].ID)
            Pause(720)      
            if journal:Find("That is too far away", "out of sight", "cannot be seen") then
               looted = false
               break
            end
          end
                                        
        end
      end       
    end  
    if looted == true then
      Print("Ignoring Corpse.")        
      HeadMsg("Ignoring Corpse.", 65, corpse[1].ID)
      ignoreobject:Push(corpse[1].ID)
    end
  end
  if isShearSheep == true then
    ShearSheepIfExists()
  end                      
  journal:Clear()
  
  CutHidesIfExists()
end
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  