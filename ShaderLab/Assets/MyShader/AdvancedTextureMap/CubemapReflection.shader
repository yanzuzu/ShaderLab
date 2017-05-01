// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/CubemapReflection"
{
	Properties
	{
		_Color("Color",Color) = (1,1,1,1)
		_ReflectionColor("Color",Color) = (1,1,1,1)
		_ReflectionAmount("ReflectionAmount",Range(0,1)) = 1
		_CubeMap("CubeMap",CUBE ) = "_Skybox"{}
	}

	SubShader
	{
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			fixed4 _Color;
			fixed4 _ReflectionColor;
			samplerCUBE _CubeMap;
			fixed4 _CubeMap_ST;
			fixed _ReflectionAmount;

			struct a2v
			{
				float4 vertex: POSITION;
				float3 normal: NORMAL;
			};

			struct v2f
			{
				float4 pos: SV_POSITION;
				float3 worldNormal: TEXCOORD0;
				float3 worldPos: TEXCOORD1;
				float3 worldView: TEXCOORD2;
				float3 worldReflect: TEXCOORD3;
			};

			v2f vert( a2v i )
			{
				v2f o;
				o.pos = UnityObjectToClipPos(i.vertex);
				o.worldPos = mul( unity_ObjectToWorld , i.vertex );
				o.worldNormal = UnityObjectToWorldNormal(i.normal);
				o.worldView = UnityWorldSpaceViewDir(i.vertex);
				o.worldReflect = reflect(-o.worldView , o.worldNormal );
				return o;
			}

			fixed4 frag( v2f i ): SV_Target
			{
				fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLight = UnityWorldSpaceLightDir(i.worldPos);
				fixed3 diffuseColor = _LightColor0.rgb * _Color.rgb * saturate( dot( worldLight , worldNormal ));
				fixed3 reflection = texCUBE(_CubeMap,i.worldReflect ).rgb * _ReflectionColor.rgb;

				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos );

				fixed3 color = ambientColor + lerp(diffuseColor,reflection,_ReflectionAmount)*atten;

				return fixed4(color,1);

			}

			ENDCG
		}
	}

	Fallback "Diffuse"

}