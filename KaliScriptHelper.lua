--------------------------------------------------------- 
---------------------------------------------------------
-- Script Name: KaliScriptHelper.lua 
-- Author: Kali of LS 
-- Version: 2.0 
-- Client Tested with: 7.0.29.2 
-- EUO version tested with: OpenEUO 0.91.0029 
-- Shard OSI / FS: OSI 
-- Revision Date: January 2, 2013  
-- Public Release: April 4, 2012 
-- Purpose: User inteface to quarry UO item information
-- Dependencies: None 
-- http://www.easyuo.com/forum/viewtopic.php?t=48407
---------------------------------------------------------
---------------------------------------------------------
--Default Data log file.
local dLog = getinstalldir()..'/scripts/KSHdatalog.txt'

--Variable Initialization
local Note = ""                                                                           --Modify and each line in a save file will have this precluding it
--Don't change anything below here unless you know what you are doing--
local nID,nType,nKind,nContID,nX,nY,nZ,nStack,nRep,nCol = 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    --Init for Display
local Item = { ["ID"] = nID,                                                              --Hold Item Information
               ["Type"] = nType, 
               ["Kind"] = nKind, 
               ["ContID"] = nContID, 
               ["X"] = nX, 
               ["Y"] = nY, 
               ["Z"] = nZ, 
               ["Stack"] = nStack, 
               ["Rep"] = nRep, 
               ["Col"]= nCol
             }
local Label = {}                                                                           --Button Table
local Edit = {}                                                                            --EditBox Table             


local List = {}                                                                            --Table for saved targets
local Order = { "ID", "ContID", "Type", "Kind", "Col", "Rep", "X", "Y", "Z", "Stack" }     --used to index Item

--Functions---------------------------------------------------------------------------------

--Table To String---------------------------------------------------------------------------
-- Input: Table
-- Return: string
-- Recursively calls if value is a table
function TableToString(t)
   local s = '{\n'
   for k,v in pairs(t) do
      if type(k) == 'string' then s = s..'["'..k..'"] = '
      else s = s..'['..tostring(k)..'] = ' end
      if type(v) == 'table' then s = s..TableToString(v)..',\n'
      elseif type(v) == 'string' then s = s..'"'..v..'",\n'
      else s = s..tostring(v)..',\n' end 
   end
   return s..'}\n'
end

function HashIt(t,c)
   local sum = t*10000+c
   return sum
end

function LoadFile(fn)
   local f,e = openfile(fn,'r')
   if f then
      f:close()
      return dofile(fn)
   else
      return {}
   end
end

function SaveLog(fn,t)
   local f,e = openfile(fn,'w+')
   if f then
      f:write('return '..TableToString(t))
      f:close()
      return true
   end 
   return false
end

function Save(list) 
  local qForm = Obj.Create("TForm")
  qForm.Caption = "Save...?"
  qForm.Height = 120
  qForm.Width = 220
  qForm.FormStyle = 3
  qForm.Color = 0
  qForm.Font.Color = 255
  qForm.OnClose = function()
    Obj.Exit()
  end
  
  local qLabel = Obj.Create("TLabel")
  qLabel.Caption = "Save your file?"
  qLabel.Height = 25
  qLabel.Width = 100
  qLabel.Top = 15
  qLabel.Left = 30
  qLabel.Font.Color = 255
  qLabel.Font.Size = 12
  qLabel.Parent = qForm
  
  local yB = Obj.Create("TButton")
  yB.Caption = "Yes"
  yB.Left = 20
  yB.Width = 80
  yB.Top = 40
  yB.Height = 25
  
  local nB = Obj.Create("TButton")
  nB.Caption = "No"
  nB.Left = 110
  nB.Width = 80
  nB.Top = 40
  nB.Height = 25
  
  nB.OnClick = function()
   Obj.Exit()
  end
  
  yB.OnClick = function()
    
    local Saving = Obj.Create("TSaveDialog")
    Saving.FileName = "NewList.txt"
    Saving.Title = "Save..."
    Saving.Execute()
      
    local f,e = openfile(Saving.FileName, "w")    
    if f then
      for i = 1, #list do
        f:write(string.format(list[i]).."\n")
      end  
      f:close()
    else
      Print("Failed to Save")
    end
    
    Obj.Free(Saving)
    Obj.Exit()
  end    
  
  nB.Parent = qForm
  yB.Parent = qForm
  
  qForm.Show()
  Obj.Loop()
  
  Obj.Free(qForm)
  Obj.Free(qLabel)
  Obj.Free(nB)
  Obj.Free(yB)
  return
end

--MainMenu, waits user to choose to target something
--displays target information with chance to save

function MainMenu()
  local data = LoadFile(dLog)
 
  local sForm = Obj.Create("TForm")
  sForm.Height = 340
  sForm.Width = 320
  sForm.FormStyle = 3
  sForm.Color = 0
  sForm.Font.Color = 255
  sForm.OnClose = function()
    Obj.Exit()
  end
  
  local sLabel = Obj.Create("TLabel")
  sLabel.Caption = "Welcome to Kali's Script Helper"
  sLabel.Top = 30
  sLabel.Left = 20
  sLabel.Height = 25
  sLabel.Width = 260
  sLabel.Font.Style = 1
  sLabel.Font.Size = 12
  sLabel.Font.Color = 255
  sLabel.Parent = sForm
  
  local aLabel = Obj.Create("TLabel")
  aLabel.Caption = "Annotate:"
  aLabel.Height = 25
  aLabel.Width = 50
  aLabel.Left = 20
  aLabel.Top = 200
  aLabel.Parent = sForm
  
  local Annotate = Obj.Create("TEdit")
  Annotate.Text = string.format(#List+1)
  Annotate.Height = 25
  Annotate.Width = 200
  Annotate.Top = 198
  Annotate.Left = 70
  Annotate.Parent = sForm
    
  local bTarg = Obj.Create("TButton") 
  local bQuit = Obj.Create("TButton")
  
  bTarg.Caption = "Target"  
  bQuit.Caption = "Quit"
  
  bTarg.Height = 25
  bQuit.Height = 25
  
  bTarg.Width = 80                   
  bQuit.Width = 80
  
  bTarg.Top = 230
  bQuit.Top = 230
  
  bTarg.Left = 20        
  bQuit.Left = 200
   
  for k,v in pairs(Order) do
    if k < 3 then
      Label[k] = Obj.Create("TLabel")
      Label[k].Caption = v
      local a,b = math.modf((k-1)/2)
      Label[k].Top = 62 + a*30
      Label[k].Left = 20 + 120*b*2
      Label[k].Height = 25
      Label[k].Width = 50
      Label[k].Parent = sForm
    
      Edit[k] = Obj.Create("TEdit")
      Edit[k].Text = string.format(Item[v])
      Edit[k].Top = 58 + a*30
      Edit[k].Left = 60 + 120*b*2
      Edit[k].Height = 25
      Edit[k].Width = 70
      Edit[k].Parent = sForm
    else
      Label[k] = Obj.Create("TLabel")
      Label[k].Caption = v
      local a,b = math.modf((k-3)/4)
      Label[k].Top = 92 + 3*b*30
      Label[k].Left = 20 + 100*a
      Label[k].Height = 25
      Label[k].Width = 50
      Label[k].Parent = sForm
    
      Edit[k] = Obj.Create("TEdit")
      Edit[k].Text = string.format(Item[v])
      Edit[k].Top = 88 + 3*b*30
      Edit[k].Left = 60 + 100*a
      Edit[k].Height = 25
      Edit[k].Width = 50
      Edit[k].Parent = sForm
    end
  end
      
  bTarg.OnClick = function()
  
    nCnt = UO.ScanItems(false)
    UO.TargCurs = true
    while UO.TargCurs do
      wait(10)
    end
    
    for i = 0, nCnt-1 do 
      nID,nType,nKind,nContID,nX,nY,nZ,nStack,nRep,nCol = UO.GetItem(i)
      if nID == UO.LTargetID then
        Item = { ["ID"] = nID, ["Type"] = nType, ["Kind"] = nKind, ["ContID"] = nContID, ["X"] = nX, ["Y"] = nY, ["Z"] = nZ, ["Stack"] = nStack, ["Rep"] = nRep, ["Col"]= nCol, }
      end
    end
      
    for k,v in pairs(Order) do
      Edit[k].Text = string.format(Item[v])
    end
    
    local s = ''
    local sName,sInfo = UO.Property(UO.LTargetID)
    for w in sName:gmatch('[%w%p]+') do    
      if tonumber(w) ~= tonumber(Item["Stack"]) then
        s = s..w..' '
      end 
    end    
    Annotate.Text = s
    
    Note = s
    for k,v in pairs(Order) do
      Note = Note.." "..v.." "..Item[v].." "
    end   
        
    List[#List+1] = Note    
    if not data[ HashIt(Item['Type'],Item['Col']) ] then data[ HashIt(Item['Type'],Item['Col']) ] = Note end
    
    save = true
     
  end
  bQuit.OnClick = function()
    SaveLog(dLog,data)
    if save then
      Save(List)
    end
    Obj.Exit()
  end
      
  bTarg.Parent = sForm 
  bQuit.Parent = sForm
  
  sForm.Show()
  Obj.Loop()
  
  Obj.Free(bTarg)
  for i = 1, #Label do
    Obj.Free(Label[i])
    Obj.Free(Edit[i])
  end
  
  Obj.Free(Annotate)
  Obj.Free(aLabel)
  Obj.Free(bQuit)
  Obj.Free(sForm)
  
end

function ClientMenu()
  
  if UO.CliCnt > 1 then
    local timer = 0
  
    local sForm = Obj.Create("TForm")
    sForm.Caption = "Kali's Party Builder"
    sForm.Font.Color = 255
    sForm._ = {Height = 100+30*UO.CliCnt, Width = 160, Color = 0, FormStyle = 3}
    sForm.OnClose = function() Obj.Exit() return end
  
    local sLabel = Obj.Create("TLabel")
    sLabel.Caption = "Choose Master Client"
    sLabel._ = {Height = 25, Width = 100, Top = 20, Left = 23, Parent = sForm}
  
    local sButton = {}
    for i = 1, UO.CliCnt do
      UO.CliNr = i
      wait(100)
      UO.Macro(8,2)
      timer = getticks()
      while UO.ContName ~= "status gump" and UO.ContName ~= "MainMenu gump" do
        wait(100)
        if (getticks() - timer) > 1000 then
          UO.Macro(8,2)
        end
      end
      sButton[i] = Obj.Create("TButton")
      sButton[i].Caption = tostring(UO.CliNr.." - "..UO.CharName)
      sButton[i].Top = 30 + 30*i
      sButton[i]._ = {Height = 25, Width = 100, Left = 25, Parent = sForm}
      sButton[i].OnClick = function()
        UO.CliNr = i
        Obj.Exit()
      end
    end
    sForm.Show()
    Obj.Loop()
    sForm.Hide()
  
    for k,v in pairs(sButton) do
      Obj.Free(v)
    end
    Obj.Free(sLabel)
    Obj.Free(sForm)       
  end 
  return
end

ClientMenu()
MainMenu()