
Shader "Babybus/Rim/vertex Rim outL3" {
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}		
		_Color("Main Color", Color) = (1,1,1,1)
		
		[Toggle] _Rim ("Invert Rim?", Float) = 0
		_RimColor("RimColor", Color) = (1,1,1,1)  
		_RimPower("RimPower", Range(0, 10.0)) = 0.1  
		_RimIntensity("RimIntensity", Range(0, 3.0)) = 0.1 
		
		[Toggle] _Outl ("Invert Outline?", Float) = 0
		_OutlineColor ("Outline Color", Color) = (0,0,0,0)
		_Outline("Outline", Range(0, 20.0)) = .01
		_Factor("Factor", Range(0,1)) = .5
				
    }
    SubShader {
	    Pass {
			Cull Back
			//Offset -10, -10
			ZWrite On
       		Lighting Off
			Blend SrcAlpha OneMinusSrcAlpha
            CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"
				#pragma shader_feature _RIM_ON
				
                struct appdata {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float2 texcoord : TEXCOORD0;
                };

                struct v2f {
                    float4 pos : SV_POSITION;
                    float2 uv : TEXCOORD0;
					float3 Emissive : TEXCOORD1;
                   
                };
				
				sampler2D _MainTex;
                float4 _MainTex_ST;
				fixed4 _Color;
				fixed4 _RimColor;  
				float _RimPower,_RimIntensity; 

                v2f vert (appdata_base v) {
                    v2f o;
                    o.pos = UnityObjectToClipPos (v.vertex);
					
					#if _RIM_ON
                    float3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
					//float3  viewnormal = normalize(v.normal);
					float3  viewnormal = normalize( mul(float4(v.normal,0.0),unity_WorldToObject).xyz);
					float Rim=1 -dot(viewDir,viewnormal);
					o.Emissive = _RimColor.rgb * pow(Rim,_RimPower) *_RimIntensity;  
					#endif
					
                    o.uv = v.texcoord.xy;
                    return o;
                }

             
                fixed4 frag(v2f i) : COLOR {
                    fixed4 texcol = tex2D(_MainTex, i.uv);
                    texcol *= _Color;
					
					#if _RIM_ON
                    texcol.rgb += i.Emissive;
					#endif
					
                    return texcol;
                }
            ENDCG
        }
	    Pass
		{
			
			Cull Front
			ZWrite On			
			
			//Offset 5, 5
			
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#pragma shader_feature _OUTL_ON

			
			float _Outline;			
			fixed4 _OutlineColor;
			fixed _Factor;
			
			
			struct appdata {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
            };			
			struct v2f
			{
				float4 pos:SV_POSITION;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				//o.pos = UnityObjectToClipPos(v.vertex);
				o.pos = v.vertex;
				#if _OUTL_ON
				float3 dir = normalize(v.vertex.xyz);
				float3 dir2 = normalize(v.normal);
				dir = lerp(dir, dir2,_Factor);
				dir = mul((float3x3)UNITY_MATRIX_IT_MV, dir);	
				float2 offset = TransformViewToProjection(dir.xy);
				offset = normalize(offset);
				o.pos.xy += offset * o.pos.z * _Outline;				
                #endif
				o.pos = UnityObjectToClipPos(o.pos);
				return o;
			}

			fixed4 frag(v2f i):COLOR
			{
				return _OutlineColor;
			}
			ENDCG
		}
        
		
    }
	Fallback "Unlit/Texture"
}