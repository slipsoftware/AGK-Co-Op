attribute vec3 position;
attribute vec3 normal;
attribute vec2 uv;

varying highp vec3 posVarying;
varying mediump vec2 uvVarying;
varying mediump vec3 normalVarying;
uniform vec4 uvBounds0;
uniform mat4 agk_World;
uniform mat4 agk_ViewProj;
uniform mat3 agk_WorldNormal;

void main() {
    vec4 worldPos = agk_World * vec4(position, 1.0);
    gl_Position = agk_ViewProj * worldPos;
    posVarying = worldPos.xyz;
    normalVarying = agk_WorldNormal * normal;
    uvVarying = uv * uvBounds0.xy + uvBounds0.zw;
}