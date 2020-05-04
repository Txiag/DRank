#include <Vis2>
#include <Console>
#include <range>


; global Console := new CConsole
global DBDLoading := FALSE
global currentState := "IDLE"

; What the button in the bottom-right corner currently says
global CTAState := ""

; Try to detect when we're stuck in a corner
global lastFrameSample := ""

; Are we currently in an error state?
global inErrorState := FALSE
global timersDisabled := TRUE

Loop {
	active := WinActive("DeadByDaylight")
	toggleEnabled := toggle and active

	global timersDisabled

	; ; Main loop once hotkey is enabled and pressed	
	if toggleEnabled {
		if (timersDisabled) {
			ToolTip, "Dead By Daylight Derank Bot 1.0 is running. Press F8 to Quit.", 200, 200
			SetTimer, HandleErrorState, 23000
			SetTimer, HandleQueueMechanics, 5000
			; SetTimer, HandleGameplayMechanics, 10000
			timersDisabled := FALSE
		}

	} else {
		ToolTip
		SetTimer, HandleErrorState, OFF
		SetTimer, HandleQueueMechanics, OFF
		; SetTimer, HandleGameplayMechanics, OFF
		timersDisabled := TRUE
	}
}

return


StrJoin(obj,delimiter:="",OmitChars:=""){
	string:=obj[1]
	Loop % obj.MaxIndex()-1
		string .= delimiter Trim(obj[A_Index+1],OmitChars)
	return string
}

HandleErrorState:
	Console.log("Starting Error Check...")
	ErrorHeaderState := readErrorHeader()
	disconnectedError := InStr(ErrorHeaderState, "DISCONNECTION FROM HOST")
	canceledError := InStr(ErrorHeaderState, "Cancelled")

	if (disconnectedError or canceledError) {
		Console.log("Found Error State: '" . ErrorHeaderState . "'" )

		; Click the ok button
		click(1404, 630)

		; Move the mouse back to center 
		; in the case there is another error hidden behind it
		MouseMove, A_ScreenWidth / 2, A_ScreenHeight / 2
	}

	return


TurnMouseRandom:
	screenHeight := A_ScreenHeight / 2
	screenWidth := A_ScreenWidth *

	MouseMove, A_ScreenWidth / 2, A_ScreenHeight / 2
	sleep, 500
	Random, newX, screenWidth - (screenWidth * 2), screenWidth * 2
	Random, movement, 100, 3000

	MouseMove, newX, A_ScreenHeight / 2, movement
	return


HandleMouseMovement:
	global lastFrameSample

	; split the screen up into a 9/9 grid
	gridSize := 9
	diameter := 15
	gridSizeX := A_ScreenWidth / gridSize
	gridSizeY := A_ScreenHeight / gridSize

	sampleLocationX := gridSizeX * (gridSize - 1) + diameter
	sampleLocationY := gridSizeY + diameter

	nextFrameSample := getRegionColorData(sampleLocationX, sampleLocationY, diameter)
	comp := StrJoin(nextFrameSample, "")

	if (comp := lastFrameSample) {
		Gosub, TurnMouseRandom
	}

	lastFrameSample := comp

	return


HandleQueueMechanics:
	global CTAState

	Console.log("Starting queue check...")
	ActionButtonX := 1800
	ActionButtonY := 1000

	CTAState := readCTAButton()

	inUnreadyState := InStr(CTAState, "UNREADY") 
	inReadyState := (not inUnreadyState && InStr(CTAState, "READY"))
	inEndgameState := InStr(CTAState, "CONTINUE")

	if (inReadyState or inEndgameState) {
		click(ActionButtonX, ActionButtonY)
	}
	return


HandleGameplayMechanics:
	global CTAState

	; Professor Oak: Now is not the time to use that!
	if (CTAState) {
		return
	}

	Console.log("Running Gameplay Mechanics")

	; Gosub, MoveRandom
	; Gosub, TeaBagw
	; Gosub, CrouchWalk
	return

; Loop struggling for 1s a random amount of times between 2-10 times 
Struggle:
	Send, {a Down}
	Sleep, 50
	Send, {a Up}
	Sleep, 50
	Send, {d Down}
	Sleep, 50
	Send, {d Up}
	return


; Loop struggling for 1s a random amount of times between 2-10 times 
TeaBag:
	Random, LoopCount, 2, 30
	Loop, %LoopCount%
	{
		Send, {CtrlDown}
		Sleep, 100
		Send, {CtrlUp}
		Sleep, 100
	}
	return


; Loop walking foward for 1s a random amount of times between 2-10 times 
CrouchWalk:
	Random, LoopCount, 2, 10
	Loop, %LoopCount%
	{
		key = Random_Choice("w", "a", "s", "d")
		Send, {CtrlDown}
		Send, {%key% Down}
		Sleep, 3000
		Send, {%key% Up}
		Send, {CtrlUp}
	}
	return


MoveRandom:
	Random, runTime, 1000, 7000
	Send, {ShiftDown}{w Down}
	Sleep, runTime
	Gosub, HandleMouseMovement
	Send, {ShiftUp}{w Up}
	return



F8::toggle:=!toggle


; TODO: More than 1080p support
readCTAButton() {
	return,OCR([1630, 988, 203, 50])
}

readErrorHeader() {
	return,OCR([700, 440, 525, 45])
}

click(x, y) {
	MouseClick, Left, x, y, , , D
	MouseClick, Left, x, y, , , U
	Sleep, 300
}

transitionState() {
	currentState := getNextState()
	return
}

getNextState() {
	if (currentState = "IDLE") {
		return,"LOBBIED"
	} else if (currentState = "LOBBIED") {
		return,"PLAYING"
	} else if (currentState = "PLAYING") {
		return,"ENDGAME"
	} else if (currentState = "ENDGAME") {
		return,"IDLE"
	}

	return,"N/A"
}


Random_Choice(Choices*){
	Random,Index,1,% Choices.MaxIndex()
	Return,Choices[Index]
}

getRegionColorData(x, y, diameter) {
	colors := []

	for j in range(1, diameter + 1) {
		PixelGetColor, left, x - j, y 
		PixelGetColor, right, x + j, y

		PixelGetColor, topLeft, x - j, y + j 
		PixelGetColor, top, x, y + j 
		PixelGetColor, topRight, x + j, y + j

		PixelGetColor, bottomLeft, x - j, y - j 
		PixelGetColor, bottom, x, y - j 
		PixelGetColor, bottomRight, x + j, y - j

		colors.Push(left) 
		colors.Push(right) 

		colors.Push(topLeft) 
		colors.Push(topRight) 
		colors.Push(top) 

		colors.Push(bottomLeft) 
		colors.Push(bottom) 
		colors.Push(bottomRight) 
	}

	return,colors
}













