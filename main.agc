// Project: AGK Co-op 
#option_explicit
SetErrorMode(2)
SetWindowTitle( "AGK Coop" ):SetWindowSize(1920,1080,0):setWindowAllowResize( 1 ) 
SetVirtualResolution( 1920, 1080 ) // doesn't have to match the window
SetOrientationAllowed( 1, 1, 1, 1 ) // allow both portrait and landscape on mobile devices
SetSyncRate( 30, 0 ) // 30fps instead of 60 to save battery
SetScissor( 0,0,0,0 ):UseNewDefaultFonts( 1 )
SetSunActive(1):SetAmbientColor(155,155,155):SetCameraRange(1,.01,1000)



#include "src/core.agc"
`#include "src/networking.agc"
`#include "src/navigation.agc"
`#include "src/api.agc"
`#include "src/Gui_keybinds.agc"
`#include "src/shaders.agc"
`#include "src/LoadObject.agc"
#include "src/camera_Control.agc"
`#include "UserInput.agc"
#include "src/import.agc"

#include "src/import.agc"
runImport()
global cam as cam // from camera prolly shaders will access or replace
global OldMouseY# // from import will need to be combined
global OldMouseX#
global cam as cam // from camera prolly shaders will access or replace
global OldMouseY# // from import will need to be combined
global OldMouseX#
//Init variables
load_Camera()
runImport()


function TestingCode()
	Print("toggle me for unfinished code")
	if GetRawKeyPressed(27)=1 then end
	Debug()
	Camera() //from camera.agc
endfunction






SetRawMouseVisible(0)
do	
	
	 //for complete features
	TestingCode()
    Sync()
loop


function Debug()
	SetPrintSize(25)
	SetPrintColor(0,255,255)
	Print("fps: "+str(ScreenFPS()))
	print("camX:"+str(getcamerax(1)))
	print("camY:"+str(getcameraY(1)))
	print("camZ:"+str(getcameraZ(1)))
endfunction


