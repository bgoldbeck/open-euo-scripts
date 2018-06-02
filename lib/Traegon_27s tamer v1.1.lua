--========================================================================
-- Script Name: Traegon's Jhelom and Deceit Tamer.
-- Author: Traegon, but original idea from watching another script. 
-- Version 1.1
-- OEUO Version Tested with .91.0010
-- Shard OSI / FS: OSI 
-- Public Release: 11/14/10
-- Purpose: Tames stuff, duh.
-- Usage: Just depends on what you want to tame, I guess...
--        Stand in the Middle of Jhelom's Pen with the Bulls, hit play.     
--        OR..
--        Stand in the cave west of Deceit and hit play.              
--========================================================================

dofile(getinstalldir().."/lib/FluentUO.lua")
dofile(getinstalldir().."/lib/tgnsubs.lua")
dofile(getinstalldir().."/lib/Journal.txt")

CheckClient()

function main()
  local result
  local tameables = {}
  local spots = {}
  local harts = {}
  local tamed = 0

  if UO.CharPosX >= 1112 and UO.CharPosX <= 1142 and UO.CharPosY >= 3568 and UO.CharPosY <= 3598 then
    tameables = {232,233}
    spots = {{1127,3581,0},{1119,3575,0},{1136,3574,0},
             {1137,3592,0},{1121,3589,0}}
  end
  
  if UO.CharPosY >= 300 and UO.CharPosY <= 350 and UO.CharPosX >= 4000 and UO.CharPosX <= 4090 then
    tameables = {213,221,34,64,65}
    spots = {{4017,340,0},{4028,338,0},{4035,329,0},
             {4036,316,0},{4022,314,0},{4017,307,0},
             {4022,314,0},{4036,316,0},{4044,314,0},
             {4055,313,0},{4057,321,0},{4063,329,0},
             {4071,337,0},{4080,346,0},{4087,339,0},
             {4080,346,0},{4071,337,0},{4063,329,0},
             {4057,321,0},{4055,313,0},{4044,314,0},                          
             {4036,316,0},{4035,329,0},{4028,338,0},
             {4017,340,0}}    
  end  
  -- tame polar bears and stuff around then near Deceit.
  if UO.CharPosX >= 4020 and UO.CharPosX <= 4120 and UO.CharPosY >= 430 and UO.CharPosY <= 490 then
    tameables = {213,221,34,64,65}
    spots = {{4029,434,3},{4037,436,3},{4046,438,3},
             {4048,449,3},{4039,459,3},{4051,447,3},
             {4060,439,3},{4068,439,3},{4074,449,3},
             {4078,459,0},{4073,470,0},{4063,480,0},
             {4054,489,0},{4063,480,0},{4073,470,0},
             {4078,459,0},{4074,449,3},{4079,438,5},
             {4087,436,5},{4098,436,4},{4109,436,5},
             {4117,442,5},{4109,436,5},{4098,436,4},
             {4087,436,5},{4079,438,5},{4068,439,3},
             {4060,439,3},{4052,439,3},{4042,435,3},
             {4031,432,3}}
  end

  if #spots == 0 then
    print("YOU NEED TO BE IN A SUPPORTED AREA!  HALTING.")
    stop()
  end
  
  local spot = 1
  
  while true do
    spotx,spoty,spotz = unpack(spots[spot])
    Pathfind(spotx,spoty,spotz)
                  
    harts = World().WithType(tameables).InRange(10).Where("item.Rep == 3").Items
    while #harts > 0 do
      tamed = 1
      hart = World().WithID(harts[1].ID).InRange(10).Where("item.Rep == 3").Items
      while #hart > 0 do 
        Pathfind(hart[1].X,hart[1].Y,hart[1].Z)
        UO.Macro(13,35)
        wait(1500)
        TargetLast(hart[1].ID,1,true,10000)
        result = scanjournal(hart[1].ID)
        if result == "seems to accept you as master" or result == "tame already" or result == "too many" or result == "no chance" then
          if result == "seems to accept you as master" or result == "tame already" then
            UO.RenamePet(hart[1].ID,"killme")
            wait(1000)
            UO.Macro(1,0,"killme release")
            wait(1000)
          end
          hart = World().WithID(hart[1].ID).InRange(10).Items
          while #hart > 0 do
            UO.Macro(15,29)
            TargetLast(hart[1].ID,1,false,10000)
            wait(1500)
            hart = World().WithID(hart[1].ID).InRange(10).Items
          end 
        else
          hart = World().WithID(hart[1].ID).InRange(10).Where("item.Rep == 3").Items
        end
      end          
      harts = World().WithType(tameables).InRange(10).Where("item.Rep == 3").Items
    end
    spot = spot + 1
    if spot > #spots then 
      spot = 1 
      if tamed == 0 then wait(30000) end
      tamed = 0
    end
  end
end

function scanjournal(id)
  local temp = {}
  local journalResult
  Journal.Diagnostics.JournalOutputEnabled = false 
  Journal.Mark() 
  local successCheckTimeout = 12000 + DateTime.RunningMilliseconds
  local timeoutOccurred = true 
  repeat    
    temp = World().WithID(id).InRange(10).Items
    if #temp > 0 then Pathfind(temp[1].X,temp[1].Y,temp[1].Z) end    
    journalResult = Journal.Search({"fail to tame","seems to accept you as master","tame already","too far away","too angry","no chance","too many"}, 1000)
    if journalResult ~= "ERR_Timeout" then timeoutOccurred = false end        
  until timeoutOccurred == false or DateTime.RunningMilliseconds > successCheckTimeout
  return journalResult
end

main()