// Simplified Diffuse shader. Differences from regular Diffuse one:
// - no Main Color
// - fully supports only 1 directional light. Other lights can affect it, but it will be per-vertex/SH.

Shader "Babybus/lightmap/Lightmap Diffuse" {
Properties {
	_MainTex ("Base (RGB)", 2D) = "white" {}
	_LightMap ("Lightmap (RGB)", 2D) = "black" {}
	_LightIntensity ("Light Intensity", Range(0,2)) = 1
}
SubShader {
	Tags { "RenderType"="Opaque" }
	LOD 150

CGPROGRAM
#pragma surface surf Lambert noforwardadd

sampler2D _MainTex;
 sampler2D    _LightMap;
 fixed _LightIntensity;
struct Input {
	float2 uv_MainTex;
	float2 uv2_LightMap;
};

void surf (Input IN, inout SurfaceOutput o) {
	fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
	half4 lm = tex2D (_LightMap, IN.uv2_LightMap);
	o.Albedo = c.rgb*lm*_LightIntensity;
	o.Alpha = c.a;
}
ENDCG
}

Fallback "Mobile/VertexLit"
}
