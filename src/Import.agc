

function runImport()
	global spec as integer
	spec=LoadShader("/media/shaders/specular/spec.vs","/media/shaders/specular/spec.ps")
	global obj as objectType[]
    global LoadedImages as loadedimagestype []
    global Dir as dirtype []
    global TempDir as dirtype
	global path as string
	global light as lighttype []
	global ImportScale as float
	ImportScale=1
	GLOBAL importOffset as float
	importOffset=512
	
	
	path="raw:"+getreadpath()+"media/"
	FileDiscovery("textures")
	loadLevel()
	t as lightType
	t.name="null"
	light.insert(t)
Endfunction

type loadedImagesType
	ImageName as string
	ImageID as integer
endtype

type ObjectType
	Name as string
	ID as integer
	rot as vec3
	pos as vec3
	textName as string[]
	meshTexture as meshTextureType
	textId as integer[]
endtype

type meshTextureType
	primary as integer []
	secondary as integer []
	normal as integer[]
endtype



type lighttype
	number as integer
	kind as string
	name as string
	px as float
	py as float
	pz as float
	rx as float
	ry as float
	rz as float
	col as integer
	range as float
endtype





function loadLevel()
	local num as integer
	local data$ as string
	local read as integer
	setfolder("")
	read=OpenToRead("\import.lls")
	setfolder("\media\objects")
	local eof as integer
	eof=-1
	while FileEOF(read) = 0 
		data$=readline(read)
		`if data$="//END" 
			` exitfunction
			`endif
		
		num=countstringtokens(data$,":")
		if num>0
			if GetStringToken(data$,":",1)="Type"
				if GetStringToken(data$,":",2)="MESH"
					 loadobj(read)
				endif
				if GetStringToken(data$,":",2)="LAMP" then loadLamp(read)
			endif
		endif
	endwhile
	`Textureobjects()
endfunction

function loadobj(read)
	local data$ as string
	local objid as integer
	local mesh as integer
	local i as integer
	local r as integer
	local g as integer
	local b as integer
	local str$ as string
	local textID as integer
	local load2 as integer
	local name$ as string
	setfolder("\media\objects")
	t as objecttype
	obj.insert(t)
	objid=obj.length
	data$=readline(read)
	obj[objid].name=getstringtoken(data$,":",2)
	obj[objid].id=LoadObject(obj[objid].name+".fbx")
	global reflect as integer[]
	reflect.insert(obj[objid].id)
	setobjectscale(obj[objid].id,0.002,.002,.002)
	SetObjectCullMode(obj[objid].id,0)
	SetObjectCastShadow(obj[objid].id,1)
	SetObjectReceiveShadow(obj[objid].id,1)
	readline(read)
	data$=readline(read):obj[objid].rot.x=val(getstringtoken2(data$,":",2))
	data$=readline(read):obj[objid].rot.y=val(getstringtoken2(data$,":",2))
	data$=readline(read):obj[objid].rot.z=val(getstringtoken2(data$,":",2))
	local scale# as float
	scale#=10
	
	data$=readline(read)
	data$=readline(read):obj[objid].pos.x=val(getstringtoken2(data$,":",2))
	data$=readline(read):obj[objid].pos.y=val(getstringtoken2(data$,":",2))
	data$=readline(read):obj[objid].pos.z=val(getstringtoken2(data$,":",2))
	SetObjectPosition(obj[objid].id,obj[objid].pos.x*scale#,obj[objid].pos.y*scale#,obj[objid].pos.z*scale#)
	setobjectscale(obj[objid].id,1,1,1)
	
mesh=0
	for i = 0 to 30
		if data$="//END" then exitfunction
		data$=readline(read)
		if data$="//Material Color RGB"
			
			data$=readline(read)
			r=val(GetStringToken(data$,":",1))
			g=val(GetStringToken(data$,":",1))
			b=val(GetStringToken(data$,":",1))
			data$=readline(read)
		endif
		
		
		
		
			if GetStringToken(data$,":",1)="Texture"
				 name$=GetStringToken(data$,":",2)
				 str$=GetStringToken(data$,":",3)
				 if left(str$,6)="second" then load2=1
				 if left(str$,6)="normal" then load2=2
				 
				 if load2 >0
				 	 textid=LoadImages(name$)
				 endif
				 
				 if load2 < 1
				 	  textid=LoadImages(name$)
				  endif
				  SetShaderConstantByName(spec,"WaterAlpha", 0.6, 0.0, 0.0, 0.0)
				  SetShaderConstantByName(spec, "GlassSpecularBoost", 16.0, 0.0, 0.0, 0.0) // 2x specularity
					SetShaderConstantByName(spec, "DiffuseBrightness", 1.2, 0.0, 0.0, 0.0) // Half brightness

	
				 if load2 < 1
				 	inc mesh,1
				 	obj[objid].textid.insert(textid)
					if GetObjectNumMeshes(obj[objid].id) < 1 
						 `setobjectimage(obj[objid].id,textid,0)
					else
						local glass as integer
						local tobj as integer
						local cnums as integer
						if mesh <=GetObjectNumMeshes(obj[objid].id) 
							SetObjectReceiveShadow(obj[objid].id,1)
							SetObjectcastShadow(obj[objid].id,1)
							if name$="color#glass.png" 
							setObjectTransparency(obj[objid].id,1)
					 	 	endif
						
					 	 	SetObjectmeshImage(obj[objid].id,mesh,textid,0)
					 	 	SetObjectmeshImage(obj[objid].id,mesh,textid,1)
					 	 	SetObjectMeshShader(obj[objid].id,mesh,spec)
					 	 	SetObjectMeshNormalMap(obj[objid].id,mesh,textid)
					 	 	`SetObjectTransparency(obj[objid].id,1)
					 	 	obj[objid].meshtexture.primary.insert(textid)
							`endif

						


					 	 	
					 	 	
					 	endif
					endif
				endif
				
				if load2=1
					if mesh =0  
						`SetObjectimage(obj[objid].id,textid,1)
						 load2=-1
					else
						if mesh <=GetObjectNumMeshes(obj[objid].id)
					 	 	SetObjectmeshimage(obj[objid].id,mesh,textid,1)
					 	 	obj[objid].meshtexture.secondary.insert(textid)
					 	endif
					endif
					load2=-1
				endif
				
				

				if load2=2
					if mesh =0  
						 `SetObjectNormalMap(obj[objid].id,textid)
					else
						if mesh <=GetObjectNumMeshes(obj[objid].id)
					 	 	SetObjectmeshnormalmap(obj[objid].id,mesh,textid)
					 	 	obj[objid].meshtexture.normal.insert(textid)
					 	endif
					endif
				endif
					load2=-1
				textid=-1
				name$=""
			str$=""
		endif
			
			

	next
endfunction

function loadlamp(read as integer)
	global globalpointlights 
	local data$ as string
	local name$ as string
	local c1 as integer
	local c2 as integer
	local c3 as integer
	local col$ as string
	local ry# as float 
	local rx# as float
	Local rz# as float
	local py# as float 
	local px# as float
	Local pz# as float
	local col as integer
	local range# as float
	local num as integer
	
	name$=getstringtoken(readline(read),":",2)
	readline(read) //rotline
	data$=readline(read):rx#=val(getstringtoken2(data$,":",2))
	data$=readline(read):ry#=val(getstringtoken2(data$,":",2))
	data$=readline(read):rz#=val(getstringtoken2(data$,":",2))
	readline(read)//pos
	
	data$=readline(read):px#=val(getstringtoken2(data$,":",2))
	data$=readline(read):py#=val(getstringtoken2(data$,":",2))
	data$=readline(read):pz#=val(getstringtoken2(data$,":",2))
	col$=readline(read)
	c1=val(getstringtoken(col$,":",1))
	c2=val(getstringtoken(col$,":",2))
	c3=val(getstringtoken(col$,":",3))
	col=makecolor(c1,c2,c3)
	range#=round( val(readline(read)))
	
	
	//make sun
	if left(name$,3)="sun" 
		SetSunActive(1)
		SetSunColor(c1,c2,c3)
		SetSunDirection(px#,py#,pz#)
	endif

	if lower(left(name$,5))="point" or left(name$,4) ="Lamp"
		inc globalpointlights ,1
		num=globalpointlights 
		CreatePointLight(num,px#,py#,pz#,range#,c1,c2,c3)
		setpointlightmode(num,2)
		t as lighttype
		t.px=px#:t.py=py#:t.pz=pz#
		t.rx=rx#:t.ry=ry#:t.rx=rx#
		t.name=name$
		t.col=makecolor(c1,c2,c2)
		t.range=range#:t.kind="point"
		t.number=num
		light.insert(t)
	endif
	
endfunction 






function Camera_controls()
	local x# as float
	local y# as float
	y#=mousemovey()
	x#=Mousemovex()
	if GetRawMouseLeftstate()=1
	RotateCameralocalX(1,y#/2)
	RotateCameraglobaly(1,x#/2)
	endif
	if GetRawKeystate(87)=1
		MoveCameraLocalZ(1,.2)
	endif
	if GetRawKeystate(83)=1
		MoveCameraLocalZ(1,-.2)
	endif
endfunction

function MousemoveX()
    local dx# as float
    dx# = GetRawMouseX() - OldMouseX#
    OldMouseX# = GetRawMouseX()
endfunction dx#
 
 
 
function MousemoveY()
    local dy# as float
	dy# = GetRawMouseY() - OldMouseY#
    OldMouseY# = GetRawMouseY()
 endfunction dy#
remstart
function TextureObjects()
	local found as integer
	local parent as integer
	local image1 as integer
	local image2 as integer
	 
	SetObjectUVScale (obj[i].id,1,1,1)
	setimagewrapu (Loadedimages[find].Imageid,1)
	setimagewrapv (Loadedimages[find].Imageid,1)
	if  found <=GetObjectNumMeshes(object[i].id)
		setobjectmeshimage(object[i].id,found,Loadedimages[find].Imageid,1)
	else
		if object[i].imageName.length =1
			parent=object[i].id
			image1=object[i].imageid[0]
			image2=object[i].imageid[1]
			ShaderFilter(parent,image1,image2)
		endif
	endif
lights()
endfunction
remend


	type dirtype
		DirName as string
		ImageName as string[]
		ImageID as integer[]
	endtype
	
	
	type TempDirtype
		DirName as string
	endtype
	




function FileDiscovery(directory$)
	local ID as integer 
	local i as integer
	local foldercount as integer 
	local folderName$ as string
	local folder as integer
	local newid as integer
	ID=OpenRawFolder(path+directory$) //open media folder search for folders
	foldercount=GetRawFolderNumFolders(id) //get num of folders inside
	for i = 0 to Foldercount-1 //find names of folders 
		FolderName$=GetRawFolderFolderName(id,i)
		folder=i// folder= array id technically
		if len(foldername$)>0
			Tempdir.DirName=foldername$ //fill temp type
			Dir.insert(tempdir)//inserttemp into  dir type (folder name)
		endif
		newid=OpenRawFolder(path+directory$+"/"+foldername$)
		FindFiles(folder,newid)
	next
endfunction

function FindFiles(folder,id)//raw folder id
	local Filecount as  integer
	local i as integer
	local FileName$ as string
	FileCount=GetRawFolderNumFiles(id)
	For i = 0 to FileCount-1
		FileName$=GetRawFolderFileName(id,i)
		If len(FileName$)>0
			dir[folder].ImageName.insert(Filename$) //fill temp type
		endif
	next
endfunction

function LoadImages(FileName$)
	local i as integer
	local found as integer
	local directory as integer
	local image as integer
	local images as integer
	found=0
	//loadimage into global image array dont load twice
	for i=0 to LoadedImages.length 
		
		if len(Loadedimages[i].ImageName)>-1
			if Loadedimages[i].imagename =Filename$
				found=i
				exit
			endif
		endif
	next
	
	`end
	`load image if not found
	if found =0
		if len(filename$)>1
			for directory=0 to dir.length 
				for image=0 to dir[directory].ImageName.length
					if dir[directory].ImageName[image]=filename$
						setfolder("/media")
						setfolder("Textures/")
						setfolder(dir[directory].DirName)
						images=loadimage(filename$)
						t as loadedimagestype
						t.imagename=filename$
						t.imageid=images
						loadedimages.insert(t)
						found=LoadedImages.length
						exitfunction images
					endif
				next
			next
		endif
		else 
			images=loadedimages[found].ImageID
	endif
	`print(filename$)
	`print(images)
	`print(loadedimages[found].ImageName)
	`sync()
	`sleep(2000)

Endfunction images

    