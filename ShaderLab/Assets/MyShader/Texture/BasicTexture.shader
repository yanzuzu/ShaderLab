// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/BasicTexture"
{
	Properties
	{
		_Color("Color", Color ) = (1,1,1,1)
		_MainTex("MainTex",2D) = "white"{}
		_Specular("Specular", Color ) = (1,1,1,1)
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
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Specular;
			float _Glow;

			struct a2v
			{
				float3 vertex: POSITION;
				float3 normal: NORMAL;
				float4 texcoord: TEXCOORD0;
			};

			struct v2f
			{
				float4 pos: SV_POSITION;
				float3 worldNormal: TEXCOORD0;
				float3 worldPos : TEXCOORD1;
				fixed2 uv: TEXCOORD2;
			};

			v2f vert( a2v i )
			{
				v2f o;
				o.pos = UnityObjectToClipPos( i.vertex );
				o.worldNormal  = UnityObjectToWorldNormal( i.normal );
				o.worldPos = mul(unity_ObjectToWorld,i.vertex);
				o.uv = TRANSFORM_TEX(i.texcoord, _MainTex);
				// o.uv = i.texcoord.xy * _MainTex.xy + _MainTex.zw;
				return o;
			}

			fixed4 frag( v2f i ) : SV_Target
			{
				fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;
				fixed3 diffuseColor = _LightColor0.rgb * albedo * saturate( dot( worldNormal, worldLight ) );

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfLambert = normalize( viewDir + worldLight );
				fixed3 specularColor = _LightColor0.rgb * _Specular.rgb * pow( saturate( dot( halfLambert, worldNormal ) ), _Glow );

				return fixed4( ambientColor + diffuseColor + specularColor , 1 );

			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}