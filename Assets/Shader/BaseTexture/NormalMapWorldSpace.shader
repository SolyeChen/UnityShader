// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/BaseTexture/NormalMapWorldSpace"
{
    Properties
    {
         _Color ("Color Tint", Color) = (1,1,1,1)
         _MainTex ("Main Tex", 2D) = "white" {}
         _BumpMap ("Normal Map", 2D) = "bump" {}
         _BumpScale ("Bump Scale", Float) = 1.0
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

            fixed4 _Specular;
            float _Gloss;


            struct a2v {
                float4 vertex : POSITION;
                float3 normal : NORMAL;

                //使用TANGENT语义来描述float4类型的tangent变量，以告诉Unity把顶点的切线方向填充到tangent变量中。需要注意的
                //是，和法线方向normal不同，tangent的类型是float4，而非float3，这是因为我们需要使用tangent.w分量来决定切线空间中的第三个
                //坐标轴——副切线的方向性。
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            //包含从切线空间到世界空间的变换矩阵
            struct v2f {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float4 TtoW0 : TEXCOORD1;
                float4 TtoW1 : TEXCOORD2;
                float4 TtoW2 : TEXCOORD3;
            };


            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                
                o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
                o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w;

                // Compute the matrix that transform directions from tangent space to world space， Put the world position in w component for optimization  
                /* 
                计算了世界空间下的顶点切线、副切线和法线的矢量表示，并把它们按列摆放得到从切线空间到世界空间的变换矩阵。
                我们把该矩阵的每一行分别存储在TtoW0、TtoW1和TtoW2中，并把世界空间下的顶点位置的xyz分量分别存储在了这些变量的w分量中，以便充分利用插值寄存器的存储空间。
                */
                o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);

                return o;
            };

            fixed4 frag(v2f i) : SV_Target {

                /*
                    首先从TtoW0、TtoW1和TtoW2的w分量中构建世界空间下的坐标。然后，使用内置的UnityWorldSpaceLightDir和
                    UnityWorldSpaceViewDir函数得到世界空间下的光照和视角方向。接着，我们使用内置的UnpackNormal函数对法线纹理进行采样
                    和解码（需要把法线纹理的格式标识成Normal map），并使用_BumpScale对其进行缩放
                */
                // Get the position in world space
                float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
                // Compute the light and view dir in world space
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                // Get the normal in tangent space
                fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
                bump.xy *= _BumpScale;
                bump.z = sqrt(1.0 - saturate(dot(bump.xy, bump.xy)));

                // Transform the normal from tangent space to world space
                //使用TtoW0、TtoW1和TtoW2存储的变换矩阵把法线变换到世界空间下。这是通过使用 点乘 操作来实现矩阵的每一行和法线相乘来得到的。
                bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
                

                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump, lightDir));
                fixed3 halfDir = normalize(lightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(bump, halfDir)), _Gloss);
                return fixed4(ambient + diffuse + specular, 1.0);
            }


            ENDCG
        }
    }
    Fallback "Specular"
}
