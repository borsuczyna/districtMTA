#include "mta-helper.fx"

float4 gVehicleColor = float4(1, 0, 0, 1);
float gVehicleLighting = 1.0;
float3 gVehiclePosition = float3(0, 0, 0);
texture gEnvMap;

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
    float3 WorldPos : TEXCOORD3;
    float3 RelativePos : TEXCOORD4;
};

sampler2D TextureSampler = sampler_state
{
    Texture = <gTexture0>;
};

sampler2D EnvMap = sampler_state
{
    Texture = <gEnvMap>;
};

PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;
    PS.Position = mul(float4(VS.Position, 1), gWorldViewProjection);
    PS.Normal = normalize( mul(VS.Normal, (float3x3)gWorldInverseTranspose).xyz );
    PS.WorldPos = mul(float4(VS.Position, 1), gWorld).xyz;

    float4 Specular = MTACalculateSpecular( gCameraDirection, gLightDirection, PS.Normal, 10 ) * 0.2;
    float4 VehicleDiffuse = MTACalcGTAVehicleDynamicDiffuse(PS.Normal, VS.Diffuse, gLightDirection);

    // Calculate the position relative to the vehicle
    float3 partPosition = gWorld[3].xyz - gVehiclePosition;
    matrix relativeWorld = gWorld;
    relativeWorld[3].xyz = partPosition;
    float4 relativePosition = mul(float4(VS.Position, 1), relativeWorld);

    matrix removeRotation = gWorld;
    removeRotation[3].xyz = 0;
    removeRotation = transpose(removeRotation);
    relativePosition = mul(relativePosition, removeRotation);

    PS.Diffuse.rgb = (gVehicleColor / 2) * VehicleDiffuse * gVehicleLighting * 4 + Specular.rgb;
    PS.TexCoord = VS.TexCoord;
    PS.RelativePos = relativePosition.xyz;

    return PS;
}

float4 PixelShaderFunction(PSInput PS) : COLOR0
{
    float4 texColor = tex2D(TextureSampler, PS.TexCoord);
    float2 envMapCoords = float2(
        ((PS.RelativePos.x + PS.RelativePos.y)/8 + (-PS.WorldPos.x + PS.WorldPos.y)/30) % 1,
        PS.RelativePos.z/2 + 0.25
    );
    envMapCoords.y = max(0, min(0.6, envMapCoords.y));

    float4 envColor = tex2D(EnvMap, envMapCoords);
    // float4 VehicleDiffuseDynamic = MTACalcGTAVehicleDynamicDiffuse(PS.Normal, PS.Diffuse, gLightDirection);
    // MTACalcGTAVehicleDiffuse( float3 WorldNormal, float4 InDiffuse)
    // float4 VehicleCompleteDiffuse = MTACalcGTACompleteDiffuse(PS.WorldPos, PS.Normal, float4(0.1, 0.1, 0.1, 1 ));
    float4 DynamicDiffuse = min(0.1, MTACalcGTADynamicDiffuse(PS.Normal));
    float4 finalColor = texColor * PS.Diffuse * pow(envColor.r, 0.15) * 0.6;
    // finalColor.rgb = DynamicDiffuse.rgb/1;
    // finalColor.rgb *= gAmbientColor.rgb;

    return finalColor;
}

technique simple
{
    pass P0
    {
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}