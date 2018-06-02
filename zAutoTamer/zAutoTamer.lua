--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\--
--              SET YOUR VARIABLES                  -- 
tamerName = ("Beatlemania")           
petRename = ("BM")
ignoreKey = ("HOME")
pauseKey = ("END")
clearIgnoreList = false
isReleasing = true
local numSearchTiles = 7
--///////////////////////////////////////////////////--
--                    zAutoTamer                     --
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\--
local tamerFound = false
for i = 1, UO.CliCnt do
  UO.CliNr = i
  if UO.CharName == tamerName then
    print("We found your tamer.")
    tamerFound = true
    break
  end
end
if tamerFound == false then
  print("Where is your tamer? Is the name correct?")
  stop()
end


dofile("../lib/RLib.lua")
             
local f, e
if clearIgnoreList == true then
  f, e = openfile("ignorelist.lua", 'w')        
else
  f, e = openfile("ignorelist.lua", 'a')
end           
f:close()

dofile("ignorelist.lua") 


tameables = List:CreateList()
tameables:Push(233) --Bull 1
tameables:Push(232) --Bull 2   
tameables:Push(234) --Great Hart     
tameables:Push(212) --Grizzly Bear


local lastTamingNorm, real, cap, lock = UO.GetSkill("animal taming")
print("We begin with " .. lastTamingNorm / 10 .. " normal taming skill.")

local paused = false

function ignoreAnimal(id)
  ignoreobject:Push(id)     
  f, e = openfile("ignorelist.lua", 'a')
  f:write("ignoreobject:Push(" .. id .. ")\n")
  f:close()
  return
end

function ReleasePet(name)  
  Msg(name .. " release")
  Pause(350)
                  
  timeout = 2500 + getticks()
  repeat      
  i = 0
  while UO.ContKind ~= 20988 do
    i = i + 1
    if (i > 10) then
      break
    end
    Pause(150)
  end
  Pause(150)
  UO.Click(UO.ContPosX + 35, UO.ContPosY + 90, true, true, true, false)
  Pause(150)
  until UO.ContSizeX ~= 270 and UO.ContSizeY ~= 120 or getticks() > timeout
end

function targetIgnoreMob()
  UO.TargCurs = false
  UO.TargCurs = true
  HeadMsg("Please target the animal to ignore.", 65, UO.CharID)
  while UO.TargCurs == true do
    Pause(50)        
  end
  ignoreAnimal(UO.LTargetID)
  HeadMsg("Ignoring animal!", 65, UO.LTargetID)
  return
end

while UO.Hits > 0 do
  while UO.Followers == UO.MaxFol do
    Pause(15)
  end
  for i = 1, tameables:Count() do  
    local cantTame = false
                                    
    if getkey(ignoreKey) then 
      targetIgnoreMob()
      cantTame = true
      break 
    end
    local found = nil
    for j = 1, numSearchTiles do
      found = FindType(tameables[i], nil, nil, nil, j)
      Pause(1)
      if #found > 0 then
        break
      end
    end
    if found == nil then break end
    --if found[1] == nil then break end
                                    
                                    
    if #found >= 0 and found[1] ~= nil then
      if found[1].Rep ~= 3 then
        cantTame = true
        break
      end
    end
                                    
    if #found > 0 then
      HeadMsg("Found something to tame!", 65, UO.CharID)
                                                      
      local id = found[1].ID    
      HeadMsg("[Taming Target]", 65, id)
      Target(id, 1)
      --print("Moving towards animal with coordinates:" .. x .. " " .. y .. " " .. z)
                                                
      --print(math.abs(UO.CharPosX - x))
      --print(math.abs(UO.CharPosY - y))
      local cntr = 0		
      while UO.Hits > 0 do
        if getkey(pauseKey) then
          paused = true   
          print("Paused..")
          HeadMsg("Paused..", 65, UO.CharID)
          Pause(1000)
        end
                                                                    
        while paused == true do
          if getkey(pauseKey) then
            paused = false
            HeadMsg("Unpaused..", 65, UO.CharID)
            print("Unpaused!")
            Pause(1000)
            break
          end
          Pause(10)
        end
        currentTamingNorm, real, cap, lock = UO.GetSkill("animal taming")
        if lastTamingNorm ~= currentTamingNorm then
          lastTamingNorm = currentTamingNorm
          local nHour, nMinute, nSecond, nMillisec = gettime()
          f, e = openfile(UO.CharName .. " gains.lua", 'a')
          print("Gained Animal Taming @ " .. nHour .. "h " .. nMinute .. "m " .. nSecond .. "secs" .. " [" .. currentTamingNorm / 10 .. "]")
          year, month, day = getdate()
          f:write(year .. "/" .. month .. "/" .. day .. " - Gained Animal Taming @ " .. nHour .. "h " .. nMinute .. "m " .. nSecond .. "secs" .. " [" .. currentTamingNorm / 10 .. "]\n")
          f:close()   
        end
        if getkey(ignoreKey) then targetIgnoreMob() end
        found = FindObject(found[1].ID)
        if (found[1] == nil) then
          print("Too far away!")
          cantTame = true
          break
        end
        local x = found[1].X
        local y = found[1].Y
        local z = found[1].Z
        cntr = cntr + 1
        if cntr > 40 then   
          cntr = 0
          local rnd = math.random(0,3)
          HeadMsg("Trying to unstuck", 65, UO.CharID)     
          HeadMsg("[Taming Target]", 65, id)
          if rnd == 0 then
            for i = 1, 5 do
              Run("North")
              Pause(50)
            end
          elseif rnd == 1 then
            for i = 1, 3 do
              Run("South")
              Pause(50)
            end
          elseif rnd == 2 then
            for i = 1, 5 do
              Run("East")
              Pause(50)
            end
          elseif rnd == 3 then
            for i = 1, 5 do
              Run("West")
              Pause(50)
            end
          end
        end
        if cantTame == true then break end
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
        Pause(10)
        if math.abs(UO.CharPosX - x) <= 2 and math.abs(UO.CharPosY - y) <= 2 then 
          UseSkill("Animal Taming")
          HeadMsg("[Taming Target]", 65, id)
          WaitForTarget(250)
          Target(id, 1)
          Pause(50)
          cntr = 0
        end
        local jres = journal:Find("looks tame already", "too many owners")
        if jres == 1 or found[1].Rep ~= 3 then
          if isReleasing == true then
            HeadMsg("Releasing..", 65, UO.CharID)
            while found[1].Rep ~= 3 do  
              UO.RenamePet(id, petRename)
              Pause(100)
              ReleasePet(petRename)   
              Pause(100)
              found = FindObject(found[1].ID) 
              if found[1] == nil then
                break
              end
            end
            Pause(50)
            HeadMsg("I am released.", 65, id)
            break   
          else     
            UO.RenamePet(id, petRename)
            break
          end     
        elseif jres == 2 then
          break
        end
                      
      end
      if (cantTame == false) then
        ignoreAnimal(id)     
        HeadMsg("Ignoring animal.", 65, id)
        journal:Clear()
        Pause(500)
      end
    end
  end
end




