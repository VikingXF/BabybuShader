
Shader "Babybus/Particles/Alpha Blended Mask2" {
	Properties {
    _TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
    _MainTex ("Particle Texture", 2D) = "white" {}
	_Mask ("Mask ( R Channel )", 2D) = "white" {}	
	[Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("ZTest", Float) = 4  //声明外部控制开关
}

Category {
    Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" }
    Blend SrcAlpha OneMinusSrcAlpha
    Cull Off Lighting Off ZWrite Off
	ZTest [_ZTest] //获取值应用
	
    SubShader {
        Pass {
			Stencil {
                Ref 2
                Comp NotEqual
                Pass keep 
                ZFail decrWrap
            }
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
                o.texcoord.xy = TRANSFORM_TEX(v.texcoord,_MainTex);
				o.texcoord.zw = TRANSFORM_TEX(v.texcoord,_Mask);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }


            fixed4 frag (v2f i) : SV_Target
            {

                fixed4 col = tex2D(_MainTex, i.texcoord.xy);
				col.a *= tex2D(_Mask, i.texcoord.zw).r;
				
                col.a = saturate(col.a); // alpha should not have double-brightness applied to it, but we can't fix that legacy behaior without breaking everyone's effects, so instead clamp the output to get sensible HDR behavior (case 967476)
                UNITY_APPLY_FOG(i.fogCoord, col);
                return 2.0f * i.color * col;
            }
            ENDCG
        }
    }
}
}