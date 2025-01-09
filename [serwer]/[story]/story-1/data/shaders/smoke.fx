// shader napisany na serwer district mta
// autor: borsuk
// domyslnie shader byl wiekszy ale w chuj lagowal to polecial do kosza xd

#include "mta-helper.fx"

struct PSInput
{
    float4 Position : POSITION0;
    float4 Diffuse  : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

float4 PixelShaderFunction(PSInput PS) : COLOR0
{
    return float4(0.4, 0.4, 0.4, 1) * PS.Diffuse;
}

technique complercated
{
    pass P0
    {
        PixelShader  = compile ps_2_0 PixelShaderFunction();
        AlphaBlendEnable = true;
        AlphaRef = 1;
    }
}