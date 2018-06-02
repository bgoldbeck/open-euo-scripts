dofile("lib/SmelterLib.lua")        

  
miningGlovesID = 0x40c34b6f
oreContainerID = 0x4021b746
ingotContainerID = 0x40e62ec0

ingotType = 0x1bf2 
oreType = 0x19b9

ironCol = 0    
dullCopperCol = 1045
copperCol = 1119
shadowCol = 1109
bronzeCol = 1752    
goldCol = 1719
agapiteCol = 2430
veriteCol = 2002
valoriteCol = 1348


--Ingot Count before smelting
ironBeforeCnt = ItemTypeCountWithColor(ingotType, ingotContainerID, ironCol)   
dullCopperBeforeCnt = ItemTypeCountWithColor(ingotType, ingotContainerID, dullCopperCol)
copperBeforeCnt = ItemTypeCountWithColor(ingotType, ingotContainerID, copperCol)    
shadowBeforeCnt = ItemTypeCountWithColor(ingotType, ingotContainerID, shadowCol)
bronzeBeforeCnt = ItemTypeCountWithColor(ingotType, ingotContainerID, bronzeCol)     
goldBeforeCnt = ItemTypeCountWithColor(ingotType, ingotContainerID, goldCol)
agapiteBeforeCnt = ItemTypeCountWithColor(ingotType, ingotContainerID, agapiteCol)
veriteBeforeCnt = ItemTypeCountWithColor(ingotType, ingotContainerID, veriteCol)
valoriteBeforeCnt = ItemTypeCountWithColor(ingotType, ingotContainerID, valoriteCol)
print("Ore count before smelting..")
print("#Iron Ore          : " .. ItemTypeCountWithColor(oreType, oreContainerID, ironCol)) 
print("#Dull Copper Ore   : " .. ItemTypeCountWithColor(oreType, oreContainerID, dullCopperCol))
print("#Copper Ore        : " .. ItemTypeCountWithColor(oreType, oreContainerID, copperCol))     
print("#Shadow Ore        : " .. ItemTypeCountWithColor(oreType, oreContainerID, shadowCol))
print("#Bronze Ore        : " .. ItemTypeCountWithColor(oreType, oreContainerID, bronzeCol))
print("#Gold Ore          : " .. ItemTypeCountWithColor(oreType, oreContainerID, goldCol))
print("#Agapite Ore       : " .. ItemTypeCountWithColor(oreType, oreContainerID, agapiteCol))
print("#Verite Ore        : " .. ItemTypeCountWithColor(oreType, oreContainerID, veriteCol))
print("#Valorite Ore      : " .. ItemTypeCountWithColor(oreType, oreContainerID, valoriteCol))
print("")
print("")
print("Ingot count before smelting..")
print("#Iron Ingot          : " .. ironBeforeCnt) 
print("#Dull Copper Ingot   : " .. dullCopperBeforeCnt)
print("#Copper Ingot        : " .. copperBeforeCnt)     
print("#Shadow Ingot        : " .. shadowBeforeCnt)
print("#Bronze Ingot        : " .. bronzeBeforeCnt)
print("#Gold Ingot          : " .. goldBeforeCnt)
print("#Agapite Ingot       : " .. agapiteBeforeCnt)
print("#Verite Ingot        : " .. veriteBeforeCnt)
print("#Valorite Ingot      : " .. valoriteBeforeCnt)

     
-- Small Forge.                   
forgeType = 4017

forgeID = FindTypeGround(forgeType, 2)
if forID ~= nil then
  print("Found a nearby forge with ID: " .. forgeID)
end

-- Open Ingot Container
UO.LObjectID = ingotContainerID   
UO.Macro(17, 0)
wait(1000)
-- Open Ore Container
UO.LObjectID = oreContainerID   
UO.Macro(17, 0)
wait(1000)
       
print("Equipping +Skill mining gloves.. " .. miningGlovesID)          
GetGloves(oreContainerID)   
--Iron
while MoveTypeWithColor(bigOreType, oreContainerID, UO.BackpackID, 20, 0x0, 0, 0) do
  wait(715)
  SmeltOre(forgeID)
  if UO.Weight > 200 then      
    DepositIngotsToIngotContainer(ingotContainerID, 0x0, 0, 0)
  end
end
DepositIngotsToIngotContainer(ingotContainerID, 0x0, 0, 0)

--Dull Copper
while MoveTypeWithColor(bigOreType, oreContainerID, UO.BackpackID, 2, 0x415, 20, 120) do
  wait(715)
  SmeltOre(forgeID)
  wait(715)
  if UO.Weight > 200 then      
    DepositIngotsToIngotContainer(ingotContainerID, 0x415, 0, 20)
  end
end
DepositIngotsToIngotContainer(ingotContainerID, 0x415, 0, 20)
--Shadow
while MoveTypeWithColor(bigOreType, oreContainerID, UO.BackpackID, 2, 0x455, 0, 40) do
  wait(715)
  SmeltOre(forgeID)
  wait(715)
  if UO.Weight > 200 then      
    DepositIngotsToIngotContainer(ingotContainerID, 0x455, 0, 40)
  end
end
DepositIngotsToIngotContainer(ingotContainerID, 0x455, 0, 40)

--Bronze
while MoveTypeWithColor(bigOreType, oreContainerID, UO.BackpackID, 2, 0x6d8, 0, 60) do
  wait(715)
  SmeltOre(forgeID)
  wait(715)
  if UO.Weight > 200 then      
    DepositIngotsToIngotContainer(ingotContainerID, 0x6d8, 0, 60)
  end
end
DepositIngotsToIngotContainer(ingotContainerID, 0x6d8, 0, 60)

--Copper
while MoveTypeWithColor(bigOreType, oreContainerID, UO.BackpackID, 2, 0x45f, 0, 80) do
  wait(715)   
  SmeltOre(forgeID)
  wait(715)
  if UO.Weight > 200 then      
    DepositIngotsToIngotContainer(ingotContainerID, 0x45f, 20, 0)
  end
end
DepositIngotsToIngotContainer(ingotContainerID, 0x45f, 20, 0)

--Valorite
while MoveTypeWithColor(bigOreType, oreContainerID, UO.BackpackID, 1, 0x544, 0, 100) do
  wait(715)
  SmeltOre(forgeID)
  wait(715)
  if UO.Weight > 200 then      
    DepositIngotsToIngotContainer(ingotContainerID, 0x544, 20, 20)
  end
end
DepositIngotsToIngotContainer(ingotContainerID, 0x544, 20, 20)

--Verite
while MoveTypeWithColor(bigOreType, oreContainerID, UO.BackpackID, 2, 0x7d2, 100, 0) do
  wait(715)
  SmeltOre(forgeID)
  wait(715)
  if UO.Weight > 200 then      
    DepositIngotsToIngotContainer(ingotContainerID, 0x7d2, 20, 40)
  end
end
DepositIngotsToIngotContainer(ingotContainerID, 0x7d2, 20, 40)

--Agapite
while MoveTypeWithColor(bigOreType, oreContainerID, UO.BackpackID, 2, 0x97e, 100, 40) do
  wait(715)
  SmeltOre(forgeID)
  wait(715)
  if UO.Weight > 200 then      
    DepositIngotsToIngotContainer(ingotContainerID, 0x97e, 20, 60)
  end
end
DepositIngotsToIngotContainer(ingotContainerID, 0x97e, 20, 60)

--Gold
while MoveTypeWithColor(bigOreType, oreContainerID, UO.BackpackID, 2, 0x6b7, 100, 100) do
  wait(715)
  SmeltOre(forgeID)
  wait(715)
  if UO.Weight > 200 then      
    DepositIngotsToIngotContainer(ingotContainerID, 0x6b7, 40, 0)
  end
end
DepositIngotsToIngotContainer(ingotContainerID, 0x6b7, 40, 0)

print("Puting gloves away in crate " .. oreContainerID)
wait(1500) 
DepositGloves(oreContainerID)

print("")
print("")
print("Differences..")  
print("Iron Ingot        : + (" .. ItemTypeCountWithColor(ingotType, ingotContainerID, ironCol) - ironBeforeCnt .. ")") 
print("Dull Copper Ingot : + (" .. ItemTypeCountWithColor(ingotType, ingotContainerID, dullCopperCol) - dullCopperBeforeCnt .. ")")
print("Copper Ingot      : + (" .. ItemTypeCountWithColor(ingotType, ingotContainerID, copperCol) - copperBeforeCnt .. ")")     
print("Shadow Ingot      : + (" .. ItemTypeCountWithColor(ingotType, ingotContainerID, shadowCol) - shadowBeforeCnt .. ")")
print("Bronze Ingot      : + (" .. ItemTypeCountWithColor(ingotType, ingotContainerID, bronzeCol) - bronzeBeforeCnt .. ")")
print("Gold Ingot        : + (" .. ItemTypeCountWithColor(ingotType, ingotContainerID, goldCol) - goldBeforeCnt .. ")")
print("Agapite Ingot     : + (" .. ItemTypeCountWithColor(ingotType, ingotContainerID, agapiteCol) - agapiteBeforeCnt .. ")")
print("Verite Ingot      : + (" .. ItemTypeCountWithColor(ingotType, ingotContainerID, veriteCol) - veriteBeforeCnt .. ")")
print("Valorite Ingot    : + (" .. ItemTypeCountWithColor(ingotType, ingotContainerID, valoriteCol) - valoriteBeforeCnt .. ")")
print("")
print("")
--Get new ingot balances
print("New ingot balance..")  
print("Iron Ingot        : " .. ItemTypeCountWithColor(ingotType, ingotContainerID, ironCol)) 
print("Dull Copper Ingot : " .. ItemTypeCountWithColor(ingotType, ingotContainerID, dullCopperCol))
print("Copper Ingot      : " .. ItemTypeCountWithColor(ingotType, ingotContainerID, copperCol))     
print("Shadow Ingot      : " .. ItemTypeCountWithColor(ingotType, ingotContainerID, shadowCol))
print("Bronze Ingot      : " .. ItemTypeCountWithColor(ingotType, ingotContainerID, bronzeCol))
print("Gold Ingot        : " .. ItemTypeCountWithColor(ingotType, ingotContainerID, goldCol))
print("Agapite Ingot     : " .. ItemTypeCountWithColor(ingotType, ingotContainerID, agapiteCol))
print("Verite Ingot      : " .. ItemTypeCountWithColor(ingotType, ingotContainerID, veriteCol))
print("Valorite Ingot    : " .. ItemTypeCountWithColor(ingotType, ingotContainerID, valoriteCol))

