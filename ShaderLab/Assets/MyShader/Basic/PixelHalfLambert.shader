// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/PixelHalfLambert"
{
	Properties
	{
		_Diffuse ( "Diffuse" , Color ) = ( 1, 1, 1, 1 )
	}

	SubShader
	{	
		Tags{ "LightMode" = "ForwardBase" }
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			struct a2v
			{
				float3 pos: POSITION;
				float3 normal: NORMAL;
			};

			struct v2f
			{
				float4 pos: SV_POSITION;
				float3 worldNormal : NORMAL;
			};

			fixed4 _Diffuse;

			v2f vert( a2v input )
			{
				v2f o;
				o.pos = UnityObjectToClipPos(input.pos);
				o.worldNormal = mul(input.normal,(float3x3)unity_WorldToObject);
				return o;
			}

			fixed4 frag( v2f input ) : SV_Target
			{
				fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize( input.worldNormal );
				fixed3 worldLight = normalize( _WorldSpaceLightPos0.xyz );

				fixed halfLambert = dot( worldNormal , worldLight ) * 0.5 + 0.5;
				fixed3 diffuseColor = _LightColor0.rgb * _Diffuse.rgb * halfLambert;

				return fixed4(diffuseColor + ambientColor , 1 );
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}