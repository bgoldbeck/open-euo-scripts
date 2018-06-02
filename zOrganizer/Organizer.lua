dofile("lib/BraLib.lua")                
jrnl = NewJournal() -- create a new journal object                 
 --========================================--
--===============CONTAINERS=================--
 --========================================--
 local nNewRef,nCnt= UO.ScanJournal(0)
 local sLine = UO.GetJournal(0)
 print(sLine)
 sLine = UO.GetJournal(1)
 print(sLine)     
 sLine = UO.GetJournal(2)
 print(sLine)            
 sLine = UO.GetJournal(3)
 print(sLine)
 stop()
 
--UNSORTED BIN
local unsortedContainerID = 0x40237931
--TRASH BARREL        
local trashContainerID    = 0x40cb5631  
--SELL BIN       
local sellContainerID    = 0x40f77d80
--LEATHER BINS
local leatherFortContainerID   = 0x4064ee01
local leatherInvulnContainerID = 0x40a2c048

--Open EVERY Container we use.    
UseObjectByID(unsortedContainerID)     
wait(700)       
 --========================================--
--================LEATHER===================--
 --========================================--
leatherTypes = {}
leatherTypes[#leatherTypes + 1] = 0x13cc --Leather Tunic 
leatherTypes[#leatherTypes + 1] = 0x13cb --Leather Leggings
leatherTypes[#leatherTypes + 1] = 0x13c7 --Leather Gorgets
leatherTypes[#leatherTypes + 1] = 0x1db9 --Leather Caps
leatherTypes[#leatherTypes + 1] = 0x13cd --Leather Sleeves
leatherTypes[#leatherTypes + 1] = 0x13c6 --Leather Gloves


--Loop through all leather types.
for i = 1, #leatherTypes do  

  local t = ScanItems(false,{ Type=leatherTypes[i], ContID=unsortedContainerID})
  --Keep looping this leather type.
  while #t > 0 do 
    for j = 1, #t do
      print("Found a " .. t[j].Name) 
      jrnl:Clear() 
      ClickItemWithAssistUO(t[j].ID, "DELETE")
      local name, info = UO.Property(t[i].ID)
      print("NAME: ".. name .. " INFO: " .. info)
      wait(2500)
      --We found some leather
      if jrnl:Find("leather") ~= nil then 
        print("HERE")
        --Find the property type.
        if jrnl:Find("Unidentified") then
          wait(700)
        --tunic
        elseif jrnl:Find("tunic", "invulnerable") then 
          print("is an invulnerable piece")
        elseif jrnl:Find("tunic", "fortification") then 
          print("is a fortification piece")
        --leggings  
        elseif jrnl:Find("leggings", "invulnerable") then 
          print("is an invulnerable piece")   
        elseif jrnl:Find("leggings", "fortification") then  
          print("is a fortification piece")
        --sleeves    
        elseif jrnl:Find("sleeves", "invulnerable") then
          print("is an invulnerable piece")    
        elseif jrnl:Find("sleeves", "fortification") then 
          print("is a fortification piece")
        --gloves  
        elseif jrnl:Find("gloves", "invulnerable") then 
          print("is an invulnerable piece")   
        elseif jrnl:Find("gloves", "fortification") then 
          print("is a fortification piece")
        --gorget   
        elseif jrnl:Find("gorget", "invulnerable") then
          print("is an invulnerable piece")    
        elseif jrnl:Find("gorget", "fortification") then
          print("is a fortification piece")
        --cap      
        elseif jrnl:Find("cap", "invulnerable") then 
          print("is an invulnerable piece")   
        elseif jrnl:Find("cap", "fortification") then 
          print("is a fortification piece")
        else
          --default (move to sell bin)
          print("moving to sell bin..") 
          MoveObjectByID(t[j].ID, unsortedContainerID, sellContainerID)
          wait(800)
        end --endif
      end --endif
    end --endfor
    t = ScanItems(false, { Type=leatherTypes[i], ContID=unsortedContainerID})
  end --endwhile
end --endfor

pushlist 'loot' 0x13bf //Chain Tunic
pushlist 'loot' 0x13be //Chain Leggings
pushlist 'loot' 0x13ee //Ring Sleeves
pushlist 'loot' 0x13eb //Ring Gloves
pushlist 'loot' 0x1413 //Plate Gorget
pushlist 'loot' 0x1411 //Plate Leggings
pushlist 'loot' 0x1410 //Plate Sleeves
pushlist 'loot' 0x1414 //Plate Gloves
pushlist 'loot' 0x1408 //Close Helmet
pushlist 'loot' 0x140e //Norse Helm
pushlist 'loot' 0x13db //Studded Tunic
pushlist 'loot' 0x13d5 //Studded Gloves
pushlist 'loot' 0x1412 //Plate Helm
pushlist 'loot' 0x140c //Bascinet

pushlist 'loot' 0x1405 //War Fork
pushlist 'loot' 0x1401 //Kryss
pushlist 'loot' 0x1403 //Short Spear
pushlist 'loot' 0xf62  //Long Spear

pushlist 'loot' 0x13ff     //Katana
pushlist 'loot' 0xe89      //Q-Staff
pushlist 'loot' 0x143d     //Hammer Pick
pushlist 'loot' 0xf61      //Longsword
pushlist 'loot' 0xf43      //Hatchet
pushlist 'loot' 0xf49      //Axe
pushlist 'loot' 0x13f8     //Gnarled Staff
pushlist 'loot' 0x143b     //Maul
pushlist 'loot' 0x1441     //Cutlass
pushlist 'loot' 0x1439     //War Hammer
pushlist 'loot' 0x13b2     //Bow
pushlist 'loot' 0x13fd     //Heavy X-Bow
pushlist 'loot' 0xf50      //X-Bow
pushlist 'loot' 0x1443     //2H Axe
pushlist 'loot' 0xf4b      //Double Axe
pushlist 'loot' 0x1407     //War Mace
pushlist 'loot' 0xf47      //Battle Axe
pushlist 'loot' 0x13fb  //Large Battle Axe
pushlist 'loot' 0xf4d   //Bardiche
pushlist 'loot' 0xe87   //Pitchfork
pushlist 'loot' 0xf45   //Executioner's Axe
pushlist 'loot' 0xf52   //Dagger
pushlist 'loot' 0xf5e   //Broadsword


pushlist 'misc' 0x9f1  //Meat
pushlist 'misc' 0xe21  //Bandages
pushlist 'misc' 0xf0e  //Empty Bottles
--//Regs
pushlist 'misc' 0xf85
pushlist 'misc' 0xf8d
pushlist 'misc' 0xf86
pushlist 'misc' 0xf8c
pushlist 'misc' 0xf7b
pushlist 'misc' 0xf84
pushlist 'misc' 0xf7a
pushlist 'misc' 0xf88


pushlist 'barding' 0xe9c //Drum
pushlist 'barding' 0xe9e //Tamb. Tassle
pushlist 'barding' 0xe9d //Tamb. 2
pushlist 'barding' 0xeb3 //Lute
pushlist 'barding' 0xeb2 //Lap Harp
pushlist 'barding' 0xeb1 //Standing Harp

pushlist 'scrolls' 0x1f2d // Reactive Armor
pushlist 'scrolls' 0x1f2e // Clumsy
pushlist 'scrolls' 0x1f2f // Create Food
pushlist 'scrolls' 0x1f30 // Feeblemind
pushlist 'scrolls' 0x1f31 // Heal
pushlist 'scrolls' 0x1f32 // Magic Arrow
pushlist 'scrolls' 0x1f33 // Night Sight
pushlist 'scrolls' 0x1f34 // Weaken
pushlist 'scrolls' 0x1f35 // Agility
pushlist 'scrolls' 0x1f36 // Cunning
pushlist 'scrolls' 0x1f37 // Cure
pushlist 'scrolls' 0x1f38 // Harm
pushlist 'scrolls' 0x1f39 // Magic Trap
pushlist 'scrolls' 0x1f3a // Magic Untrap
pushlist 'scrolls' 0x1f3b // Protection
pushlist 'scrolls' 0x1f3c // Strength
pushlist 'scrolls' 0x1f3d // Bless
pushlist 'scrolls' 0x1f3e // Fireball
pushlist 'scrolls' 0x1f3f // Magic Lock
pushlist 'scrolls' 0x1f40 // Poison
pushlist 'scrolls' 0x1f41 // Telekinesis
pushlist 'scrolls' 0x1f42 // Teleport
pushlist 'scrolls' 0x1f43 // Unlock
pushlist 'scrolls' 0x1f44 // Wall of Stone
pushlist 'scrolls' 0x1f45 // Arch Cure
pushlist 'scrolls' 0x1f46 // Arch Protection
pushlist 'scrolls' 0x1f47 // Curse
pushlist 'scrolls' 0x1f48 // Fire Field
pushlist 'scrolls' 0x1f49 // Greater Heal
pushlist 'scrolls' 0x1f4a // Lightning
pushlist 'scrolls' 0x1f4b // Mana Drain
pushlist 'scrolls' 0x1f4c // Recall
pushlist 'scrolls' 0x1f4d // Blade Spirit
pushlist 'scrolls' 0x1f4e // Dispel Field
pushlist 'scrolls' 0x1f4f // Incognito
pushlist 'scrolls' 0x1f50 // Magic Reflection
pushlist 'scrolls' 0x1f51 // Mind Blast
pushlist 'scrolls' 0x1f52 // Paralyze
pushlist 'scrolls' 0x1f53 // Poison Field
pushlist 'scrolls' 0x1f54 // Summon Creature
pushlist 'scrolls' 0x1f55 // Dispel
pushlist 'scrolls' 0x1f56 // Energy Bolt
pushlist 'scrolls' 0x1f57 // Explosion
pushlist 'scrolls' 0x1f58 // Invisibility
pushlist 'scrolls' 0x1f59 // Mark
pushlist 'scrolls' 0x1f5a // Mass Curse
pushlist 'scrolls' 0x1f5b // Paralyze Field
pushlist 'scrolls' 0x1f5c // Reveal
pushlist 'scrolls' 0x1f5d // Chain Lightning
pushlist 'scrolls' 0x1f5e // Energy Field
pushlist 'scrolls' 0x1f5f // Flamestrike
pushlist 'scrolls' 0x1f60 // Gate Travel
pushlist 'scrolls' 0x1f61 // Mana Vampire
pushlist 'scrolls' 0x1f62 // Mass Dispel
pushlist 'scrolls' 0x1f63 // Meteor Swarm
pushlist 'scrolls' 0x1f64 // Polymorph
pushlist 'scrolls' 0x1f65 // Earthquake
pushlist 'scrolls' 0x1f66 // Energy Vortex
pushlist 'scrolls' 0x1f67 // Ressurrection
pushlist 'scrolls' 0x1f68 // Summon Air Elemental
pushlist 'scrolls' 0x1f69 // Summon Daemon
pushlist 'scrolls' 0x1f6a // Summon Earth Elemental
pushlist 'scrolls' 0x1f6b // Summon Fire Elemental
pushlist 'scrolls' 0x1f6c // Summon Water Elemental


pushlist 'stuff' 0xeed  //Gold
pushlist 'stuff' 0x1bf2 //Ingots

pushlist 'tailoring' 0x1081  //Plain Leather

pushlist 'loot' 0x1b7a  //Wooden Shields
pushlist 'loot' 0x1c02  //Female Studded Armor
pushlist 'loot' 0x1c04  //Female Plate Armor
pushlist 'loot' 0x1b73  //Buckler
pushlist 'loot' 0x1b76  //Heater Shield
pushlist 'loot' 0x1c06  //Female Plate
pushlist 'loot' 0x1b79  //Tear Kite Shield
pushlist 'loot' 0x1bfb  //X-Bow Bolts
pushlist 'loot' 0x1b72  //Bronze Shield
pushlist 'loot' 0x1b74  //Metal Kite Shield


pushlist 'trash' 0x1452  //Bone legs


pushlist 'containers' 
pushlist 'containers' 
pushlist 'containers' 
pushlist 'containers' 0xe74
pushlist 'containers' 0xe78
pushlist 'containers' 0xe7d
pushlist 'containers' 0xe77