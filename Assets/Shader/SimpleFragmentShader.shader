Shader "Custom/Simple Fragment Shader"  // 定义Shader的名字
{
    Properties
    {
        //Number
        _FragmentColor("Color", Color) = (1.0, 0.0, 0.0, 1.0)
    }

    //Unity会选择最适合GPU的subshader块
    SubShader
    {
        // 一个shader会有多个Pass块
        Pass {
            // 开始Unity的shader
            CGPROGRAM

            //定义一个顶点程序, 名为vert
            #pragma vertex vert
            //定义一个片段程序, 名为frag
            #pragma fragment frag

            float4 vert(float4 v :POSITION) : SV_POSITION{

                //这行代码的作用是使用Unity内置的矩阵UNITY_MATRIX_MVP将顶点输入参数vertexPos进行转换，现已改为一个函数，
                //UnityObjectToClipPos将顶点输入参数v从模型空间转换到 后的值作为返回顶点程序的输出参数，片段程序的输入参数
                return UnityObjectToClipPos(v);
            }

            float4 _FragmentColor;
            //该片段程序返回一个片段输出参加,也即语义 SV_TARGET(DX10+) 或 COLOR(DX9),
            //该代码的意思是设置一个不透明的红色(red = 1, green = 0, blue = 0, alpha = 1)
            float4 frag() : SV_TARGET {
                return _FragmentColor;
            }
            ENDCG
            //结束CG
        }
    }
    FallBack "Diffuse"
}
