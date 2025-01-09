#define GENERATE_NORMALS
#include "mta-helper.fx"

float gVehicleLighting = 1.0;

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
    PS.Normal = normalize( mul(VS.Normal, (float3x3)gWorldInverseTranspose).xyz );

    float4 Lighting = float4(gVehicleLighting, gVehicleLighting, gVehicleLighting, 1);
    float4 VehicleDynamicDiffuse = MTACalcGTAVehicleDynamicDiffuse(PS.Normal, VS.Diffuse, gLightDirection);
    float4 VehicleDiffuse = MTACalcGTAVehicleDiffuse(PS.Normal, Lighting);
    PS.Diffuse.rgb = ((VehicleDiffuse + VehicleDynamicDiffuse) * Lighting) / 1.5;

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