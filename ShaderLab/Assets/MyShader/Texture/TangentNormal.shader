Shader "Custom/TangentNormal"
{
	Properties
	{
		_Color("Color",Color ) = (1,1,1,1)
		_MainTex("MainTex" , 2D ) = "white"{}
		_BumpMap("BumpMap", 2D ) = "bump"{}
		_BumpScale("BumpScale",Float) = 1
		_Specular("Specular",Color) = (1,1,1,1)
		_Glow("Glow",float ) = 20
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
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
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
				float3 tangentLight : TEXCOORD0;
				float3 tangentViewDir: TEXCOORD1;
				float4 uv : TEXCOORD2;
			};

			v2f vert( a2v v )
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				TANGENT_SPACE_ROTATION;
				o.tangentLight = mul( rotation , ObjSpaceLightDir(v.vertex) ).xyz;
				o.tangentViewDir = mul( rotation, ObjSpaceViewDir(v.vertex) ).xyz;
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);
				return o;
			}

			fixed4 frag( v2f i ) : SV_Target
			{
				fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 tangentLight = normalize(i.tangentLight);
				fixed3 tangentView = normalize(i.tangentViewDir);

				fixed4 packNormal = tex2D(_BumpMap, i.uv.zw );
				fixed3 tangentNormal = UnpackNormal(packNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt( 1 - saturate( dot( tangentNormal.xy , tangentNormal.xy ) ) );
				fixed3 albedo = tex2D(_MainTex, i.uv ).rgb * _Color.rgb;
				fixed3 diffuseColor = _LightColor0.rgb * albedo * saturate( dot( tangentNormal , tangentLight ) );

				fixed3 halfLambert = normalize( tangentView + tangentLight );
				fixed3 specularColor = _LightColor0.rgb * _Specular.rgb * pow( saturate( dot(halfLambert , tangentNormal ) ) , _Glow );

				return fixed4( ambientColor + diffuseColor + specularColor   , 1 );
			}


			ENDCG

		}
	}
	FallBack "Diffuse"
}