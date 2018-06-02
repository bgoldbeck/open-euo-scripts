--[[
;-----------------------------------------------
; BWSmelt
; @author BadWolf63
; @version 1.0
; @client-compat 7.0.1.1
; @shard-compat OSI / FS: OSI
; @revised 2/17/2011
; @released 2/18/2011
; @Description: Smelt Ore with firebeetle with Options to smelt
;       one by one, drop iron ore on the ground and Organize
;       the backpack.
;       The Organizer can be called also for any container.
;       ******** NEEDS FLUENTUO *******
;
; BWSmelt(FirebeetleID,Speedsmelt,Cleansmelt,DropIronOre[,Ingots])
; speedsmelt: Slow = Split and Smelt all colored ores 1 by 1
;             Medium = Split and Smelt gold, agapite, verite, valorite ores 1 by 1
;             Fast = Doesn't Split
; cleansmelt: True or False. If true organizes ingots, gems and stones
; DropIronOre:True or False. If true drops on the grond Iron Ores before to smelt
; Ingots:     Minimum number of iron ingots for dropping iron ore
;-----------------------------------------------
; BWOrganize(ContainerID) Organizes ingots, gems and stones
-- ]]
dofile(getinstalldir().."scripts/lib/FluentUO/FluentUO.lua")

BWSmelt = function(FI,SS,CS,DropIronOre,ingots)
   ingots = ingots or 10
   local movx = 50
   local movy = 115
   local drgamt = 0
   if DropIronOre == true then
      DropIron(ingots)
   end
   if UO.ContID ~= UO.BackpackID then
      UO.Macro(8,7)
      waitforvars("UO.ContsizeX == 230 and UO.ContsizeY == 204 and UO.Contname == 'container gump'",1)
   end
   local backposx = UO.ContPosX
   local backposy = UO.ContPosY
   repeat --Check the firebeetle
      wait(500)
      local beet = Ground().WithID(FI).InRange(2).Items
   until (#beet > 0)
   local Backpackore = Backpack().WithType("DWJ_EWJ_GWJ_TVJ")
   while(1 < 2) do
      local ore = Backpackore.Update().Items
      local tt = 0
      for zz = 1, #ore do
         if not (ore[zz].Type == FluentUO.Utils.ToOpenEUO("TVJ") and ore[zz].Stack < 2) then
            if ore[zz].Col ~= 0 and ((SS=="Medium" and string.find("2213_2425_2207_2219",ore[zz].Col)) or (SS=="Slow")) and ore[zz].Type ~= FluentUO.Utils.ToOpenEUO("TVJ") and ore[zz].Stack > 1 then
               drgamt = ore[zz].Stack - 1 
               moveitem(ore[zz].ID, UO.BackpackID,drgamt,movx,movy)
            end
            UO.LObjectID = ore[zz].ID
            UO.LTargetKind = 1
            UO.LTargetID = FI
            UO.Macro(17, 0)
            wait(100)
            UO.Macro(22,0)
            wait(1000)
            tt = zz
            break
         end
      end
      if tt == 0 then 
         break
      end
   end
   local found = Ground().InRange(2).WithType("ENK").Items
   if #found > 0 then
      for xx = 1, #found do
          moveitem(found[xx].ID,UO.BackpackID, found[xx].Stack)
      end
   end
   if CS == true then
      BWOrganize(UO.BackpackID)
   end
end
--[[
;*************************************************************
;----
;* @name s7DropG
;* @author snicker7
;* @ver ??
;* @purpose To Drop Items to the Ground
;* @params  %1 Item to Drop
;* @returns none
;* @Ported under OpenEUO by BadWolf63
;----
-- ]]
function s7DropG(id)
   local bsuccess = UO.TileInit()
   for dXT = -1, 1 do
       for dYT = -1, 1 do
           if dXT ~= 0 and dYT ~= 0 then
              local dX = UO.CharPosX + dXT
              local dY = UO.CharPosY + dYT
              local dTi = false
              local cnt = UO.TileCnt(dX,dY,UO.CursKind)
              for dTc = 1, cnt do
                  local nType,nZ,sName,nFlags = UO.TileGet(dX,dY,dTc,UO.CursKind)
                  if string.find(nFlags,"impassable") then
                     dTi = true
                  end
              end
              if dTi == false then
                 UO.Drag(id,65535)
                 UO.DropG(dX,dY)
                 UO.DropC(UO.BackpackID)
                 wait(1000)
                 local found = Backpack().WithID(id).Items
                 if #found > 0 then
                    return true
                 else
                    return false
                 end
              end
           end
       end
   end
end
--;******************************
--;****** FindItemOnGround ******
--;******************************
local FindItemOnGround = function(typ,col)
   local found = Ground().InRange(2).WithType(typ).WithCol(col).Items
   if #found > 0 then 
      return found[1].ID
   else
      return false 
   end 
end
--;****************************************
DropIron = function(miningots)
local tmpiron = 0
local ironingots = Backpack().WithType("ENK").WithCol(0).Items
if #ironingots > 0 then
   for xx = 1,#ironingots do
       if ironingots[xx].Col == 0 then
          tmpiron = tmpiron + ironingots[xx].Stack
       end
   end
end
if tmpiron >= miningots then
  local found = Backpack().WithType("DWJ").WithCol(0).Items 
  if #found > 0 then
     for xx = 1, #found do
         local todrop = found[xx].ID
         local stackdrop = found[xx].Stack
         local result = FindItemOnGround("DWJ", 0)
         if result == false then
            s7DropG(todrop)
         else
            moveitem(todrop,result,stackdrop)
            break
         end
     end
  end
end
end

--;*************************************************
---;-----------------------------------------------
---; Moveitem(IDObjectToMove, IDContainerMoveTo, [StackToMove], [PosXinContainer, PosYinContainer])
---;-----------------------------------------------
function moveitem(...)
   local sArgs = {n=select('#',...),...}
   if #sArgs == 2 or #sArgs == 4 then
      UO.Drag(sArgs[1])
      end
   if #sArgs == 3 or #sArgs == 5 then
      UO.Drag(sArgs[1],sArgs[3])
   end
   wait(100)
   if #sArgs == 2 or #sArgs == 3 then
      UO.DropC(sArgs[2])
   end
   if #sArgs == 4 then
      UO.DropC(sArgs[2],sArgs[3],sArgs[4])
   end   
   if #sArgs == 5 then
      UO.DropC(sArgs[2],sArgs[4],sArgs[5])
   end
   wait(1000)
end
---;-----------------------------------------------
waitforvars = function(sArgs, secs)
   secs = secs or 1
   local x = "while(res==false and getticks()<endtimer) do if "..string.gsub(sArgs, "'", string.char(34)).. " then res=true end wait(500) end"
   local endtimer = getticks() + ( secs * 1000 )
   local res = false
   assert(loadstring(x))()
   wait(1000)
   return res 
end
---;-----------------------------------------------
--;-----------------------------
--;**** Organize ingots and gems in container
--;**** BWOrganize(CONTAINERID)
--; NEEDS FLUENTUO
--;-----------------------------

BWOrganize = function(contID)

local sec = contID
local foundiron = false
local tmovx = nil
local tingoty = nil
local smovx = nil
local singoty = nil
local sgenstmp = nil
local pos = {
--Ingots
     [0]    = 0,  -- Iron
     [2419] = 10, -- Dull Copper
     [2406] = 20, -- Shadow
     [2413] = 30, -- Copper
     [2418] = 40, -- Bronze
     [2213] = 50, -- Gold
     [2425] = 60, -- Agapite
     [2207] = 70, -- Verite
     [2219] = 80, -- Valorite
-- Stones
     [12693] = 0,  -- TWS
     [12696] = 10, -- GXS
     [12695] = 20, -- VWS
     [12691] = 30, -- ZWS
     [12690] = 40, -- AXS
     [12692] = 50, -- UWS
     [3882]  = 60, -- GWF
     [22322] = 70,
-- Gems
     [3862] = 0,  -- EVF
     [3855] = 10, -- VUF
     [3856] = 20, -- GVF
     [3861] = 30, -- BVF
     [3859] = 40, -- HVF
     [3877] = 50, -- RVF
     [3864] = 60, -- OVF
     [3878] = 70, -- UVF
     [3857] = 80, -- FVF
-- Tinkers tool
     [7868] = 0, -- GTL
     [7864] = 0, -- KTL
     [7865] = 0, -- JTL
}
if UO.ContID ~= sec then
  if sec ~= UO.BackpackID then
     UO.LObjectID = sec
     wait(40)
     UO.Macro(17,0)
     wait(1000)
  else
      UO.Macro(8,7)
      waitforvars("UO.ContsizeX == 230 and UO.ContsizeY == 204 and UO.Contname == 'container gump'",1)
  end
end
local posxc = UO.ContPosX
local posyc = UO.ContPosY

if sec == UO.BackpackID then
    tmovx = 45
    tingoty = 66
    foundiron = true
else
   if smovx == nil then
      local result = World().InContainer(sec).WithType("ENK").Items
      if #result >= 1 then 
         for xx = 1, #result do
           if result[xx].Col == 0 then
              local ir = result[xx].ID
              foundiron = true
              moveitem(ir,sec,result[xx].Stack,1,1)
              local result2 = World().InContainer(sec).WithID(result[xx].ID).Items
              smovx = result2[1].X - posxc
              singoty = result2[1].Y - posyc
              break
           end
         end
      end
   end
   if foundiron == true then
      tmovx = smovx
      tingoty = singoty
   end
end
if foundiron == true then
   local tgemsy = tingoty + 40
   local tgemsy2 = tingoty + 20
   local result = World().InContainer(sec).WithType("ENK_BVI_TWS_GXS_VWS_ZWS_AXS_UWS_GWF_EVF_VUF_GVF_BVF_HVF_RVF_OVF_UVF_FVF_TVJ_GTL_KTL_JTL_MDHB").Items
   if #result >= 1 then
      for xx = 1,#result do
          local pkX = result[xx].X - posxc
          local pkY = result[xx].Y - posyc
          if result[xx].Type == FluentUO.Utils.ToOpenEUO("ENK") or result[xx].Type == FluentUO.Utils.ToOpenEUO("BVI") then
             local tmp_pos = pos[result[xx].Col] + tmovx
             if result[xx].Type == FluentUO.Utils.ToOpenEUO("ENK") then
                sgenstmp = tingoty
             else
                sgenstmp = 108
             end
             if pkX ~= tmp_pos or pkY ~= sgenstmp then
                moveitem(result[xx].ID,sec,result[xx].Stack,tmp_pos,sgenstmp)
             end
          else
             if string.find ("TWS_GXS_VWS_ZWS_AXS_UWS_GWF_MDHB", FluentUO.Utils.ToEUOX(result[xx].Type)) then
                sgenstmp = tgemsy
                tmp_pos = pos[result[xx].Type] + tmovx
                if pkX ~= tmp_pos or pkY ~= sgenstmp then
                   moveitem(result[xx].ID,sec,result[xx].Stack,tmp_pos,sgenstmp)
                end
             else
                if string.find("EVF_VUF_GVF_BVF_HVF_RVF_OVF_UVF_FVF", FluentUO.Utils.ToEUOX(result[xx].Type)) then
                   sgenstmp = tgemsy2
                   tmp_pos = pos[result[xx].Type] + tmovx
                   if pkX ~= tmp_pos or pkY ~= sgenstmp then
                      moveitem(result[xx].ID,sec,result[xx].Stack,tmp_pos,sgenstmp)
                   end
                else
                   if string.find("GTL_KTL_JTL", FluentUO.Utils.ToEUOX(result[xx].Type)) then
                      tmp_pos = 45
                      sgenstmp = 66
                      if pkX ~= tmp_pos or pkY ~= sgenstmp then
                         moveitem(result[xx].ID,sec,result[xx].Stack,tmp_pos,sgenstmp)
                      end
                   else
                      if FluentUO.Utils.ToEUOX(result[xx].Type) == "TVJ" then
                         tmp_pos = 45
                         sgenstmp = 115
                         if pkX ~= tmp_pos or pkY ~= sgenstmp then
                            moveitem(result[xx].ID,sec,result[xx].Stack,tmp_pos,sgenstmp)
                         end
                      end
                   end
                end
             end
          end
      end
   end
end
end
--;*************************************************
--Test:
--BWSmelt(FluentUO.Utils.ToOpenEUO("XXXXXX"),"Slow",true,false)
--BWOrganize(UO.BackpackID)