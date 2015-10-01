Shader "Custom/MyBumpReflection" {
	Properties
	{
		_MainTex("MainTex",2D) = "white"{}
		_NormalMap("NormalMap",2D)="white"{}
		_CubeMap("CubeMap",CUBE) = ""{}
	}
	
	SubShader
	{
		CGPROGRAM
		#pragma surface surf Lambert
		
		struct Input
		{
			float2 uv_MainTex;
			float2 uv_NormalMap;
			float3 worldRefl;
			float3 worldNormal;INTERNAL_DATA
		};
		
		sampler2D _MainTex;
		sampler2D _NormalMap;
		samplerCUBE _CubeMap;
		
		void surf(Input IN, inout SurfaceOutput o )
		{
			float4 color = tex2D(_MainTex, IN.uv_MainTex);
			o.Normal = UnpackNormal( tex2D(_NormalMap, IN.uv_NormalMap ));
			o.Emission = texCUBE(_CubeMap, IN.worldRefl );
			o.Albedo = color.rgb * 0.5;
			o.Alpha = color.a;		
		}
		
		ENDCG
	}
	
	FallBack "Diffuse"
}
