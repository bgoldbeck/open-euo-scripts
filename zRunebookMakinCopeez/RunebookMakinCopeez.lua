dofile("lib/lib.lua")
dofile("lib/KalOCR.lua")

journal = journal:new()  
if GetCurrentRunebookCount() < 2 then
  print("Not enough runebooks exist on character!")
  stop()
end
                      
runebookSourceID = SetTarget("Target Source Runebook.")
wait(250)
runebookDestID   = SetTarget("Target Destination Runebook.")
wait(250)
runeContID       = SetTarget("Target Container With Runes In Stock.")    
wait(250)
regContID       = SetTarget("Target Container With Regs In Stock.")


print(runebookSourceID .. " Source")
print(runebookDestID .. " Destination")  
print(runeContID .. " Rune Container")       
print(regContID .. " Reagent Container")


--Restock Runes. 16 of them
if GetCountOfItemOnSelf(3974) < 16 then
   print("Need 16 runes, go get them. Retard")
end


while GetCountOfItemOnSelf(3974) < 40 do  --Mandrake Root.
    RestockStackableItem(3974, 40, regContID)
end     

while GetCountOfItemOnSelf(3962) < 40 do  --Black Pearl
    RestockStackableItem(3962, 40, regContID)
end


while GetCountOfItemOnSelf(3963) < 40 do  --Bloodmoss
    RestockStackableItem(3963, 40, regContID)
end

--Get the name of each rune
UO.LObjectID = runebookSourceID
UO.Macro(17, 0) 
while UO.ContName ~= "generic gump" do
  wait(100)
end 
        
runeList = {}
for i = 1, 16 do
  runeList[#runeList + 1] = KAL.GetRuneName(i,UO.ContPosX,UO.ContPosY,"text")
end
for i = 1, 16 do
  print(runeList[i])
end

local counter = 0
--Recall to each spot in for loop
for i = 0, 7 do
  if i == 3 then
      while UO.Mana < UO.MaxMana do
        UO.Macro(13, 46)
        wait(1000)
      end
  end
  
  for j = 0, 1 do
    counter = counter + 1
    WorldSaveCheck(journal)
    if RecallToSpot(runebookSourceID, i, j) == true then
      if LocationBlockedChecked(journal) == true then
        print("Problem Recalling to location")
      end
      --We are at a loctaion to be marked
      local markedRune = MarkRune()
      UO.Macro(13, 46)
      if markedRune ~= nil then
        --Rename rune
        RenameRune(markedRune, runeList[counter])
        --Drag rune to runebook.
        DragRuneToRunebook(markedRune, runebookDestID )
      else
        print("Could not mark rune!")
        stop()
      end
    else
      print("Problem with runebook gump")
    end
  end
end