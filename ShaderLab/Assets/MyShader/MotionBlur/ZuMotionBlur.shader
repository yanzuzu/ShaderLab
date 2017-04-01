// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/MotionBlur" {
	Properties
	{
		_MainTex("MainTex",2D) = "white"{}
		_BlurAmount("BlurAmount",Range(0,1)) = 0.01
	}
	
	SubShader
	{
		ZTest Always AlphaTest off ZWrite off
		Pass
		{
			ColorMask RGB
			Blend SrcAlpha OneMinusSrcAlpha
			
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
			float _BlurAmount;
			
			v2f vert( appdata_base v )
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex );
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			half4 frag( v2f i ):COLOR
			{
				return half4(tex2D(_MainTex, i.uv ).rgb, _BlurAmount );
			}
			
			ENDCG
		
		}
		
		Pass
		{
			ColorMask A
			Blend One Zero
			
			CGPROGRAM
			#include "UnityCG.cginc"
			#pragma vertex vert
			#pragma fragment frag
			
			struct v2f
			{
				float4 pos: POSITION;
				float2 uv:TEXCOORD;
			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert( appdata_base v )
			{
				v2f o;
				o.pos = UnityObjectToClipPos( v.vertex );
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}
			
			half4 frag( v2f i ):COLOR
			{
				return tex2D( _MainTex , i.uv );
			}
			
			ENDCG
		}
	
	
	}
	
	FallBack off
}
