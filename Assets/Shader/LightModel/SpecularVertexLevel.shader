Shader "Custom/LightModel/SpecularVertexLevel"
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
                float3 color : COLOR;
            };

            v2f vert (a2v v)
            {
                v2f o;
                //坐标转换
                o.pos = UnityObjectToClipPos(v.vertex);

                //通过Unity的内置变量UNITY_LIGHTMODEL_AMBIENT得到了环境光部分。
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                //通过法线和光线计算出漫反射光照部分
                fixed3 worldNormal = normalize(UnityWorldToObjectDir(v.normal));
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb *saturate(dot(worldNormal, worldLight));

                float3 reflectDir = normalize(reflect(-worldLight, worldNormal));
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - UnityObjectToWorldDir(v.vertex));
                fixed3 specular =  _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, viewDir)), _Gloss);
                o.color = ambient + diffuse + specular;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(i.color, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Specular"
}
