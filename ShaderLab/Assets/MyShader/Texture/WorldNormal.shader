// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/WorldNormal"
{
	Properties
	{
		_Color("Color",Color) = (1,1,1,1)
		_MainTex("MainTex",2d) = "white"{}
		_BumpTex("BumpTex",2d) = "bump"{}
		_BumpScale("BumpScale",float) = 1
		_Specular("Specular",color) = (1,1,1,1)
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
			sampler2D _BumpTex;
			float4 _BumpTex_ST;
			float _BumpScale;
			fixed4 _Specular;
			float _Glow;

			struct a2v
			{
				float4 vertex: POSITION;
				float3 normal: NORMAL;
				float4 tangent: TANGENT;
				float4 texcoord: TEXCOORD0;
			};

			struct v2f
			{
				float4 pos: SV_POSITION;
				float4 uv: TEXCOORD0;
				float4 t2w1: TEXCOORD1;
				float4 t2w2: TEXCOORD2;
				float4 t2w3: TEXCOORD3;
			};

			v2f vert( a2v v )
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.texcoord,_MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord,_BumpTex);

				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldTangent = UnityObjectToWorldDir(v.tangent);
				float3 binormal = cross( worldNormal,worldTangent ) * v.tangent.w;
				float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
				o.t2w1 = float4(worldTangent.x,binormal.x,worldNormal.x,worldPos.x);
				o.t2w2 = float4(worldTangent.y,binormal.y,worldNormal.y,worldPos.y);
				o.t2w3 = float4(worldTangent.z,binormal.z,worldNormal.z,worldPos.z);
				return o;
			}

			fixed4 frag( v2f i ) : SV_Target
			{
				fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.xyz;

				// normal
				fixed3 bump = UnpackNormal( tex2D(_BumpTex, i.uv.zw ) );
				bump.xy *= _BumpScale;
				bump.z = sqrt( 1 - saturate( dot( bump.xy , bump.xy ) ) );
				bump = normalize( half3( dot(i.t2w1 , bump ) , dot(i.t2w2, bump ) , dot(i.t2w3, bump ) ) );

				float3 worldPos = float3(i.t2w1.w,i.t2w2.w,i.t2w3.w);
				fixed3 lightDir = normalize( UnityWorldSpaceLightDir(worldPos) );
				fixed3 albedo = tex2D(_MainTex,i.uv.xy).rgb * _Color.rgb;
				fixed3 diffuseColor = _LightColor0.rgb * albedo * saturate( dot( bump , lightDir ) ) ;

				fixed3 viewDir = normalize( UnityWorldSpaceViewDir(worldPos));
				fixed3 halfLambert = normalize( viewDir + lightDir );
				fixed3 specularColor = _LightColor0.rgb * _Specular.rgb * pow( saturate( dot( bump, halfLambert ) ) , _Glow );

				return fixed4( ambientColor + diffuseColor + specularColor , 1 );
			}


			ENDCG
		}
	}
	FallBack "Diffuse"
}
