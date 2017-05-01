// Upgrade NOTE: replaced '_LightMatrix0' with 'unity_WorldToLight'
// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/ForwardRendering"
{
	Properties
	{
		_DiffuseColor("Color",Color) = (1,1,1,1)
		_SpecularColor("Color",Color) = (1,1,1,1)
		_Glow("Glow",float) = 20
	}
	SubShader
	{
		Pass
		{
			Tags { "LightMode" = "ForwardBase" }
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			#include "Lighting.cginc"

			fixed4 _DiffuseColor;
			fixed4 _SpecularColor;
			float _Glow;

			struct a2v
			{
				float4 vertex: POSITION;
				float3 normal: NORMAL;
			};

			struct v2f
			{
				float4 pos: SV_POSITION;
				float3 worldPos: TEXCOORD0;
				float3 worldNormal: TEXCOORD1;
			};

			v2f vert( a2v v )
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				return o;
			}

			fixed4 frag( v2f i ) : SV_Target
			{
				fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 diffuseColor = _LightColor0.rgb * _DiffuseColor.rgb * saturate( dot( worldNormal , worldLight ));

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfLambert = normalize( worldLight +viewDir );
				fixed3 specularColor = _LightColor0.rgb * _SpecularColor.rgb * pow( saturate( dot( worldNormal , halfLambert ) ) , _Glow );

				float atten = 1;
				return fixed4( ambientColor + ( diffuseColor + specularColor ) * atten , 1 );
			}

			ENDCG
		}

		Pass
		{
			Tags { "LightMode" = "ForwardAdd" }

			Blend one one
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdadd
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _DiffuseColor;
			fixed4 _SpecularColor;
			float _Glow;

			struct a2v
			{
				float4 vertex: POSITION;
				float3 normal: NORMAL;
			};

			struct v2f
			{
				float4 pos: SV_POSITION;
				float3 worldPos: TEXCOORD0;
				float3 worldNormal: TEXCOORD1;
			};

			v2f vert( a2v v )
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				return o;
			}

			fixed4 frag( v2f i ) : SV_Target
			{

				fixed3 worldNormal = normalize(i.worldNormal);
				#ifdef USING_DIRECTIONAL_LIGHT
					fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				#else
					//fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
					fixed3 worldLight = normalize(   _WorldSpaceLightPos0.xyz -  i.worldPos.xyz);
				#endif

				fixed3 diffuseColor = _LightColor0.rgb * _DiffuseColor.rgb * saturate( dot( worldNormal , worldLight ));

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfLambert = normalize( worldLight +viewDir );
				fixed3 specularColor = _LightColor0.rgb * _SpecularColor.rgb * pow( saturate( dot( worldNormal , halfLambert ) ) , _Glow );

				#ifdef USING_DIRECTIONAL_LIGHT
					fixed atten = 1;
				#else
					float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos,1)).xyz;
					fixed atten = tex2D(_LightTexture0, dot(lightCoord,lightCoord).rr).UNITY_ATTEN_CHANNEL;
					//fixed atten = 1;
				#endif

				return fixed4( ( diffuseColor  + specularColor ) * atten , 1 );
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}