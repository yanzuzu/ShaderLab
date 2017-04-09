// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/RampTexture"
{
	Properties
	{
		_Color("Color", Color ) = (1,1,1,1)
		_RampTex("RampTex",2d) = "white"{}
		_Specular("Specular",Color) = (1,1,1,1)
		_Glow("Glow",float) = 20
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

			fixed4 _Color;
			sampler2D _RampTex;
			float4 _RampTex_ST;
			fixed4 _Specular;
			float _Glow;

			struct a2v
			{
				float4 vertex: POSITION;
				float3 normal: NORMAL;
				float4 texcoord: TEXCOORD0;
			};

			struct v2f
			{
				float4 pos: SV_POSITION;
				float3 worldPos: TEXCOORD0;
				float2 uv: TEXCOORD1;
				float3 worldNormal:TEXCOORD2;
			};

			v2f vert( a2v v )
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.uv = TRANSFORM_TEX(v.texcoord,_RampTex);
				return o;
			}

			fixed4 frag( v2f i ) : SV_Target
			{
				fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed3 worldNormal = normalize( i.worldNormal);
				fixed3 worldLight = normalize( UnityWorldSpaceLightDir(i.worldPos));

				fixed halfLambert = 0.5 * ( dot(worldNormal,worldLight ) ) + 0.5f;
				fixed3 diffuseTerm =  tex2D(_RampTex, fixed2(halfLambert ,halfLambert ) ).rgb * _Color.rgb ;
				fixed3 diffuseColor = _LightColor0.rgb * diffuseTerm;

				fixed3 worldView = normalize( UnityWorldSpaceViewDir(i.worldPos));
				fixed3 half = normalize( worldView + worldLight );
				fixed3 specularColor = _LightColor0.rgb * _Specular.rgb * pow( saturate( dot( half, worldNormal ) ) , _Glow );

				return fixed4( ambientColor + diffuseColor + specularColor , 1 );
			}


			ENDCG
		}
	}

	FallBack "Diffuse"
}