
Shader "Babybus/Particles/Mask(customDataUV)" {
Properties {
	_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
    _MainTex ("Particle Texture", 2D) = "white" {}  
	_Mask ("Mask ( R Channel )", 2D) = "white" {}	
	[Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("ZTest", Float) = 4  //声明外部控制开关
	[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend ("Src Blend Mode", Float) = 5
    [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend ("Dst Blend Mode", Float) = 1
}

Category {
    Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
    Blend [_SrcBlend] [_DstBlend]
    Cull Off Lighting Off ZWrite Off
	ZTest [_ZTest] //获取值应用
    SubShader {
        Pass {

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0
            #pragma multi_compile_fog
            #include "UnityCG.cginc"

       

            struct appdata_t {
                float4 vertex : POSITION;
                fixed4 color : COLOR;
                float4 texcoord : TEXCOORD0;  
				UNITY_VERTEX_INPUT_INSTANCE_ID				
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
                float4 texcoord : TEXCOORD0;
				float2 DataUV : TEXCOORD2;
                UNITY_FOG_COORDS(1)
				UNITY_VERTEX_OUTPUT_STEREO
            };
			sampler2D _MainTex,_Mask;          
            float4 _MainTex_ST,_Mask_ST;
			fixed4 _TintColor;
            v2f vert (appdata_t v)
            {
                v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.vertex = UnityObjectToClipPos(v.vertex);				
                o.color = v.color * _TintColor;
				o.DataUV = v.texcoord.zw;
                o.texcoord.xy = TRANSFORM_TEX(v.texcoord.xy,_MainTex);
				o.texcoord.zw = TRANSFORM_TEX(v.texcoord.xy,_Mask);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
         


            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.texcoord.xy+i.DataUV);
				col.a *= tex2D(_Mask, i.texcoord.zw).r;
                col.a = saturate(col.a); 

                UNITY_APPLY_FOG_COLOR(i.fogCoord, col, fixed4(0,0,0,0)); // fog towards black due to our blend mode
                return 2.0f * i.color  * col;
            }
            ENDCG
        }
    }
}
}
