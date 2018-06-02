dofile("../lib/RLib.lua")

UO.TileInit()

ignoreobject:Push(UO.CharID)  -- Ignore self for player detection  



local water = {6041, 6039, 6044, 6043, 6042, 6040}
local poleType = 0xdbf
local recallFromPlayers = true

--UO.Pathfind(UO.CharPosX + 2, UO.CharPosY, UO.CharPosZ)
local pole = FindType(poleType, nil, UO.BackpackID)
if #pole > 0 then
  EquipType(poleType, nil, UO.BackpackID)
  Pause(790)
end
pole = FindType(poleType, nil, UO.CharID)  
if #pole == 0 then
  HeadMsg("Where is my fucking pole?", 39)
  Stop()
end  
pole = pole[1].ID
  
while UO.Hits > 0 do
  Pause(150)
  -- OMG Player boater
  if recallFromPlayers == true then
    local boater = FindType({400, 401}, nil, nil, nil, 15)
            		    		      
    if #boater > 0 and (boater[1].Rep == 1 or boater[1].Rep == 4 or boater[1].Rep == 6) then
      --Msg("Stop", 65) -- Causing crashing?!?
      HeadMsg("Zermurgurd a player!", 39)  
      CancelTarget()
      Cast("Recall")    
      WaitForTarget(4500)
      TargetType(8901, 2124, UO.BackpackID, nil, 1)
    end  
  end
    
   
    
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
  print(waterTileType)
  if waterTileType ~= 0 then
    CancelTarget()
    Pause(100)
    UseObject(pole)
    --Pause(1000)
    WaitForTarget(2500)
    Pause(250)
    TargetTileTypeRelative(waterTileType, -3, 0, -3, 3)
    Pause(1500)
    local jres = journal:Find("biting")
    if jres == 1 then
      Msg("Forward one", 65)
      journal:Clear()
    end
  end	    
      	  	      
end





