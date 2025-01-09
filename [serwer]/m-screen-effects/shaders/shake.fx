//
// shake.fx
// author: Ren712/AngerMAN
//

//---------------------------------------------------------------------
// Settings
//---------------------------------------------------------------------
float wSpeed = 1;
float2 wStrenght = float2( 0, 0 );
float strenght = 0; 

//---------------------------------------------------------------------
// shake settings
//---------------------------------------------------------------------
texture sTex0 : TEX0;

//---------------------------------------------------------------------
// Include some common stuff
//---------------------------------------------------------------------
float gTime : TIME;

//---------------------------------------------------------------------
// Static data
//---------------------------------------------------------------------
static const float PI = 3.141592653589793f;

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
    float4 preColor = tex2D( Sampler0, TexCoord.xy );
    float move = fmod( gTime * wSpeed, 1);
    float2 uv = TexCoord;
    if (move < 0.25) uv.xy += float2( move * 0.4 * wStrenght.x , move * 0.4 * wStrenght.y ) - 0.2 * wStrenght.xy; 
    else if (move < 0.5) uv.xy += float2( -move * 0.4 * wStrenght.x , move * 0.4 * wStrenght.y ) + 0.2 * wStrenght.xy;
    else if (move < 0.75) uv.xy += float2( move * 0.4 * wStrenght.x , -move * 0.4 * wStrenght.y ) - 0.2 * wStrenght.xy;
    else uv.xy += float2( -move * 0.4 * wStrenght.x , -move * 0.4 * wStrenght.y ) + 0.2 * wStrenght.xy;
    float4 color = tex2D( Sampler0, uv.xy );
    float4 output = lerp( preColor, color, saturate( strenght ));
    return output;
}

//------------------------------------------------------------------------------------------
// Techniques
//------------------------------------------------------------------------------------------
technique shake
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
 