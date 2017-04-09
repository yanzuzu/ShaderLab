// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/TransparentTexture"
{
	Properties
	{
		_Color ( "Color" , Color ) = (1,1,1,1)
		_MainTex( "MainTex" , 2d ) = "white"{}
		_AlphaScale( "AlphaScale" , float ) = 1
	}

	SubShader
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		Pass
		{
			Tags{ "LightMode" = "ForwardBase"  }

			Zwrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "Lighting.cginc"

			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _AlphaScale;

			struct a2v
			{
				float3 vertex: POSITION;
				float3 normal: NORMAL;
				float4 texcoord: TEXCOORD0;
			};

			struct v2f
			{
				float4 pos: SV_POSITION;
				float2 uv: TEXCOORD0;
				float3 worldPos: TEXCOORD1;
				float3 worldNormal: TEXCOORD2;
			};

			v2f vert( a2v v )
			{
				v2f o;
				o.pos = UnityObjectToClipPos( v.vertex );
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex );
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.vertex);
				return o;
			}

			fixed4 frag( v2f i ) : SV_Target
			{
				fixed3 lightDir = normalize( UnityWorldSpaceLightDir(i.worldPos) );
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed4 texColor =  tex2D(_MainTex,i.uv);
				fixed3 albedo = texColor * _Color.rgb;
				fixed3 diffuseColor = _LightColor0.rgb * albedo * saturate( dot(lightDir,worldNormal));
				return fixed4(diffuseColor , texColor.a * _AlphaScale );
			}

			ENDCG
		}
	}

	FallBack "Diffuse"
}