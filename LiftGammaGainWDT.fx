/**
 * Lift Gamma Gain version 1.1
 * by 3an and CeeJay.dk
 */
#ifndef WDT_COLOR_OR_NOT
	#define WDT_COLOR_OR_NOT 1
#endif
	
	float3 test(float3 color, float WDTS) {
		if(WDT_COLOR_OR_NOT == 0)
		{
			const float3 A = float3(0.50f, 0.50f, 0.50f);	// Shoulder strength
			const float3 B = float3(0.25f, 0.25f, 0.25f);	// Linear strength
			const float3 C = float3(0.10f, 0.10f, 0.10f);	// Linear angle
			const float3 D = float3(0.06f, 0.06f, 0.06f);	// Toe strength
			const float3 E = float3(0.01f, 0.01f, 0.01f);	// Toe Numerator
			const float3 F = float3(0.30f, 0.30f, 0.30f);	// Toe Denominator
			const float3 W = float3(3.10f, 3.10f, 3.10f);	// Linear White Point Value
			const float3 F_linearWhite = (((W*(A*W+C*B)+D*E)/(W*(A*W+B)+D*F))-(E/F));
			float3 F_linearColor = (((color*(A*color+C*B)+D*E)/(color*(A*color+B)+D*F))-(E/F));

    		// gamma space or not?
			//return pow(saturate(F_linearColor * 1.25 / F_linearWhite),1.25);
			return pow(saturate(F_linearColor * 1.25 / F_linearWhite * WDTS),1.25);
		}
		else
		{
			const float3 A = float3(0.55f, 0.50f, 0.45f);	// Shoulder strength
			const float3 B = float3(0.30f, 0.27f, 0.22f);	// Linear strength
			const float3 C = float3(0.10f, 0.10f, 0.10f);	// Linear angle
			const float3 D = float3(0.10f, 0.07f, 0.03f);	// Toe strength
			const float3 E = float3(0.01f, 0.01f, 0.01f);	// Toe Numerator
			const float3 F = float3(0.30f, 0.30f, 0.30f);	// Toe Denominator
			const float3 W = float3(2.80f, 2.90f, 3.10f);	// Linear White Point Value
			const float3 F_linearWhite = (((W*(A*W+C*B)+D*E)/(W*(A*W+B)+D*F))-(E/F));
			float3 F_linearColor = ((color*(A*color+C*B)+D*E)/(color*(A*color+B)+D*F))-(E/F);

    		// gamma space or not?
			//return pow(saturate(F_linearColor * 1.25 / F_linearWhite),1.25);
			return pow(saturate(F_linearColor * 1.25 / F_linearWhite * WDTS),1.25);
		}
	}
#include "ReShadeUI.fxh"

uniform float3 RGB_Lift < __UNIFORM_SLIDER_FLOAT3
	ui_min = 0.0; ui_max = 2.0;
	ui_label = "RGB Lift";
	ui_tooltip = "Adjust shadows for red, green and blue.";
> = float3(1.0, 1.0, 1.0);
uniform float3 RGB_Gamma < __UNIFORM_SLIDER_FLOAT3
	ui_min = 0.0; ui_max = 2.0;
	ui_label = "RGB Gamma";
	ui_tooltip = "Adjust midtones for red, green and blue.";
> = float3(1.0, 1.0, 1.0);
uniform float3 RGB_Gain < __UNIFORM_SLIDER_FLOAT3
	ui_min = 0.0; ui_max = 2.0;
	ui_label = "RGB Gain";
	ui_tooltip = "Adjust highlights for red, green and blue.";
> = float3(1.0, 1.0, 1.0);

uniform bool WatchDOG <
	ui_label = "Watch Dog Tonemaping";
> = false;

uniform bool FOS <
	ui_label = "First or Second | Enable First || Disable Second";
> = false;

uniform float WDTS < __UNIFORM_SLIDER_FLOAT1
	ui_min = 0.0; ui_max = 2.0;
	ui_label = "Gain WDT";
	ui_tooltip = "Adjust highlights for red, green and blue.";
> = float(1.0);


#include "ReShade.fxh"

float3 LiftGammaGainPass(float4 position : SV_Position, float2 texcoord : TexCoord) : SV_Target
{
	float3 color = tex2D(ReShade::BackBuffer, texcoord).rgb;
	if(WatchDOG == true) {
		if(FOS == true)
		{
			color = test(color, WDTS);
		}
	}	
	// -- Lift --
	color = color * (1.5 - 0.5 * RGB_Lift) + 0.5 * RGB_Lift - 0.5;
	color = saturate(color); // Is not strictly necessary, but does not cost performance
	
	// -- Gain --
	color *= RGB_Gain; 
	
	// -- Gamma --
	color = pow(abs(color), 1.0 / RGB_Gamma);
	
	if(WatchDOG == false)
	{
		return saturate(color);
	}
		
	else if (FOS == false)
	{
		color = test(color, WDTS);
	}
	
	return saturate(color);

}


technique LiftGammaGainWDT
{
	pass
	{
		VertexShader = PostProcessVS;
		PixelShader = LiftGammaGainPass;
	}
}
