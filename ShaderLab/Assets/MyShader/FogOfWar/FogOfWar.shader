Shader "Custom/MaskTest"
{
	Properties
	{
		_MainTex ("Main (RGB)", 2D) = "white" {}
		_MaskTex ("Mask (RGB)", 2D) = "white" {}
	}
	SubShader
	{
		Tags {"RenderType"="Transparent"}
		Blend SrcAlpha OneMinusSrcAlpha
		Lighting Off
		Cull Off 
	
		pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
				
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv2 = o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _MaskTex;

			fixed4 frag (v2f i) : SV_Target
			{
				half4 baseColor = tex2D(_MainTex,i.uv);
				half4 baseColor2 = tex2D(_MaskTex,i.uv2);
				fixed4 col;
				col.rgb = baseColor.rgb * baseColor2.b;
				col.a =  ( baseColor.a - baseColor2.g );
				return col;
			}
			ENDCG
		}
	}
	FallBack "Diffuse"
}