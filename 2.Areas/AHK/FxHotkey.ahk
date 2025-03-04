SetTitleMatchMode, 2 ; Set title match mode to find partial matches
#NoEnv
#UseHook
#Persistent

SetWorkingDir, %A_ScriptDir%
Menu, Tray, Icon, FxHotkey.ico

#Space::Send, {PrintScreen}

;--- MT5 hotkey
#IfWinActive, ahk_exe terminal64.exe
	XButton1::End
	XButton2::Esc
	+WheelUp::Send, {,}
	+WheelDown::Send, {.}
	^XButton1::Send, {/}
	^WheelUp::^WheelDown
	^WheelDown::^WheelUp
#IfWinActive

;------------------------------------------------------------ MT 4 Hotkey --------------------------------------------------------------------------------
#If WinActive("ahk_class MetaQuotes::MetaTrader::4.00") or WinActive("ahk_class AfxFrameOrView140s")
; #IfWinActive, ahk_exe terminal.exe
	XButton1::End
	XButton2::Esc
	^WheelUp::Send, {+}
	^WheelDown::Send, {-}
	+WheelUp::Send, {,}
	+WheelDown::Send, {.}
	^XButton1::Send, {/}
;==== Timmy Maker Compatible
	; ^XButton1::
	; 	Send, J ;Chart Force
	; 	sleep, 100
	; 	Send, H ;Chart Free
	; return
	; XButton2::
	; 	Send, {Esc}
	; 	Send, H ;Chart Free
	; return
	; ^MButton::
	; 	Send, J ;Chart Force
	; 	Send, H ;Chart Free
	; return
	; +Q::Send, P

;==== Disable [Backspace] -> Khắc phục lỗi xung đột với Unikey
	BackSpace::
	return
	
;==== Soft4fx simulation
	F1::
		WinActivate, ahk_exe Forex Simulator.exe
		Send ^{Left}
	return
	F2::
		WinActivate, ahk_exe Forex Simulator.exe
		Send ^{Right}
	return
#IfWinActive

#IfWinActive, ahk_exe Forex Simulator.exe
	F1::^Left
	F2::^Right
	F3::
		WinActivate, ahk_exe terminal.exe
		Send 5
		WinActivate, ahk_exe Forex Simulator.exe
	return
#IfWinActive

;------------------------------------------------------------ Chrome Hotkey --------------------------------------------------------------------------------
#IfWinActive, WhoIsInControl  ; Only perform the following hotkey actions when the active window title contains "WhoIsInControl"
	MButton::Send !r
	XButton1::Send !+{Right}

	XButton2::
		Send {Esc}
		Send {Esc}
	return
#IfWinActive ; Reset the hotkey context back to all windows

#IfWinActive, ahk_exe chrome.exe
	^XButton2::
		SendInput, {Ctrl}{Home}
	return
#IfWinActive