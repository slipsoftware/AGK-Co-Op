// Project: AGK Co-op 
#option_explicit

SetErrorMode(2)
SetWindowTitle( "AGK Coop" )
SetWindowSize(1920,1080,0)
setWindowAllowResize( 1 ) 
SetVirtualResolution(100, 100 ) // doesn't have to match the window
SetOrientationAllowed( 1, 1, 1, 1 ) // allow both portrait and landscape on mobile devices
SetSyncRate( 60, 0 ) // 30fps instead of 60 to save battery
SetScissor( 0,0,0,0 )
UseNewDefaultFonts( 1 )
SetSunActive(1)
SetAmbientColor(155,155,155)
SetCameraRange(1,1,1000)
SetClearColor(23,64,128)
SetSoundDeviceMode(1)

// #include "src/navigation.agc"
// #include "src/api.agc"
// #include "src/Gui_keybinds.agc"
// #include "src/shaders.agc"
// #include "src/LoadObject.agc"
// #include "src/import.agc"
#include "src/Core.agc"
#include "src/Sound3D.agc"
#include "src/Network.agc"
#include "src/Camera.agc"
#include "src/Input.agc"
#include "src/Menu.agc"
#include "src/Game.agc"


// Init variables
local ReadPath$ as string
ReadPath$=GetReadPath()
Input_Init(9, 3, 300, ReadPath$+"media/settings/keybindings.ini")

Menu_Init()
end





