Shader"Shaders/FirstShader"
{
  Properties
  {
    _Color("Fog Color", Color) = (1,1,1,1)

  }
  SubShader
  {
    Tags
		{
			"Queue" = "Transparent"
		}

		Pass
		{
			Cull Off
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha // standard alpha blending

        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag

        #include "UnityCG.cginc"

        float4 _Color;
        float _redSlider;
        float _greenSlider;
        float _blueSlider;
        float _alphaSlider;


        struct VertexShaderInput
        {
          float4 vertex   : POSITION;
          float3 normal   : NORMAL;
          float2 uv       : TEXCOORD0;
          float3 vertexPos: TEXCOORD2;
          float4 scrPos   : TEXCOORD3;
        };

        struct VertexShaderOutput
        {
          float4 pos: SV_POSITION;
          float2 uv : TEXCOORD0;
          float3 normal: TEXCOORD1;
          float3 vertexPos: TEXCOORD2;
          float4 scrPos   : TEXCOORD3;
          float4 ro       : TEXCOORD4;
        };

        VertexShaderOutput vert(VertexShaderInput v)
        {
          VertexShaderOutput o;

          o.pos = UnityObjectToClipPos(v.vertex);
          o.uv = v.uv;
          o.normal = UnityObjectToWorldNormal(v.normal);
          o.vertexPos = (mul(unity_ObjectToWorld, v.vertex)).xyz;

          return o;
        }
        float4 frag(VertexShaderOutput i):COLOR
        {
          float4 output;
          output = _Color;
          float3 P = i.vertexPos;
          float3 L = normalize(_WorldSpaceLightPos0.xyz);
          float3 N = normalize(i.normal);
          float3 V = normalize(_WorldSpaceCameraPos - P);
          float3 H = normalize(L + V);

          half3 refraction = refract(-V,N,1.5);
          half3 reflection = reflect(-V, N);
          float4 final = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, refraction);
          half3 skyColor = DecodeHDR (final, unity_SpecCube0_HDR);

          output.rgb = skyColor + _Color.rgb;
          output.a = _Color.a;
          return output;
        }

        ENDCG
      }
  }
}
