#include "mta-helper.fx"

texture outTarget < string renderTarget = "yes"; >;
float4 color = float4(0, 0, 0, 1);
texture rotateTexture;
int axis = 0;

sampler Sampler0 = sampler_state
{
    Texture = <rotateTexture>;
};

sampler Sampler1 = sampler_state
{
    Texture = <outTarget>;
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
};

struct Pixel
{
    float4 World : COLOR0;      // Render target #0
    float4 Color : COLOR1;      // Render target #1
};

PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;

    PS.Position = mul(float4(VS.Position, 1), gWorldViewProjection);
    PS.Position.z /= 20;

    PS.Diffuse = VS.Diffuse;
    PS.TexCoord = VS.TexCoord;

    return PS;
}

Pixel PixelShaderFunction(PSInput PS) : COLOR0
{
    Pixel pixel = (Pixel)0;

    float4 rotateColor = tex2D(Sampler0, PS.TexCoord) * color;
    // rotateColor.a = 0.01;
    float outAlpha = tex2D(Sampler1, PS.TexCoord).a;

    float4 finalColor = float4(PS.TexCoord.x, PS.TexCoord.y, 0, 1);

    if (axis == 0)
        finalColor.rg = finalColor.rg/3;
    else if (axis == 1)
        finalColor.rg = 1.0/3.0 + finalColor.rg/3;
    else if (axis == 2)
        finalColor.rg = 1.0/3.0*2 + finalColor.rg/3;

    pixel.World = rotateColor;
    pixel.Color = finalColor;

    return pixel;
}

technique complercated
{
    pass P0
    {
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader  = compile ps_2_0 PixelShaderFunction();
        AlphaBlendEnable = true;
        AlphaRef = 1;
        SeparateAlphaBlendEnable = true;
        SrcBlendAlpha = SrcAlpha;
        DestBlendAlpha = One;

    }
}