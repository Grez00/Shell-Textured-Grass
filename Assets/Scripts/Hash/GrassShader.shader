Shader "Custom/GrassShader"
{
    Properties
    {
        _Index ("Index", float) = 0.0
        _Shells ("Shells", float) = 6.0
        _Resolution ("Resolution", Vector) = (100.0, 100.0, 0, 0)
        _ShellColour ("Shell Colour", Color) = (0.0, 1.0, 0.0, 1.0)
        _TipColour ("Tip Colour", Color) = (1.0, 1.0, 0.0, 1.0)
        _BaseColour ("Base Colour", Color) = (0.0, 0.1, 0.0, 1.0)
        _MinLength ("Min Length", float) = 0.0
        _MaxLength ("Max Length", float) = 1.0
        _Frequency ("Frequency", float) = 1.0
        _Magnitude ("Magnitude", float) = 1.0
        _Seed ("Seed", int) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM

            #pragma target 3.0

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 worldpos : TEXCOORD1;
                float3 offset : TEXCOORD2;
                float height : TEXCOORD3;
                float2 hash_uv : TEXCOORD4;
            };

            float _Index;
            float _Shells;

            float4 _Resolution;
            float4 _ShellColour;
            float4 _TipColour;
            float4 _BaseColour;

            float _MinLength;
            float _MaxLength;
            float _Frequency;
            float _Magnitude;

            int _Seed;

            uint2 pcg2d(uint2 v, uint seed) {
                v += seed;
                v = v * 1664525u + 1013904223u;

                v.x += v.y * 1664525u;
                v.y += v.x * 1664525u;

                v = v ^ (v>>16u);

                v.x += v.y * 1664525u;
                v.y += v.x * 1664525u;

                v = v ^ (v>>16u);

                return v;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.worldpos = mul(unity_ObjectToWorld, v.vertex);

                // multiply uv by dimensions of field
                float2 hash_uv = v.uv * _Resolution.xy;
                o.hash_uv = hash_uv;

                // get value of hash at uv coords
                uint2 hash = pcg2d(uint2(hash_uv), _Seed);

                // clamp hash value between 0 and 1
                float hash_length = frac((float) length(hash) / 1000.0);
                o.height = hash_length + (_MaxLength - 1.0);

                float windHash = frac((float) length(pcg2d(uint2(hash_uv * 1000.0), _Seed + 1000)) / 1000.0);
                float windHash2 = frac((float) length(pcg2d(uint2(hash_uv * 1000.0), _Seed + 2000)) / 1000.0);

                o.offset = (_MaxLength * _Index / _Shells) * v.normal;
                o.offset.x += cos(_Time.y * windHash * _Frequency) * (_Index / _Shells) * _Magnitude * windHash2;
                o.offset.z += cos(_Time.y * windHash * _Frequency) * (_Index / _Shells) * _Magnitude * windHash2 * 0.25;
                o.worldpos.xyz += o.offset;

                o.vertex = mul(UNITY_MATRIX_VP, o.worldpos);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 local_uv = float2(frac(i.hash_uv.x), frac(i.hash_uv.y));

                // taper blades
                float dist_from_center = length(local_uv - float2(0.5, 0.5));
                if (dist_from_center > (0.5 * (1.0 - (length(i.offset) / i.height)))){
                    discard;
                }

                fixed4 col;
                if (i.height > i.offset.y && i.offset.y >= _MinLength){
                    if (i.offset.y / i.height > 0.5){
                        col = lerp(_ShellColour, _TipColour, (i.offset.y / i.height) - 0.5);
                    }
                    else{
                        col = lerp(_BaseColour, _ShellColour, (i.offset.y / i.height));
                    }
                }
                else{
                    discard;
                }

                return col;
            }
            ENDCG
        }
    }
}
