// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/BumpMappingWithSnow" {
	Properties
	{
		_MainTex("MainTex", 2D ) = "white"{}
		_BumpTex("BumpTex", 2D ) = "white"{}
		_SnowLevel("SnowLevel",Range(0,1)) = 0
		_SnowColor("SnowColor",Color ) = (1,1,1,1)
		_SnowDir("SnowDir",Vector ) = ( 0, 1, 0 )
		_SnowDepth("SnowDepth", Range(0,0.3)) = 0
	}
	
	SubShader
	{
		CGPROGRAM
		#pragma surface surf Lambert vertex:vert
		
		struct Input
		{
			float2 uv_MainTex;
			float2 uv_BumpTex;
			float3 worldNormal; INTERNAL_DATA
		};
		
		sampler2D _MainTex;
		sampler2D _BumpTex;
		float _SnowLevel;
		float4 _SnowColor;
		float4 _SnowDir;
		float _SnowDepth;
		
		void vert( inout appdata_full v )
		{
			float4 snowDirLocal = mul( unity_WorldToObject , _SnowDir );
			if( dot( v.normal , snowDirLocal.xyz ) > lerp(1,-1,_SnowLevel ))
			{
				v.vertex.xyz += ( v.normal * _SnowLevel * _SnowDepth );
			}
		}
		
		void surf( Input IN, inout SurfaceOutput o )
		{
			float4 color = tex2D(_MainTex, IN.uv_MainTex );
			o.Normal = UnpackNormal(tex2D(_BumpTex, IN.uv_BumpTex ));
			if( dot( WorldNormalVector(IN, o.Normal ), _SnowDir ) > lerp( 1, -1 , _SnowLevel ) )
			{
				o.Albedo = _SnowColor;
			}else
			{
				o.Albedo = color.rgb;
			}
			
			o.Alpha = color.a;
		}
		
		ENDCG
	}
	
	FallBack "Diffuse"
}
