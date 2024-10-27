#include "mta-helper.fx"

texture newTexture;
texture outRt < string renderTarget = "yes"; >;

sampler Sampler0 = sampler_state
{
    Texture = (newTexture);
};

struct PSInput
{
    float4 Position : POSITION0;
    float4 Diffuse  : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

struct Pixel
{
    float4 Color : COLOR0;
    float4 Extra : COLOR1;
};

Pixel PixelShaderFunction(PSInput PS)
{
    Pixel output = (Pixel)0;
    float4 finalColor = tex2D(Sampler0, PS.TexCoord);
    finalColor.a *= PS.Diffuse.a;

    output.Color = finalColor;
    output.Color.a = 0.01;
    output.Extra = finalColor;

    return output;
}

technique simple
{
    pass P0
    {
        PixelShader  = compile ps_2_0 PixelShaderFunction();
        AlphaBlendEnable = true;
        AlphaRef = 0;
    }
}