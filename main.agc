
// Project: AGK Coop 
#include "src/core.agc"
#include "src/networking.agc"
`#include "api.agc"
`#include "Gui_keybinds.agc"
`#include "shaders.agc"
#option_explicit

SetErrorMode(2):SetWindowTitle( "AGK Coop" ):SetWindowSize(1920,1080,0):setWindowAllowResize( 1 ) 
SetVirtualResolution( 1024, 768 ) // doesn't have to match the window
SetOrientationAllowed( 1, 1, 1, 1 ) // allow both portrait and landscape on mobile devices
SetSyncRate( 30, 0 ) // 30fps instead of 60 to save battery
SetScissor( 0,0,0,0 ):UseNewDefaultFonts( 1 )





do
	// example
	//Run_Game() //ref:from source filename
    //Run_Network()
    //Run_Api()
    //custom_sync()
    Sync()
loop
