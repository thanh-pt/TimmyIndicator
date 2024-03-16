SetTitleMatchMode, 2 ; Set title match mode to find partial matches
#NoEnv
; #InstallKeybdHook
#UseHook
#Persistent

#Space::Send, {PrintScreen}
; ^Space::Send, +{PrintScreen}

^+n::
	Run, Chrome.exe "https://www.youtube.com/watch?v=2y4r5_jPp8A"
	WinClose, ahk_exe msedge.exe
return

;------------------------------------------------------------ MT 4 Hotkey --------------------------------------------------------------------------------
#IfWinActive, ahk_exe terminal.exe
	XButton1::End
	^XButton1::
		Send, J ;Chart Force
		sleep, 100
		Send, H ;Chart Free
	return

	XButton2::
		Send, {Esc}
		Send, H ;Chart Free
	return

	^WheelUp::Send, {+}
	^WheelDown::Send, {-}
	+WheelUp::Send, {,}
	+WheelDown::Send, {.}

	^MButton::
		Send, J ;Chart Force
		Send, H ;Chart Free
	return
#IfWinActive

; Vô hiệu hoá phím backspace -> Khắc phục lỗi xung đột với Unikey
#IfWinActive, ahk_class MetaQuotes::MetaTrader::4.00
	BackSpace::
	return
	+Q::Send, P
	^Right::
		WinActivate, ahk_exe Forex Simulator.exe
	return
	$]::
		WinActivate, ahk_exe Forex Simulator.exe
	return
	$[::
		WinActivate, ahk_exe Forex Simulator.exe
	return
	$/::
		WinActivate, ahk_exe Forex Simulator.exe
	return
#IfWinActive

#IfWinActive, ahk_exe Forex Simulator.exe
	Right::^Right
	Left::^Left
	$]::^Right
	$[::^Left
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