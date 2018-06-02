dofile("lib/RLib.lua")


local addkey = ("F7")


local railname = ("Moonglow RailJacker")
      
local railnote = ("Moonglow Rail: Please start the script near moonglow north gate.")

local f, e = openfile(railname .. ".lua", 'w')
f:write("print(\"" .. railnote .. "\")\n")
f:close()


while not Dead(UO.CharID) do
	if getkey(addkey) then
                HeadMsg("Adding rail " .. UO.CharPosX .. "," .. UO.CharPosY, 65, UO.CharID) 
                local f, e = openfile(railname .. ".lua", 'a')
		f:write("rails:Push(\"" .. UO.CharPosX .. "," .. UO.CharPosY .. "\")\n")     
                f:close()
	end
        Pause(1)
end