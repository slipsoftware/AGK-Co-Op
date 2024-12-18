//--------------
// Uniforms
//--------------
uniform mat4 agk_WorldViewProj;
uniform mat4 agk_World;
uniform mat3 agk_WorldNormal;
uniform vec3 CameraPos;

//--------------
// Attributes
//--------------
attribute vec3 position;
attribute vec2 uv;
attribute vec3 normal;
attribute vec3 tangent;

//--------------
// VS Out
//--------------
varying vec4 Vs_Tex;          // Restore vec4 type
varying vec3 Vs_TBNRow1;
varying vec3 Vs_TBNRow2;
varying vec3 Vs_TBNRow3;
varying vec3 Vs_WorldPos;
varying vec3 Vs_ViewVec;

void main()
{
    // Position transformation
    vec4 Pos = agk_WorldViewProj * vec4(position, 1.0);
    gl_Position = Pos;

    // Restore vec4 Vs_Tex (compatible with pixel shader)
    Vs_Tex.xy = uv;
    Vs_Tex.zw = uv; // Duplicate for compatibility

    // World space normals and tangent space matrix
    vec3 Normals = normalize(agk_WorldNormal * normal);
    vec3 Tangent = normalize(agk_WorldNormal * tangent);
    vec3 Bitangent = cross(Normals, Tangent);

    Vs_TBNRow1 = Tangent;
    Vs_TBNRow2 = Bitangent;
    Vs_TBNRow3 = Normals;

    // World position and View vector
    Vs_WorldPos = (agk_World * vec4(position, 1.0)).xyz;
    Vs_ViewVec = normalize(CameraPos - Vs_WorldPos);
}
