// Project: AGK Co-op 
#option_explicit
SetErrorMode(2)
SetWindowTitle( "AGK Coop" )
SetWindowSize(1920,1080,0)
setWindowAllowResize( 1 ) 
SetVirtualResolution(100, 100 ) // doesn't have to match the window
SetOrientationAllowed( 1, 1, 1, 1 ) // allow both portrait and landscape on mobile devices
SetSyncRate( 30, 0 ) // 30fps instead of 60 to save battery
SetScissor( 0,0,0,0 )
UseNewDefaultFonts( 1 )
SetSunActive(1)
SetAmbientColor(155,155,155)
SetCameraRange(1,1,1000)


#include "src/core.agc"
#include "src/networking.agc"
`#include "src/navigation.agc"
`#include "src/api.agc"
`#include "src/Gui_keybinds.agc"
`#include "src/shaders.agc"
`#include "src/LoadObject.agc"
#include "src/camera_Control.agc"
#include "src/input.agc"
//~#include "src/import.agc"
#include "src/menu.agc"
#include "src/game.agc"


//Init variables
load_Camera()
//~runImport()

Menu_Init()
end





