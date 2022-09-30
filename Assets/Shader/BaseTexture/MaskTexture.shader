// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/BaseTexture/MaskTexture"
{
   Properties
    {
         _Color ("Color Tint", Color) = (1,1,1,1)
         _MainTex ("Main Tex", 2D) = "white" {}
         _BumpMap ("Normal Map", 2D) = "bump" {}
         _BumpScale ("Bump Scale", Float) = 1.0

         _SpecularMask("Specular Mask", 2D) = "white" {}
         _SpecularScale ("Specular Scale", Float) = 1.0
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

            #include "UnityCG.cginc"
            #include "Lighting.cginc"


            fixed4 _Color;

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;

            sampler2D _SpecularMask;
            float4 _SpecularMask_ST;
            float _SpecularScale;
            fixed4 _Specular;

            float _Gloss;


            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;

   
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 lightDir: TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };


            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;

                TANGENT_SPACE_ROTATION;
                // Transform the light direction from object space to tangent space
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                // Transform the view direction from object space to tangent space
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;


                return o;
            };

            fixed4 frag(v2f i) : SV_Target {
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);
                fixed3 tangentNormal = UnpackNormal(tex2D(_BumpMap, i.uv));
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));
                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                // Get the mask value
                fixed specularMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;
                // Compute specular term with the specular mask

                /*
                在计算高光反射时，我们首先对遮罩纹理_SpecularMask进行采样。由
                于本书使用的遮罩纹理中每个纹素的rgb分量其实都是一样的，表明了该点对应的高光反射强度，在这里我们选择使用r分量来计
                算掩码值。然后，我们用得到的掩码值和_SpecularScale相乘，一起来控制高光反射的强度。

                */
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss) * specularMask;
                return fixed4(ambient + diffuse + specular, 1.0);
            }

            // fixed4 frag(v2f i) : SV_Target {
            //     fixed3 tangentLightDir = normalize(i.lightDir);
            //     fixed3 tangentViewDir = normalize(i.viewDir);

            //     // Get the texel in the normal map
            //     fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
            //     fixed3 tangentNormal;

            //     // If the texture is not marked as "Normal map"
            //     // tangentNormal.xy = (packedNormal.xy * 2 - 1) * _BumpScale;
            //     // tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));
            //     // Or mark the texture as "Normal map", and use the built-in funciton
            //     tangentNormal = UnpackNormal(packedNormal);
            //     tangentNormal.xy *= _BumpScale;
            //     tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

            //     fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
            //     fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
            //     fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tangentNormal, tangentLightDir));
            //     fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
            //     fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tangentNormal, halfDir)), _Gloss);
            //     return fixed4(ambient + diffuse + specular, 1.0);
            // }

            ENDCG
        }
    }
    Fallback "Specular"
}
