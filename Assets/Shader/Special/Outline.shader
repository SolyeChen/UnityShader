Shader "Custom/Special/Outline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_OutlineWidth ("Outline width", Range(0.01, 4)) = 0.01
		_OutlineColor ("Outline Color", color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}

		Pass
		{
            Cull Front
            ZWrite Off
			CGPROGRAM

			#pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

			float _OutlineWidth;
			fixed4 _OutlineColor;

            // v2f vert (appdata v)
            // {
            //     v2f o;
			// 	v.vertex.xy += normalize(v.normal) * _OutlineWidth;
			// 	o.vertex = UnityObjectToClipPos(v.vertex);
            //     return o;
            // }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float3 viewNormal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);
                float2 clipNormal = mul((float2x2)UNITY_MATRIX_P, viewNormal.xy);
                o.vertex.xy += normalize(clipNormal) * _OutlineWidth;
                return o;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                return _OutlineColor;
            }

			ENDCG
		}
        Pass
        {
            Cull Back
            ZTest LEqual
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
			#include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv);
                return fixed4(color.rgb, 1.0);
            }
            ENDCG
        }
       
    }
    Fallback "diffuse"
}
