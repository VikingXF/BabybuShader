/*
根据UV XY值进行 贴图变灰跟亮贴图变化

*/

Shader "Babybus/Special/Unlit-diagram UVGrey" {
Properties {
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_Transitions("Transitions", float) = 0
	_BlendRange("Blend Range" , Range(0,1)) = 1
	_Alpha("Alpha" , Range(0,1)) = 1
	[KeywordEnum(X,Y)]_AxialXY("X Y axial" , Float) = 0
	_Intensity ("Intensity", Range(0,2)) = 1
	_Color ("Main Color", Color) = (1,1,1,1)
}

SubShader {
	//Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
	//LOD 100
	
	//ZWrite Off
	//Blend SrcAlpha OneMinusSrcAlpha 
	
	Tags { "RenderType"="Opaque" }
	LOD 100
	Pass {  
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			#pragma shader_feature _AXIALXY_X _AXIALXY_Y
			#include "UnityCG.cginc"
			
			struct appdata_t {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				half4 texcoord : TEXCOORD0;
				float3 posWorld :TEXCOORD2;
				UNITY_FOG_COORDS(1)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _Transitions,_BlendRange,_Alpha;
			fixed _Intensity;
			fixed4 _Color;
			v2f vert (appdata_t v)
			{
				v2f o;
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.texcoord.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
				o.texcoord.zw = v.texcoord;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.texcoord.xy);
				
				float gray = dot(col.rgb, float3(0.299, 0.587, 0.114));
				float4 col2 =_Intensity*_Color;
				col2.rgb*=float3(gray, gray, gray);

				
				#if _AXIALXY_X				
				col.rgb = lerp(col.rgb,col2.rgb,saturate((i.texcoord.z+_Transitions)/_BlendRange));
				
				#elif _AXIALXY_Y
				col.rgb = lerp(col.rgb,col2.rgb,saturate((i.texcoord.w+_Transitions)/_BlendRange));
				
				#endif
				col.a = _Alpha;
				
				UNITY_APPLY_FOG(i.fogCoord, col);
				
				return col;
			}
		ENDCG
	}
}

}
