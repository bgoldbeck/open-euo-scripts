dofile("../lib/RLib.lua")
dofile("lumberLib.lua")

local bank = 1077256559 
local woodContainer = 1087465711
local numSearchTiles = 7

local bsuccess = UO.TileInit()
if bsuccess ~= true then
  print("Tile init error!")
  stop()
end
    
axes = List:CreateList()
axes:Push(3907) -- Hatchet 
axes:Push(5187) -- 2H Axe
              
journal:Clear()
while UO.Hits > 0 do      
  print("Searching for valid tree.")
  for i = 1, trees:Count() do
    -- Find a valid tree
    local x, y, z = FindTileType(trees[i], numSearchTiles)
    
    -- Run up to that tree.
    if x ~= nil and y ~= nil then
    
      local cntr = 0
      print("Moving towards tile with coordinates:" .. x .. " " .. y .. " " .. z)       
      HeadMsg("Found a tree.", 65, UO.CharID)

      --print(math.abs(UO.CharPosX - x))
      --print(math.abs(UO.CharPosY - y))		
      while ((math.abs(UO.CharPosX - x) > 1) or (math.abs(UO.CharPosY - y) > 1)) do
        cntr = cntr + 1
        if cntr > 25 then   
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
        Pause(60)
        --print(math.abs(UO.CharPosX - x))
        --print(math.abs(UO.CharPosY - y))
      end	
      print("We made it to tree.")
      Pause(500)      
    
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
                  
      print("Chop tree with this axe: " .. myAxeID .. " of type: " .. myAxeType)
      
      HeadMsg("Chopping tree.", 65, UO.CharID)
      -- Chop the tree
      while not journal:Find("not enough wood", "too far away", "You can't", "cannot be seen") do
        UseObject(myAxeID)
        WaitForTarget(3000)
        TargetTile(trees[i], x, y, z, 3)
        Pause(1500) 
        while UO.Hits ~= UO.MaxHits do
           Pause(100)
        end
        if UO.Weight > UO.MaxWeight - 12 then
           print("Let's recall to bank, we have a lot of wood. Giggity.")
           --Cast("Recall")
           --WaitForTarget(8000)
           --TargetType(0x22c5, 2213, UO.BackpackID)
           --Pause(2500)
           --Msg("Bank")
           --while MoveType(7133, UO.BackpackID, woodContainer) do
                 --print("Banking some wood..")
                 --Pause(690)
           --end
           HeadMsg("Get to a bank", 65, UO.CharID)
           print("Done! Please restart script when your in a forest.")
           stop()
        end
      end
      print("No more wood..")
      ignoretile:Push({X=x, Y=y, Z=z})
      journal:Clear()
      Pause(150)
      HeadMsg("Looking for next tree.", 65, UO.CharID)
      Msg("[e whistle")
      Pause(math.random(200, 1200))
    end              
  end
end