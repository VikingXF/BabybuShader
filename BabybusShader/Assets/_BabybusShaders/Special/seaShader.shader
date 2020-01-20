// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Babybus/Special/seaShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		 _ScrollXSpeed ("X Scrll Speed", Range(0, 10)) = 2
        _ScrollYSpeed ("Y Scrll Speed", Range(0, 10)) = 2
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 200

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
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _ScrollXSpeed;
			fixed _ScrollYSpeed;
			
			v2f vert (appdata v)
			{

				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				
				fixed xScrollValue = _ScrollXSpeed * _Time.y;
				fixed yScrollValue = _ScrollYSpeed * _Time.y;
			    v.uv += fixed2(xScrollValue, yScrollValue);
			
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
			
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
