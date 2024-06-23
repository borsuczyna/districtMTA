texture screenSource;
 
sampler TextureSampler = sampler_state
{
    Texture = <screenSource>;
};

float4 PixelShaderFunction(float2 TextureCoordinate : TEXCOORD0) : COLOR0
{
    float4 color = tex2D(TextureSampler, TextureCoordinate);
 
    float value = (color.r + color.g + color.b) / 3; 
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