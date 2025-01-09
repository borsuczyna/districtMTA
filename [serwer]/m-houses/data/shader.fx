texture Tex0;

technique tex_replace
{
    pass P0
    {
        Texture[0] = Tex0;
    }
}