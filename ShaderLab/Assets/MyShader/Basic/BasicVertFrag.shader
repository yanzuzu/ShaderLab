// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/BasicVertFrag"
{
	Properties
	{
		_Color( "Color Tint" , Color ) = (1,1,1,1)
	}

	SubShader
	{
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma enable_d3d11_debug_symbols

			fixed4 _Color;

			struct a2v
			{
				float4 pos : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos: SV_POSITION;
				fixed3 color: COLOR0;
			};

			v2f vert( a2v i )
			{
				v2f output;
				output.pos = UnityObjectToClipPos( i.pos );
				output.color = i.normal * 0.5 + ( 0.5,0.5,0.5);
				return output;
			}

			fixed4 frag( v2f i ) : SV_Target
			{
				fixed3 c = i.color;
				c *= _Color.rgb;
				return fixed4(c,1);
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}