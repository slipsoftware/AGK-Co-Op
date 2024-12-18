// File: waterShader.agc
// Created: 24-12-12

type water
	waterobj as integer
	waterNormal as integer
	ID as integer// shader id
	uvScale as float
	reflectionimage as integer
	renderSkip as integer
	RippleTimer# as float
	WaterEvent as integer
	startTimer# as float
	waterRender as integer
endtype

type sky
	skyshader as integer
	skyboxImage as integer
	skyplain as integer
	cloudshader as integer
	SkyBox as integer
	fogspr as integer
	fogimg as integer
	skyboxRender as integer
	waterspr as integer

	er as integer
	eg as integer
	eb as integer
endtype

function runClouds()
	if GetRawKeystate(82)=1 then inc tod# ,0.1
	local camerax# as float
	local cameray# as float
	local cameraz# as float
	`local time2# as float
	
	
	local  baseR as integer
	local baseg as integer
	local baseb as integer
	
	local factor# as float
	local er as integer
	local eb as integer
	local eg as integer
	
	`local tod# as float
	`tod#=engine.shader.sky.tod#

	baseR = 151
	baseG = 173
	baseB = 200
	if tod# >= 21.0 and tod# < 24.0
	    factor# = (tod# - 21.0) / 3.0  // Normalize 
	    er = baseR * factor#         
	    eg = baseG * factor#
	    eb = baseB * factor#
	endif
	
	if tod# > 12.0 and tod# < 15.0 
	    factor# = (15.0 - tod#) / 3.0  // Normalize 
	    er = baseR * factor#          
	    eg = baseG * factor#
	    eb = baseB * factor#
	endif
	
	if tod#>0.0 and tod# < 12.0
		eR = baseR
		eG = baseG
		eB = baseB
	endif
	if tod#<21.0 and tod# >15
		eR = 0
		eG = 0
		eB = 0
	endif
	
	engine.shader.sky.er=er
	engine.shader.sky.eg=eg
	engine.shader.sky.eb=eb
	
	
	if tod#>=24.0 then tod#=0.0
	
	timeOfDay = tod#
	
	SetShaderConstantByName(engine.shader.sky.cloudShader,"invertScene",0,0,0,0)
	SetShaderConstantByName(engine.shader.sky.cloudShader,"timeOfDay", tod#,0,0,0)
	
	SetShaderConstantByName(engine.shader.sky.cloudShader,"topColor",0.07,0.21,0.619,0.0)
	SetShaderConstantByName(engine.shader.sky.cloudShader, "bottomColor", 0.5,0.7,0.9, 0.0)
	local x as integer
	local z as integer
	x=ceil(getcamerax(1))
	z=ceil(getcameraz(1))
	
	
	

	cameraX# = GetCameraX(1)
	cameraY# = GetCameraY(1)
	cameraZ# = GetCameraZ(1)
	global t# as float
	t#=t#+.01
	ConvertTimeToSunDirection(tod#)
	SetShaderConstantByName(engine.shader.sky.cloudShader, "cameraPosition", cameraX#, cameray#, cameraZ#, 0)
	SetShaderConstantByName(engine.shader.sky.cloudShader,"time",timer()+120.0,0,0,0)
	SetShaderConstantByName(engine.shader.water.id, "CameraPos", cameraX#, cameray#, cameraZ#, 0)

	SetCameraRange(1,1,90000)
	RenderShadowMap()
	
	SetObjectImage(engine.shader.sky.skybox,engine.shader.sky.skyboximage,0)

	local tod2# as float
	global light# as float
		tod2#=tod#+5
	if tod2#>24 then tod2#= (tod2#-24)
	
	if tod2# >=5.0 and tod2# <= 7.0 then light#= (tod2#-5.0)/2.0
	if tod2#>=17.0 and tod2# <= 19.0 then light#=(tod2#-17.0)/2.0
	
	
	if tod2# < 5.0 or tod2# >17.0 then light#=0.0
	
	if tod2# >7.0 and tod2# < 17.0 then light#=1.0 
	
	
	
	
	
	
	SetCameraRange(1,1,90000)
	RenderShadowMap()
	if engine.shader.sky.skyshader=1
	SetObjectImage(engine.shader.sky.skybox,engine.shader.sky.skyboximage,0)
	endif
	`SetCameraRange(1,1,9000)
	
	RenderReflection(1,10)
	
	if engine.shader.sky.skyshader=1
	//render skyBox
	SetObjectVisible(engine.shader.sky.SkyBox,1)
	DrawObject(engine.shader.sky.SkyBox)
	SetObjectVisible(engine.shader.sky.SkyBox,0)
	
	endif
	`SetCameraRange(1,1,600)


endfunction




function shaderLoadSky()
	global tod# as float
	global timeofday as float
	timeofDay=12.0
	tod#=timeofDay-6.0
	engine.shader.sky.skyboxImage=CreateRenderImage(1024,1024,0,1)
	engine.shader.sky.skyplain=CreateObjectPlane(4000,4000)
	
	SetObjectPosition(engine.shader.sky.skyplain,0,1001,0)
	RotateObjectLocalx(engine.shader.sky.skyplain,90)
	SetDefaultWrapU(1):SetDefaultWrapV(1)
	//sky_


	local skybox as integer
	engine.shader.sky.skybox=loadobject("/media/shaders/clouds/sky13.obj")
	skybox= engine.shader.sky.skybox
	SetObjectFogMode(skybox,0)
	SetObjectUVScale(SkyBox,0,2,2)
	RotateObjectLocaly(skybox,90)
	SetObjectPosition(SkyBox,1,1000,299)
	SetObjectScale(SkyBox,4000,4000,4000)
	SetObjectCastShadow(SkyBox,0)
	SetObjectUVScale(skybox,0,1,1)
	SetObjectLightMode(skybox,0)
	//Clouds
	
	engine.shader.sky.cloudShader=LoadShader("/media/shaders/clouds/clouds.vs", "/media/shaders/clouds/clouds.ps")
	local cloudshader as integer
	cloudshader=engine.shader.sky.cloudShader
	engine.shader.sky.fogimg=LoadImage("/media/shaders/clouds/fog.png")
	engine.shader.sky.fogspr=createsprite(engine.shader.sky.fogimg)
	SetSpriteColorAlpha(engine.shader.sky.fogspr,100)
	SetSpriteColor(engine.shader.sky.fogspr,0,0,0,100)
	SetSpriteSize(engine.shader.sky.fogspr,1024,1024)
	SetSpriteShapeBox(engine.shader.sky.fogspr,0,0,0,0,0)
	SetSpriteTransparency(engine.shader.sky.fogspr,1)
	SetSpriteVisible(engine.shader.sky.fogspr,0)

	
	
	SetShaderConstantByName(cloudShader,"colorC",0.64, 0.64, 0.64,0)//highlight
	SetShaderConstantByName(cloudShader,"colorD",0, 0,0,1.0)//shadow
	SetShaderConstantByName(cloudShader,"colorB",1.0,1.0,1.0,0) //the clouds colour
	SetShaderConstantByName(cloudShader, "uvScale", 1,0,0,0) // Adjust the scale as neede
	SetShaderConstantByName(cloudShader, "speed", .02, 0.0, 0.0,0) // Grey color for contrast
		`SetShaderConstantByName(cloudShader, "speed", .11, 0.0, 0.0,0) // Grey color for contrast
	SetShaderConstantByName(cloudShader, "frequency", .01, 0.0, 0.0,0) // Grey color for contrast
	SetShaderConstantByName(cloudShader, "size", .001, 0.0, 0.0,0) // Grey color for contras
	SetShaderConstantByName(cloudShader, "density", 1.15, 0.0, 0.0,0)
	SetShaderConstantByName(cloudShader, "densityFactor",1.2,0,0,0)
	
	
	`tod#=0.50 //set start time
	SetShaderConstantByName(cloudShader, "fogDensity", .3, 0.0, 0.0, 0.0)  // Moderate fog density
	SetShaderConstantByName(cloudShader, "fogColor", 0.9,0.9, 0.9, 0)
	SetShaderConstantByName(cloudShader, "sunDirection", 0,0,0, 0.0)  // Sun coming from above
	SetShaderConstantByName(cloudShader, "sunColor", 1.0,0.9,0.40, 0.0)
	SetShaderConstantByName(cloudShader, "ambientLightColor", 0.1,0, 0, 0)
	SetShaderConstantByName(cloudShader, "textureSize", 1920,1080, 0, 0)
	SetShaderConstantByName(cloudShader, "starSize", .00001,0, 0, 0)
	SetShaderConstantByName(cloudShader, "sunSize", 6.5,0,0, 0)// this is reversed bigg=smaller














endfunction



function shaderLoadWater()


		


		//water
		engine.shader.water.waterobj=CreateObjectPlane(1024,1024)
		SetObjectDepthBias(engine.shader.water.waterobj,0.0)
		RotateObjectLocalX(engine.shader.water.waterobj,90)
		SetObjectPosition(engine.shader.water.waterobj,512,2,512)

		engine.shader.water.id=LoadShader("/media/shaders/water/water planar.vs", "/media/shaders/water/water planar.ps")
		engine.shader.water.waterNormal=LoadImage("/media/shaders/water/water normalmap.png")


		
		SetObjectShader(engine.shader.water.waterobj,engine.shader.water.ID)
		SetObjectImage(engine.shader.water.waterobj,engine.shader.water.waterNormal,0)
		SetObjectUVScale(engine.shader.water.waterobj,0,40,40)
		SetImageWrapU(engine.shader.water.waterNormal,1) : SetImageWrapV(engine.shader.water.waterNormal,1)
		
		SetObjectVisible(engine.shader.water.waterobj,1)
		SetObjectTransparency(engine.shader.water.waterobj,1)
		SetObjectAlpha(engine.shader.water.waterobj,190)
		
	
	engine.shader.water.reflectionimage=CreateRenderImage(1024,1024,0,1)
	
endfunction




function ReflectCameraPositionSimple(cameraID, waterY#)
	local originalX# as float
	local originalY# as float
	local originalZ# as float
	local oax# as float
	local oaY# as float
	local oaZ# as float
	local reflectY# as float
    // Get the original camera position
    originalX# = GetCameraX(cameraID)
    originalY# = GetCameraY(cameraID)
    originalZ# = GetCameraZ(cameraID)
    oax#=GetCameraAngleX(cameraID)
    oay#=GetCameraAngley(cameraID)
    oaz#=GetCameraAnglez(cameraID)
    // Calculate the reflected Y position
    reflectY# = -originalY#
	`reflectY#= originalY#*-1.0-waterY#
    // Set the camera to the reflected position
    SetCameraPosition(cameraID, originalX#, reflectY#, originalZ#)
    SetCamerarotation(cameraID,-oax#,oay#,oaz#)
endfunction








function RenderReflection(cameraID, waterY#)
	local camerax# as float
	local cameray# as float
	local cameraz# as float
	global time2# as float
	time2#=-0.8
	cameraX# = GetCameraX(1)
	cameraY# = GetCameraY(1)
	cameraZ# = GetCameraZ(1)
	SetShaderConstantByName(engine.shader.water.id, "LightColor", 1.0, 1.0, 1.0, 0)
	SetShaderConstantByName(engine.shader.water.id, "ambientColor",.5,.5,.5, 0)
	SetShaderConstantByName(engine.shader.water.id, "CameraPos", cameraX#, cameray#, cameraZ#, 0)
	SetShaderConstantByName(engine.shader.water.id, "Time", time2#, 0, 0, 0)
	local originalX# as float
	local originalY# as float
	local originalZ# as float
	local oax# as float
	local oaY# as float
	local oaZ# as float

	local skyx# as float
	local skyy# as float
	local skyz# as float
	
	
	local fogspr as integer
	fogspr=engine.shader.sky.fogspr
	
	
	local skyBoxRender as integer
	skyBoxRender=engine.shader.sky.skyBoxRender
	local skyBox as integer
	skybox=engine.shader.sky.skyBox
	local skyBoxImage as integer
	local water as integer
	water=engine.shader.water.id
	
	skyBoxImage=engine.shader.sky.skyBoxImage
	
		originalX# = GetCameraX(cameraID)
    originalY# = GetCameraY(cameraID)
    originalZ# = GetCameraZ(cameraID)
    oax#=GetCameraAngleX(cameraID)
    oay#=GetCameraAngley(cameraID)
    oaz#=GetCameraAnglez(cameraID)
    SetObjectVisible(SkyBox,1)
    
	inc skyboxRender,1
	`if skyboxRender >= ScreenFPS()/10.0
		SetObjectVisible(engine.shader.water.waterobj,0)
		SetObjectVisible(engine.shader.sky.skyplain,1)
		skyx#=(GetObjectSizeMinX(skybox)-GetObjectSizeMinX(skybox))/2.0
		skyY#=(GetObjectSizeMiny(skybox)-GetObjectSizeMiny(skybox))/2.0
		skyz#=(GetObjectSizeMinz(skybox)-GetObjectSizeMinz(skybox))/2.0
		SetCameraPosition(1,skyx#,skyy#-1800,skyz#)
		SetCameraLookAt(1,skyx#,skyy#+5000,skyz#,0)
		SetRenderToImage(skyboximage,0)
		clearscreen()
		`if getstate(gui.scene.skyshaderBool)=1
		setobjectshader(engine.shader.sky.skyplain,engine.shader.sky.cloudshader)
		`endif
		DrawObject(engine.shader.sky.skyplain)
		SetSpriteVisible(engine.shader.sky.fogspr,1)
		setspritecolor(engine.shader.sky.fogspr,engine.shader.sky.er,engine.shader.sky.eg,engine.shader.sky.eb,255)
		SetSpriteSize(fogspr,GetWindowWidth(),GetWindowHeight())
   		DrawSprite(fogspr)
    		SetSpriteVisible(engine.shader.sky.fogspr,0)
		setobjectshader(engine.shader.sky.skyplain,0)
		SetObjectVisible(engine.shader.sky.skyplain,0)
		`SetSpriteImage(watersp,skyboximage)
		`SetObjectImage(skybox,skyboximage,0)
		skyboxRender=0
		if engine.shader.water.waterRender <=1 //reset camera since  water loop will miss it this Cycl
		    SetCameraPosition(cameraID, originalX#, originalY#, originalZ#)
    		SetCameraRotation(cameraID,oax#,oay#,oaz#)
    		SetObjectVisible(engine.shader.water.waterobj,1)
    	endif
	`endif
	
	`setobjec


inc engine.shader.water.waterRender,1
`if engine.shader.water.waterRender >1  //skipping doubles frame rate max skip 3 frames per 60 or gets choppy
	
	SetObjectVisible(skybox,1)
	`SetCameraRange(1,.01,9000)
	SetCameraPosition(cameraID, originalX#, originalY#, originalZ#)
    SetCameraRotation(cameraID,oax#,oay#,oaz#)
    ReflectCameraPositionSimple(cameraID, waterY#)
	SetRenderToImage(engine.shader.water.reflectionimage, 0) 
    ClearScreen()
    DrawObject(skybox) 
    local i as integer
    for i =0 to reflect.length
    	drawobject(reflect[i])
    next
    
    
	`drawobject(box)
   ` getobject
	  ` for i = 100000 to 100256`draw reflections range based, need to add to shader and skip frame?
	   `	if GetObjectExists(i)=1
	   		`if Distance3d(0,i) < 100.0 and i<> waterobj and i <> skybox and i <> skyplain
	   			`drawobject(i)
	   		`endif
	   `	endif
	  ` next
    // Reset camera
    SetCameraPosition(cameraID, originalX#, originalY#, originalZ#)
    SetCameraRotation(cameraID,oax#,oay#,oaz#)

    // Apply the reflection
    SetObjectImage(engine.shader.water.waterObj, engine.shader.water.waterNormal, 0) // Normal map or base texture
    SetObjectImage(engine.shader.water.waterObj, engine.shader.water.reflectionimage, 1) // Reflection texture
    SetObjectImage(engine.shader.water.waterObj, engine.shader.water.reflectionimage, 2) // Another layer if needed
	
    SetShaderConstantByName(Water, "ReflectColor", 1, 1, 1, 0)
    SetShaderConstantByName(Water, "RefractColor", .9, .9, .9, 0)
    SetShaderConstantByName(Water, "AmbientColor", 0.5, 0.5, 0.5, 0)
    SetShaderConstantByName(spec, "AmbientColor", 0.5, 0.5, 0.5, 0)
    SetShaderConstantByName(Water, "LightColor", 1.0, 1.0, .9, 0)
     SetShaderConstantByName(spec, "LightColor", .50, .50, 0.5, 0)
    SetShaderConstantByName(Water, "Heightvec", .4, 0, 0, 0)
   SetShaderConstantByName(Water, "texture0", engine.shader.water.waterNormal, 0, 0, 0)
    `SetShaderConstantByName(Water, "texture1", engine.shader.water.reflectionimage, 0, 0, 0)
    `SetShaderConstantByName(Water, "texture2", engine.shader.water.reflectionimage, 0, 0, 0)
    
    SetShaderConstantByName(Water, "WaterAlpha", .9, 0, 0, 0)//was .80
     ` SetShaderConstantByName(spec, "WaterAlpha", .9, 0, 0, 0)//was .80
  	SetObjectReceiveShadow(water,1)
   //set constants
    engine.shader.water.UvScale=engine.shader.water.UvScale+.004
  	SetShaderConstantByName(Water, "UvScroll", engine.shader.water.uvscale* 0.8  , 0, 0, 0)
  	engine.shader.water.waterRender=0
  `endif
    SetRenderToScreen()
endfunction




function ConvertTimeToSunDirection(hourOfDay as float)
	local hod# as float 
	local pi# as float
	local sX# as float
	local sY# as float
	local sZ# as float
	
hod#=hourofday+6.0
if hod#>24.0 then hod#=hod#-24.0
	// Ensure hourOfDay is within 0-24 range hourOfDay = Mod(hourOfDay, 24.0)
	pi#=3.14159265

	local angleRad as float
	angleRad = (hod# / 24.0) * 2.0 * pi#

	local sunX as float
	local suny as float
	
	sunX = Sin(angleRad * 180.0 / pi#)
	sunY = Cos(angleRad * 180.0 / pi#)
	sx# = sunX*-1
	sy# = sunY
	sz# = -0.5 
	SetSunDirection(sx#,sy#,sz#) 
	SetShaderConstantByName(engine.shader.Water.ID, "LightDirection",sx#,sy#,sz#,0)
	SetShaderConstantByName(spec, "LightDirection",sx#,sy#,sz#,0)
	`SetShaderConstantByName(Engine.Globals.GrassShaderID,"lightPosition",sx#,sy#,sz#,0)
endfunction 