//
// wobble.fx
// author: Ren712/AngerMAN
//

//---------------------------------------------------------------------
// Settings
//---------------------------------------------------------------------
float wSpeed = 0.16;
float wSize = 0.03;
float wDensity = 100;
float strenght = 0;
texture sTex0 : TEX0;

//---------------------------------------------------------------------
// Include some common stuff
//---------------------------------------------------------------------
float gTime : TIME;

//---------------------------------------------------------------------
// Samplers
//---------------------------------------------------------------------
sampler2D Sampler0 = sampler_state
{
    Texture         = (sTex0);
    MinFilter       = Linear;
    MagFilter       = Linear;
    MipFilter       = Linear;
    AddressU        = Mirror;
    AddressV        = Mirror;
};

//------------------------------------------------------------------------------------------
// PixelShaderFunction
//  1. Read from PS structure
//  2. Process
//  3. Return pixel color
//------------------------------------------------------------------------------------------
float4 PixelShaderFunction(float2 TexCoord:TEXCOORD0) : COLOR0
{
    float2 uv = TexCoord;
    float4 preColor = tex2D( Sampler0, uv.xy ); 
    float move = fmod( gTime * wSpeed, 1 );
    uv.y = uv.y  + (sin(( uv.y + move ) * wDensity) * wSize );
    float4 color = tex2D( Sampler0, uv.xy ); 
    float4 output = lerp( preColor, color, saturate( strenght ));
    return output;
}

//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique wobble
{
    pass P0
    {
        PixelShader  = compile ps_2_0 PixelShaderFunction();
    }
}

// Fallback
technique fallback
{
    pass P0
    {
        // Just draw normally
    }
}
