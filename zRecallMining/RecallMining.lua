dofile("lib/MiningLib.lua")
dofile("user.lua")
  
--Extremely Dangerous!
local passes  = 1
--Runebook IDs 
local bookIDs = {}    
--Please add as many of these lines as you want!        
bookIDs[#bookIDs + 1]         = 1154159438 -- Book 1       
--bookIDs[#bookIDs + 1]         = 1118512402 -- Book 2       
   
--End runebooks
         
--local bankID                  = 1096753503   --Your bank ID.         
local crateID                 = 1136807471   --To dump ore in bag.
local homeRuneID              = 1149619411   --Recall home to dump ore.
local beetleID                = 80767836                
             
--=================================================================================--
--==============================END SETUP==========================================--  
--=================================================================================--

PrintIngotDetails(crateID)       
  

local result = UO.TileInit(true)
if result == false then
  print("Could not init tiles!")
end   
         
   
journal = journal:new()
      
local allGoldEarned = 0
local allOreMinedTotal = 0
local allTimeTaken     = 0
        
--Digger(beetleID)
--stop()  

for loop = 1, passes do

  local startTime = getticks()   
  local goldEarnedLog = {}  
  local mineralLog = {}
  for i = 1, 16 do
    mineralLog[#mineralLog + 1] = 0
  end

  local runebookNo = lastRunebook + 1
  if runebookNo > #bookIDs then
    runebookNo = 1
  end

  print("Starting off with runebook #" .. runebookNo)  
             

  local f,e = openfile("user.lua", 'w')
  f:write("lastRunebook = " .. runebookNo)   
  f:close()

      
  --Deposit Ore
  --DepositOreToBank(crateID) 
  --Restock recall regs
  --ReagentCheck(bankID)    
  local counter = 0
           
  for i = 0, 7 do  
    for j = 0, 1 do
      counter = counter + 1
      --Check if status bar remains open.
      ErrorStatusBar()    
    
      local currentPosX = UO.CharPosX   
      local currentPosY = UO.CharPosY
    
      --Recall to next location.       
      print(" ")    
      print("Recalling to location -=-(" .. counter .. ")-=-")  
      --Wait until recall goes off.
      local retry = 0
      while currentPosX == UO.CharPosX and currentPosY == UO.CharPosY do
        retry = retry + 1
        RecallFromRunebook(bookIDs[runebookNo], i, j)       
        wait(300)
        for z = 1, 100 do
          wait(100) 
          if currentPosX ~= UO.CharPosX or currentPosY ~= UO.CharPosY then
            break
          end
        end         
        if retry >= 5 then
          break
        end
      end 
      wait(100) 
              
      --Get the tile to mine on.
      Digger(beetleID) 
      wait(1950)
              
      currentPosX = UO.CharPosX   
      currentPosY = UO.CharPosY
      --Make sure we are not overweight.
      while UO.Weight > ( UO.MaxWeight + 4 ) do   
        for x = -1, 1 do
          dropX = UO.CharPosX + x
          dropY = UO.CharPosY
          if x == 0 then
            dropY = UO.CharPosY + 1
          end
          local dropNum = 2
          if UO.Weight > 406 then
            dropNum = 2
          end
          --Drop some stuff.
          MoveTypeGround(bigOreType, UO.BackpackID, dropNum, dropX, dropY)   
          wait(720)  
          if FindColorOreGround(1) ~= 0 then
            MoveItem(FindColorOreGround(1), UO.BackpackID, 2)
            wait(720)
          end
          if UO.Weight < ( UO.MaxWeight + 5 ) then
            break
          end
        end
      end
      Mount(beetleID)           
      goldEarnedLog[#goldEarnedLog + 1] = PrintIngotDetails(UO.BackpackID) 
      mineralLog[counter] = ItemTypeCount(ingotType, UO.BackpackID)
      if counter ~= 1 then
        print("Amount of Ingot gathered here: " .. mineralLog[counter] - mineralLog[counter - 1])
      else
        print("Amount of Ingot gathered here: " .. mineralLog[counter])
      end    
      --Go to home
      print(" ")
      if (ItemTypeCount(ingotType, UO.BackpackID) > 500) or counter == 16 then                  
        currentPosX = UO.CharPosX   
        currentPosY = UO.CharPosY
        while currentPosX == UO.CharPosX and currentPosY == UO.CharPosY do
          print("Recalling to home with rune")
          RecallFromRune(homeRuneID)
          wait(2750)
        end
     
        -- Stand exactly next to crate in house.
        while UO.CharPosX ~= 1927 or UO.CharPosY ~= 2200 do
          UO.Macro(5, 1)
        end
      
        wait(4000)
      
      
        --Deposit Ore
        DepositToCrate(crateID)  
      end  
      --Check if player paused script.
      PlayerPaused()
    end
  end               
  print("")    
  print("|---------------------------------------|") 
  print("       Ingot in bank details...")    
  print("|---------------------------------------|") 
  PrintIngotDetails(crateID)       
  --print("|---------------------------------------|") 
  --print("Mandrake   : " .. ItemTypeCount(mandrakeRootType, bankID))
  --print("Bloodmoss  : " .. ItemTypeCount(bloodmossType, bankID))
  --print("Black Pearl: " .. ItemTypeCount(blackPearlType, bankID))
  --print("|---------------------------------------|") 

  --Save log       
  local mineralTotal = 0
  local goldTotal = 0
  f,e = openfile("log.txt", 'w')
  
  for i = 1, #mineralLog do  
    goldTotal = goldTotal + goldEarnedLog[i] 
    mineralTotal = mineralTotal + mineralLog[i]
    allOreMinedTotal = allOreMinedTotal + mineralLog[i]
    if goldEarnedLog[i] < 250 then  
      f:write("Ingot mined at location #" .. i .. " = " .. mineralLog[i] .. " (" .. goldEarnedLog[i] .. "gp) <---- LOW WARNING\n")   
      print("Ingot mined at location #" .. i .. " = " .. mineralLog[i] .. " (" .. goldEarnedLog[i] .. "gp) <---- LOW WARNING\n")
      else
      f:write("Ingot mined at location #" .. i .. " = " .. mineralLog[i] .. " (" .. goldEarnedLog[i] .. "gp)\n")   
      print("Ingot mined at location #" .. i .. " = " .. mineralLog[i] .. " (" .. goldEarnedLog[i] .. "gp)\n")  
    end  
  end    
  f:write("Total Ingot mined = " .. mineralTotal .. " Using runebook #" .. runebookNo)   
  print("Total Ingot mined = " .. mineralTotal .. " Using runebook #" .. runebookNo)  
  f:close()
  print("Total gold earned = " .. goldTotal .. "gp")
  allGoldEarned = allGoldEarned + goldTotal

  --Time stuff
  local endTime = getticks()
  local diffTime = endTime - startTime
  diffTime = math.ceil(diffTime / 1000 )
  allTimeTaken = allTimeTaken + diffTime
  print("It took " .. diffTime .. " seconds to complete.")    
  print("")
  
  dofile("user.lua")   --Update the last runebook used.
end --endfor  
               
allMins = math.ceil(allTimeTaken / 60)           
print("Master Totals...")
print("It took " .. allTimeTaken .. " seconds (" .. allMins .. "mins) to completely run through " .. passes .. " books.")    
print("You mined " .. allOreMinedTotal .. " total ore in all locations and earned " .. allGoldEarned .. "gp")
local earnedPerSecond = round(allGoldEarned/allTimeTaken) 
local earnedPerHour = round(earnedPerSecond * 3600)
print("You are earning " .. earnedPerSecond .. "gp per sec ((" .. earnedPerHour .. "gp per hour))")

--DepositPickaxe(crateID)   
--DepositGloves(crateID)

UO.Msg("/".. allTimeTaken .. string.char(13))

--Hiding

UO.Macro(13, 21)
wait(1000)
Mount(beetleID)

--Done!
print("Done!")    
for i = 1, 2 do                        
  UO.ExMsg(UO.CharID, 0, i * 10, "!!!!!!!!!!!" )  
  UO.ExMsg(UO.CharID, 0, i * 20, "Done! Done!" )  
  UO.ExMsg(UO.CharID, 0, i * 30, "!!!!!!!!!!!" )
  wait(250)
end                        
UO.ExMsg(UO.CharID, 0, 300, "Done! Done!" )    
UO.ExMsg(UO.CharID, 0, 45 , "Done! Done!" )     
UO.ExMsg(UO.CharID, 0, 15 , "Done! Done!" )