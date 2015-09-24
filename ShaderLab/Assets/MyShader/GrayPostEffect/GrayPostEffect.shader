Shader "Custom/GrayPostEffect" {
	Properties
	{
		_MainTex("MainTex",2D) = "white"{}
	}
	
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag
			
			struct v2f
			{
				float4 pos:POSITION;
				float2 uv:TEXCOORD;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert( appdata_base v )
			{
				v2f o;
				o.pos = mul( UNITY_MATRIX_MVP, v.vertex );
				o.uv = TRANSFORM_TEX( v.texcoord, _MainTex );
				return o;
			}
			
			half4 frag( v2f i ):COLOR
			{
				float4 color =  tex2D(_MainTex, i.uv );
				//Gray = 0.299 * Red + 0.587 * Green + 0.114 * Blue
				color.rgb = 0.299 * color.r + 0.587 * color.g + 0.114 * color.b;
				return color;

			}
			
			ENDCG
		}
		
	}
	
	FallBack off
}
