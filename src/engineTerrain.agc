type majorType
	ObjectID as integer
	height as float
	TerrainHmapName as string
	SplatmapID as integer

	MemblockSplat as integer
	splatMem as integer
	HeightMap as integer
	MemblockHeight as integer //
	index as indextype [255] `chunks majors into minors
	newsplat as integer
endtype	
	
	
	
type Terrain
	Divisions as integer
	guiLoaded as integer // flag after assets are loaded
//major=full terrain tile
	major as majortype[]
	majorTileSize as float
	terrainGenImage as integer
//terrain generation shader
	GenerateShader as integer
	ShaderImage as integer
	terrainsprite as integer
//render Images
	HeightPrevRenderImage as integer
	HeightNextRenderImage as integer
	SplatPrevRenderImage as integer
	SplatNextRenderImage as integer
	
	// water
	waterHeight as float
	WaterObjID as integer
	TextureID as integer
	// tagetObject
	PointerObject as integer
	width as integer
	highlight as integer
	
	//images
	textureBtn0 as integer
	textureBtn1 as integer
	textureBtn2 as integer
	textureBtn3 as integer
	textureBtn4 as integer
	
	Deftexture as integer [4]

	xImage as integer
	SplatmapImage as integer
	//brush
	
	BrushImage as integer
	BrushSprite as integer
	brushWidth as integer
	brushobject as integer

	oldSelectTerrainObj as integer
	NewSelectTerrainObj as integer
	
endtype

type indextype
	objID as integer
	
	t0 as integer 
	t1 as integer 
	t2 as integer
	t3 as integer
	t4 as integer
endtype
	
	

	
	
	
	
	
	
	
	
function loadTerrain(name as string)
global terrain as terrain
global indextype as indextype

	
	
local col as integer
local row as integer
local nums$ as string
local numPNG$ as string
local fileNames$ as integer
local folder as integer
local raw$ as string
local filename$ as string
local i as integer

folder=OpenRawFolder("raw:" + GetReadPath()+"media/terrain")
raw$="raw:" + GetReadPath()+"media/terrain"
for i = 0 to GetRawFolderNumFiles(folder)-1
	`CreatesplatImage(major.HeightMap)
	filename$=GetRawFolderFileName(folder,i)
	if left(filename$,7)="terrain" 
		if right(filename$,3)="png"

			majorTile as majortype
			majorTile.TerrainHmapName=raw$+"/"+filename$
			majorTile.HeightMap=loadimage(raw$+"/"+filename$)
			majorTile.splatmapid =loadimage(raw$+"/"+"splat"+right(filename$,6))
				`majorTile.splatMapID=loadimage(raw$+"/"+filename$)
			//get row/col from filename
			numpng$=right(filename$,6)
			nums$=left(numpng$,2)
			col=val(left(nums$,1))
			row=val(right(nums$,1))
			terrain.major.insert(majorTile)
		endif
	endif
next
	
load_Terrain()
endfunction



function load_Terrain()
	sync()
	local quaid as integer
	local quaid2 as integer
	terrain.HeightPrevRenderImage=CreateRenderImage(1024,1024,0,1)
	quadid=CreateObjectQuad()
	quadid2=CreateObjectQuad()
	CreateText(2,"")
	if terrain.guiLoaded=0
		global lastSelectedTile
		global quadID
		global quadID2
		global MinorIndex as integer
		global fakesprite
		Terrain.Divisions=16
		terrain.width=1024
		
		`SP_Init()
		`SP_SetReadRawFiles(1)
		SetDefaultWrapU(1):SetDefaultWrapV(1)
	
		
		setimagewrapu(terrain.DefTexture[0],1):setimagewrapV(terrain.DefTexture[0],1)
		setimagewrapu(terrain.DefTexture[1],1):setimagewrapV(terrain.DefTexture[1],1)
		setimagewrapu(terrain.DefTexture[2],1):setimagewrapV(terrain.DefTexture[2],1)
		setimagewrapu(terrain.DefTexture[3],1):setimagewrapV(terrain.DefTexture[3],1)
		setimagewrapu(terrain.DefTexture[4],1):setimagewrapV(terrain.DefTexture[4],1)

		setfolder("/media/Terrain/resources")
		if GetImageExists(terrain.DefTexture[0])=0
			terrain.DefTexture[0]=Loadimage("dirt.png")
			terrain.DefTexture[1]=Loadimage("rock height.png")
			terrain.DefTexture[2]=Loadimage("grass height.png")
			`terrain.DefTexture[3]=Loadimage("stone.jpg")
			terrain.DefTexture[3]=Loadimage("color_yellow.png")
			`terrain.DefTexture[4]=Loadimage("sand height.png")
			terrain.DefTexture[4]=Loadimage("color_red.png")
		endif
		terrain.textureBtn0=terrain.Deftexture[0]
		terrain.textureBtn1=terrain.Deftexture[1]
		terrain.textureBtn2=terrain.Deftexture[2]
		terrain.textureBtn3=terrain.Deftexture[3]
		terrain.textureBtn4=terrain.Deftexture[4]
		terrain.major[0].height=120.0
		if GetMemblockExists(terrain.major[0].MemblockSplat)=1
			 DeleteMemblock(terrain.major[0].MemblockSplat)
			 DeleteMemblock(terrain.major[0].HeightMap)
		endif
		
		
		terrain.major[0].MemblockSplat = CreateMemblockFromImage(terrain.major[0].splatMapID)
		terrain.major[0].MemblockHeight = CreateMemblockFromImage(terrain.major[0].HeightMap)

		`SetCameraPosition(1,20,getobjecty(terrain.major[0].objectid) +terrain.major[0].height,20)
		terrain.guiLoaded=1
	endif
	
	
	
	

	`create terrain pointer
	if GetObjectExists(Terrain.PointerObject)=0
		Terrain.PointerObject=CreateObjectSphere(.1,16,16)
		SetObjectColor(Terrain.PointerObject,255,0,0,0)
		SetObjectCollisionMode(Terrain.PointerObject,0)
	endif

	if GetSpriteExists(Terrain.BrushSprite)=0
		Terrain.BrushSprite=CreateSprite(terrain.brushImage)
	endif
	SetSpriteSize(Terrain.brushsprite,12,12)
	SetObjectImage(QuadID,terrain.major[0].HeightMap,0)
	ClearScreen()
	SetRenderToImage(terrain.HeightPrevRenderImage,0)
	SetObjectImage(quadid2,terrain.major[0].splatMapID,0)
	DrawObject(QuadID)
	SetRenderToScreen()
	local splatPrevRenderImage as integer
	splatPrevRenderImage=terrain.major[0].splatMapID
	terrain.major[0].newsplat=terrain.major[0].SplatmapID
	
	
	//initialise starting poss for terrain blocks
	if GetMemblockExists(terrain.major[0].splatmem)=0
		terrain.major[0].splatmem=CreateMemblockFromImage(terrain.major[0].splatMapID)//dont move below loop
	endif
	local t as indextype
	terrain.major[0].newsplat=terrain.major[0].splatMapID
	local i as integer
	for i = 0 to 255//preset textures for minor tiles
		t.t0=terrain.Deftexture[0]
		t.t1=terrain.Deftexture[1]
		t.t2=terrain.Deftexture[2]
		t.t3=terrain.Deftexture[3]
		t.t4=terrain.Deftexture[4]
		terrain.major[0].index[i]=t
	next

	
	local c as integer
	local r as integer
	
	
	r=0
	c=-1
	
	for i = 0 to 16*16	-1
		inc c ,1
		if c=16
			c=0
			inc r,1
		endif
		`SetCameraLookAt(1,0,120,0,180)
		CopyCellToNewMemblock(0,i,terrain.major[0].MemblockHeight ,r,c)//generate minor tiles from heightmap
		SetTextString(1,"Generating Tiles: ("+str(i)+")")
	
			`SP_ControlCamera()
		
		sync()
		if r=16 then exit
		SetObjectUVGrid(0,i,r,c)//update textures
	NEXT
	SetTextString(1,"")
	SetClearColor(178,204,229)
	fakeSprite=CreateObjectBox(1,.01,1)
	SetObjectShapeBox(fakesprite,0,0,0)
	SetObjectCollisionMode(fakesprite,0)

endfunction

function CopyCellToNewMemblock(majorTile,Minorindex,sourceMemblockID,x,y)
	local cellWidth as integer
	local cellHeight as integer
	local sourceHeight as integer
	local sourceWidth as integer
	local newMemblockId as integer
	local startPosition as integer
	local objectId as integer 
	local colq as integer
	local rowQ as integer
	local sourcePosition as integer
	local byteValue as integer

        cellWidth = 64:cellHeight = 64
    sourceWidth = 1024:sourceHeight = 1024
    // The startPosition calculation is adjusted to step by 128 but grab 129 pixels
    startPosition = 12 + (((x * (cellHeight - 1)) * sourceWidth) + (y * (cellWidth - 1))) * 4
    newMemblockID = CreateMemblock(cellWidth * cellHeight * 4 + 12)

    SetMemblockInt(newMemblockID, 0, cellWidth)
    SetMemblockInt(newMemblockID, 4, cellHeight)
    SetMemblockInt(newMemblockID, 8, 32) // Assuming 32-bit depth (RGBA)
	local i as integer
    for rowq = 0 to cellHeight - 1
        for colq = 0 to cellWidth 
            sourcePosition = startPosition + ((rowq * sourceWidth + colq) * 4)
           if Sourceposition >= 0 and Sourceposition < GetMemblockSize(sourceMemblockID)
                for i = 0 to 3
                    byteValue = GetMemblockByte(sourceMemblockID, sourcePosition + i)
                    if 12 + ((rowq * cellWidth + colq) * 4) + i  <= GetMemblockSize(sourceMemblockID)
                    		SetMemblockByte(newMemblockID, 12 + ((rowq * cellWidth + colq) * 4) + i, byteValue)
                    endif
                next
            endif
        next
    next
		local tempImage as integer
		local posy# as float
	
	
    		TempImage = CreateImageFromMemblock(newMemblockID)
   		objectID=terrain.major[majorTile].index[MinorIndex].objID
		posy#=getobjectworldy(objectID)
		deleteobject(objectID)
	
		iDex as indextype
		iDex=Terrain.major[majorTile].index[Minorindex]
		SaveImage(TempImage,"raw:"+GetReadPath()+"temp/blue.png")
		DeleteImage(tempimage)
		DeleteMemblock(newmemblockid)

objectID=CreateObjectFromHeightMap ("raw:"+GetReadPath()+"temp/blue.png",64.0,terrain.major[0].height,64.0,0,1)
    		SetObjectCullMode(objectID,0)
    		SetObjectCollisionMode(objectID,1)
    		SetObjectLightMode(objectID,2)
     	SetObjectPosition(objectID, (y*64.0)   ,posy#,1024-(x+1) *64.0)
     	SetObjectReceiveShadow(objectID,1)
    		terrain.major[majortile].index[minorindex].objid=objectID
    		`SP_Terrain_AddObject(objectID,iDex.t0,iDex.t1,iDex.t2,iDex.t3,iDex.t4,terrain.major[majorTile].newsplat,0) //Height Blend last param set to 0
     	`SP_Terrain_SetHeightBlending(objectID,.1,.1,.1,.1) // set the blending depth for each texture channel independently
endfunction

function SetObjectUVGrid(majorTile,index,y,x)
	local objectID as integer
	local uvStepSize# as float
	local uvOffsetU# as float
	local uvOffsetV# as float
	local terrainSize# as float
	objectid=terrain.major[majorTile].index[index].objid
    // Calculate UV step size
    uvStepSize# = 1.0 /16
    // UV offsets
    uvOffsetU# = x * uvStepSize#
    uvOffsetV# = y * uvStepSize#
    
    // Set the UV offset and scale for each texture stage
   	terrainSize#=16.0
    SetObjectUVScale(objectID,5,1.0/terrainSize#,1.0/terrainSize#) 
    SetObjectUVOffset(objectID,5, uvOffsetU#, uvOffsetV#)
 
    SetObjectUVScale(objectID,0,1,1) // scale the rock texture stage 1
    SetObjectUVScale(objectID,1,1,1) // scale the rock texture stage 1
    SetObjectUVScale(objectID,2,1,1) // scale the rock texture stage 1
    SetObjectUVScale(objectID,3,1,1) // scale the rock texture stage 1
    SetObjectUVScale(objectID,4,1,1) // scale the rock texture stage 1
endfunction