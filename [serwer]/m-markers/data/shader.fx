texture defaultTexture;
texture glowTexture;
float markerSize = 1;
float4 markerColor = float4(1, 1, 1, 1);
float Time : TIME;

sampler Sampler0 = sampler_state
{
    Texture = (defaultTexture);
};

sampler Sampler1 = sampler_state
{
    Texture = (glowTexture);
};

struct PSInput
{
    float4 Position : POSITION0;
    float4 Diffuse  : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

float4 PixelShaderFunction(PSInput PS) : COLOR0
{
    float prevTexX = PS.TexCoord.x;
    PS.TexCoord.x -= (Time/10)%2-1;

    float4 finalColor = tex2D(Sampler0, PS.TexCoord);
    float4 glowColor = tex2D(Sampler1, PS.TexCoord);
    float p = abs(0.5*markerSize - prevTexX)/markerSize;
    
    finalColor.rgba += glowColor.rgba/2 * min(max((sin(Time)+.5), 0.1), 0.8);
    finalColor *= markerColor;
    finalColor.rgb = lerp(finalColor.rgb, float3(1,1,1), p/2);

    return finalColor;
}

technique marker
{
    pass P0
    {
        PixelShader  = compile ps_2_0 PixelShaderFunction();
    }
}