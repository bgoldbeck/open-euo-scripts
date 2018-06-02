             
desiredStr = 100
desiredInt = 100
desiredDex = 25

strDone = false
intDone = false
dexDone = false

while 1 do
  if desiredStr == UO.Str and strDone == false then
    UO.StatLock("str", 2)
    strDone = true
  end                    
  if desiredInt == UO.Int and intDone == false then
    UO.StatLock("int", 2)
    intDone = true
  end 
  if desiredDex == UO.Dex and dexDone == false then
    UO.StatLock("dex", 2)
    dexDone = true
  end 
  if strDone and intDone and dexDone then
    print("Perfect stats!")
    stop()
  end
end