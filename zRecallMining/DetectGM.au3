Global $soundFile =  "C:\Windows\Media\chord.wav"

While 1
   $alarm = IniRead(@SCRIPTDIR & "/lib/gm.ini", "gm", "sound", 0)
   If $alarm = 1 Then
	  For $i=1 to 10
		 _PlaySound($soundFile)
		 Sleep(250)
	  Next
	  IniWrite(@SCRIPTDIR & "/lib/gm.ini", "gm", "sound", 0)
   EndIf
   Sleep(100)

WEnd

Func _PlaySound($file)
   Beep(80, 200)
   Beep(100, 200)
   SoundPlay($soundFile)
EndFunc