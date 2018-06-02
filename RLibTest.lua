dofile("lib/Rlib.lua")

local humans = FindType(400)

for i = 1, #humans do
    print(humans[i])
    print( Hits(humans[i]) )
end

stop()

print(Y(1495580))
Run("Northeast")
stop()    
journal:Clear()

instruments = List:CreateList()
instruments:Push(3742)  -- Tambourine with red tassle

for i = 1, instruments:Count() do
    local found = FindType(instruments:Get(i), nil, UO.BackpackID)
    if (#found > 0) then
       UseSkill("Provocation")
       WaitForTarget(3000)
       if journal:Find("What instrument") ~= nil then
          Target(found[1], 1)
          journal:Clear()
       end
    end
end
stop()
--print(FindType(290))

if MoveType(3742, UO.BackpackID, UO.BackpackID) then
   print("Moved Item")
end
Pause(690)
UseType(8901, nil, UO.BackpackID)
--if MoveTypeGround(3980, UO.BackpackID, UO.CharPosX + 1, UO.CharPosY, UO.CharPosZ, nil, 2, 2) then
  -- print("Moved Item to ground")
--end

--UseSkill("Animal Taming")