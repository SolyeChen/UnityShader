Shader "Custom/Simple RGBCube Shader"  // 定义Shader的名字
{
    Properties
    {
    }

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

            struct vertexOutput{
                float4 pos : SV_POSITION;
                float4 color : TEXCOORD0;
            };

            vertexOutput vert(float4 vertexPos : POSITION){
                vertexOutput output;
                //这里将立方体的模型空间顶点坐标直接转换成像素，由于cube长度为1，中心在立方体中心，
                //因此各个顶点的坐标取值范围在[-0.5, 0.5]，直接转换成颜色值需要排除负的值，
                //因此所有顶点坐标值加上了0.5, 得到的颜色值取值范围也变为为[0, 1].
                output.color = vertexPos + float4(0.5, 0.5, 0.5 ,0);

                //转换到裁剪坐标系
                output.pos =  UnityObjectToClipPos(vertexPos);
                return output;
            };

            //片段着色器入口函数frag，与pragma第二条声明匹配，返回类型为float4语义为COLOR,
            //这里除了颜色没有其他的输出，所以没有输出结构体
            float4 frag(vertexOutput input) : SV_TARGET
            //此函数的形参类型为顶点着色器的输出结构体，没有语义
            //原因就在于片段着色器位于顶点着色器的下一个环节，参数按照这个顺序传递
            {
                //由于col属性已经在顶点着色器中计算，直接返回进入下一环节
                //下一环节是什么这里不探讨了
                return input.color;
            }
            ENDCG
            //结束CG
        }
    }
    FallBack "Diffuse"
}
