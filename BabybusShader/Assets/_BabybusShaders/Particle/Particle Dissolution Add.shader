
Shader "Babybus/Particles/Dissolution_Add" {
    Properties {
        _TintColor ("Diffuse Color", Color) = (0.6985294,0.6985294,0.6985294,1)
        _MainTex ("Diffuse Texture", 2D) = "white" {}
        _N_mask ("N_mask", Float ) = 0.3
        _MaskTexture ("Mask Texture", 2D) = "white" {}
        _C_BYcolor ("C_BYcolor", Color) = (1,0,0,1)
        _N_BY_QD ("N_BY_QD", Float ) = 3
        _N_BY_KD ("N_BY_KD", Float ) = 0.01
        [HideInInspector]_Cutoff ("Alpha cutoff", Range(0,1)) = 0.5
		[Enum(UnityEngine.Rendering.CompareFunction)] _ZTest ("ZTest", Float) = 4  //声明外部控制开关
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend One One
            ZWrite Off
            Cull Off
            ZTest [_ZTest] //获取值应用
			
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
		          						
             sampler2D _MaskTexture; 
			 float4 _MaskTexture_ST;
             sampler2D _MainTex; 
			 float4 _MainTex_ST;
             float4 _TintColor;
             float _N_mask;
             float _N_BY_KD;
             float4 _C_BYcolor;
             float _N_BY_QD;
			 
            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float4 uv0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
				o.uv0.xy = TRANSFORM_TEX(v.texcoord0, _MainTex);
				o.uv0.zw = TRANSFORM_TEX(v.texcoord0, _MaskTexture);

                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos(v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
			
                float4 MainColor = tex2D(_MainTex,i.uv0.xy);
				float4 MaskColor = tex2D(_MaskTexture,i.uv0.zw);
				
                float V_mask = (i.vertexColor.a*_N_mask);
                
				
                float StepA = step(V_mask,MaskColor.r);
                float StepB = step(MaskColor.r,V_mask);
				
                float LeA = lerp((StepB),1,StepA*StepB);
				
                float StepC = step(V_mask,(MaskColor.r+_N_BY_KD));
                float StepD = step((MaskColor.r+_N_BY_KD),V_mask);
				
                float LeB = (LeA-lerp((StepD),1,StepC*StepD));
                float LeC = (LeA+LeB);
                float3 LeD = ((LeB*_C_BYcolor.rgb)*_N_BY_QD);
                float3 emissive = (_TintColor.a*(((_TintColor.rgb*MainColor.rgb)*LeC)+LeD));
                float3 finalColor = emissive + (_TintColor.a*LeD);
                float finalAlpha = (_TintColor.a*(MainColor.a*LeC));
                return fixed4(finalColor,finalAlpha);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"  
}
