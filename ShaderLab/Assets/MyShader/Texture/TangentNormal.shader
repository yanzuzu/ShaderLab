Shader "Custom/TangentNormal"
{
	Properties
	{
		_Color( "Color" , Color ) = (1,1,1,1)
		_MainTex( "MainTex", 2d ) = "white"{}
		_BumpTex( "BumpTex", 2d ) = "bump"{}
		_BumpScale( "BumpScale", float ) = 1
		_Specular( "Specular" , Color ) = (1,1,1,1)
		_Glow("Glow", float ) = 20
	}

	SubShader
	{
		Tags{ "LightMode" = "ForwardBase" }
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
				float3 tangentLight: TEXCOORD1;
				float3 tangentView: TEXCOORD2;
			};

			v2f vert( a2v v )
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);

				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpTex);

				TANGENT_SPACE_ROTATION;
				o.tangentLight = mul(rotation,ObjSpaceLightDir(v.vertex));
				o.tangentView = mul(rotation,ObjSpaceViewDir(v.vertex));
				return o;
			}

			fixed4 frag( v2f i ) : SV_Target
			{
				fixed3 ambientColor = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed4 packedNormal = tex2D(_BumpTex , i.uv.zw);
				fixed3 tangentNormal = UnpackNormal(packedNormal);
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt( 1 - saturate( dot( tangentNormal.xy , tangentNormal.xy ) ) );
				fixed3 tangentLight = normalize(i.tangentLight);
				fixed3 tangentView = normalize(i.tangentView);
				fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;
				fixed3 diffuseColor = _LightColor0.rgb * albedo * saturate( dot( tangentLight , tangentNormal ) );

				fixed3 halfLambert = normalize(tangentView + tangentLight );
				fixed3 specularColor = _LightColor0.rgb * _Specular.rgb * pow( saturate( dot( tangentNormal , halfLambert ) ) , _Glow );

				return fixed4( ambientColor + diffuseColor + specularColor , 1 );

			}

			ENDCG
		}
	}

	FallBack "Diffuse"

}