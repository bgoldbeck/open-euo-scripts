dofile("KalOCR.lua")
name, price, x, y = KAL.GetShopInfo()  

print(name)
print(price)
print(x)
print(y)
UO.Click(x,y, true, true, true, false)