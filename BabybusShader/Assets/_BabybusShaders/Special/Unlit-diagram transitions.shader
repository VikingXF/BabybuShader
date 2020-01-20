/*
从不同方向过渡2张贴图变化
xf.2018.10.30

*/

Shader "Babybus/Special/Unlit-diagram transitions" {
Properties {
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_MainTex2 ("Base (RGB)2", 2D) = "white" {}
	_length("length", float) = -1.18	
	_Transitions("Transitions", Range(0, 1)) = 0
	[KeywordEnum(Center,Bottom,Right,Top,Left,Before,After)]_TransFormPoint("Fill Origin" , Float) = 0
}

SubShader {
	Tags { "RenderType"="Opaque" }
	LOD 100
	
	Pass {  
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#pragma shader_feature _TRANSFORMPOINT_CENTER _TRANSFORMPOINT_BOTTOM _TRANSFORMPOINT_RIGHT _TRANSFORMPOINT_TOP _TRANSFORMPOINT_LEFT _TRANSFORMPOINT_BEFORE _TRANSFORMPOINT_AFTER
			struct appdata_t {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				half2 texcoord : TEXCOORD0;
				float3 posWorld :TEXCOORD2;
				UNITY_FOG_COORDS(1)
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
				UNITY_TRANSFER_FOG(o,o.vertex);
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
								
				col.rgb = lerp(col.rgb,col2.rgb,_BlendRange);
				
				
				
				UNITY_APPLY_FOG(i.fogCoord, col);
				UNITY_OPAQUE_ALPHA(col.a);
				return col;
			}
		ENDCG
	}
}

}
