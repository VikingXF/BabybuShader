// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Unlit alpha-blended shader.
// - no lighting
// - no lightmap support
// - no per-material color

Shader "Babybus/Unlit/Unlit-Shadows-Transparent" {
Properties {
	_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
	_Color ("Main Color", Color) = (1,1,1,1)
	[Toggle] _Transition ("Invert Transition?", Float) = 0
	[KeywordEnum(X,Y)]_AxialXY("X Y axial" , Float) = 0
	_Transitions("Transitions", float) = 0
	_BlendRange("Blend Range" , Range(0,1)) = 1
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
			#pragma shader_feature _TRANSITION_ON
			
			struct appdata_t {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				float4 texcoord : TEXCOORD0;
				UNITY_FOG_COORDS(1)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			fixed _Transitions,_BlendRange;
			
			v2f vert (appdata_t v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.texcoord.zw = v.texcoord;
				
				#if _TRANSITION_ON
				
				#endif
			
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 Maincol = tex2D(_MainTex, i.texcoord.xy);
				#if _AXIALXY_X				
				Maincol.a *= saturate((i.texcoord.z+_Transitions)/_BlendRange);
				
				#elif _AXIALXY_Y
				Maincol.a *= saturate((i.texcoord.w+_Transitions)/_BlendRange);
				
				#endif
				
				fixed4 col = fixed4(_Color.rgb,_Color.a*Maincol.a);
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
		ENDCG
	}
}

}
