// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Unlit alpha-blended shader.
// - no lighting
// - no lightmap support
// - no per-material color

Shader "Babybus/Unlit/Rim Transparent An" {
Properties {
	_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
	_Color ("Main Color", Color) = (1,1,1,1)
	
	_RimColor("Rim Color", Color) = (0.5,0.5,0.5,1)  
    _RimPower("Rim Power", Range(0.0, 5)) = 0.1 
	_RimIntensity("Rim Intensity", Range(0.0, 10)) = 3  	
}

SubShader {
	Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
	LOD 100
	
	ZWrite On
	Blend SrcAlpha OneMinusSrcAlpha 
	
	Pass {  
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"  
			
			struct appdata_t {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				float3 normal:NORMAL;
			};
			
			struct v2f
            {
                float4 vertex:POSITION;
                float2 uv:TEXCOORD0;
                float NdotV:TEXCOORD1;
            };
 
            sampler2D _MainTex;
            float4 _RimColor;
            float _RimPower,_RimIntensity;
			
			float4 _Color;
			
            v2f vert(appdata_base v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                float3 normalDirection = normalize(WorldSpaceViewDir(v.vertex));
				float3 normalDir =  normalize( mul(float4(v.normal,0.0),unity_WorldToObject).xyz);
                o.NdotV.x = saturate(dot(normalDir,normalDirection));
                return o;
            }
 
            half4 frag(v2f IN):COLOR
            {
                half4 c = tex2D(_MainTex,IN.uv);  
				fixed3 Rim = pow((1-IN.NdotV) ,_RimPower) *_RimIntensity*_RimColor.a;
				c.rgb = lerp(c.rgb,_RimColor.rgb,Rim.r);
                //c.rgb += pow((1-IN.NdotV.x) ,_RimPower)* _RimColor.rgb *_RimIntensity*_RimColor.a;

                return c*_Color;
            }
			
		ENDCG
	}
}

}
