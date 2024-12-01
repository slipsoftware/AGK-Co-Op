// File: constants.agc
// Created: 20-08-22

// Keymapping
// Base
#Constant KEY_BACK 8
#Constant KEY_TAB 9
#Constant KEY_ENTER 13
#Constant KEY_SHIFT 16
#Constant KEY_CONTROL 17
#Constant KEY_ALT 18
#Constant KEY_PAUSE 19
#Constant KEY_SCROLLLOCK 145
#Constant KEY_CAPSLOCK 20
#Constant KEY_ESCAPE 27
#Constant KEY_SPACE 32
 
#Constant KEY_INSERT 45
#Constant KEY_DELETE 46
#Constant KEY_PAGEUP 33
#Constant KEY_PAGEDOWN 34
#Constant KEY_END 35
#Constant KEY_HOME 36
 
#Constant KEY_LEFT 37
#Constant KEY_UP 38
#Constant KEY_RIGHT 39
#Constant KEY_DOWN 40
 
#Constant KEY_WIN_LEFT 91
#Constant KEY_WIN_RIGHT 92
#Constant KEY_COMMAND 93
#Constant KEY_MENU 93
#Constant KEY_FUNCTION 93
#Constant KEY_LEFT_SHIFT 257
#Constant KEY_RIGHT_SHIFT 258
#Constant KEY_LEFT_CTRL 259
#Constant KEY_RIGHT_CTRL 260
#Constant KEY_LEFT_ALT 261
#Constant KEY_RIGHT_ALT 262
 
// (triggered by both top row number keys and numpad keys)
#Constant KEY_0 48 
#Constant KEY_1 49
#Constant KEY_2 50
#Constant KEY_3 51
#Constant KEY_4 52
#Constant KEY_5 53
#Constant KEY_6 54
#Constant KEY_7 55
#Constant KEY_8 56
#Constant KEY_9 57
#Constant KEY_A 65
#Constant KEY_B 66
#Constant KEY_C 67
#Constant KEY_D 68
#Constant KEY_E 69
#Constant KEY_F 70
#Constant KEY_G 71
#Constant KEY_H 72
#Constant KEY_I 73
#Constant KEY_J 74
#Constant KEY_K 75
#Constant KEY_L 76
#Constant KEY_M 77
#Constant KEY_N 78
#Constant KEY_O 79
#Constant KEY_P 80
#Constant KEY_Q 81
#Constant KEY_R 82
#Constant KEY_S 83
#Constant KEY_T 84
#Constant KEY_U 85
#Constant KEY_V 86
#Constant KEY_W 87
#Constant KEY_X 88
#Constant KEY_Y 89
#Constant KEY_Z 90
 
// Numpad (Optional)
#Constant KEY_NUMLOCK 144
#Constant KEY_NUMPAD_0 96
#Constant KEY_NUMPAD_1 97
#Constant KEY_NUMPAD_2 98
#Constant KEY_NUMPAD_3 99
#Constant KEY_NUMPAD_4 100
#Constant KEY_NUMPAD_5 101
#Constant KEY_NUMPAD_6 102
#Constant KEY_NUMPAD_7 103
#Constant KEY_NUMPAD_8 104
#Constant KEY_NUMPAD_9 105
#Constant KEY_ASTERISK 106
#Constant KEY_PLUS 107
#Constant KEY_SUBTRACT 109
#Constant KEY_DECIMAL 110
#Constant KEY_DIVIDE 111
 
// Function
#Constant KEY_F1 112
#Constant KEY_F2 113
#Constant KEY_F3 114
#Constant KEY_F4 115
#Constant KEY_F5 116
#Constant KEY_F6 117
#Constant KEY_F7 118
#Constant KEY_F8 119
#Constant KEY_F9 120
#Constant KEY_F10 121
#Constant KEY_F11 122
#Constant KEY_F12 123
 
// Media
#Constant KEY_VOLUME_MUTE 173
#Constant KEY_VOLUME_DOWN 174
#Constant KEY_VOLUME_UP 175
#Constant KEY_MEDIA_NEXT 176
#Constant KEY_MEDIA_PREV 177
#Constant KEY_MEDIA_STOP 178
#Constant KEY_MEDIA_PLAY 179
#Constant KEY_CALCULATOR 183
 
// Punctuation
#Constant KEY_SEMICOLON 186
#Constant KEY_EQUAL 187
#Constant KEY_COMMA 188
#Constant KEY_HYPHON 189
#Constant KEY_FULLSTOP 190
#Constant KEY_FORWARDSLASH 191
#Constant KEY_QUOTE 192
#Constant KEY_BRACKETOPEN 219
#Constant KEY_BACKSLASH 220
#Constant KEY_BRACKETCLOSE 221
#Constant KEY_HASH 222
#Constant KEY_APOSTROPHE 223
 
// Number Keys
#Constant KEY_TOP_0 263
#Constant KEY_TOP_1 264
#Constant KEY_TOP_2 265
#Constant KEY_TOP_3 266
#Constant KEY_TOP_4 267
#Constant KEY_TOP_5 268
#Constant KEY_TOP_6 269
#Constant KEY_TOP_7 270
#Constant KEY_TOP_8 271
#Constant KEY_TOP_9 272

#constant KEYINDEX_UP			0
#constant KEYINDEX_DOWN		1
#constant KEYINDEX_LEFT		2
#constant KEYINDEX_RIGHT		3
#constant KEYINDEX_ACTION		4
#constant KEYINDEX_CROUCH		5
#constant KEYINDEX_LEANLEFT	6
#constant KEYINDEX_LEANRIGHT	7
#constant KEYINDEX_SHOOT		8

// Input Types
type Input_MouseData
	Speed# as float
	Start as Core_Vec2Data
	Stop as Core_Vec2Data
	Current as Core_Vec2Data
	Drag as Core_Vec2Data
endtype

type Input_KeyBindingData
	Primary as integer
	Secondary as integer
endtype

type Input_KeyboardData
	Key as Input_KeyBindingData[60]
endtype

type Input_JoystickData
	Speed# as float
	Size# as float
	Current as Core_Vec2Data
endtype

type InputData
	Mouse as Input_MouseData
	Keyboard as Input_KeyboardData
	Joystick as Input_JoystickData
	BindingsFile$ as string
endtype

global Input as InputData

function Input_Init(MouseSpeed# as float, JystickSpeed# as float, File$ as string)	
	// Initialize all Input Variables
	Input.Mouse.Speed#=MouseSpeed#*3
	Input.Joystick.Speed#=JystickSpeed#
	Input.Joystick.Size#=GetVirtualHeight()*0.25
	Input.BindingsFile$="raw:"+File$
	
	Input_SetDefaultBinding()
endfunction

function Input_Update()
	Input_MouseUpdate()
	Input_JoystickUpdate()
endfunction

function Input_Read()
	if GetFileExists(Input.BindingsFile$)
		local String$ as string
		String$=Core_FileLoad(Input.BindingsFile$)
		local TempKeyBindings as Input_KeyboardData
		TempKeyBindings.fromJSON(String$)
		Input.Keyboard=TempKeyBindings
	endif
endfunction

function Input_Write()
	local string$ as string	
	local TempKeyBindings as Input_KeyboardData
	TempKeyBindings=Input.Keyboard
	String$=TempKeyBindings.toJSON()
	Core_FileSave(String$,Input.BindingsFile$)
endfunction

// Mouse Handling
function Input_MouseUpdate()	
	Input.Mouse.Current.X#=GetPointerX()
	Input.Mouse.Current.Y#=GetPointerY()
	
    if GetPointerPressed()=1
        Input.Mouse.Start.X#=Input.Mouse.Current.X#
        Input.Mouse.Start.Y#=Input.Mouse.Current.Y#
    elseif GetPointerReleased()=1
        Input.Mouse.Stop.X#=Input.Mouse.Current.X#
        Input.Mouse.Stop.Y#=Input.Mouse.Current.Y#
    endif
    if GetPointerState()=1
	    Input.Mouse.Drag.X#=Input.Mouse.Current.X#-Input.Mouse.Start.X#
	    Input.Mouse.Drag.Y#=Input.Mouse.Current.Y#-Input.Mouse.Start.Y#
	endif
endfunction

// Keyboard Handling
function Input_SetDefaultBinding()
	Input_SetKeyBinding(KEYINDEX_UP,		KEY_W, KEY_UP)
	Input_SetKeyBinding(KEYINDEX_DOWN,	KEY_S, KEY_DOWN)
	Input_SetKeyBinding(KEYINDEX_LEFT,	KEY_A, KEY_LEFT)
	Input_SetKeyBinding(KEYINDEX_RIGHT,	KEY_D, KEY_RIGHT)
	Input_SetKeyBinding(KEYINDEX_ACTION,	KEY_E, KEY_ENTER)
endfunction

function Input_SetKeyBinding(KeyIndex,PrimaryKeyCode,SecondaryKeyCode)
	Input.Keyboard.Key[KeyIndex].Primary=PrimaryKeyCode
	Input.Keyboard.Key[KeyIndex].Secondary=SecondaryKeyCode
endfunction

function Input_GetPrimaryKeyCode(KeyIndex)
	KeyCode=Input.Keyboard.Key[KeyIndex].Primary
endfunction KeyCode

function Input_GetSecondaryKeyCode(KeyIndex)
	KeyCode=Input.Keyboard.Key[KeyIndex].Secondary
endfunction KeyCode

function Input_GetKeyPressed(KeyIndex)
	KeyPressed=(GetRawKeyPressed(Input.Keyboard.Key[KeyIndex].Primary) or GetRawKeyPressed(Input.Keyboard.Key[KeyIndex].Secondary))
endfunction KeyPressed

function Input_GetKeyState(KeyIndex)
	KeyPressed=(GetRawKeyState(Input.Keyboard.Key[KeyIndex].Primary) or GetRawKeyState(Input.Keyboard.Key[KeyIndex].Secondary))
endfunction KeyPressed

function Input_GetKeyReleased(KeyIndex)
	KeyPressed=(GetRawKeyReleased(Input.Keyboard.Key[KeyIndex].Primary) or GetRawKeyReleased(Input.Keyboard.Key[KeyIndex].Secondary))
endfunction KeyPressed

function Input_GetKeyName(KeyCode)
	local Result$ as string
	select KeyCode		
		case KEY_BACK: 		Result$="Back":			endcase
		case KEY_TAB: 		Result$="Tab":			endcase
		case KEY_ENTER:		Result$="Enter":			endcase
		case KEY_SHIFT:		Result$="Shift":			endcase
		case KEY_CONTROL:	Result$="Ctrl":			endcase
		case KEY_ESCAPE:		Result$="Escape":		endcase
		case KEY_SPACE:		Result$="Space":			endcase
		case KEY_PAGEUP:		Result$="Page Up":		endcase
		case KEY_PAGEDOWN:	Result$="Page Down":		endcase
		case KEY_END:		Result$="End":			endcase
		case KEY_HOME:		Result$="Home":			endcase
		case KEY_LEFT:		Result$="Left":			endcase
		case KEY_UP:		Result$="Up":			endcase
		case KEY_RIGHT:		Result$="Right":			endcase
		case KEY_DOWN:		Result$="Down":			endcase
		case KEY_INSERT:		Result$="Insert":		endcase
		case KEY_DELETE:		Result$="Delete":		endcase
		case default:		Result$=Chr(KeyCode):	endcase
	endselect
endfunction Result$

// Joystick Handling
function Input_JoystickUpdate()
	Size#=Input.Joystick.Size#
	SetJoystickScreenPosition(GetScreenBoundsLeft()+Size#*0.75,GetScreenBoundsBottom()-Size#*0.75,Size#)
	Input.Joystick.Current.X#=GetJoystickX()
	Input.Joystick.Current.Y#=GetJoystickY()
endfunction
