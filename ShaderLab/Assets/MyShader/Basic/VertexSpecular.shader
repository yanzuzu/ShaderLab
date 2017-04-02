// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/VertexSpecular"
{
	Properties
	{
		_Diffuse ( "Diffuse" , Color ) = (1,1,1,1)
		_Specular( "Specular", Color ) = (1,1,1,1)
		_Glow	 ( "Glow"	 , range(8,256) ) = 20
	}


	SubShader
	{
		Tags { "LightMode" = "ForwardBase" }
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Glow;

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

			v2f vert( a2v input )
			{
				v2f o;
				o.pos = UnityObjectToClipPos(input.pos);
				fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize( mul( input.normal, (float3x3)unity_WorldToObject));
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

				fixed3 diffuseTerm = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));

				fixed3 reflection = reflect(-worldLight,worldNormal);
				fixed3 viewDir = normalize( _WorldSpaceCameraPos.xyz - mul(unity_ObjectToWorld,input.pos).xyz );
				fixed3 specualrTerm = _LightColor0.rgb * _Specular.rgb *  pow( saturate( dot(reflection, viewDir ) ), _Glow );
				o.color = ambientColor + diffuseTerm + specualrTerm;
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