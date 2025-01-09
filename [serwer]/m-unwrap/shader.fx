#include "mta-helper.fx"

texture Tex0;
float4x4 vehicleMatrix;
float3 vehicleSize = {3.5, 8.6, 1};

sampler Sampler0 = sampler_state
{
    Texture = (Tex0);
};

struct VSInput
{
    float3 Position : POSITION;
    float4 Diffuse  : COLOR0;
    float2 TexCoord : TEXCOORD0;
    float3 Normal   : NORMAL;
};

struct PSInput
{
    float4 Position : POSITION0;
    float4 Diffuse  : COLOR0;
    float2 TexCoord : TEXCOORD0;
    float3 Normal   : TEXCOORD1;
};

PSInput VertexShaderFunction(VSInput VS)
{
    PSInput PS = (PSInput)0;

    // create unwrap projection matrix
    float4x4 gWorldWithVehicleRotation = float4x4(
        vehicleMatrix[0],
        vehicleMatrix[1],
        vehicleMatrix[2],
        gWorld[3]
    );

    // calculate real vehicle parts positions
    float4 worldPosition = mul(float4(VS.Position, 1), gWorldWithVehicleRotation);
    float4x4 invWorldRotation = transpose(gWorldWithVehicleRotation);
    float4 position = mul(worldPosition - vehicleMatrix[3], invWorldRotation);

    PS.Position = mul(float4(VS.Position, 1), gWorld);
    PS.Position = mul(PS.Position, gView);
    PS.Position = mul(PS.Position, gProjection);

    float normalX = abs(dot(VS.Normal, float3(1, 0, 0)));
    float normalY = abs(dot(VS.Normal, float3(0, 1, 0)));
    float normalZ = abs(dot(VS.Normal, float3(0, 0, 1)));
    // multiply them by themselves to get the same sign
    // normalX *= normalX;
    // normalY *= normalY;
    // normalZ *= normalZ;

    // normalize dot products
    float3 normalized = normalize(float3(normalX, normalY, normalZ));

    VS.TexCoord.y = ((position.y - vehicleSize.y / 2) / vehicleSize.y);
    VS.TexCoord.x = 1 - ((position.x - vehicleSize.x / 2) / vehicleSize.x);

    // add texcoord based on normal
    VS.TexCoord.x += VS.Position.z * 0.2 * normalized.x;
    VS.TexCoord.y -= VS.Position.z * 0.2 * normalized.y;
    // if (normalized.x > 0.4)
    // {
    //     VS.TexCoord.x += VS.Position.z * 0.2;
    // }

    // if (normalized.y > 0.4)
    // {
    //     VS.TexCoord.y -= VS.Position.z * 0.2;
    // }

    float3 WorldNormal = MTACalcWorldNormal(VS.Normal);
    PS.Diffuse = MTACalcGTAVehicleDiffuse(WorldNormal, VS.Diffuse);
    PS.TexCoord = VS.TexCoord;
    PS.Normal = VS.Normal;

    return PS;
}

float4 PixelShaderFunction(PSInput PS) : COLOR0
{
    float4 finalColor = tex2D(Sampler0, PS.TexCoord);
    finalColor *= PS.Diffuse;

    return finalColor;
}

technique unwrap_slow
{
    pass P0
    {
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader  = compile ps_2_0 PixelShaderFunction();
    }
}

technique unwrap_fast
{
    pass P0
    {
        VertexShader = compile vs_3_0 VertexShaderFunction();
        PixelShader  = compile ps_3_0 PixelShaderFunction();
    }
}