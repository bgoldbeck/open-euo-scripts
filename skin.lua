--================================================================
--Setup
--================================================================
local SkinningTool  = 1073742058 --1085305433 -- Manually set skinning tool
local Hides         = 4217
local Scissors      = 1073878500 --1080721841
local currentCorpse
--================================================================
 
 
--================================================================
--Move to Corpse
--================================================================
function MoveToCorpse()
  local totalItems = UO.ScanItems(true)
  print(totalItems.." total 'visible' items found!")
  for i=0,totalItems - 1,1 do
    local nID,nType,nKind, nContID, nX, nY, nZ, nStack, nRep, nCol = UO.GetItem(i)
    print("Searching for a corpse @ scan#"..i.."...")
    if nType == 8198 then
      local c = 10
      while c > 1 do
        --Determines distance from item found
        local a = math.max (UO.CharPosX,nX) - math.min (UO.CharPosX,nX)--
        local b = math.max (UO.CharPosY,nY) - math.min (UO.CharPosY,nY)
        c = math.max (a,b) --c is the distance from the item found
        local d = UO.Property(nID) --For debugging
        print("Found "..d.." "..c.." tiles away.") --For debugging
        --UO.Pathfind(nX,nY)
        UO.Move(nX,nY,1,4000)
        wait(1000)
      end
      return nID --returns the item ID of the found corpse
    end -- end if statement
  end -- end for loop
end -- end function
--================================================================
 
 
--================================================================
--Skin/Loot Corpse
--================================================================
function SkinLootCorpse(skin)
 
  while UO.ContID ~= currentCorpse do
    --wait (1000)
    UO.LObjectID = currentCorpse
    UO.Macro(17,0)
    wait (200)
  end
 
  if skin == true then
    while UO.TargCurs == false do
      --wait (1000)
      UO.LObjectID = SkinningTool
      UO.Macro(17,0)
      wait (500)
    end
       
    --while UO.TargCurs == true do
    --wait (1000)
    UO.LTargetID   = currentCorpse
    UO.LTargetKind = 1
    UO.Macro(22,0)
    wait (500)
    --end
       
    --while UO.ContID ~= currentCorpse do
    --wait (1000)
    UO.LObjectID = currentCorpse
    UO.Macro(17,0)
    wait (300)
    --end
  end
       
  --if UO.ContID == currentCorpse then
  --local d = UO.Property(nID)    
  --print(d.." body container has been detected! ")
  --print("")
       
  local totalItems = UO.ScanItems(false)
  print(totalItems.." total 'visible' items found!")
       
  for i=0,totalItems - 1,1 do
 
    local nID,nType,nKind, nContID, nX, nY, nZ, nStack, nRep, nCol = UO.GetItem(i)
    print("Searching for item in corpse @ scan#"..i.."...")
    --local d = UO.Property(nID)
    --print("Searching for ")
    if UO.ContID == 0 then
      print("Corpse no longer exist.")
      break
    end
   
    local d = UO.Property(nID)
    local f = UO.Property(nContID)
    print("scan #"..i.." Found "..d.." with a Find Kind = "..nKind.." , with a Find ID = "..nID.." , Found in "..f.." = "..nContID)
    print("Does "..nContID.." = "..UO.ContID.." ?")
    print("")
         
    if nContID == UO.ContID then      
      local d = UO.Property(nID)
      local f = UO.Property(UO.ContID)
      print("Found "..d.." in "..f)
                       
      if nType == Hides then -- 4217 Hides
        -- "Items you wish to cut must be in your backpack."
        wait (1000)
        UO.Drag(nID,nStack)
        wait (500)
        UO.DropC(UO.BackpackID)
        wait (2000)
        -- comment out the above five lines if you can cut hides while they are still on the corpse
       
        UO.LObjectID = Scissors
        wait (300)
        UO.Macro(17,0)
        UO.LTargetID = nID
        UO.Macro(22,0)
        wait(300)
        -- return -- uncomment this line if you can cut hides while they are still on the corpse
      else
        wait (1000)
        UO.Drag(nID,nStack)
        wait (500)
        UO.DropC(UO.BackpackID)
      end
   
         --UO.CliDrag(123) --drags item 123
         --UO.Click(795,383,true,true,true,false) --clicks at screen coords 400/400 to drop item 123
       
         --while UO.ContName ~= "drag gump" do
         --wait (1000)
         --UO.Drag(nID,nStack)
         --wait (2000)
         --end
         --UO.DropC(UO.BackpackID)
         --end          
         --end
 
    end -- end if
  end -- end for loop
end
--================================================================
 
--================================================================
--Main
--================================================================
currentCorpse = MoveToCorpse()
if currentCorpse ~= nil then
  print("The corpses item id is "..currentCorpse)
  SkinLootCorpse(true)
  -- SkinLootCorpse(false) -- uncomment this line if you can cut hides while they are still on the corpse
  currentCorpse = nil
else
  if currentCorpse == nil then
    print("No Corpses Found.")
  end
end
print("Program will now end.")
--================================================================