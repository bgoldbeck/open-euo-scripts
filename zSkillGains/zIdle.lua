--Leave alone! (unless you know what to do.)
dofile("../lib/RLib.lua")   

evalTimer = Timer:New()
evalTimer:Set(500000)
        
while not Dead(self) do
        
  if evalTimer:Dif() > 120000 then
    UseSkill("Evaluating Intelligence")
    WaitForTarget(2500)
    Target(self)
    evalTimer:Clear()      
  end
end

