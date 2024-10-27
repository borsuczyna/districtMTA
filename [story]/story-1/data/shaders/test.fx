// shader napisany na serwer district mta
// autor: borsuk
// cel: sprawdzanie jaki shader model obsluguje karta graficzna gracza

float4 PixelShaderFunctionSupported() : COLOR0
{
    return float4(1, 0, 0, 1);
}

float4 PixelShaderFunctionUnsupported() : COLOR0
{
    return float4(0, 1, 0, 1);
}

technique supported
{
    pass P0
    {
        PixelShader  = compile ps_3_0 PixelShaderFunctionSupported();
        AlphaBlendEnable = true;
        AlphaRef = 1;
    }
}

technique unsupported
{
    pass P0
    {
        PixelShader  = compile ps_3_0 PixelShaderFunctionUnsupported();
    }
}