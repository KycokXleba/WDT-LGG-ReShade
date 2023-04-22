/*

									Watch Dogs Tonemap: 
		Enables one of the numerous watch dogs tonemapping algorithms. No tweaking values.
		
		Full credits to the ReShade team.
		Ported by Insomnia

*/


#include "ReShade.fxh"

uniform float LinearWhite <
	ui_label = "Tonemap - Curve";
	ui_type = "drag";
	ui_min = 0.5; ui_max = 2.0;
	ui_step = 0.01;
	> = 1.25;
	uniform float LinearColor <
	ui_label = "Tonemap - Whiteness";
	ui_type = "drag";
	ui_min = 0.5; ui_max = 2.0;
	ui_step = 0.01;
	> = 1.25;
	
float3 ColorFilmicToneMappingPass(float4 position : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
	float3 x = tex2D(ReShade::BackBuffer, texcoord).rgb;
	// Filmic tone mapping
	const float3 A = float3(0.55f, 0.50f, 0.45f);	// Shoulder strength
	const float3 B = float3(0.30f, 0.27f, 0.22f);	// Linear strength
	const float3 C = float3(0.10f, 0.10f, 0.10f);	// Linear angle
	const float3 D = float3(0.10f, 0.07f, 0.03f);	// Toe strength
	const float3 E = float3(0.01f, 0.01f, 0.01f);	// Toe Numerator
	const float3 F = float3(0.30f, 0.30f, 0.30f);	// Toe Denominator
	const float3 W = float3(2.80f, 2.90f, 3.10f);	// Linear White Point Value
	const float3 F_linearWhite = ((W*(A*W+C*B)+D*E)/(W*(A*W+B)+D*F))-(E/F);
	float3 F_linearColor = ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-(E/F);

    // gamma space or not?
	//return pow(saturate(F_linearColor * 1.25 / F_linearWhite),1.25);
	return pow(saturate(F_linearColor * LinearColor / F_linearWhite),LinearWhite);
}


technique WatchDogsTonemapping2
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = ColorFilmicToneMappingPass;
	}
}