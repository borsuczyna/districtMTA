texture screenSource;
 
sampler TextureSampler = sampler_state
{
    Texture = <screenSource>;
};

float4 PixelShaderFunction(float2 TextureCoordinate : TEXCOORD0) : COLOR0
{
    float4 color = tex2D(TextureSampler, TextureCoordinate);
 
    float value = dot(color.rgb, float3(0.3, 0.59, 0.11));
    value *= 0.3;

    color.r = value;
    color.g = value;
    color.b = value;
 
    return color;
}
 
technique BlackAndWhite
{
    pass Pass1
    {
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}