Shader "Unlit/Move"
{
    
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _GlowColor ("Glow Color", Color) = (1,0.2391481,0.1102941,1)
		_Start_y("index", float) = 0.7
		_Ctor("ctor", float) = 0.2
		_Dia("Dia", float) = 0.2

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed3 normal:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD1;

            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Start_y;
            float _Ctor;
            float _Dia;
             float4 _GlowColor;

            v2f vert (appdata v)
            {
                 v2f o;
                 fixed3 new_normal=v.normal;
                  float end_y=_Start_y-_Dia;
                  float world_cir = end_y+(_Dia/2);
                  float cir_y =_Dia/2;
                  float cir_x =abs(world_cir-v.uv.y);
                  float angle= asin(min(cir_x/cir_y,1));
                  float need_dis =cir_y*cos(angle);
                  v.vertex+=need_dis*float4(new_normal,0) *_Ctor;
                  o.screenPos.x=need_dis;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                col+=_GlowColor*i.screenPos.x*4;
                return col;
            }
            ENDCG
        }
    }
}

