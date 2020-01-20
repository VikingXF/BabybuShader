Shader "Babybus/Special/Unlitwater"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_ReflectionTex ("Reflect", 2D) = "white" {}
		_NoiseTex ("NoiseTex", 2D) = "white" {}
		_AlphaTex ("AlphaTex", 2D) = "white" {}
		_WaveSpeed ("WaveSpeed", float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex,_ReflectionTex,_NoiseTex,_AlphaTex;
			float4 _MainTex_ST,_ReflectionTex_ST;
			fixed _WaveSpeed;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv.zw = TRANSFORM_TEX(v.uv, _ReflectionTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv.xy);
				fixed4 NoiseTex = tex2D(_NoiseTex,i.uv.xy);
				fixed4 AlphaTex = tex2D(_AlphaTex,i.uv.xy);
				fixed4 ReTex = (tex2D(_ReflectionTex, i.uv.zw + float2(_Time.x * _WaveSpeed+ NoiseTex.r/3 , 0)) + tex2D(_ReflectionTex, float2(1-i.uv.w,i.uv.z) + float2(_Time.x * _WaveSpeed + NoiseTex.r/3, 0)))/2;
				col =(1-AlphaTex.r)*col + AlphaTex.r*ReTex;
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
