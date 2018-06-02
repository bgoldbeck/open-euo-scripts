dofile("../lib/RLib.lua")
local result = UO.TileInit(true)
if result == false then
  print("Could not init tiles!")
end   
       
--ignoreobject:Push(UO.CharID)  -- Ignore self for player detection  

local water = {6041, 6039, 6044, 6043, 6042, 6040}
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
    for j = 1, #water do
      if nType == water[j] then
        waterTileType = nType
        break
      end
    end
  end
  if waterTileType ~= 0 then
    --CancelTarget()
    Pause(100)
    UseObject(pole)
    --Pause(1000)
    WaitForTarget(2500)
    Pause(250)
    TargetTile(waterTileType, X() + 3, Y() - 3, Z(), waterKind)
    Pause(1500)
    local jres = journal:Find("biting")
    if jres == 1 then
      Msg("Forward one", 65)
      journal:Clear()
    end
  end	    
      	  	      
end



