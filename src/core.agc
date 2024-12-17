// File: core.agc
// Created: 24-11-28

remstart
type ObjectType
	ID as integer
	kind as string
	Name as string
	Media
	Pos as Vec3
	Rot as Vec3
	Scale as Vec3
	Color as integer
	Texture as TextureType
	Text as integer
	Children as integer []
	Mesh as meshType []
	Range as float
	ShaderID as integer
	Specular as float
	Emissive as float
	Diffuse as float
	UVscrollSpeed as float
endtype

type Meshtype
	Texture as TextureType [7]
	Shader as string
	Uscale as float
	VScale as float
endtype

type TextureType
	ID as integer
	Name as String
	Path as string
endtype
remend
type Vec3
	X as float
	Y as float
	Z as float
endtype

type Core_Vec3Data
    X# as float
    Y# as float
    Z# as float
endtype
 
type Core_Vec2Data
    X# as float
    Y# as float
endtype
 
type Core_ColorData
    Red as integer
    Green as integer
    Blue as integer
    Alpha as integer
endtype
 
type Core_Int3Data
    X as integer
    Y as integer
    Z as integer
endtype
 
type Core_Int2Data
    X as integer
    Y as integer
endtype

function Core_GetPointer3D(pointer as Core_Vec2Data)
	pointer3D as Core_Vec3Data
 	pointer3D.X#=Get3DVectorXFromScreen(pointer.X#,pointer.Y#)
	pointer3D.Y#=Get3DVectorYFromScreen(pointer.X#,pointer.Y#)
	pointer3D.Z#=Get3DVectorZFromScreen(pointer.X#,pointer.Y#)
endfunction pointer3D

function Core_GetAngleBetween(start as Core_Vec2Data, stop as Core_Vec2Data)
	local angle# as float
	dist as Core_Vec2Data
	dist.X#=stop.X#-start.X#
	dist.Y#=stop.Y#-start.Y#
	angle#=atanfull(dist.X#,-dist.Y#)
endfunction angle#

function Core_CurveValue(current# as float, destination# as float, speed# as float)
    local diff# as float
    if speed#<1.0 then speed#=1.0
    diff#=destination#-current#
    current#=current#+(diff#/speed#)
endfunction current#
 
function Core_CurveAngle(current# as float, destination# as float, speed# as float)

    local diff# as float
    if speed#<1.0 then speed#=1.0
    destination#=Core_WrapAngle(destination#)
    current#=Core_WrapAngle(current#)
    diff#=destination#-current#
    if diff#<-180.0 then diff#=(destination#+360.0)-current#
    if diff#>180.0 then diff#= destination#-(current#+360.0)
    current#=current#+(diff#/speed#)
    current#=Core_WrapAngle(current#)
endfunction current#

function Core_WrapAngle(angle# as float)
    if angle#=>0
        angle#=fmod(angle#,360.0)
    else
        angle#=360.0+fmod(angle#,-360.0)
    endif
endfunction angle#
 
function Core_ManhattanDistance2D(startX,startY,endX,endY)
	local distx as integer
	local disty as integer
	local distz as integer
	local dist as integer
    distX=abs(endX-startX)
    distY=abs(endY-startY)
    dist=distX+distY
endfunction dist
 
function Core_Distance2D(startX#,startY#,endX#,endY#)
	local distx# as float
	local disty# as float
	local distz# as float
	local dist# as float
    distX#=endX#-startX#
    distY#=endY#-startY#
    dist#=sqrt(distX#*distX#+distY#*distY#)
endfunction dist#
 
function Core_Distance3D(startX#,startY#,startZ#,endX#,endY#,endZ#)
	local distx# as float
	local disty# as float
	local distz# as float
	local dist# as float
    distX#=endX#-startX#
    distY#=endY#-startY#
    distZ#=endZ#-startZ#
    dist#=sqrt(distX#*distX#+distY#*distY#+distZ#*distZ#)
endfunction dist#
 
function Core_Lerp(time#,start#,end#)
endfunction start#+time#*(end#-start#)
 
function Core_InverseLerp(value#,start#,end#)
endfunction (value#-start#)/(end#-start#)
 
function Core_Map(value#,inMin#,inMax#,outMin#,outMax#)
	local time# as float
	local result# as float
    time#=Core_InverseLerp(value#,inMin#,inMax#)
    result#=Core_Lerp(time#,outMin#,outMax#)
endfunction result#
 
function Core_Clamp(value#,min#,max#)
    if value#>max# then value#=max#
    if value#<min# then value#=min#
endfunction value#

function Core_Max(valueA#,valueB#)
    if valueB#>valueA# then valueA#=valueB#
endfunction valueA#

function Core_Min(valueA#,valueB#)
    if valueB#<valueA# then valueA#=valueB#
endfunction valueA#

function Core_Wrap(value#,min#,max#)
	local range# as float
	range#=max#-min#
	if value#> max# then value#=value#-range#
	if value#< min# then value#=value#+range#
endfunction value#
 
function Core_Sign(value#)
	local result as integer
    result=((value#>0)*2)-1
endfunction result

function Core_FileLoad(Filename$)
	local string$ as string
	local memblockId as integer
	if GetFileExists(Filename$)
		MemblockID=CreateMemblockFromFile(Filename$)
		String$=GetMemblockString(MemblockID,0,GetMemblockSize(MemblockID))
		DeleteMemblock(MemblockID)
	endif
endfunction String$

function Core_FileSave(String$,Filename$)
	local FileID as integer
    FileID=OpenToWrite(Filename$) 
    WriteString(FileID,String$)
    CloseFile(FileID)
endfunction

function Core_RequestString(String$,SizeX#,SizeY#)
	local EditBoxID as integer
    EditBoxID=CreateEditBox()
    SetEditBoxSize(EditBoxID,SizeX#,SizeY#)
    SetEditBoxPosition(EditBoxID,GetVirtualWidth()/2-SizeX#/2,GetVirtualHeight()/2)
    FixEditBoxToScreen(EditBoxID,1)
    SetEditBoxDepth(EditBoxID,1)
    SetEditBoxFocus(EditBoxID,1)
    SetEditBoxText(EditBoxID,String$)
    while GetEditBoxHasFocus(EditBoxID)
        sync()
    endwhile
    String$=GetEditBoxText(EditBoxID)
    DeleteEditBox(EditBoxID)
endfunction String$

