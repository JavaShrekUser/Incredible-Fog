Shader "Custom/PostProcessing"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [MaterialToggle] _Invert("Invert", Float) = 0
        [MaterialToggle] _Grain("Grain", Float) = 0
        [MaterialToggle] _Blur("Blur", Float) = 0
        _Brightness("Brightness",Range(-0.5,1)) = 0
        _Saturation("Saturation",Range(0,1)) = 0
        _Contrast("Contrast",Range(0,1)) = 0


    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float4 objPos: TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.objPos = v.vertex;
                return o;
            }


            sampler2D _MainTex;
            float _Invert;
            float _Grain;
            float _Blur;
            float _Brightness;
            float _Saturation;
            float _Contrast;

            //---------------------------------------------------
            float4 _MainTex_ST;
            float2 _MainTex_TexelSize;
            float	_KernelSize;
            //---------------------------------------------------

            float rand(float2 pos)
            {
                return frac(sin(dot(pos + _Time.y,
                    float2(12.9898f, 78.233f))) * 43758.5453123f);
            }

            

            float2 randUnitCircle(float2 pos)
            {
                const float PI = 3.14159265f;
                float randVal = rand(pos);
                float theta = 2.0f * PI * randVal;

                return float2(cos(theta), sin(theta));
            }

            float quinterp(float2 f)
            {
                return f * f * f * (f * (f * 6.0f - 15.0f) + 10.0f);
            }

            float perlin2D(float2 pixel)
            {
                float2 pos00 = floor(pixel);
                float2 pos10 = pos00 + float2(1.0f, 0.0f);
                float2 pos01 = pos00 + float2(0.0f, 1.0f);
                float2 pos11 = pos00 + float2(1.0f, 1.0f);

                float2 rand00 = randUnitCircle(pos00);
                float2 rand10 = randUnitCircle(pos10);
                float2 rand01 = randUnitCircle(pos01);
                float2 rand11 = randUnitCircle(pos11);

                float dot00 = dot(rand00, pos00 - pixel);
                float dot10 = dot(rand10, pos10 - pixel);
                float dot01 = dot(rand01, pos01 - pixel);
                float dot11 = dot(rand11, pos11 - pixel);

                float2 d = frac(pixel);

                float x1 = lerp(dot00, dot10, quinterp(d.x));
                float x2 = lerp(dot01, dot11, quinterp(d.x));
                float y = lerp(x1, x2, quinterp(d.y));

                return y;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                float3 weight = float3(0.299, 0.587, 0.114);
                fixed4 col = tex2D(_MainTex, i.objPos);

                float luminance = dot(col.rgb, weight);
                float3 grayscale = luminance.xxx;

                float midpoint = pow(0.5, 2.2);

                float2 pos = i.uv * _ScreenParams.xy;////
                float n = perlin2D(pos);////

                /////////////////////////////////////////////////////////
                fixed3 sum = fixed3(0.0, 0.0, 0.0);
                int _KernelSize = 3;
                float upper = ((_KernelSize - 1) / 2);
                float lower = -upper;

                for (float x = lower; x <= upper; ++x)
                {
                    for (float y = lower; y <= upper; ++y)
                    {
                        fixed2 offset = fixed2(_MainTex_TexelSize.x * x, _MainTex_TexelSize.y * y);
                        sum +=  tex2D(_MainTex, i.objPos + offset);
                    }
                }

                sum /= (_KernelSize * _KernelSize);
                ////////////////////////////////////////////////////////

                // just invert the colors
                col.rgb = (abs(_Invert - col.rgb) + _Brightness)
                    - (1 - _Saturation) * (col.rgb - luminance.xxx)
                    - ((1 - _Contrast) * (col.rgb - midpoint));

                float4 Grainess = (col - _Grain * n);

                return col, Grainess , float4(sum, 1);

                
            }
            ENDCG
        }
    }
}
