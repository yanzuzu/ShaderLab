Shader "Custom/ZuRay" {
	Properties
	{
		_MainTex("MainTex",2D) = "white"{}
		_TransX("TransX",Range(0,1)) = 0.5
		_TransY("TransY",Range(0,1)) = 0.5
		_DeltaUvScale("DeltaUvScale", FLOAT ) = 0.96
		_IllumDecayValue("IllumDecayValue",FLOAT) = 0.93
		_SampleCount("SampleCount",Range(0,100)) = 80
		_ColorDecayValue("ColorDecayValue",FLOAT ) = 0.6
		_ColorWeight("ColorWeight",FLOAT ) = 0.4
	}
	
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
	
		CGPROGRAM
		#include "UnityCG.cginc"
		#pragma surface surf Lambert
		
		struct Input
		{
			float2 uv_MainTex;
		};
		
		sampler2D _MainTex;
		float _TransX, _TransY, _IllumDecayValue, _SampleCount, _DeltaUvScale, _ColorDecayValue, _ColorWeight;
		
		void surf(Input IN, inout SurfaceOutput o )
		{
			float2 uv = IN.uv_MainTex;
			float2 deltaUV = float2( uv - float2(_TransX, _TransY ));
			deltaUV *= 1.0/ float(_SampleCount) * _DeltaUvScale;
			
			float illumination = 1;
			float4 fragColor = float4(0);
			
			for( int i = 0 ; i < _SampleCount ; i ++ )
			{
				uv -= deltaUV;
				float4 texColor = tex2D(_MainTex, uv );
				texColor *= illumination * _ColorWeight;
				illumination *= _IllumDecayValue;
				fragColor += texColor;
			}
			fragColor *= _ColorDecayValue;
			fragColor = clamp(fragColor, 0 , 1 );
			
			o.Albedo = fragColor.rgb;
			o.Alpha = fragColor.a;
		}
		
		ENDCG
	}
	
	FallBack "Diffuse"
}
