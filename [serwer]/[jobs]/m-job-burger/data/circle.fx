#define PI 3.141592653589793

texture DrawTexture;
float2 Angles = float2(0, PI * 2);

sampler Sampler0 = sampler_state
{
    Texture = (DrawTexture);
};

struct PSInput
{
    float4 Position : POSITION0;
    float4 Diffuse  : COLOR0;
    float2 TexCoord : TEXCOORD0;
};

float GetAngle(float2 uv)
{
    float2 center = float2(0.5, 0.5);
    float2 dir = uv - center;
    return atan2(-dir.x, dir.y);
}

float4 PixelShaderFunction(PSInput PS) : COLOR0
{
    float4 finalColor = tex2D(Sampler0, PS.TexCoord);
    finalColor = finalColor * PS.Diffuse;

    float2 uv = float2(PS.TexCoord.x, PS.TexCoord.y) - float2(0.5, 0.5);
    float angle = atan2(-uv.x, uv.y);
    // if ( sAngleStart > sAngleEnd )
    // {
    //     if ( angle < sAngleStart && angle > sAngleEnd )
    //         return 0;
    // }
    // else
    // {
    //     if ( angle < sAngleStart || angle > sAngleEnd )
    //         return 0;
    // }
    if (Angles.x > Angles.y)
    {
        if (angle < Angles.x && angle > Angles.y)
            return 0;
    }
    else
    {
        if (angle < Angles.x || angle > Angles.y)
            return 0;
    }

    return finalColor;
}

technique circle
{
    pass P0
    {
        PixelShader  = compile ps_2_0 PixelShaderFunction();
    }
}