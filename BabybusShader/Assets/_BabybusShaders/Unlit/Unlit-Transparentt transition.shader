
/*
从不同方向透明
xf.2018.10.24

*/
Shader "Babybus/Unlit/Transparent transition" {
Properties {
	_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
	_length("length", float) = -1.18
	_BlendRange("Blend Range" , Range(0,1)) = 1
	[KeywordEnum(Center,Bottom,Right,Top,Left,Before,After)]_TransFormPoint("Fill Origin" , Float) = 0
}

SubShader {
	Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
	LOD 100
	
	ZWrite Off
	Blend SrcAlpha OneMinusSrcAlpha 
	
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

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _length,_BlendRange;
			
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
				
				#if _TRANSFORMPOINT_CENTER
				col.a = col.a*_BlendRange;
				
				#elif _TRANSFORMPOINT_RIGHT 
				col.a = col.a*saturate(1- (i.posWorld.x + _length ) /_BlendRange);
				
				#elif _TRANSFORMPOINT_LEFT
				col.a = col.a*saturate((i.posWorld.x + _length ) /_BlendRange);
				
				#elif _TRANSFORMPOINT_BOTTOM
				col.a = col.a*saturate((i.posWorld.y + _length ) /_BlendRange);
				
				#elif _TRANSFORMPOINT_TOP 
				col.a = col.a*saturate(1- (i.posWorld.y + _length ) /_BlendRange);
				
				#elif _TRANSFORMPOINT_BEFORE 				
				col.a = col.a*saturate((i.posWorld.z + _length ) /_BlendRange);
				
				#elif _TRANSFORMPOINT_AFTER
				col.a = col.a*saturate(1- (i.posWorld.z + _length ) /_BlendRange);
				
				#endif
				
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
				
			}
		ENDCG
	}
}

}
