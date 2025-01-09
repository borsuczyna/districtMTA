//
// custom_corona0.fx
//
//-----------------------------------------------------------------------------
// Effect Settings
//-----------------------------------------------------------------------------
float4 coronaPos0[4];
float4 coronaColor0[4];
float4 coronaPos1[4];
float4 coronaColor1[4];
float4 coronaPos2[4];
float4 coronaColor2[4];
float drawSize = 50;
float3 drawPos = 0;
float farClip = 2000;

//-----------------------------------------------------------------------------
// Include some common stuff
//-----------------------------------------------------------------------------
float4x4 gWorld : WORLD;
float4x4 gView : VIEW;
float4x4 gProjection : PROJECTION;
float3 gCameraPosition : CAMERAPOSITION;

//-----------------------------------------------------------------------------
// Texture
//-----------------------------------------------------------------------------
texture gCoronaTexture;

//-----------------------------------------------------------------------------
// Sampler Inputs
//-----------------------------------------------------------------------------
sampler Sampler0 = sampler_state{
	Texture = (gCoronaTexture);
};

//-----------------------------------------------------------------------------
// Structure of data sent to the vertex shader
//-----------------------------------------------------------------------------
struct VSInput{
	float4 Position : POSITION0;
	float4 Diffuse : COLOR0;
	float2 TexCoord : TEXCOORD0;
};

//-----------------------------------------------------------------------------
// Structure of data sent to the pixel shader ( from the vertex shader )
//-----------------------------------------------------------------------------
struct PSInput{
	float4 Position : POSITION0;
	float4 Diffuse : COLOR0;
	float2 TexCoord : TEXCOORD0;
};

// Utils
float4x4 makeTranslation (float3 pos){
	return float4x4(
		1, 0, 0, 0,
		0, 1, 0, 0,
		0, 0, 1, 0,
		pos.x, pos.y, pos.z, 1
	);
}

float MTAUnlerp( float from, float to, float pos ){
	if ( from == to )
		return 1.0;
	else
		return ( pos - from ) / ( to - from );
}

PSInput VertexShaderFunction(VSInput VS, float4 cPos, float4 cColor){
	PSInput PS = (PSInput)0;
	float4x4 posMat = makeTranslation( cPos.xyz );
	float4x4 worldViewMatrix = mul(posMat,gView);
	float4 worldViewPosition = float4(worldViewMatrix[3].xyz+VS.Position.xzy-drawPos.xzy,1);
	worldViewPosition.xyz += mul(normalize(gCameraPosition-cPos.xyz),gView).xyz;
	PS.Position = mul(worldViewPosition, gProjection);
	PS.TexCoord = float2(VS.TexCoord.x,1-VS.TexCoord.y );
	PS.Diffuse = saturate(VS.Diffuse*2)*cColor/255;
	float dis = 199;
	PS.Diffuse.a *= saturate(dis/50-1);
	PS.Diffuse.a *= saturate(1-(dis-farClip/2)/farClip*2);
	return PS;
}

// Main
PSInput VertexShaderFunction00(VSInput VS){return VertexShaderFunction(VS,coronaPos0[0],coronaColor0[0]);}
PSInput VertexShaderFunction01(VSInput VS){return VertexShaderFunction(VS,coronaPos0[1],coronaColor0[1]);}
PSInput VertexShaderFunction02(VSInput VS){return VertexShaderFunction(VS,coronaPos0[2],coronaColor0[2]);}
PSInput VertexShaderFunction03(VSInput VS){return VertexShaderFunction(VS,coronaPos0[3],coronaColor0[3]);}
PSInput VertexShaderFunction10(VSInput VS){return VertexShaderFunction(VS,coronaPos1[0],coronaColor1[0]);}
PSInput VertexShaderFunction11(VSInput VS){return VertexShaderFunction(VS,coronaPos1[1],coronaColor1[1]);}
PSInput VertexShaderFunction12(VSInput VS){return VertexShaderFunction(VS,coronaPos1[2],coronaColor1[2]);}
PSInput VertexShaderFunction13(VSInput VS){return VertexShaderFunction(VS,coronaPos1[3],coronaColor1[3]);}
PSInput VertexShaderFunction20(VSInput VS){return VertexShaderFunction(VS,coronaPos2[0],coronaColor2[0]);}
PSInput VertexShaderFunction21(VSInput VS){return VertexShaderFunction(VS,coronaPos2[1],coronaColor2[1]);}
PSInput VertexShaderFunction22(VSInput VS){return VertexShaderFunction(VS,coronaPos2[2],coronaColor2[2]);}
PSInput VertexShaderFunction23(VSInput VS){return VertexShaderFunction(VS,coronaPos2[3],coronaColor2[3]);}

float4 PixelShaderFunction(PSInput PS, float size){
	float2 coord = (PS.TexCoord-0.5)*drawSize/size*2+0.5;
	if(coord.x < 0 || coord.y < 0 || coord.x > 1 || coord.y > 1)
		return 0;
	else
		return tex2D(Sampler0,coord)*PS.Diffuse;
}

float4 PixelShaderFunction00(PSInput PS):COLOR0{ return PixelShaderFunction(PS,coronaPos0[0][3]); }
float4 PixelShaderFunction01(PSInput PS):COLOR0{ return PixelShaderFunction(PS,coronaPos0[1][3]); }
float4 PixelShaderFunction02(PSInput PS):COLOR0{ return PixelShaderFunction(PS,coronaPos0[2][3]); }
float4 PixelShaderFunction03(PSInput PS):COLOR0{ return PixelShaderFunction(PS,coronaPos0[3][3]); }
float4 PixelShaderFunction10(PSInput PS):COLOR0{ return PixelShaderFunction(PS,coronaPos1[0][3]); }
float4 PixelShaderFunction11(PSInput PS):COLOR0{ return PixelShaderFunction(PS,coronaPos1[1][3]); }
float4 PixelShaderFunction12(PSInput PS):COLOR0{ return PixelShaderFunction(PS,coronaPos1[2][3]); }
float4 PixelShaderFunction13(PSInput PS):COLOR0{ return PixelShaderFunction(PS,coronaPos1[3][3]); }
float4 PixelShaderFunction20(PSInput PS):COLOR0{ return PixelShaderFunction(PS,coronaPos2[0][3]); }
float4 PixelShaderFunction21(PSInput PS):COLOR0{ return PixelShaderFunction(PS,coronaPos2[1][3]); }
float4 PixelShaderFunction22(PSInput PS):COLOR0{ return PixelShaderFunction(PS,coronaPos2[2][3]); }
float4 PixelShaderFunction23(PSInput PS):COLOR0{ return PixelShaderFunction(PS,coronaPos2[3][3]); }

// Techniques
technique custom_corona0{
	pass P0{
        SrcBlend = SRCALPHA;
        DestBlend = ONE;
        AlphaRef = 1;
        AlphaBlendEnable = TRUE;
        FogEnable = false;
		VertexShader = compile vs_2_0 VertexShaderFunction00();
		PixelShader = compile ps_2_0 PixelShaderFunction00();
	}
	pass P1{
        SrcBlend = SRCALPHA;
        DestBlend = ONE;
        AlphaRef = 1;
        AlphaBlendEnable = TRUE;
        FogEnable = false;
		VertexShader = compile vs_2_0 VertexShaderFunction01();
		PixelShader = compile ps_2_0 PixelShaderFunction01();
	}
	pass P2{
        SrcBlend = SRCALPHA;
        DestBlend = ONE;
        AlphaRef = 1;
        AlphaBlendEnable = TRUE;
        FogEnable = false;
		VertexShader = compile vs_2_0 VertexShaderFunction02();
		PixelShader = compile ps_2_0 PixelShaderFunction02();
	}
	pass P3{
        SrcBlend = SRCALPHA;
        DestBlend = ONE;
        AlphaRef = 1;
        AlphaBlendEnable = TRUE;
        FogEnable = false;
		VertexShader = compile vs_2_0 VertexShaderFunction03();
		PixelShader = compile ps_2_0 PixelShaderFunction03();
	}
	pass P10{
        SrcBlend = SRCALPHA;
        DestBlend = ONE;
        AlphaRef = 1;
        AlphaBlendEnable = TRUE;
        FogEnable = false;
		VertexShader = compile vs_2_0 VertexShaderFunction10();
		PixelShader = compile ps_2_0 PixelShaderFunction10();
	}
	pass P11{
		DestBlend = ONE;
		AlphaRef = 1;
		AlphaBlendEnable = TRUE;
		VertexShader = compile vs_2_0 VertexShaderFunction11();
		PixelShader = compile ps_2_0 PixelShaderFunction11();
	}
	pass P12{
        SrcBlend = SRCALPHA;
        DestBlend = ONE;
        AlphaRef = 1;
        AlphaBlendEnable = TRUE;
        FogEnable = false;
		VertexShader = compile vs_2_0 VertexShaderFunction12();
		PixelShader = compile ps_2_0 PixelShaderFunction12();
	}
	pass P13{
        SrcBlend = SRCALPHA;
        DestBlend = ONE;
        AlphaRef = 1;
        AlphaBlendEnable = TRUE;
        FogEnable = false;
		VertexShader = compile vs_2_0 VertexShaderFunction13();
		PixelShader = compile ps_2_0 PixelShaderFunction13();
	}
	pass P20{
		DestBlend = ONE;
		AlphaRef = 1;
		AlphaBlendEnable = TRUE;
		VertexShader = compile vs_2_0 VertexShaderFunction20();
		PixelShader = compile ps_2_0 PixelShaderFunction20();
	}
	pass P21{
        SrcBlend = SRCALPHA;
        DestBlend = ONE;
        AlphaRef = 1;
        AlphaBlendEnable = TRUE;
        FogEnable = false;
		VertexShader = compile vs_2_0 VertexShaderFunction21();
		PixelShader = compile ps_2_0 PixelShaderFunction21();
	}
	pass P22{
        SrcBlend = SRCALPHA;
        DestBlend = ONE;
        AlphaRef = 1;
        AlphaBlendEnable = TRUE;
        FogEnable = false;
		VertexShader = compile vs_2_0 VertexShaderFunction22();
		PixelShader = compile ps_2_0 PixelShaderFunction22();
	}
	pass P23{
        SrcBlend = SRCALPHA;
        DestBlend = ONE;
        AlphaRef = 1;
        AlphaBlendEnable = TRUE;
        FogEnable = false;
		VertexShader = compile vs_2_0 VertexShaderFunction23();
		PixelShader = compile ps_2_0 PixelShaderFunction23();
	}
}

// Fallback
technique fallback{
	pass P0{
		// Just draw normally
	}
}