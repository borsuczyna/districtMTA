#define GENERATE_NORMALS
#include "mta-helper.fx"

texture Texture;
texture GlowTexture;

float4 markerColor = float4(1.0f, 0, 0, 1.0f);
float Time : TIME;
float2 markerSize = 1.0f;
bool isSquare = false;

sampler Sampler0 = sampler_state
{
    Texture = (Texture);
};

sampler Sampler1 = sampler_state
{
    Texture = (GlowTexture);
};

struct VSInput
{
    float4 Position : POSITION0;
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
    PS.Position = mul(VS.Position, gWorldViewProjection);
    PS.Diffuse = VS.Diffuse;
    PS.TexCoord = VS.TexCoord;
    PS.Normal = abs(VS.Normal);
    return PS;
}

float4 PixelShaderFunction(PSInput PS) : COLOR0
{
    float mSize = isSquare ? markerSize.x*PS.Normal.y + markerSize.y*PS.Normal.x : markerSize.x;
    PS.TexCoord.x *= mSize;
    float prevTexX = PS.TexCoord.x;
    PS.TexCoord.x += (Time/5)%2-1;
    float4 finalColor = tex2D(Sampler0, PS.TexCoord);
    float4 glowColor = tex2D(Sampler1, PS.TexCoord);
    float p = abs(0.5*mSize - prevTexX)/mSize;
    finalColor.rgba += glowColor.rgba/2 * min(max((sin(Time)+.5), 0.1), 0.8);
    finalColor = finalColor * markerColor;

    finalColor.a *= 0.5;
    finalColor.rgb = lerp(finalColor.rgb, float3(1,1,1), p);

    return finalColor;
}

technique marker
{
    pass P0
    {
        AlphaBlendEnable = true;
		AlphaRef = 1;
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader  = compile ps_2_0 PixelShaderFunction();
    }
}