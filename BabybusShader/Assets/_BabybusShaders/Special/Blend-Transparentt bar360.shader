/*

模拟UI360 度时钟进度条效果
贴图360度转变透明
xf.2019.5.28
贴图透明
*/

Shader "Babybus/Special/TransparentBlend bar360" {
Properties {
	_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
	_Cutoff ("Alpha cutoff", Range(-0.01,1.01)) = 0.5
	[KeywordEnum(Counterclockwise,clockwise)]_TransFormPoint("Fill Origin" , Float) = 0
	[KeywordEnum(Bottom,Right,Top,Left)]_Direction("Direction" , Float) = 0
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
			#pragma shader_feature _TRANSFORMPOINT_COUNTERCLOCKWISE _TRANSFORMPOINT_CLOCKWISE
			#pragma shader_feature _DIRECTION_BOTTOM _DIRECTION_RIGHT _DIRECTION_TOP _DIRECTION_LEFT
			
			#include "UnityCG.cginc"

			struct appdata_t {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				half4 texcoord : TEXCOORD0;
				UNITY_FOG_COORDS(1)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			 fixed _Cutoff;
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.texcoord.zw = v.texcoord;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.texcoord.xy);
				float2 uv_center = i.texcoord.zw*2.0-1;	  
				
                #if _DIRECTION_BOTTOM
				float uv_dir = atan2(uv_center.x,uv_center.y)*0.1592357+0.5;
				
				#elif _DIRECTION_TOP
				float uv_dir = atan2(-uv_center.x,-uv_center.y)*0.1592357+0.5;
				
				#elif _DIRECTION_LEFT
				float uv_dir = atan2(uv_center.y,uv_center.x)*0.1592357+0.5;
				
				#elif  _DIRECTION_RIGHT
				float uv_dir = atan2(-uv_center.y,-uv_center.x)*0.1592357+0.5;
				
				#endif
				
				uv_dir = step(uv_dir,_Cutoff);
				
				#if _TRANSFORMPOINT_COUNTERCLOCKWISE
				
				col.a = saturate(col.a-uv_dir);
				
				#elif _TRANSFORMPOINT_CLOCKWISE
				
				col.a = saturate(col.a-(1-uv_dir));
				
				#endif
				
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
				//return fixed4(uv_dir,uv_dir,uv_dir,1);
			}
		ENDCG
	}
}

}
