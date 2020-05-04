
/*
	; AHK v1.1
	global Console := new CConsole
	Console.hotkey := "^+c"  ; to show the console
	Console.log("Hello", "world", "Mina", "konnichiha", "Bonjour tout le monde")
	Console.show()
	Console.log("Point", {x:100,y:200})
	;Hello world Mina konnichiha Bonjour tout le monde
	;Point {
	;	x: 100
	;	y: 200
	;}
*/


class CConsole {
    ahkPID  := ""
    ahkHWND := ""

	__New( title := "Console" ) {
		HWND := WinExist( title " ahk_class Notepad" )
		if ( HWND ) {
			WinGet, PID, PID, % "ahk_id " HWND
			this.ahkPID  := "ahk_pid " PID
			this.ahkHWND := "ahk_id  " HWND
			this.clear()
		} else {
			DetectHiddenWindows, On
			Run, Notepad,, Hide, PID
			this.ahkPID := "ahk_pid " PID
			WinWait, % this.ahkPID
			HWND := WinExist()
			if HWND=0
				return
			this.ahkHWND := "ahk_id  " HWND
			WinMove, % this.ahkHWND,, 0, 0, % A_ScreenWidth/4, % A_ScreenHeight
			WinSetTitle, % this.ahkHWND,, % title
			WinShow, % this.ahkHWND
			;WinActivate, % this.ahkHWND
		}
		return this
    }

	hotkey{
		set {
			show_bind := ObjBindMethod(this, "show")
			Hotkey, % value, % show_bind
		}
	}


	log( texts* ) {
		if ( !WinExist( this.ahkHWND ) )
			return
		last := texts.Length()
		if last == 0
			Control, EditPaste, % "`r`n", Edit1, % this.ahkHWND
		for idx, txt in texts {
			;if (Type(txt)="Object") {
			if (IsObject(txt)) {
				Control, EditPaste, % "{`r`n", Edit1, % this.ahkHWND
				for key, value in txt {
					Control, EditPaste, % "`t" key ": " value "`r`n", Edit1, % this.ahkHWND
				}
				Control, EditPaste, % "}`r`n", Edit1, % this.ahkHWND
			} else {
				rc := (idx=last? "`r`n" : " ")
				Control, EditPaste, % txt rc, Edit1, % this.ahkHWND  ; ControlSendText ? ControlEditPaste
			}
		}
	}

	show() {
		WinSet, AlwaysOnTop, % true, % this.ahkHWND
		WinSet, AlwaysOnTop, % false, % this.ahkHWND
	}

	clear() {
		ControlSetText, Edit1,, % this.ahkHWND
	}

}