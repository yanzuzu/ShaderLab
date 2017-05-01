// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/ForwardShadowRendering"
{
	Properties
	{
		_Color("Color", Color ) = (1,1,1,1)
		_SpecularColor("SpecularColor", Color ) = (1,1,1,1)
		_Glow("Glow", Float ) = 20
	}

	SubShader
	{
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase

			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Color;
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
				fixed3 worldPos: TEXCOORD0;
				fixed3 worldNormal: TEXCOORD1;
				SHADOW_COORDS(2)
			};

			v2f vert( a2v i )
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.worldPos = mul(unity_ObjectToWorld,i.vertex);
				o.worldNormal = UnityObjectToWorldNormal(i.normal);
				TRANSFER_SHADOW(o);
				return o;
			}

			fixed4 frag( v2f i ): SV_Target
			{
			//
				fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));

				fixed3 diffuseColor = _LightColor0.rgb * _Color.rgb * saturate( dot( worldNormal , worldLight ) );

				fixed3 worldView = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfLambert = normalize( worldView + worldLight );
				fixed3 specularColor = _LightColor0.rgb * _SpecularColor.rgb * pow( saturate( dot( halfLambert , worldNormal ) ) , _Glow );

				//fixed atten = 1;
				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
				//return fixed4 ( ambientColor + diffuseColor + specularColor   , 1 );
				return fixed4 ( ambientColor + ( diffuseColor + specularColor ) * atten  , 1 );
			}


			ENDCG
		}

		Pass
		{
			Tags{"LightMode" = "ForwardAdd"}
			Blend one one
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdadd

			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Color;
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
				fixed3 worldPos: TEXCOORD0;
				fixed3 worldNormal: TEXCOORD1;
			};

			v2f vert( a2v i )
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.worldPos = mul(unity_ObjectToWorld,i.vertex);
				o.worldNormal = UnityObjectToWorldNormal(i.normal);
				return o;
			}

			fixed4 frag( v2f i ): SV_Target
			{
				fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(i.worldNormal);
				#ifdef USING_DIRECTION_LIGHT
					fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				#else
					fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz - i.worldPos.xyz );
				#endif

				fixed3 diffuseColor = _LightColor0.rgb * _Color.rgb * saturate( dot( worldNormal , worldLight ) );

				fixed3 worldView = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfLambert = normalize( worldView + worldLight );
				fixed3 specularColor = _LightColor0.rgb * _SpecularColor.rgb * pow( saturate( dot( halfLambert , worldNormal ) ) , _Glow );

				//fixed atten = 1;
				//#ifdef USING_DIRECTION_LIGHT
				//	atten = 1;
				//#else
				//	float3 lightCoord = mul(unity_WorldToLight, float4(i.worldPos,1)).xyz;
				//	atten = tex2D(_LightTexture0 , dot(lightCoord, lightCoord ).rr ).UNITY_ATTEN_CHANNEL;
				//#endif
				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);
				return fixed4 ( ( diffuseColor + specularColor)*atten, 1 );
			}


			ENDCG
		}
	}

	FallBack "Diffuse"

}