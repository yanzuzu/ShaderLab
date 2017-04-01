// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/WaterMobile" {
	Properties
	{
		_WaterTex ("Normal Map (RGB), Foam (A)", 2D) = "white" {}
		_DepthTex ("Depth Map", 2D) = "white" {}
		_Color0 ("Shallow Color", Color) = (1,1,1,1)
		_Color1 ("Deep Color", Color) = (0,0,0,0)
		_Specular ("Specular", Color) = (0,0,0,0)
		_Shininess ("Shininess", Range(0.01, 511.0)) = 255.0
		_Tiling ("Tiling", Range(0.025, 0.25)) = 0.25
		_ReflectionTint ("Reflection Tint", Range(0.0, 1.0)) = 0.8
		_ReflectionColor("Reflection Color", Color) = (1,1,1,1)
		_WaveHeight("Wave Height", float) = 0
		_WaveSpeed("Wave Speed", float) = 1
		_WaveScale ("Wave Scale", float) = 1
		_LightDir ("Light direction", Vector) = (139, -139, 182,1)
	}	
	SubShader {
				LOD 1000
	Pass 	{
				Tags {"RenderType" = "Transparent" "Queue" = "Transparent-10" }
				
				Blend SrcAlpha OneMinusSrcAlpha
				ZTest LEqual
				
				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fog
				#pragma fragmentoption ARB_precision_hint_fastest
				#pragma only_renderers opengl d3d9 gles gles3 metal
				//#pragma target 2.0
				//#pragma only_renderers d3d9 gles opengl
				

				#include "UnityCG.cginc"
				
				sampler2D _DepthTex;
				sampler2D _WaterTex;
				
				fixed3 _ReflectionColor;
				
				fixed _WaveHeight;
				fixed _WaveSpeed;
				fixed _WaveScale;
				
				fixed4 _Color0;
				fixed4 _Color1;
				fixed4 _Specular;
				fixed _Shininess;
				fixed _Tiling;
				fixed _ReflectionTint;
				
				fixed4 _LightDir;
				
				struct WaterInput
				{
					float4 position  : POSITION;
					float2 uv1: TEXCOORD0;
					float2 uv2: TEXCOORD1;
					fixed2 depthParams : TEXCOORD2;
					fixed3 viewT : TEXCOORD3;
					
					UNITY_FOG_COORDS(4)
				};
				
				WaterInput vert(appdata_full v)  
				{
					WaterInput o;
					o.viewT = WorldSpaceViewDir(v.vertex);

					//o.normal = mul( _Object2World, float4( v.normal, 0.0 ) ).xyz;
					o.depthParams.xy = v.texcoord.xy;
									
					//fixed water = sin((v.vertex.x+v.vertex.z)*_WaveScale+(_Time.y*_WaveSpeed));
					//v.vertex.y += water*_WaveHeight;


					o.position = UnityObjectToClipPos(v.vertex);
					
					//float time = fmod_Time.x
					
					float2 uv = v.texcoord;
					float offsetTime1 = fmod(_Time.x * 0.5f, 1.0f);
					float offsetTime2 = fmod(_Time.x * 0.5f * 0.3f, 1.0f);
					float2 tiling = uv.xy*200 * _Tiling;
					o.uv1 = tiling + offsetTime1;
					o.uv2 = float2(-tiling.y*0.3f, tiling.x*0.3f) - offsetTime2;
					
					

					UNITY_TRANSFER_FOG(o,o.position);
					return o;
				}
				
				fixed4 frag(WaterInput IN) : COLOR 
				{
					fixed3 lightDir = normalize(_LightDir.xyz);
					fixed3 viewVec = normalize(IN.viewT.xyz);

					// Calculate the object-space normal (Z-up)
					
					//Moved there to vertex shader
					//float offsetTime = _Time.x * 0.5f;
					//half2 tiling = IN.worldPos.xz * _Tiling;
					//half2 uv1 = tiling + offsetTime;
					//half2 uv2 = half2(-tiling.y*0.3f, tiling.x*0.3f) - offsetTime*0.3f;
					
					fixed3 nmap = UnpackNormal((tex2D(_WaterTex, IN.uv1) + tex2D(_WaterTex, IN.uv2)) * 0.5f).rgb;
					nmap.xyz = nmap.xzy;
					// Calculate the color tint
					fixed depth = tex2D(_DepthTex, IN.depthParams.xy).a;
					fixed4 col;
					
					// Dot product for fresnel effect
					fixed3 normal = normalize(nmap);
					//half3 normal = normalize(IN.normal + nmap);
					//half3 normal = normalize( half3(IN.normal.x + nmap.x, IN.normal.y, IN.normal.z + nmap.z));
					//half3 normal = normalize( half3(IN.normal.x + nmap.x, IN.normal.y * nmap.y, IN.normal.z + nmap.z));

					fixed fresnelDot = dot(viewVec, normal);
					fixed fresnel = (0.75*fresnelDot*fresnelDot)+0.25f;

		//return fixed4(fresnel.xxx, 1.0f);
					
					col.rgb = lerp(_Color1.rgb, _Color0.rgb, depth);
								
					fixed3 reflection = (1.0f-fresnel) * _ReflectionColor.xyz * _ReflectionTint;

		//return fixed4(reflection, 1.0f);
					
					col.a = (1-(depth*depth));//+0.5f;
					
					// Calculate the initial material color
					col.rgb = lerp(reflection, col.rgb, saturate(fresnel+depth));
		//return fixed4(col.rgb, 1.0f);
		
					
					// Calculate the amount of illumination that the pixel has received already
					fixed3 emission = col.rgb+(1.0f-fresnel)*_Specular.xyz*_Specular.w;
		
					emission *= col.rgb;

		
					
					col.rgb *= 1.0f - (fresnel*0.75f);
									
					fixed reflectiveFactor = max(0.0f, dot(viewVec, reflect(lightDir, normal)));
		//return fixed4(reflectiveFactor.xxx, 1.0f);
				
					fixed diffuseFactor = max(0.0f, dot(normal, -lightDir));
		//return fixed4(diffuseFactor.xxx, 1.0f);

					fixed specularFactor = pow(reflectiveFactor, _Shininess)*col.a * _LightDir.w;
		//return fixed4(specularFactor.xxx, 1.0f);
					
					col.rgb = ((col.rgb * diffuseFactor + specularFactor* _Specular.xyz));
					col.rgb += emission;

					UNITY_APPLY_FOG(IN.fogCoord, col);

					return col;
				}	
				ENDCG		
			}
	} 
	SubShader {
			LOD 100
	Pass 	{
				Tags {"RenderType" = "Transparent" "Queue" = "Transparent-10" }
				
				Blend SrcAlpha OneMinusSrcAlpha
				ZTest LEqual
				
				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag
				#pragma fragmentoption ARB_precision_hint_fastest
				#pragma only_renderers opengl d3d9 gles gles3 metal
				//#pragma target 2.0
				//#pragma only_renderers d3d9 gles opengl
				

				#include "UnityCG.cginc"
				
				sampler2D _DepthTex;
						
				fixed4 _Color0;
				fixed4 _Color1;
				
				struct WaterInput
				{
					fixed4 position  : POSITION;
					fixed2 depthParams : TEXCOORD0;
				};
				
				WaterInput vert(appdata_full v)  
				{
					WaterInput o;					
					o.depthParams.xy = v.texcoord.xy;									
					o.position = UnityObjectToClipPos(v.vertex);

					return o;
				}
				
				fixed4 frag(WaterInput IN) : COLOR 
				{
					// Calculate the color tint
					fixed depth = tex2D(_DepthTex, IN.depthParams.xy).a;
					fixed4 col;									
					
					col.rgb = lerp(_Color1.rgb, _Color0.rgb, depth);	
					col.a = (1-(depth*depth));//+0.5f;
					 
					return col;
				}	
				ENDCG		
			}
	} 
}

