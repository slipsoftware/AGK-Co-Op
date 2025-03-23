// File: MKenu.agc
// Created: 21-03-15

#constant STATE_EXIT					 -1
#constant STATE_MAIN_MENU				0
#constant STATE_GAME_MENU				1
#constant STATE_JOINGAME				2
#constant STATE_OPTIONS					3
#constant STATE_OPTION_GENERAL			4
#constant STATE_OPTION_MULTIPLAYER		5
#constant STATE_OPTION_BINDINGS			6
#constant STATE_GAME					7

type MenuData
	IP$ as string
	ReceivePort as integer
	TransmitPort as integer
endtype

global Menu_TextColorUp as Core_ColorData
global Menu_TextColorDown as Core_ColorData

function Menu_GetItemHitTest(TextID, Pointer as Core_Vec2Data, ColorUp as Core_ColorData, ColorDown as Core_ColorData)
	if GetTextHitTest(TextID, Pointer.X#, Pointer.Y#)
		SetTextColor(TextID, 192, 192, 192, 255)
		if GetPointerReleased()
			SetTextSize(TextID, 11)
			exitfunction 1
		endif
	else
		SetTextColor(TextID, 255, 255, 255, 255)
	endif
endfunction 0

Function Menu_SetEditboxKey(EditBoxID, KeyCode)
	if GetEditBoxHasFocus(EditBoxID) = 1 and KeyCode > -1 and KeyCode <> KEY_BACK
		SetEditBoxText(EditBoxID, Input_GetKeyName(KeyCode))
		exitfunction 1
	endif
Endfunction 0

//main State Handler
function Menu_Init()
	//TODO: Load Settings Here
	
	Menu_TextColorUp.Red = 192
	Menu_TextColorUp.Green = 192
	Menu_TextColorUp.Blue = 192
	Menu_TextColorUp.Alpha = 255
	
	Menu_TextColorDown.Red = 255
	Menu_TextColorDown.Green = 255
	Menu_TextColorDown.Blue = 255
	Menu_TextColorDown.Alpha = 255
	
	Menu as MenuData
	local GameState as integer
	GameState = 0
	do
		Select GameState
			case STATE_EXIT
				exit
			endcase
			case STATE_MAIN_MENU
				GameState = Menu_Main()
			endcase
			case STATE_JOINGAME
				GameState = Menu_JoinGame()
			endcase
			case STATE_GAME
				GameState = Game()
			endcase
			case STATE_OPTIONS
				GameState = Menu_Options()
			endcase
			case STATE_OPTION_GENERAL
				GameState = Menu_General()
			endcase
			case STATE_OPTION_MULTIPLAYER
				GameState = Menu_Multiplayer()
			endcase
			case STATE_OPTION_BINDINGS
				GameState = Menu_KeyBindings()
			endcase
		endselect
	    Sync()
	loop
endfunction

// this function is subject to change
function Menu_Main()	
	local GameState as integer
	local Pointer as Core_Vec2Data
	
	local HostTextID as integer
	HostTextID = CreateText("Host Game")
	SetTextSize(HostTextID, 12)
	
	local JoinTextID as integer
	JoinTextID = CreateText("Join Game")
	SetTextSize(JoinTextID, 12)
	SetTextPosition(JoinTextID, 0, 12)
	
	local OptionsTextID as integer
	OptionsTextID = CreateText("Options")
	SetTextSize(OptionsTextID, 12)
	SetTextPosition(OptionsTextID, 0, 24)
	
	local ExitTextID as integer
	ExitTextID = CreateText("Exit")
	SetTextSize(ExitTextID, 12)
	SetTextPosition(ExitTextID, 0, 36)
	
	GameState = STATE_MAIN_MENU
	while GameState = STATE_MAIN_MENU
		Input_MouseUpdate()
		Pointer = Input_GetMouseCurrentPoition()

		if Menu_GetItemHitTest(HostTextID, Pointer, Menu_TextColorUp, Menu_TextColorDown)
			Game_IsHost = 1
			GameState = STATE_GAME
		endif
		
		if Menu_GetItemHitTest(JoinTextID, Pointer, Menu_TextColorUp, Menu_TextColorDown)
			Game_IsHost = 0
			GameState = STATE_JOINGAME
		endif
		
		if Menu_GetItemHitTest(OptionsTextID, Pointer, Menu_TextColorUp, Menu_TextColorDown)
			GameState = STATE_OPTIONS
		endif
		
		if Menu_GetItemHitTest(ExitTextID, Pointer, Menu_TextColorUp, Menu_TextColorDown)
			GameState = STATE_EXIT
		endif

		sync()
	endwhile
	DeleteText(HostTextID)
	DeleteText(JoinTextID)
	DeleteText(OptionsTextID)
	DeleteText(ExitTextID)
endfunction GameState

function Menu_Options()
	local GameState as integer
	local Pointer as Core_Vec2Data
	
	local BackTextID as integer
	BackTextID = CreateText("Back")
	SetTextSize(BackTextID, 12)
	FixTextToScreen(BackTextID, 1)
	SetTextPosition(BackTextID, 0, 0)
	
	local GeneralTextID as integer
	GeneralTextID = CreateText("General")
	SetTextSize(GeneralTextID, 12)
	FixTextToScreen(GeneralTextID, 1)
	SetTextPosition(GeneralTextID, 0, 12)
	
	local MultiplayerTextID as integer
	MultiplayerTextID = CreateText("Multiplayer")
	SetTextSize(MultiplayerTextID, 12)
	FixTextToScreen(MultiplayerTextID, 1)
	SetTextPosition(MultiplayerTextID, 0, 24)
	
	local KeyBindingsTextID as integer
	KeyBindingsTextID = CreateText("Key Bindings")
	SetTextSize(KeyBindingsTextID, 12)
	FixTextToScreen(KeyBindingsTextID, 1)
	SetTextPosition(KeyBindingsTextID, 0, 36)
	
	GameState = STATE_OPTIONS
	while GameState = STATE_OPTIONS
		Input_MouseUpdate()
		Pointer = Input_GetMouseCurrentPoition()

		if Menu_GetItemHitTest(BackTextID, Pointer, Menu_TextColorUp, Menu_TextColorDown)
			GameState = STATE_MAIN_MENU
		endif
		
		if Menu_GetItemHitTest(GeneralTextID, Pointer, Menu_TextColorUp, Menu_TextColorDown)
			GameState = STATE_OPTION_GENERAL
		endif
		
		if Menu_GetItemHitTest(MultiplayerTextID, Pointer, Menu_TextColorUp, Menu_TextColorDown)
			GameState = STATE_OPTION_MULTIPLAYER
		endif
		
		if Menu_GetItemHitTest(KeyBindingsTextID, Pointer, Menu_TextColorUp, Menu_TextColorDown)
			GameState = STATE_OPTION_BINDINGS
		endif

		sync()
	endwhile
	
	DeleteText(BackTextID)
	DeleteText(GeneralTextID)
	DeleteText(MultiplayerTextID)
	DeleteText(KeyBindingsTextID)
endfunction GameState

//TODO: Menu options for the Host and/or Client
function Menu_Multiplayer()	
	local GameState as integer
	local Pointer as Core_Vec2Data
	
	local BackTextID as integer
	BackTextID = CreateText("Back")
	SetTextSize(BackTextID, 12)
	FixTextToScreen(BackTextID, 1)
	SetTextPosition(BackTextID, 0, 0)
	
	GameState = STATE_OPTION_MULTIPLAYER
	while GameState = STATE_OPTION_MULTIPLAYER
		Input_MouseUpdate()
		Pointer = Input_GetMouseCurrentPoition()

		if Menu_GetItemHitTest(BackTextID, Pointer, Menu_TextColorUp, Menu_TextColorDown)
			GameState = STATE_OPTIONS
		endif
		
		sync()
	endwhile
	
	DeleteText(BackTextID)
endfunction GameState

//TODO: General Menu Options for the interface, language etc.
function Menu_General()
	local GameState as integer
	local Pointer as Core_Vec2Data
	
	local BackTextID as integer
	BackTextID = CreateText("Back")
	SetTextSize(BackTextID, 12)
	FixTextToScreen(BackTextID, 1)
	SetTextPosition(BackTextID, 0, 0)
	
	GameState = STATE_OPTION_GENERAL
	while GameState = STATE_OPTION_GENERAL	
		Input_MouseUpdate()
		Pointer = Input_GetMouseCurrentPoition()

		if Menu_GetItemHitTest(BackTextID, Pointer, Menu_TextColorUp, Menu_TextColorDown)
			GameState = STATE_OPTIONS
		endif
		
		sync()
	endwhile
	
	DeleteText(BackTextID)
endfunction GameState

//TODO: Keybinding Options Menu
function Menu_KeyBindings()
	Input_Read()

	local GameState as integer
	local Pointer as Core_Vec2Data
	local KeyCode as integer

	local KeyUpName$ as string
	local KeyDownName$ as string
	local KeyLeftName$ as string
	local KeyRightName$ as string
	local KeyActionName$ as string
	local KeyReloadName$ as string

	KeyUpName$=Input_GetKeyName(Input_GetPrimaryKeyCode(KEYINDEX_UP))
	KeyDownName$=Input_GetKeyName(Input_GetPrimaryKeyCode(KEYINDEX_DOWN))
	KeyLeftName$=Input_GetKeyName(Input_GetPrimaryKeyCode(KEYINDEX_LEFT))
	KeyRightName$=Input_GetKeyName(Input_GetPrimaryKeyCode(KEYINDEX_RIGHT))
	KeyActionName$=Input_GetKeyName(Input_GetPrimaryKeyCode(KEYINDEX_ACTION))
	KeyReloadName$=Input_GetKeyName(Input_GetPrimaryKeyCode(KEYINDEX_RELOAD))
	
	local BackTextID as integer
	BackTextID = CreateText("Back")
	SetTextSize(BackTextID, 12)
	FixTextToScreen(BackTextID, 1)
	SetTextPosition(BackTextID, 0, 0)

	local KeyUpTextID as integer
	KeyUpTextID=CreateText("Move Forward: ")
	SetTextSize(KeyUpTextID,4)
	SetTextPosition(KeyUpTextID,0,12)
	
	local KeyUpEditBoxID as integer
	KeyUpEditBoxID=CreateEditBox()
	SetEditBoxText(KeyUpEditBoxID,KeyUpName$)
	SetEditBoxSize(KeyUpEditBoxID,75,6)
	SetEditBoxPosition(KeyUpEditBoxID,50,12)
	SetEditBoxBackgroundColor(KeyUpEditBoxID,0,0,0,0)
	SetEditBoxBorderColor(KeyUpEditBoxID,0,0,0,0)
	SetEditBoxTextColor(KeyUpEditBoxID,255,255,255)
	SetEditBoxMaxChars(KeyUpEditBoxID,1)
	
	local KeyDownTextID as integer
	KeyDownTextID=CreateText("Move Bckward: ")
	SetTextSize(KeyDownTextID,4)
	SetTextPosition(KeyDownTextID,0,18)
	
	local KeyDownEditBoxID as integer
	KeyDownEditBoxID=CreateEditBox()
	SetEditBoxText(KeyDownEditBoxID,KeyDownName$)
	SetEditBoxSize(KeyDownEditBoxID,75,6)
	SetEditBoxPosition(KeyDownEditBoxID,50,18)
	SetEditBoxBackgroundColor(KeyDownEditBoxID,0,0,0,0)
	SetEditBoxBorderColor(KeyDownEditBoxID,0,0,0,0)
	SetEditBoxTextColor(KeyDownEditBoxID,255,255,255)
	SetEditBoxMaxChars(KeyDownEditBoxID,1)
	
	local KeyLeftTextID as integer
	KeyLeftTextID=CreateText("Strave Left: ")
	SetTextSize(KeyLeftTextID,4)
	SetTextPosition(KeyLeftTextID,0,24)
	
	local KeyLeftEditBoxID as integer
	KeyLeftEditBoxID=CreateEditBox()
	SetEditBoxText(KeyLeftEditBoxID,KeyLeftName$)
	SetEditBoxSize(KeyLeftEditBoxID,75,6)
	SetEditBoxPosition(KeyLeftEditBoxID,50,24)
	SetEditBoxBackgroundColor(KeyLeftEditBoxID,0,0,0,0)
	SetEditBoxBorderColor(KeyLeftEditBoxID,0,0,0,0)
	SetEditBoxTextColor(KeyLeftEditBoxID,255,255,255)
	SetEditBoxMaxChars(KeyLeftEditBoxID,1)
	
	local KeyRightTextID as integer
	KeyRightTextID=CreateText("Strafe Right: ")
	SetTextSize(KeyRightTextID,4)
	SetTextPosition(KeyRightTextID,0,30)
	
	local KeyRightEditBoxID as integer
	KeyRightEditBoxID=CreateEditBox()
	SetEditBoxText(KeyRightEditBoxID,KeyRightName$)
	SetEditBoxSize(KeyRightEditBoxID,75,6)
	SetEditBoxPosition(KeyRightEditBoxID,50,30)
	SetEditBoxBackgroundColor(KeyRightEditBoxID,0,0,0,0)
	SetEditBoxBorderColor(KeyRightEditBoxID,0,0,0,0)
	SetEditBoxTextColor(KeyRightEditBoxID,255,255,255)
	SetEditBoxMaxChars(KeyRightEditBoxID,1)
	
	local KeyActionTextID as integer
	KeyActionTextID=CreateText("Action: ")
	SetTextSize(KeyActionTextID,4)
	SetTextPosition(KeyActionTextID,0,36)
	
	local KeyActionEditBoxID as integer
	KeyActionEditBoxID=CreateEditBox()
	SetEditBoxText(KeyActionEditBoxID,KeyActionName$)
	SetEditBoxSize(KeyActionEditBoxID,75,6)
	SetEditBoxPosition(KeyActionEditBoxID,50,36)
	SetEditBoxBackgroundColor(KeyActionEditBoxID,0,0,0,0)
	SetEditBoxBorderColor(KeyActionEditBoxID,0,0,0,0)
	SetEditBoxTextColor(KeyActionEditBoxID,255,255,255)
	SetEditBoxMaxChars(KeyActionEditBoxID,1)

	local KeyReloadTextID as integer
	KeyReloadTextID=CreateText("Reload: ")
	SetTextSize(KeyReloadTextID,4)
	SetTextPosition(KeyReloadTextID,0,42)
	
	local KeyReloadEditBoxID as integer
	KeyReloadEditBoxID=CreateEditBox()
	SetEditBoxText(KeyReloadEditBoxID,KeyReloadName$)
	SetEditBoxSize(KeyReloadEditBoxID,75,6)
	SetEditBoxPosition(KeyReloadEditBoxID,50,42)
	SetEditBoxBackgroundColor(KeyReloadEditBoxID,0,0,0,0)
	SetEditBoxBorderColor(KeyReloadEditBoxID,0,0,0,0)
	SetEditBoxTextColor(KeyReloadEditBoxID,255,255,255)
	SetEditBoxMaxChars(KeyReloadEditBoxID,1)

	GameState = STATE_OPTION_BINDINGS
	while GameState = STATE_OPTION_BINDINGS
		Input_MouseUpdate()
		Pointer = Input_GetMouseCurrentPoition()
		
		if Menu_GetItemHitTest(BackTextID, Pointer, Menu_TextColorUp, Menu_TextColorDown)
			GameState = STATE_OPTIONS
		endif
		
		KeyCode=Input_GetKeyCodeOnChange()

		if Menu_SetEditboxKey(KeyUpEditBoxID, KeyCode)
			Input_SetPrimaryKeyBinding(KEYINDEX_UP, KeyCode)
		endif
		if Menu_SetEditboxKey(KeyDownEditBoxID, KeyCode)
			Input_SetPrimaryKeyBinding(KEYINDEX_DOWN, KeyCode)
		endif
		if Menu_SetEditboxKey(KeyLeftEditBoxID, KeyCode)
			Input_SetPrimaryKeyBinding(KEYINDEX_LEFT, KeyCode)
		endif
		if Menu_SetEditboxKey(KeyRightEditBoxID, KeyCode)
			Input_SetPrimaryKeyBinding(KEYINDEX_RIGHT, KeyCode)
		endif
		if Menu_SetEditboxKey(KeyActionEditBoxID, KeyCode)
			Input_SetPrimaryKeyBinding(KEYINDEX_ACTION, KeyCode)
		endif
		if Menu_SetEditboxKey(KeyReloadEditBoxID, KeyCode)
			Input_SetPrimaryKeyBinding(KEYINDEX_RELOAD, KeyCode)
		endif
		
		sync()
	endwhile
	Input_Write()
	
	DeleteText(BackTextID)
	DeleteText(KeyUpTextID)
	DeleteText(KeyDownTextID)
	DeleteText(KeyLeftTextID)
	DeleteText(KeyRightTextID)
	DeleteText(KeyActionTextID)
	DeleteText(KeyReloadTextID)

	DeleteEditBox(KeyUpEditBoxID)
	DeleteEditBox(KeyDownEditBoxID)
	DeleteEditBox(KeyLeftEditBoxID)
	DeleteEditBox(KeyRightEditBoxID)
	DeleteEditBox(KeyActionEditBoxID)
	DeleteEditBox(KeyReloadEditBoxID)
endfunction GameState

// this function is subject to change
function Menu_JoinGame()	
	local GameState as integer
	local Pointer as Core_Vec2Data
	
	local BackTextID as integer
	BackTextID = CreateText("Back")
	SetTextSize(BackTextID, 12)
	
	local ConnectTextID as integer
	ConnectTextID = CreateText("Connect")
	SetTextSize(ConnectTextID, 12)
	SetTextPosition(ConnectTextID, 0, 12)
	
	//TODO: Present a List with Local and Online Games using broadcastlistener and http requests
	
	GameState = STATE_JOINGAME
	while GameState = STATE_JOINGAME
		Input_MouseUpdate()
		Pointer = Input_GetMouseCurrentPoition()

		if Menu_GetItemHitTest(BackTextID, Pointer, Menu_TextColorUp, Menu_TextColorDown)
			GameState = STATE_MAIN_MENU
		endif
		
		if Menu_GetItemHitTest(ConnectTextID, Pointer, Menu_TextColorUp, Menu_TextColorDown)
			GameState = STATE_GAME
		endif

		sync()
	endwhile
	DeleteText(BackTextID)
	DeleteText(ConnectTextID)
endfunction GameState
