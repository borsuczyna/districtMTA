// shader napisany na serwer district mta
// autor: borsuk

#include "mta-helper.fx"

// float missileZ = 280.0f;
float fireLength = 70.0f;
float smokeLength = 60.0f;
float totalLength = 190.0f;
float alpha = 1.0f;

float Time : TIME;

sampler Sampler0 = sampler_state
{
    Texture = (gTexture0);
};

struct VSInput
{
    float3 Position : POSITION;
    float4 Diffuse  : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

struct PSInput
{
    float4 Position : POSITION0;
    float4 Diffuse  : COLOR0;
    float2 TexCoord : TEXCOORD0;
    float3 WorldPos : TEXCOORD1;
};

float rand(float n) {
    return frac(sin(n) * 43758.5453123);
}

float perlinNoise(float2 npos)
{
    float2 p = floor(npos);
    float2 f = frac(npos);
    f = f * f * (3.0 - 2.0 * f);
    float n = p.x + p.y * 57.0;
    return lerp(lerp(rand(n), rand(n + 1.0), f.x),
        lerp(rand(n + 57.0), rand(n + 58.0), f.x), f.y);
}

PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;

    PS.WorldPos = mul(float4(VS.Position, 1), gWorld).xyz;
    PS.Position = mul(float4(VS.Position, 1), gWorldViewProjection);
    PS.Diffuse = VS.Diffuse;
    PS.TexCoord = VS.TexCoord;

    return PS;
}

float4 PixelShaderFunction(PSInput PS) : COLOR0
{
    float4 finalColor = float4(1, 1, 1, 1);
    float missileZ = mul(float4(0, 0, 100, 1), gWorld).z;

    if (PS.WorldPos.z < missileZ)
    {
        float gradientColor = (missileZ - PS.WorldPos.z) / fireLength;
        if (gradientColor > 1)
        {
            float smokeGradientColor = ((missileZ - fireLength) - PS.WorldPos.z) / smokeLength;
            if (smokeGradientColor > 1) smokeGradientColor = 1;
            finalColor = lerp(float4(1, 0.95, 0.5, 1), float4(0.5, 0.5, 0.5, 1), smokeGradientColor);
        }
        else
            finalColor = lerp(float4(1, 1, 1, 1), float4(1, 0.95, 0.5, 1), gradientColor);
    }

    float2 pos = float2(PS.WorldPos.x/4 + Time * 3 + PS.WorldPos.z/8, PS.WorldPos.y/4 + PS.WorldPos.z/10 + Time * 1);
    float noise = perlinNoise(pos);
    finalColor -= noise/5;

    float totalPosition = (missileZ - PS.WorldPos.z) / totalLength;
    float alphaNoise = (1 - noise*totalPosition) * (1-totalPosition);
    finalColor.a = alphaNoise * alpha;
    return finalColor;
}

technique complercated
{
    pass P0
    {
        VertexShader = compile vs_3_0 VertexShaderFunction();
        PixelShader  = compile ps_3_0 PixelShaderFunction();
        AlphaBlendEnable = true;
        AlphaRef = 1;
    }
}