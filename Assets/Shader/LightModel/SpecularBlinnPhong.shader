Shader "Custom/LightModel/SpecularBlinnPhong"
{
    Properties
    {
        _Diffuse ("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
        _Specular ("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
        _Gloss ("Gloss", Range(8.0, 256)) = 20   

    }
    SubShader
    {
        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"


            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;

            };

            v2f vert (a2v v)
            {
                v2f o;
                //坐标转换
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityWorldToObjectDir(v.normal);
                o.worldPos = UnityObjectToWorldDir(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

                //通过Unity的内置变量UNITY_LIGHTMODEL_AMBIENT得到了环境光部分。
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //通过法线和光线计算出漫反射光照部分
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb *saturate(dot(worldNormal, worldLight));

                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);
                fixed3 halfDir = normalize(worldLight + viewDir);
                fixed3 specular =  _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

                fixed3 color = ambient + diffuse + specular;

                return fixed4(color, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}
