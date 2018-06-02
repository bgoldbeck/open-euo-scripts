--Leave alone! (unless you know what to do.)
dofile("../lib/RLib.lua")   

evalTimer = Timer:New()
evalTimer:Set(500000)
                       

while not Dead(self) do

  while Mana() < 15 do
    UseSkill("Meditation")
    Pause(2500)
  end
  
  Cast("Reactive Armor")
  
  Pause(500)
  if evalTimer:Dif() > 60000 then

    UseSkill("Evaluating Intelligence")
    Print(GetSkill("Evaluating Intelligence"))
    WaitForTarget(2500)
    Target(self)
    evalTimer:Clear()      
  end
end
