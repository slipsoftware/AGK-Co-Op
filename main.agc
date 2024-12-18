// Project: AGK Co-op 
#option_explicit

SetErrorMode(0)
SetWindowTitle( "AGK Coop" ):SetWindowSize(1920,1080,0):setWindowAllowResize( 1 ) 
SetVirtualResolution( 1920, 1080 ) // doesn't have to match the window
SetOrientationAllowed( 1, 1, 1, 1 ) // allow both portrait and landscape on mobile devices
SetSyncRate( 60, 0 ) // 30fps instead of 60 to save battery
SetScissor( 0,0,0,0 ):UseNewDefaultFonts( 1 )
SetSunActive(1):SetAmbientColor(55,55,55):SetCameraRange(1,1,1000)
SetGenerateMipmaps(1)
setAntialiasMode(1)
SetGlobal3DDepth(2000)
SetShadowMappingMode(2)
SetShadowMapSize(1024,1024)
SetShadowRange(300)
SetShadowSmoothing(1)
setsuncolor(255,255,245)
SetSunDirection(0,0,0)
SetClearColor(75,75,155)
sync()

`#Renderer "Basic"




#include "src/core.agc"
#include "testScene.agc"
`#include "src/networking.agc"
`#include "src/navigation.agc"
`#include "src/api.agc"
`#include "src/Gui_keybinds.agc"
`#include "src/shaders.agc"
`#include "src/LoadObject.agc"
#include "src/camera_Control.agc"
`#include "UserInput.agc"
#include "src/import.agc"
`#include "src/engineTerrain.agc"
local t as integer
local t1 as integer
global engine as engineType
#include "watershader.agc"
shaderLoadSky()
shaderLoadWater()
local cube as integer
global a as integer
global b as integer

`cube=LoadObject("/media/objects/cube.002.fbx")
`a=LoadImage("/media/textures/bulk/d.png")
`b=LoadImage("/media/textures/bulk/a.png")
`SetObjectImage(cube,b,0)
`SetObjectMeshImage(cube,1,a,0)
`SetObjectMeshImage(cube,2,b,0)

t1=LoadImage("/media/terrain/resources/moss.JPG")
SetImageWrapU(t1,1)
SetImageWrapV(t1,1)

t=CreateObjectFromHeightMap("/media/terrain/terrain11.png",1024,20,1024,20,1)

SetObjectImage(t,t1,0)
SetObjectUVScale(t,0,30.5,30.5)


#include "src/import.agc"
`runImport()
global cam as cam // from camera prolly shaders will access or replace
global OldMouseY# // from import will need to be combined
global OldMouseX#
#constant key_ESC =27
//Init variables
load_Camera()
runImport()


function TestingCode()
	//"toggle me for unfinished code")
	if GetRawKeyPressed(key_ESC)=1 then end
	LoadTestScene()
	Debug()
	Camera() //from camera.agc
endfunction






SetRawMouseVisible(0)
do	
	 //for complete features
	
	TestingCode()
	
	runClouds()
	
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


