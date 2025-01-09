texture ScreenTexture;
texture MaskTexture;
float gBlurFac = 3;
float2 ScreenSize = float2(1024, 768);

static const float Kernel[13] = {-6, -5,     -4,     -3,     -2,     -1,     0,      1,      2,      3,      4,      5,      6};
static const float Weights[13] = {      0.002216,       0.008764,       0.026995,       0.064759,       0.120985,       0.176033,       0.199471,       0.176033,       0.120985,       0.064759,       0.026995,       0.008764,       0.002216};

sampler ScreenSampler = sampler_state
{
    Texture = (ScreenTexture);
};

sampler MaskSampler = sampler_state
{
    Texture = (MaskTexture);
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

float4 PixelShaderFunction(PSInput PS) : COLOR0
{
    float4 finalColor = tex2D(ScreenSampler, PS.TexCoord);
    finalColor = finalColor * PS.Diffuse;

    float mask = tex2D(MaskSampler, PS.TexCoord).a;

    if (finalColor.a > 0) {
        float2 coord = float2(PS.TexCoord.x, 0);
        finalColor = 0;

        for(int i = 0; i < 13; ++i)
        {
            coord.y = PS.TexCoord.y + (gBlurFac * Kernel[i])/ScreenSize.y;
            finalColor += tex2D(ScreenSampler, coord.xy) * Weights[i];
        }
        
        finalColor.a = mask * 6;
        return finalColor;
    }

    return finalColor;
}

technique complercated
{
    pass P0
    {
        PixelShader  = compile ps_2_0 PixelShaderFunction();
    }
}