SetTitleMatchMode, 2 ; Set title match mode to find partial matches
#NoEnv
; #InstallKeybdHook
#UseHook
#Persistent

#Space::Send, {PrintScreen}
; ^Space::Send, +{PrintScreen}

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

#IfWinActive, ahk_class MetaQuotes::MetaTrader::4.00
; Begin:: Vô hiệu hoá phím backspace -> Khắc phục lỗi xung đột với Unikey
	BackSpace::
	return
; End
	+Q::Send, P ;Phìm tắt này hoạt động với Timmy maker
	^Right::
		WinActivate, ahk_exe Forex Simulator.exe
	return

	
	$]::
		WinActivate, ahk_exe Forex Simulator.exe
	return
	$[::
		WinActivate, ahk_exe Forex Simulator.exe
	return
	$Tab::
		WinActivate, ahk_exe Forex Simulator.exe
	return
#IfWinActive

#IfWinActive, ahk_exe Forex Simulator.exe
	Right::^Right
	Left::^Left
	$]::^Right
	$[::^Left
	u::
		WinActivate, ahk_exe terminal.exe
		Send u
	return
	p::
		Loop, 8 ; Down to bottom <D1>
		{
			Send {Down}
		}
		sleep, 300
		Send ^{Right}
		sleep, 300
		Send {Up} ; Back to <H1>
		sleep, 300
		Loop, 7
		{
			sleep, 300
			Send ^{Right}
		}
		Loop, 8 ; Up to first TF <m1>
		{
			Send {Up}
		}
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