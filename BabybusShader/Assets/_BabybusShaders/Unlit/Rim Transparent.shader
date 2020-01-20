// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Unlit alpha-blended shader.
// - no lighting
// - no lightmap support
// - no per-material color

Shader "Babybus/Unlit/Rim Transparent" {
Properties {
	_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
	_Alpha ("Base Alpha", Range (0,1)) = 1
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
			
			
			struct v2f
            {
                float4 vertex:POSITION;
                float4 uv:TEXCOORD0;
                float4 NdotV:COLOR;
            };
 
            sampler2D _MainTex;
            float4 _RimColor;
            float _RimPower,_RimIntensity;
			float _Alpha;
			
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
                c.rgb += pow((1-IN.NdotV.x) ,_RimPower)* _RimColor.rgb *_RimIntensity*_RimColor.a;
				c.a *= _Alpha;
                return c;
            }
			
		ENDCG
	}
}

}
