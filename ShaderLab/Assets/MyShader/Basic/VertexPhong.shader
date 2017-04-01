// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/VertexPhong"
{
	Properties
	{
		_Diffuse( "Diffuse" , Color ) = (1,1,1,1)
	}

	SubShader
	{
		Tags {"LightMode" = "ForwardBase"}
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
				fixed3 color: COLOR;
			};

			fixed4 _Diffuse;
			v2f vert( a2v input )
			{
				v2f o;
				o.pos = UnityObjectToClipPos(input.pos);

				fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldNormal = normalize( mul( input.normal , (float3x3)unity_WorldToObject ));
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 diffuseColor = _LightColor0.rgb * _Diffuse.rgb * saturate( dot( worldNormal , worldLight ) );
				o.color = diffuseColor +ambientColor;
				return o;
			}

			fixed4 frag( v2f input ) : SV_Target
			{
				return fixed4( input.color , 1 );
			}

			ENDCG
		}
	}

	FallBack "Diffuse"

}