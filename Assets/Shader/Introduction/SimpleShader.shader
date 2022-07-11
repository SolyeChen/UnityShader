Shader "Custom/SimpleShader"
{
    Properties{
        //声明一个Color变量
        _Color("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
    }
    SubShader
    {
        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            //定义一个结构体用于vert顶点着色器函数的输入
            struct a2v {
                float4 vertex : POSITION; //POSITION语义：用模型空间的当前顶点坐标填充vertex变量
                float4 normal : NORMAL; //NORMAL语义：用模型空间的当前法线方向填充normal变量
                float4 texcoord : TEXCOORD0; //TEXCOORD0语义：用模型第一套纹理坐标填充texcoord变量
            };

            struct v2f {
                float4 pos : SV_POSITION;
                fixed3 color : COLOR0;
            };
        
            float4 _Color;
            v2f vert(a2v v) //: SV_POSITION shader入门精要 这里会报错，这是由于Unity Shader Model的版本不一致，5.6之后的版本不需要再次声明，直接删除就好
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                //normal法线取值范围[-1.0, 1.0]，需要进行转化
                o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);
                return o;
            }

            fixed4 frag(v2f f) : SV_TARGET{
                fixed3 c = f.color;
                c *= _Color;
                return fixed4(c, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
