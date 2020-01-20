
Shader "Babybus/Particles/Additive Color(FlowLight)" {
Properties {
    _TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
    _MainTex ("Particle Texture", 2D) = "white" {}   
	[Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("ZTest", Float) = 4  //声明外部控制开关
}

Category {
    Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
    Blend SrcAlpha One
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
                float2 texcoord : TEXCOORD0;  
				UNITY_VERTEX_INPUT_INSTANCE_ID				
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
                float4 texcoord : TEXCOORD0;
                UNITY_FOG_COORDS(1)
				UNITY_VERTEX_OUTPUT_STEREO
            };
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
            fixed4 _TintColor;


            v2f vert (appdata_t v)
            {
                v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.vertex = UnityObjectToClipPos(v.vertex);				
                o.color = v.color;
                //o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
				o.texcoord =  ComputeScreenPos(o.vertex);
				
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
         


            fixed4 frag (v2f i) : SV_Target
            {
                
				fixed4 col = 2.0f * i.color * _TintColor * tex2D(_MainTex, i.texcoord.xy/i.texcoord.w *_MainTex_ST.xy +_MainTex_ST.zw);
                col.a = saturate(col.a); 

                UNITY_APPLY_FOG_COLOR(i.fogCoord, col, fixed4(0,0,0,0)); // fog towards black due to our blend mode
                return col;
            }
            ENDCG
        }
    }
}
}
