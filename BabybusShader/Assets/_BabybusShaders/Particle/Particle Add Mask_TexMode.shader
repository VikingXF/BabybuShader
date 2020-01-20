
Shader "Babybus/Particles/Additive Mask_TexMode" {
Properties {
	_TintColor ("Tint Color", Color) = (0.5,0.5,0.5,0.5)
    _MainTex ("Particle Texture", 2D) = "white" {}  
	_Mask ("Mask ( R Channel )", 2D) = "white" {}	
	
	_Angle("Angle" , float) = 0
	_Speed("Speed(X:U Y:V Z: 旋转)",vector) = (1,1,1,1)
	[KeywordEnum(Default , Clamp, Repeat , Mirror , MirrorOnce)]_WrapMode ("WrapMode", Float) = 0
    [Toggle] _ScaleOnCenter("缩放中心", Float) = 1
	
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
			#pragma shader_feature __ _SCALEONCENTER_ON
            #pragma shader_feature _WRAPMODE_DEFAULT _WRAPMODE_CLAMP _WRAPMODE_REPEAT _WRAPMODE_MIRROR _WRAPMODE_MIRRORONCE
       

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
			half4 _Speed;
			half _Angle;
			
			float2 rotateUV(float2 srcUV,half angle )
            {
                //角度转弧度
                angle/=57.3;
                float2x2 rotateMat;
                rotateMat[0] = float2(cos(angle) , -sin(angle));
                rotateMat[1] = float2(sin(angle) , cos(angle));

                return mul(rotateMat , srcUV);
            }
            float2 TransfromUV(float2 srcUV,half4 argST ,half angle )
            {
                #if _SCALEONCENTER_ON
                    srcUV -= 0.5;
                #endif
                srcUV = rotateUV(srcUV, (angle+(_Speed.z*_Time.y)));
                srcUV = srcUV * argST.xy + argST.zw;
                #if _SCALEONCENTER_ON
                    srcUV += 0.5;
                #endif
                return srcUV;
            }
			
            v2f vert (appdata_t v)
            {
                v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.vertex = UnityObjectToClipPos(v.vertex);				
                o.color = v.color * _TintColor;
                _MainTex_ST.zw +=_Speed.xy*_Time.y;
                
                o.texcoord.xy = TransfromUV(v.texcoord,_MainTex_ST,_Angle);				
				o.texcoord.zw = TRANSFORM_TEX(v.texcoord,_Mask);
				
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
         


            fixed4 frag (v2f i) : SV_Target
            {
				#if _WRAPMODE_CLAMP
                    float2 uv = saturate(i.texcoord.xy);
                #elif _WRAPMODE_REPEAT
                    float2 uv = frac(i.texcoord.xy) ;
                #elif _WRAPMODE_MIRROR
                    float2 uv = frac(abs(i.texcoord.xy));
                #elif _WRAPMODE_MIRRORONCE  
                    float2 uv = saturate(abs(i.texcoord.xy));
                #else
                    float2 uv = i.texcoord.xy;
                #endif
				
                fixed4 col = tex2D(_MainTex, uv);
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