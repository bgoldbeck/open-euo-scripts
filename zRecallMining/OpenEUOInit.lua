------------------------------------
-- Script Name: OpenEUOInit.lua
-- Author: Kal In Ex
-- Version: 1.0
-- Client Tested with: 7.0.23.1 (Patch 65)
-- EUO version tested with: OpenEUO
-- Shard OSI / FS: OSI
-- Revision Date: May 29, 2012
-- Public Release: February 24, 2012
-- Purpose: Init for OpenEUOLua.dll
-- Copyright: 2012 Kal In Ex
------------------------------------
-- download and install lua for windows from http://www.lua.org/download.html
-- copy OpenEUOInit.lua to the clibs directory of lua's install directory (probably c:\program files\lua\5.1\)
-- copy OpenEUOLua.dll to the clibs directory of lua's install directory
-- copy uo.dll (it part of the OpenEUO download) to the clibs directory of lua's install directory
-- execute the following line in your script(s) to prepare the UO table.
--
-- require("OpenEUOLua")
--
-- NOTE: This file is auotmatically called by OpenEUOLua.dll

-- require("os") -- already included by OpenEUOLua.dll
require("io")

-----------------------------------------------------
-- "standard functions" included by OpenEUOLua.dll --
-----------------------------------------------------

--dostring
--getmouse
--getticks
--pause

--------------------------------------------------------
-- other "extra functions" included by OpenEUOLua.dll --
--------------------------------------------------------

--Windows.GetCurrentDirectory
--Windows.GetFullPathName
--Windows.GetLongPathName
--Windows.GetShortPathName
--Windows.GetLocalTime
--Windows.GetSystemTime
--Windows.SystemTimeToFileTime
--Windows.FileTimeToSystemTime
--Windows.GetAsyncKeyState

----------------------------------------------------------------
-- "standard functions" not going to be included at this time --
----------------------------------------------------------------

--cmpsetatom
--getatom
--listatoms
--setatom

--------------------------------
-- other "standard functions" --
--------------------------------

--Bit{}
--getbasedir
--getdate
--getinstalldir
--getkey
--gettime
--openfile
--stop

require("bit")
Bit = {
	And = bit.band,
	Not = bit.bnot,
	Or = bit.bor,
	Shl = bit.lshift,
	Shr = bit.rshift,
	Xor = bit.bxor}

getbasedir = function()
	return Windows.GetCurrentDirectory().."\\"
end

getdate = function()
	local Date = {Windows.GetLocalTime()}
	return Date[1],Date[2],Date[4],(Date[3]+6)%7
end

getinstalldir = function()
	local dir = getbasedir()
	local file = io.open(dir.."openeuo.exe","r+")
	if file ~= nil then
		file:close()
		return dir
	end
	dir = "..\\"
	local temp
	repeat
		local path = Windows.GetFullPathName(dir)
		if path == temp then
			break
		end
		file = io.open(path.."openeuo.exe","r+")
		if file ~= nil then
			file:close()
			return path
		end
		dir = dir.."..\\"
		temp = path
	until false
end

--[[
	key names that are against left edge of page are listed as possible keys
	for the getkey() command in the OpenEUO wiki at EasyUO.com. All the others
	are "extra" key codes copied from WinUser.h.
--]]

local getkeykeys = {
	LBUTTON = 0x01,
	RBUTTON = 0x02,
	CANCEL = 0x03,
	MBUTTON = 0x04,
BACK = 0x08,
TAB = 0x09,
	CLEAR = 0x0C,
	RETURN = 0x0D,
ENTER = 0x0D,
SHIFT = 0x10,
	CONTROL = 0x11,
CTRL = 0x11,
	MENU = 0x12,
ALT = 0x12,
PAUSE = 0x13,
	CAPITAL = 0x14,
CAPSLOCK = 0x14,
	ESCAPE = 0x1B,
ESC = 0x1B,
	CONVERT = 0x1C,
	NONCONVERT = 0x1D,
	ACCEPT = 0x1E,
	MODECHANGE = 0x1F,
SPACE = 0x20,
	PRIOR = 0x21,
PGUP = 0x21,
	NEXT = 0x22,
PGDN = 0x22,
END = 0x23,
HOME = 0x24,
LEFT = 0x25,
UP = 0x26,
RIGHT = 0x27,
DOWN = 0x28,
	SELECT = 0x29,
	PRINT = 0x2A,
	EXECUTE = 0x2B,
	SNAPSHOT = 0x2C,
PRNSCR = 0x2C,
INSERT = 0x2D,
DELETE = 0x2E,
	HELP = 0x2F,
	SLEEP = 0x5F,
	NUMPAD0 = 0x60,
	NUMPAD1 = 0x61,
	NUMPAD2 = 0x62,
	NUMPAD3 = 0x63,
	NUMPAD4 = 0x64,
	NUMPAD5 = 0x65,
	NUMPAD6 = 0x66,
	NUMPAD7 = 0x67,
	NUMPAD8 = 0x68,
	NUMPAD9 = 0x69,
	MULTIPLY = 0x6A,
	ADD = 0x6B,
	SEPARATOR = 0x6C,
	SUBTRACT = 0x6D,
	DECIMAL = 0x6E,
	DIVIDE = 0x6F,
F1 = 0x70,
F2 = 0x71,
F3 = 0x72,
F4 = 0x73,
F5 = 0x74,
F6 = 0x75,
F7 = 0x76,
F8 = 0x77,
F9 = 0x78,
F10 = 0x79,
F11 = 0x7A,
F12 = 0x7B,
	F13 = 0x7C,
	F14 = 0x7D,
	F15 = 0x7E,
	F16 = 0x7F,
	F17 = 0x80,
	F18 = 0x81,
	F19 = 0x82,
	F20 = 0x83,
	F21 = 0x84,
	F22 = 0x85,
	F23 = 0x86,
	F24 = 0x87,
NUMLOCK = 0x90,
	SCROLL = 0x91,
SCROLLLOCK = 0x91,
	LSHIFT = 0xA0,
	RSHIFT = 0xA1,
	LCONTROL = 0xA2,
	RCONTROL = 0xA3,
	LMENU = 0xA4,
	RMENU = 0xA5,
	}
getkey = function(key)
	key = string.upper(key)
	if string.len(key) == 1 then
		key = string.byte(key)
	else
		key = getkeykeys[key]
	end
	if Windows.GetAsyncKeyState(key) == 0 then
		return false
	end
	return true
end

gettime = function()
	local Time = {Windows.GetLocalTime()}
	return Time[5],Time[6],Time[7],Time[8]
end

openfile = io.open

stop = os.exit

--------------------------------------------------------------------------------
-- slightly modified UO metatable as it appears in uo.dll for client 7.0.23.1 --
--------------------------------------------------------------------------------

--[[
	local exec = UO.Cmd
	local function ge(...) return exec("Get",...) end
	local function se(...) return exec("Set",...) end
	local function ca(...) return exec("Call",...) end
	local function ty(...) return exec("Type",...) end
	local function he(...) return exec("Help",...) end
	local mt = {
		__index = function(t,k)
			if ty(k)==3 then
				return function(...) return ca(k,...) end
			end
			return ge(k)
		end,
		__newindex = function(t,k,v)
			se(k,v)
		end,
		__help = he,
		}
	setmetatable(UO,mt)
	return
--]]

----------------------------
-- a speedup by Kal In Ex --
----------------------------

local ge = UO.Get
local se = UO.Set
setmetatable(UO,{
	__index = function(t,k) return ge(k) end,
	__newindex = function(t,k,v) return se(k,v) end,
	__help = UO.Help})

local t = {
	"Click",
	"CliDrag",
	"ContTop",
	"Drag",
	"DropC",
	"DropG",
	"DropPD",
	"Equip",
	"ExMsg",
	"GetCont",
	"GetItem",
	"GetJournal",
	"GetPix",
	"GetShop",
	"GetSkill",
	"HideItem",
	"Key",
	"Macro",
	"Move",
	"Msg",
	"Pathfind",
	"Popup",
	"Property",
	"RenamePet",
	"ScanItems",
	"ScanJournal",
	"SetShop",
	"SkillLock",
	"StatBar",
	"StatLock",
	"SysMessage",
	"SysMsg",
	"TileCnt",
	"TileGet",
	"TileInit"}
local ca = UO.Call
for i=1,#t do
	rawset(UO,t[i],function(...) return ca(t[i],...) end)
end
return

--AR
--n
--BackpackID
--CR
--CharDir
--CharID
--CharName
--s
--CharPosX
--CharPosY
--CharPosZ
--CharStatus
--CharType
--CliCnt
--CliDrag
--CliLang
--CliLeft
--CliLogged
--b
--CliNr
--CliTitle
--CliTop
--CliVer
--CliXRes
--CliYRes
--nnbbbb
--ContID
--ContKind
--ContName
--ContPosX
--ContPosY
--ContSizeX
--ContSizeY
--ContTop
--ContType
--CursKind
--CursorX
--CursorY
--Dex
--nn
--nnn
--ER
--EnemyHits
--EnemyID
--*
--nnns
--ns
--FR
--Followers
--Gold
--Hits
--Int
--sbbb
--LHandID
--LLiftedID
--LLiftedKind
--LLiftedType
--LObjectID
--LObjectType
--LShard
--LSkill
--LSpell
--LTargetID
--LTargetKind
--LTargetTile
--LTargetX
--LTargetY
--LTargetZ
--Luck
--nns
--Mana
--MaxDmg
--MaxFol
--MaxHits
--MaxMana
--MaxStam
--MaxStats
--MaxWeight
--MinDmg
--nnnn
--NextCPosX
--NextCPosY
--PR
--RHandID
--Sex
--Shard
--sn
--Stamina
--Str
--TP
--TargCurs
--Weight
