/*
从不同方向过渡2张贴图变化
xf.2019.5.23
有参与光照烘焙
*/

Shader "Babybus/Special/MobileLight-diagram transitions" {
Properties {
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_MainTex2 ("Base (RGB)2", 2D) = "white" {}
	_length("length", float) = -1.18	
	_Transitions("Transitions", Range(0, 1)) = 0
	[KeywordEnum(Center,Bottom,Right,Top,Left,Before,After)]_TransFormPoint("Fill Origin" , Float) = 0
}

SubShader {
	Tags { "LightMode"="ForwardBase" "RenderType"="Opaque" }
	LOD 100
	
	Pass {  
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			
			// compile shader into multiple variants, with and without shadows
            // (we don't care about any lightmaps yet, so skip these variants)
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
            // shadow helper functions and macros
            #include "AutoLight.cginc"
			
			#pragma shader_feature _TRANSFORMPOINT_CENTER _TRANSFORMPOINT_BOTTOM _TRANSFORMPOINT_RIGHT _TRANSFORMPOINT_TOP _TRANSFORMPOINT_LEFT _TRANSFORMPOINT_BEFORE _TRANSFORMPOINT_AFTER
			struct appdata_t {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
				float3 posWorld :TEXCOORD2;
				
				SHADOW_COORDS(1) // put shadows data into TEXCOORD1
                fixed3 diff : COLOR0;
                fixed3 ambient : COLOR1;
				
				//UNITY_FOG_COORDS(3)
			};

			sampler2D _MainTex,_MainTex2;
			float4 _MainTex_ST;
			fixed _Transitions,_length;
			v2f vert (appdata_t v)
			{
				v2f o;
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				
                half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
                o.diff = nl * _LightColor0.rgb;
                o.ambient = ShadeSH9(half4(worldNormal,1));
                // compute shadows data
                TRANSFER_SHADOW(o)

				
				//UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.texcoord);
				fixed4 col2 = tex2D(_MainTex2, i.texcoord);
				#if _TRANSFORMPOINT_CENTER
				float _BlendRange =_Transitions;
				
				#elif _TRANSFORMPOINT_RIGHT 
				float _BlendRange = saturate(1- (i.posWorld.x + _length ) /_Transitions);
				
				#elif _TRANSFORMPOINT_LEFT
				float _BlendRange = saturate((i.posWorld.x + _length ) /_Transitions);
				
				#elif _TRANSFORMPOINT_BOTTOM
				float _BlendRange = saturate((i.posWorld.y + _length ) /_Transitions);
				
				#elif _TRANSFORMPOINT_TOP 
				float _BlendRange = saturate(1- (i.posWorld.y + _length ) /_Transitions);
				
				#elif _TRANSFORMPOINT_BEFORE 
				float _BlendRange = saturate((i.posWorld.z + _length ) /_Transitions);
				
				#elif _TRANSFORMPOINT_AFTER
				float _BlendRange = saturate(1- (i.posWorld.z + _length ) /_Transitions);
				
				#endif
						
				// compute shadow attenuation (1.0 = fully lit, 0.0 = fully shadowed)
                fixed shadow = SHADOW_ATTENUATION(i);
                // darken light's illumination with shadow, keep ambient intact
                fixed3 lighting = i.diff * shadow + i.ambient;
			
				col.rgb = lerp(col.rgb,col2.rgb,_BlendRange)*lighting;
				
				
				
				//UNITY_APPLY_FOG(i.fogCoord, col);
				UNITY_OPAQUE_ALPHA(col.a);
				return col;
			}
		ENDCG
	}
}

}
