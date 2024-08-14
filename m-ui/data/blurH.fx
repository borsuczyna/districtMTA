texture ScreenTexture;
float gBlurFac = 3;
float2 ScreenSize = float2(1024, 768);

static const float Kernel[13] = {-6, -5,     -4,     -3,     -2,     -1,     0,      1,      2,      3,      4,      5,      6};
static const float Weights[13] = {      0.002216,       0.008764,       0.026995,       0.064759,       0.120985,       0.176033,       0.199471,       0.176033,       0.120985,       0.064759,       0.026995,       0.008764,       0.002216};

sampler ScreenSampler = sampler_state
{
    Texture = (ScreenTexture);
    MinFilter       = Linear;
    MagFilter       = Linear;
    MipFilter       = Linear;
    AddressU        = Mirror;
    AddressV        = Mirror;
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
    float4 finalColor = 0;
    float4 Texel = tex2D(ScreenSampler, PS.TexCoord);

    float2 coord;
    coord.y = PS.TexCoord.y;

    for(int i = 0; i < 13; ++i)
    {
        coord.x = PS.TexCoord.x + (gBlurFac * Kernel[i])/ScreenSize.x;
        finalColor += tex2D(ScreenSampler, coord.xy) * Weights[i];
    }

    finalColor = finalColor * PS.Diffuse;
    finalColor.a = 1;
    return finalColor;
}

technique complercated
{
    pass P0
    {
        PixelShader  = compile ps_2_0 PixelShaderFunction();
    }
}