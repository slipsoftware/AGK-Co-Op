// File: core.agc
// Created: 24-11-28



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


type Vec3
	X as float
	Y as float
	Z as float
endtype
