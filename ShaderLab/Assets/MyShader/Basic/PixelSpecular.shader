// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Custom/PixelSpecular"
{
	Properties
	{
		_Diffuse ( "Diffuse" , Color ) = ( 1,1,1,1)
		_Specular( "Specular", Color ) = ( 1,1,1,1)
		_Glow    ( "Glow"    , Range(20,200) ) = 20
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
				float3 vertex: POSITION;
				float3 normal: NORMAL;
			};

			struct v2f
			{
				float4 pos: SV_POSITION;
				float3 normal: TEXCOORD0;
				float3 worldPos : TEXCOORD1;
			};

			v2f vert( a2v input )
			{
				v2f o;
				o.pos = UnityObjectToClipPos(input.vertex);
				o.normal = mul(input.normal, (float3x3)unity_WorldToObject);
				o.worldPos = mul(unity_ObjectToWorld,input.vertex).xyz;
				return o;
			}

			fixed4 frag( v2f i ) : SV_Target
			{
				fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.xyz;

				// diffuse
				fixed3 worldNormal = normalize(i.normal);
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuseColor = _LightColor0.rgb * _Diffuse.rgb * saturate( dot( worldNormal,worldLight));

				fixed3 reflection = normalize(reflect(-worldLight,worldNormal));
				fixed3 viewDir = normalize( _WorldSpaceCameraPos.xyz - i.worldPos.xyz);
				fixed3 specualrColor = _LightColor0.rgb * _Specular.rgb * pow( saturate( dot( reflection,viewDir ) ) , _Glow );

				return fixed4( ambientColor + diffuseColor + specualrColor , 1 );
			}


			ENDCG
		}
	}

	FallBack "Diffuse"
}