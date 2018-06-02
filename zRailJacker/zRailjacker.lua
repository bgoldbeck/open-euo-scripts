-- Rando's Railjacker

dofile("../lib/RLib.lua")  
dofile("lumberLib.lua")
 
rails = List:CreateList()

local myRunebookID = 1081148240
local myWoodContainerID = 1074738829
local numSearchTiles = 4
--local railfile = ("moonglow east gate")   
local railfile = ("moonglow south gate")
dofile("../" .. railfile .. ".lua")
  
axes = List:CreateList()
axes:Push(3909) -- executioners axe
axes:Push(3907) -- 2H Axe


while rails:Count() > 0 do
                        
  local ind = 1
  local coords = {x=nil, y=nil}
  for i in string.gmatch(rails:Top(), "%x+") do  
    if ind == 1 then
      coords.x = i    
    elseif ind == 2 then
      coords.y = i  
    end 
    ind = ind + 1
  end   
  local x = tonumber(coords.x)
  local y = tonumber(coords.y)
  print("Moving to next rail position " .. coords.x .. "," .. coords.y)
  -- Now let's run to this next railnode
  local cntr = 0          
  while ((math.abs(UO.CharPosX - x) > 0) or (math.abs(UO.CharPosY - y) > 0)) do
    cntr = cntr + 1
    if cntr > 10 then   
      cntr = 0
      local rnd = math.random(0,3)
      HeadMsg("Trying to unstuck", 65, UO.CharID)
      if rnd == 0 then
        for i = 1, 3 do
          Run("North")
          Pause(50)
        end
      elseif rnd == 1 then
        for i = 1, 3 do
          Run("South")
          Pause(50)
        end
      elseif rnd == 2 then
        for i = 1, 3 do
          Run("East")
          Pause(50)
        end
      elseif rnd == 3 then
        for i = 1, 3 do
          Run("West")
          Pause(50)
        end
      end
    end                                   
    if x > UO.CharPosX and y > UO.CharPosY then
      Run("Southeast")
    elseif x < UO.CharPosX and y > UO.CharPosY then
      Run("Southwest")
    elseif x > UO.CharPosX and y < UO.CharPosY then
      Run("Northeast")
    elseif x < UO.CharPosX and y < UO.CharPosY then
      Run("Northwest")
    elseif x > UO.CharPosX and y == UO.CharPosY then
      Run("East")
    elseif x < UO.CharPosX and y == UO.CharPosY then
      Run("West")
    elseif x == UO.CharPosX and y > UO.CharPosY then
      Run("South")
    elseif x == UO.CharPosX and y < UO.CharPosY then
      Run("North")
    end
    Pause(75)
  end    
  print("Arrived at node, our position is " .. UO.CharPosX .. "," .. UO.CharPosY)
  
  -- Now we will want to look and chop a tree. I it cant find a tree, then
  -- The script will continue to the next rail node.   
  for i = 1, trees:Count() do
    x, y, z = FindTileType(trees[i], numSearchTiles)
          
    if x ~= nil and y ~= nil and z ~= nil then
      -- Run up to that tree.     
      HeadMsg("Moving to tree.", 65, UO.CharID)
      while ((math.abs(UO.CharPosX - x) > 1) or (math.abs(UO.CharPosY - y) > 1)) do
        if x ~= nil and y ~= nil then
          if x > UO.CharPosX and y > UO.CharPosY then
            Run("Southeast")
          elseif x < UO.CharPosX and y > UO.CharPosY then
            Run("Southwest")
          elseif x > UO.CharPosX and y < UO.CharPosY then
            Run("Northeast")
          elseif x < UO.CharPosX and y < UO.CharPosY then
            Run("Northwest")
          elseif x > UO.CharPosX and y == UO.CharPosY then
            Run("East")
          elseif x < UO.CharPosX and y == UO.CharPosY then
            Run("West")
          elseif x == UO.CharPosX and y > UO.CharPosY then
            Run("South")
          elseif x == UO.CharPosX and y < UO.CharPosY then
            Run("North")
          end
        end
        Pause(20)
      end
                    
      -- We should now chop the tree, but first get our axe.
      local myAxeID = 0
      local myAxeType = 0
      -- Make sure our axe is equipped.
      for i = 1, axes:Count() do
        if #FindType(axes[i], nil, UO.BackpackID) > 0 then
          HeadMsg("Equipping Axe.", 65, UO.CharID)
          EquipType(axes[i], nil, UO.BackpackID)
          Pause(690)                        
        end
        local axe = FindType(axes[i], nil, UO.CharID)
        if (#axe > 0) then
          myAxeID = axe[1].ID
          myAxeType = axe[1].Type
          break
        end
      end
      HeadMsg("Chopping tree.", 65, UO.CharID)
      -- Chop the tree
      while not journal:Find("not enough wood", "too far away", "You can't", "cannot be seen") do
        UseObject(myAxeID)
        WaitForTarget(2500)
        TargetTile(trees[i], x, y, z, 3)
        Pause(1600) 
        while UO.Hits ~= UO.MaxHits do
          Pause(100)
        end
      end                         
            
      HeadMsg("No more wood.", 65, UO.CharID)
      journal:Clear()
      ignoretile:Push({X=x, Y=y, Z=z})
      Pause(math.random(650, 2200))
    end
  end
  
  if UO.Weight > UO.MaxWeight - 5 then
     HeadMsg("We must go to the bank", 65, UO.CharID)
     Cast("Recall")
     WaitForTarget(8000)
     Target(myRunebookID)
     Pause(3500)
     Msg("Bank")
     while MoveType(7133, UO.BackpackID, myWoodContainerID) do
        print("Banking some wood..")
        Pause(690)
     end
     print("Script halting, done.")
     stop()
  end
  rails:Pop()
end