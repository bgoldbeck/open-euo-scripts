
--Leave alone! (unless you know what to do.)
dofile("../lib/RLib.lua")   
                 
timer = Timer:New()
timer:Set(0)

for i = 1, 1000 do
  if timer:Dif() > 4000 then
    Print("Waited 4 seconds")
  end
  Pause(250)

end