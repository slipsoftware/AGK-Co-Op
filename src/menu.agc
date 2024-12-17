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

function Menu_GetItemHitTest(TextID, PosX#, PosY#, ColorUp as Core_ColorData, ColorDown as Core_ColorData)
	if GetTextHitTest(TextID, PosX#, PosY#)
		SetTextColor(TextID, 192, 192, 192, 255)
		if GetPointerReleased()
			SetTextSize(TextID, 11)
			exitfunction 1
		endif
	else
		SetTextColor(TextID, 255, 255, 255, 255)
	endif
endfunction 0

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
	local PointerX# as float
	local PointerY# as float
	
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
		PointerX# = ScreenToWorldX(GetPointerX())
		PointerY# = ScreenToWorldY(GetPointerY())
		
		if Menu_GetItemHitTest(HostTextID, PointerX#, PointerY#, Menu_TextColorUp, Menu_TextColorDown)
			Game_IsHost = 1
			GameState = STATE_GAME
		endif
		
		if Menu_GetItemHitTest(JoinTextID, PointerX#, PointerY#, Menu_TextColorUp, Menu_TextColorDown)
			Game_IsHost = 0
			GameState = STATE_JOINGAME
		endif
		
		if Menu_GetItemHitTest(OptionsTextID, PointerX#, PointerY#, Menu_TextColorUp, Menu_TextColorDown)
			GameState = STATE_OPTIONS
		endif
		
		if Menu_GetItemHitTest(ExitTextID, PointerX#, PointerY#, Menu_TextColorUp, Menu_TextColorDown)
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
	local PointerX# as float
	local PointerY# as float
	
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
		PointerX# = ScreenToWorldX(GetPointerX())
		PointerY# = ScreenToWorldY(GetPointerY())
		
		if Menu_GetItemHitTest(BackTextID, PointerX#, PointerY#, Menu_TextColorUp, Menu_TextColorDown)
			GameState = STATE_MAIN_MENU
		endif
		
		if Menu_GetItemHitTest(GeneralTextID, PointerX#, PointerY#, Menu_TextColorUp, Menu_TextColorDown)
			GameState = STATE_OPTION_GENERAL
		endif
		
		if Menu_GetItemHitTest(MultiplayerTextID, PointerX#, PointerY#, Menu_TextColorUp, Menu_TextColorDown)
			GameState = STATE_OPTION_MULTIPLAYER
		endif
		
		if Menu_GetItemHitTest(KeyBindingsTextID, PointerX#, PointerY#, Menu_TextColorUp, Menu_TextColorDown)
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
	local PointerX# as float
	local PointerY# as float
	
	local BackTextID as integer
	BackTextID = CreateText("Back")
	SetTextSize(BackTextID, 12)
	FixTextToScreen(BackTextID, 1)
	SetTextPosition(BackTextID, 0, 0)
	
	GameState = STATE_OPTION_MULTIPLAYER
	while GameState = STATE_OPTION_MULTIPLAYER
		
		PointerX# = ScreenToWorldX(GetPointerX())
		PointerY# = ScreenToWorldY(GetPointerY())
		
		if Menu_GetItemHitTest(BackTextID, PointerX#, PointerY#, Menu_TextColorUp, Menu_TextColorDown)
			GameState = STATE_OPTIONS
		endif
		
		sync()
	endwhile
	
	DeleteText(BackTextID)
endfunction GameState

//TODO: General Menu Options for the interface, language etc.
function Menu_General()	
	local GameState as integer
	local PointerX# as float
	local PointerY# as float
	
	local BackTextID as integer
	BackTextID = CreateText("Back")
	SetTextSize(BackTextID, 12)
	FixTextToScreen(BackTextID, 1)
	SetTextPosition(BackTextID, 0, 0)
	
	GameState = STATE_OPTION_GENERAL
	while GameState = STATE_OPTION_GENERAL
		
		PointerX# = ScreenToWorldX(GetPointerX())
		PointerY# = ScreenToWorldY(GetPointerY())
		
		if Menu_GetItemHitTest(BackTextID, PointerX#, PointerY#, Menu_TextColorUp, Menu_TextColorDown)
			GameState = STATE_OPTIONS
		endif
		
		sync()
	endwhile
	
	DeleteText(BackTextID)
endfunction GameState

//TODO: Keybinding Options Menu
function Menu_KeyBindings()
	local GameState as integer
	
	local PointerX# as float
	local PointerY# as float
	
	local BackTextID as integer
	BackTextID = CreateText("Back")
	SetTextSize(BackTextID, 12)
	FixTextToScreen(BackTextID, 1)
	SetTextPosition(BackTextID, 0, 0)
	
	GameState = STATE_OPTION_BINDINGS
	while GameState = STATE_OPTION_BINDINGS
		
		PointerX# = ScreenToWorldX(GetPointerX())
		PointerY# = ScreenToWorldY(GetPointerY())
		
		if Menu_GetItemHitTest(BackTextID, PointerX#, PointerY#, Menu_TextColorUp, Menu_TextColorDown)
			GameState = STATE_OPTIONS
		endif
		
		sync()
	endwhile
	
	DeleteText(BackTextID)
endfunction GameState

// this function is subject to change
function Menu_JoinGame()	
	local GameState as integer
	
	local PointerX# as float
	local PointerY# as float
	
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
		PointerX# = ScreenToWorldX(GetPointerX())
		PointerY# = ScreenToWorldY(GetPointerY())
		
		if Menu_GetItemHitTest(BackTextID, PointerX#, PointerY#, Menu_TextColorUp, Menu_TextColorDown)
			GameState = STATE_MAIN_MENU
		endif
		
		if Menu_GetItemHitTest(ConnectTextID, PointerX#, PointerY#, Menu_TextColorUp, Menu_TextColorDown)
			GameState = STATE_GAME
		endif

		sync()
	endwhile
	DeleteText(BackTextID)
	DeleteText(ConnectTextID)
endfunction GameState
