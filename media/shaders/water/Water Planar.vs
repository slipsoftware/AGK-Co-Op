// By EVOLVED
// www.evolved-software.com

//--------------
// un-tweaks
//--------------
   uniform mat4 agk_WorldViewProj;
   uniform mat4 agk_ViewProj;
   uniform mat4 agk_View;
   uniform mat4 agk_World;
   uniform mat3 agk_WorldNormal;
   uniform vec4 uvBounds0;

//--------------
// tweaks
//--------------
   uniform float UvScroll;
   uniform vec3 CameraPos;

//--------------
// attributes
//--------------
    attribute vec3 position;
    attribute vec2 uv;
    attribute vec3 normal;
    attribute vec3 tangent;

//--------------
// Vs Out
//--------------
    varying vec4 Vs_Tex;
    varying vec3 Vs_TBNRow1;
    varying vec3 Vs_TBNRow2;
    varying vec3 Vs_TBNRow3;
    varying vec3 Vs_WorldPos;
    varying vec4 Vs_Proj;
    varying vec3 Vs_ViewNor;

//--------------
// vertex shader
//--------------
   void main()
     {
	vec4 Pos=agk_WorldViewProj*vec4(position,1);
	gl_Position=Pos;
	vec2 Tex=uv*uvBounds0.xy+uvBounds0.zw;
	Vs_Tex.xy=Tex+vec2(UvScroll*0.25,UvScroll);
	Vs_Tex.zw=Tex*vec2(4.0,4.0)-vec2(UvScroll*0.5,UvScroll*0.5);
	vec3 Normals=normalize(agk_WorldNormal*normal);
	vec3 Tangent=normalize(agk_WorldNormal*tangent);
	Vs_TBNRow1=Tangent;
	Vs_TBNRow2=cross(Normals,Tangent);
	Vs_TBNRow3=Normals;
	vec3 WorldPos=(agk_World*vec4(position,1.0)).xyz;
	Vs_WorldPos=WorldPos;
	vec3 ViewVec=CameraPos-WorldPos;
        Vs_Proj=vec4(Pos.x*0.5+0.5*Pos.w,Pos.y*0.5+0.5*Pos.w,Pos.z,Pos.w);
	vec3 TBNRow1=vec3(Vs_TBNRow1.x,Vs_TBNRow2.x,Vs_TBNRow3.x);
	vec3 TBNRow2=vec3(Vs_TBNRow1.y,Vs_TBNRow2.y,Vs_TBNRow3.y);
	vec3 TBNRow3=vec3(Vs_TBNRow1.z,Vs_TBNRow2.z,Vs_TBNRow3.z);
	mat3 WorldTBN=mat3(TBNRow1,TBNRow2,TBNRow3);
	Vs_ViewNor=WorldTBN*ViewVec;
     }
