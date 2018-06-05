dofile("../lib/RLib.lua")
local result = UO.TileInit(true)
if result == false then
  print("Could not init tiles!")
end   
                    
--ignoreobject:Push(UO.CharID)  -- Ignore self for player detection  
local cargoHoldID = 1156735560
local reverseDirTimer = Timer:New()
local waterTypes = {6041, 6039, 6044, 6043, 6042, 6040}
local cutTypes = {2508, 2511, 2510, 2509} -- Regular Fish 
local consumeTypes = {3542}
local scissorTypes = {}
local garbageTypes = {5899, 5900, 5902, 5901, 5903, 5904, 5905, 5906} 

local hatchetType = 3907
local scissorType = 3998
local waterKind = 2
local poleType = 3519
local recallFromPlayers = true

	 
--UO.Pathfind(UO.CharPosX + 2, UO.CharPosY, UO.CharPosZ)
local pole = FindType(poleType, nil, backpack)
if #pole > 0 then
  EquipType(poleType, nil, UO.BackpackID)
  Pause(790)
end
pole = FindType(poleType, nil, self)  
if #pole == 0 then
  HeadMsg("Where is my fucking pole?", 39)
  Stop()
end  

pole = pole[1].ID
  
while UO.Hits > 0 do     
  Pause(150)
                    
  local x = UO.CharPosX
  local y = UO.CharPosY - 1
  local waterTileType = 0	
  nCnt = UO.TileCnt(x, y)
  for i = 1, nCnt do
    nType,tileZ,sName,nFlags = UO.TileGet(x, y, i)
    for j = 1, #waterTypes do
      if nType == waterTypes[j] then
        waterTileType = nType
        break
      end
    end
  end           
  if waterTileType ~= 0 then
    Pause(100)
    for loop = 0, 1 do
      UseObject(pole)
      WaitForTarget(2500)
      Pause(250)
      if loop == 0 then
        TargetTile(waterTileType, X() - 4, Y() - 4, Z(), waterKind)
      else
        TargetTile(waterTileType, X() + 4, Y() - 4, Z(), waterKind)
      end
      Pause(7500)
    end
    local jres = journal:Find("biting", "reach")
    if jres == 1 then
      Msg("Forward one", 65)
      journal:Clear()
    end
  end	   
  -- Cut stuff up 
  for i = 1, #cutTypes do
    local cut = FindType(cutTypes[i], nil, backpack)
    if #cut > 0 then
      UseType(hatchetType, nil, backpack)
      WaitForTarget(2500)
      Target(cut[1].ID)
      Pause(700)
    end
  end
  -- Scissor stuff up
  for i = 1, #scissorTypes do
  end    
  -- Scissor stuff up
  for i = 1, #garbageTypes do
    if MoveTypeGround(garbageTypes[i], backpack, X(), Y() + 1, Z()) == true then
      Pause(700)
    end
  end    
  -- Eat consume stuff up      
  for i = 1, #consumeTypes do
    if UseType(consumeTypes[i], nil, backpack) == true then
      Pause(700)  
    end
  end    
  -- Turn boat around.
  if reverseDirTimer:Dif() > 900000 then
    Msg("Come About")
    reverseDirTimer:Clear()
  end	  	 
  -- Move all fish
  if CountType(2426, nil, backpack) > 100 then
    MoveType(2426, backpack, cargoHoldID, nil, nil, nil)
    Pause(800)
  end     
end


