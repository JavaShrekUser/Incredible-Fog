Shader "Custom/PPFog"
{
  Properties
  {
      _MainTex ("Texture", 2D) = "white" {}
      [MaterialToggle]_Invert  ("Invert", Float) = 0
      [MaterialToggle]_Distort ("Distort", Float) = 0
      _Brightness ("Brightness", Range(0,1)) = 1
      _Saturation ("Saturation", Range(0,1)) = 1
      _Contrast ("Contrast", Range(0,1)) = 1
      _Size  ("Distort Amount", Range(0,50)) = 3
      _Density("Fog Density", float) = 1
      _Color ("Fog Color", Color) = (1,1,1,1)

  }
  SubShader
  {
      // No culling or depth
      Cull Off ZWrite Off ZTest Always
      Tags
  		{
  			"Queue" = "Transparent"
  		}

      Pass
      {
          CGPROGRAM
          #pragma vertex vert
          #pragma fragment frag

          #include "UnityCG.cginc"

          sampler2D _MainTex;
          float _Invert;
          float _Distort;
          float _Brightness;
          float _Saturation;
          float _Contrast;
          float _Size;
          float _Density;
          float4 _Color;

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

          float rand(float2 p){
    				return frac(sin(dot(p ,float2(12.9898,78.233))) * 43758.5453);
    			}

    			float noise(float2 x)
    			{
    				float2 i = floor(x);
    				float2 f = frac(x);

    				float a = rand(i);
    				float b = rand(i + float2(1.0, 0.0));
    				float c = rand(i + float2(0.0, 1.0));
    				float d = rand(i + float2(1.0, 1.0));
    				float2 u = f * f * f * (f * (f * 6 - 15) + 10);

    				float x1 = lerp(a,b,u.x);
    				float x2 = lerp(c,d,u.x);
    				return lerp(x1,x2,u.y);
    			}

    			float fbm(float2 x)
    			{
    				float scale = log(_Density);
    				float res = 0;
    				float w = 4;
    				for(int i=0; i<4; ++i)
    				{
    					res += noise(x * w);
    					w *= 1.5;
    				}
    				return res * scale;
    			}


          float4 frag(VertexShaderOutput i):COLOR
          {

              float3 P = i.vertexPos;
              float3 L = normalize(_WorldSpaceLightPos0.xyz);
              float3 N = normalize(i.normal);
              float3 V = normalize(_WorldSpaceCameraPos - P);
              float3 H = normalize(L + V);

              // GAUSSIAN BLUR SETTINGS {{{
              float Directions = 16.0; // BLUR DIRECTIONS
              float Quality = 10.0; // BLUR QUALITY
              float Size = _Size; // BLUR SIZE
              float Pi = 6.28318530718; // Pi*2
              // GAUSSIAN BLUR SETTINGS }}}

              fixed4 col = tex2D(_MainTex, i.uv);


              // just invert the colors
              if(_Invert == 1){
                col.rgb = 1 - col.rgb;
              }
              if(_Distort == 1){
                //float2 Radius = Size/_ScreenParams.xy;
                //for( float d=0.0; d<Pi; d+=Pi/Directions)
                //{
                //for(float j=1.0/50; j<=1.0; j+=1.0/Quality)
                    //{
                        //col += tex2D( _MainTex, i.uv+float2(cos(d),sin(d))*Radius*j);
                  //  }
              //  }
              //  col /= Quality * Directions - 15.0;
                col += float4(tex2D( _MainTex, i.uv+0.005).rgb, 0.1);
                float rd = fbm(i.uv + _Time.x);
                float3 col_fog = {rd,rd,rd};
                col_fog *= _Color;
                col.rgb = lerp(col.rgb, col_fog,0.1);

              }




              col.rgb = col.rgb * _Brightness;
              float grey = (col.r + col.b + col.g)/3;
              float distr = abs(col.r - grey);
              float distg = abs(col.g - grey);
              float distb = abs(col.b - grey);
              _Saturation = 1-_Saturation;
              if(col.r > grey){
                col.r = col.r - distr*_Saturation;
              }
              else{
                col.r = col.r + distr*_Saturation;
              }
              if(col.b > grey){
                col.b = col.b - distb*_Saturation;
              }
              else{
                col.b = col.b + distb*_Saturation;
              }
              if(col.g > grey){
                col.g = col.g - distg*_Saturation;
              }
              else{
                col.g = col.g + distg*_Saturation;
              }

              col.rgb = saturate(lerp(half3(0.5,0.5,0.5), col.rgb, _Contrast));

              return col;
          }
        ENDCG
      }
  }
}
