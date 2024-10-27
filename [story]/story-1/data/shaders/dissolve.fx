// shader napisany na serwer district mta
// autor: borsuk

#include "mta-helper.fx"

texture newTexture;
texture dissolveTexture;
texture outRt < string renderTarget = "yes"; >;

float dissolveStep = 0.0f;
float dissolveSize = 0.2f;
bool noAlpha = true;
float alphaValue = 1.0f;

sampler Sampler0 = sampler_state
{
    Texture = (newTexture);
};

sampler Sampler1 = sampler_state
{
    Texture = (dissolveTexture);
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
    float dissolveColor = tex2D(Sampler1, PS.TexCoord).r;

    output.Color = finalColor;
    output.Extra = finalColor;
    output.Extra.a = dissolveColor < dissolveStep ? output.Extra.a : (dissolveColor < dissolveStep + dissolveSize ? output.Extra.a * (dissolveStep + dissolveSize - dissolveColor) / dissolveSize : 0.0f);
    output.Extra.a *= alphaValue;
    if (noAlpha) output.Color.a = 0.01f;
    else output.Color.a = output.Extra.a;
    // output.Extra = float4(dissolveColor, dissolveColor, dissolveColor, 1.0f);

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