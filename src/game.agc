// File: game.agc
// Created: 24-12-12

global cam as cam // from camera prolly shaders will access or replace
global OldMouseY# // from import will need to be combined
global OldMouseX#

global Game_isHost

function Game()
	local GameState as integer
	local Game_IP$ as string
	if Game_isHost=1
		//TODO: Create Host
	else
		Game_IP$=Core_RequestString("127.0.0.1")
		//TODO: Create Client
	endif
	
	SetRawMouseVisible(0)
	do	
		
		 //for complete features
		TestingCode()
		
		if GetRawKeyReleased(KEY_ESCAPE)
			if GameState=STATE_MAIN_MENU then exit
		endif
		
	    Sync()
	loop
	SetRawMouseVisible(1)
endfunction GameState

function TestingCode()
	Print("toggle me for unfinished code")
	Debug()
	Camera() //from camera.agc
endfunction

function Debug()
	SetPrintColor(0,255,255)
	Print("fps: "+str(ScreenFPS()))
	print("camX:"+str(getcamerax(1)))
	print("camY:"+str(getcameraY(1)))
	print("camZ:"+str(getcameraZ(1)))
endfunction