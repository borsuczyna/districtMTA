#define GENERATE_NORMALS
#include "mta-helper.fx"

struct VSInput
{
    float3 Position : POSITION;
    float4 Diffuse  : COLOR0;
    float2 TexCoord : TEXCOORD0;
    float3 Normal   : NORMAL0;
};

struct PSInput
{
    float4 Position : POSITION0;
    float4 Diffuse  : COLOR0;
    float2 TexCoord : TEXCOORD0;
    float3 Normal   : TEXCOORD1;
};

PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;
    PS.Position = mul(float4(VS.Position, 1), gWorldViewProjection);
    PS.Diffuse.rgb = float4(2, 2, 2, 1);
    PS.TexCoord = VS.TexCoord;

    return PS;
}

technique simple
{
    pass P0
    {
        VertexShader = compile vs_2_0 VertexShaderFunction();
    }
}