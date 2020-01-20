
Shader "Babybus/Particles/Dissolve Blend" {
    Properties {
        _TintColor ("Color&Alpha", Color) = (1,1,1,1)
        _MainTex ("Diffuse Texture", 2D) = "white" {}
        _N_mask ("N_mask", Float ) = 0.3
        _T_mask ("T_mask", 2D) = "white" {}
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
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Off
            ZTest [_ZTest] //获取值应用
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _T_mask; 
			float4 _T_mask_ST;
            sampler2D _MainTex; 
			float4 _MainTex_ST;
            float4 _TintColor;
            float _N_mask;

            struct VertexInput {
                float4 vertex : POSITION;
                float2 texcoord0 : TEXCOORD0;
                float4 vertexColor : COLOR;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float4 uv0 : TEXCOORD0;
                float4 vertexColor : TEXCOORD1;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.uv0.xy = TRANSFORM_TEX(v.texcoord0, _MainTex);
				o.uv0.zw = TRANSFORM_TEX(v.texcoord0, _T_mask);
                o.vertexColor = v.vertexColor;
                o.pos = UnityObjectToClipPos(v.vertex );
                return o;
            }
            float4 frag(VertexOutput i) : SV_Target {
                fixed4 _MainTex_var = tex2D(_MainTex, i.uv0.xy);
				fixed4 _T_mask_var = tex2D(_T_mask, i.uv0.zw);
				_MainTex_var.rgb *=_TintColor.rgb*i.vertexColor.rgb;
				
				//计算alpha           
                fixed _N_maskcolor = i.vertexColor.a*_N_mask;
              //  fixed leA = step(_N_maskcolor,_T_mask_var.r);
                fixed leB = step(_T_mask_var.r,_N_maskcolor);
                //fixed le_alpha = lerp(leB,1,leA*leB);				
				_MainTex_var.a *= _TintColor.a*leB;
				
                return _MainTex_var;
            }
            ENDCG
        }
    }
    FallBack "Babybus/Particles/Alpha Blended"  
}
