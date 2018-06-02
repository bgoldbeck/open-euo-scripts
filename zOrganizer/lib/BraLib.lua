dofile("FindItems.lua")
dofile("JournalV2.lua")

dofile("../../Scripts/wvanderzalm/std.lua")
do
  local a,b=getmouse()
  Window={X=a-UO.CursorX+UO.CliLeft ,Y=b-UO.CursorY+UO.CliTop}    
end
ClientXRes = UO.CliXRes/2
ClientYRes = UO.CliYRes/2  
 
function turntomouse(X,Y,Z)
  local RX=X - UO.CharPosX
  local RY=Y - UO.CharPosY
  local RZ=(Z-UO.CharPosZ)*4  
  local NX=(RX-RY)*22 --20--+22
  local NY=(RX+RY)*22 +22 --+22
  local Left=Window.X+ClientXRes-1
  local Top=Window.Y+ClientYRes-2
  return Left+NX,Top+NY-RZ
end
 
function IsStacking(Type)
  if Type==3821 or Type==3822 or Type==3823 then return false end
  return true
end      

function FixTypeToArt(Type,Stack)      
  if Type==3821 then
    if Stack>=2 and Stack<6 then
      return 3822
    elseif Stack>=6 then
      return 3823
    end          
    return 3821
  end
  return Type
end
 
function ClickItem(Id)  
  nCnt = UO.ScanItems(false)
  for i=0,nCnt-1 do
    nID,nType,nKind, nContID, nX, nY, nZ, nStack, nRep, nCol = UO.GetItem(i)
    if nID==Id then
      break
    end
    if i==nCnt-1 then return false end
  end
  nType=FixTypeToArt(nType,nStack)  
  GetStaticArt(nType,nCol)
  local f = openfile(getinstalldir().."art.bmp","rb")      
  if f then
    local data=f:read("*a")
    local width=Read(data,0x13,4)              
    local height=Read(data,0x17,4)            
    local size=Read(data,0x3,4)
    local ClickX,ClickY=0,0
    local isset=0
    local str=""
    f:seek("set",54)  
    data=f:read("*a")
    current=1
    while true do
      if current>=size-560 then print("No Pixels Found!") return false end
      for i=current,size,4 do
        if i>=size then print("No Pixels Found!") return false end
        B=string.byte(string.sub(data,i,i+1))  
        G=string.byte(string.sub(data,i+1,i+2))  
        R=string.byte(string.sub(data,i+2,i+3))
        A=string.byte(string.sub(data,i+3,i+4))  
        if R~=0 or G~=0 or B~=0 or A~=0 then
          local count=(i-1)/4
          X=math.mod(count,width)
          Y=height-math.floor(count/width)-1
          current=i+4
          break
        end
      end
     
      if nContID~=0 then    
        if nStack>1 and IsStacking(nType) then X=X+5 Y=Y+5 end
        ClickX,ClickY=nX+X,nY+Y
      else
        if nStack>1 and IsStacking(nType) then X=X+3 Y=Y end  
        ClickX,ClickY=turntomouse(nX,nY,nZ)  
        ClickY=ClickY-height+Y-22
        ClickX=ClickX-math.floor(width/2)+X
      end
      local a=UO.GetPix(ClickX,ClickY)  
      local nB=Bit.Shr(a,16)
      local nG=Bit.Shr(a-Bit.Shl(nB,16),8)
      local nR=a-Bit.Shl(nB,16)-Bit.Shl(nG,8)
      if ( nCol~=0 and math.abs(R-nR)<=17 and math.abs(G-nG)<=17 and math.abs(B-nB)<=17 )
      or ( nCol==0 and math.abs(R-nR)<=5 and math.abs(G-nG)<=5 and math.abs(B-nB)<=5 )then  
     --   str=str.."Canvas.SetPixel("..ClickX ..","..ClickY+22 ..","..(0   +   Bit.Shl(255,8))..")"--(nR   +   Bit.Shl(nG,8)   +   Bit.Shl(nB,16))..")"
        if isset>6 then break
        else isset=isset+1 end
      else        
     --   str=str.."Canvas.SetPixel("..ClickX ..","..ClickY+22 ..",255)"
        isset=0
      end
    --  if getatom("MREAtom") then else setatom("MREAtom",str.."setatom('MREAtom',false)") str="" end
    end  
  --  while getatom("MREAtom") do end setatom("MREAtom",str.."setatom('MREAtom',false)") str=""
    f:close()  
    local oX,oY=getmouse()                    
    UO.Click(ClickX,ClickY,false,false,false,true)
    --wait(100)
    UO.Click(ClickX,ClickY,true,true,true,true)  
    UO.Click(oX-Window.X,oY-Window.Y,false,false,false,true)
    return true
  end
end

function ClickItemWithAssistUO(id, assistUOKeyClickLastItem)
    UO.TargCurs = true
	while UO.TargCurs == false do
	    wait(100)
	end
	UO.LTargetID = id
	UO.LTargetKind = 1
	UO.Macro(22, 0)
	UO.Key(assistUOKeyClickLastItem)
end

function GetIDOfItemType(itemType, source)	
    local id = nil
	t = ScanItems(true,{ Type=itemType, ContID=source})
	for i=1, #t do
		id = t[i].ID
	end	
	return id
end

function GetCountOfItemType(itemType, source)
	local count = 0
	t = ScanItems(true,{ Type=itemType, ContID=source})
	for i=1, #t do
		count = count + t[i].Stack
	end	
	return count
end

function SetTarget(msg)
	UO.TargCurs = false
	UO.TargCurs = true
	UO.SysMessage(msg, 75)
	while UO.TargCurs == true do
		wait(1)          
	end
	return UO.LTargetID
end

function FindItemIDByType(tType, cont)
    local id = nil
	local itemList = ScanItems(false)
	local t = FindItems(itemList,{Type=tType, ContID=cont})
	for i = 1, #t do
	   id = t[i].ID
	   break
	end
	return id
end

function TargetMobile(id)		
	for i = 1, 100 do
		wait(100)
		if UO.TargCurs == true then
			break
		end
	end
	UO.LTargetID = id
	UO.LTargetKind = 1 
	UO.Macro(22, 0)
end

function UseObjectByType(tType, source)
	local itemList = ScanItems(false)
	local t = FindItems(itemList,{Type=tType, ContID=source})
	if #t == 0 then
	    return false
	end
	for i = 1, #t do
		UO.LObectID = t[i].ID
		wait(1)
		UO.Macro(17, 0)
		break
	end
	return true
end

function UseObjectByID(id, source)
	local itemList = ScanItems(false)
	local t = FindItems(itemList,{ID=id, ContID=source})
	if #t == 0 then
		return false
	end
	for i = 1, #t do
		UO.LObjectID = t[i].ID
		wait(1)
		UO.Macro(17, 0)
		break
	end
	return true
end

function MoveObjectByID(id, source, dest, x, y)	
    local itemList = ScanItems(false)
	local t = FindItems(itemList,{ID=id, ContID=source})
	if #t == 0 then
	    return false
	end
	for i = 1, #t do
		UO.Drag(t[i].ID, t[i].Stack)
		wait(1)
		if x == nil or y == nil then
			UO.DropC(dest)
		else
			UO.DropC(dest, x, y)
		end
		break
	end
	return true
end

function MoveStackByType(tType, source, dest)
	local itemList = ScanItems(false)
	local t = FindItems(itemList,{Type=tType, ContID=source})
	if #t == 0 then
	    return
	end
	for i = 1, #t do
		local idOfTypeInDest = FindItemID(tType, dest) 
		if  idOfTypeInDest ~= 0 then
			UO.Drag(t[i].ID, t[i].Stack)
			wait(1)
			UO.DropC(idOfTypeInDest)
		else
			UO.Drag(t[i].ID, t[i].Stack)
			wait(1)
			UO.DropC(dest)
		end
		break
	end
	return true
end

function TargetSelf()
	if TargCurs == true then
		UO.Macro(23, 0)
		return true
	end
	return false
end

function WorldSaveCheck(jrnl)
    local jres = jrnl:find("world is saving")
    if jres ~= nil then    
        UO.ExMsg(UO.CharID, 0, 55, "World Saving..." )
        jrnl:clear()
        while jres == nil do
            jres = jrnl:find("save complete.")
            wait(1)
        end     
        print("World save complete.")

    end
end