// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/BaseTexture/RampTexture"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1,1,1,1)
        _RampTex ("Ramp Tex", 2D) = "white" {}
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8.0, 256)) = 20
    }
    SubShader
    {
        Pass
        {
            Tags {"LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            // #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
        
            fixed4 _Color;
            sampler2D _RampTex;
            fixed4 _Specular;
            float _Gloss;

            //在Unity中，我们需要使用纹理名_ST的方式来声明某个纹理的属性。其中，ST是缩放（scale）和平移（translation）的缩写。
            //_MainTex_ST可以让我们得到该纹理的缩放和平移（偏移）值。
            //_MainTex_ST.xy存储的是缩放值，而_MainTex_ST.zw存储的是偏移值
            float4 _RampTex_ST;
            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };
            struct v2f {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float2 uv : TEXCOORD2;
            };

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                o.uv = v.texcoord.xy * _RampTex_ST.xy + _RampTex_ST.zw;
                // Or just call the built-in function
                //#define TRANSFORM_TEX(tex,name) (tex.xy * name##_ST.xy + name##_ST.zw)
                // o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                
                return o;
            }

            // Transforms 2D UV by scale/bias property

            fixed4 frag(v2f i) : SV_Target {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;


                // Use the texture to sample the diffuse color
                //使用半兰伯特模型，通过对法线方向和光照方向的点积做一次0.5倍的缩放以及一个0.5大小的偏移来计算半兰伯特部分halfLambert。
                //halfLambert的范围被映射到了[0，1]之间
                fixed halfLambert = 0.5 * dot(worldNormal, worldLightDir) + 0.5;
                // fixed halfLambert = saturate(dot(worldNormal, worldLightDir));

                //使用halfLambert来构建一个纹理坐标，并用这个纹理坐标对渐变纹理_RampTex进行采样。
                //由于_RampTex实际就是一个一维纹理（它在纵轴方向上颜色不变），因此纹理坐标的u和v方向我们都使用了halfLambert。
                //然后，把从渐变纹理采样得到的颜色和材质颜色_Color相乘，得到最终的漫反射颜色。
                fixed3 diffuseColor = tex2D(_RampTex, fixed2(halfLambert, halfLambert)).rgb * _Color.rgb;

                //剩下的代码就是计算环境光和高光反射，最后把结果进行相加。
                fixed3 diffuse = _LightColor0.rgb * diffuseColor;
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(worldLightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
                return fixed4(ambient + diffuse + specular, 1.0);
            }

            ENDCG
        }
    }
    Fallback "Specular"
}
