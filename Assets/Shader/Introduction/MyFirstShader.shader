//该shader是一个 记录shader基本语法及解释的备忘录


// 这里指定 Shader 的名字,不要求跟文件名保持一致
Shader "Custom/Introduction/MyFirstShader"
{
    // Properties语义并不是必需的，可以选择不声明任何材质属性。
    // Inspector暴露的属性，如果需要在Pass中使用则需要在对应的Pass中使用类型再次声明，如 float4 _color
    Properties{
        _Color("Color",Color)= (1,1,1,1)  // 颜色
        _Vertor("Vector",Vector)=(1,2,3,4) // 一维向量
        _Int("Int",Int) = 1 // 整数
        _Float("Float",Float) = 2.3 // 浮点数
        _Range("Range",Range(1,10))= 1 // 范围
        _MainTex("Main Tex",2D) = "white"{} // 图片纹理
        _Cube("Cube",Cube)= "white"{} // 天空盒
        _3D("3D Tex",3D) ="white"{} // 3D 纹理


        //Shader当中也支持一些 特性
        [NoScaleOffset] //隐藏贴图偏移和平铺选项
        _Texture01("Texture Without Offset & Tiling",2D) = "white"{}

        [Normal] //用于自动判断法线贴图
        _NormalTexture("Normal Texture",2D) = "white" {}

        [HDR] //开启HDR
        _MainColor("Main Color",Color) = (1,1,1,1)

        [HideInInSpector]   //隐藏属性
        _FloatValue("Float Value",Float) = 0

        [Toggle] //开关
        _IsFloat("Is Float",Float) = 0

        [IntRange] //整数范围限制
        _Alpha("Alpha",Range(0,255)) = 0

        [Space] //垂直方向间隔
        _Prop1("Prop1",Float) = 0

        [Space(50)] //垂直方向间隔
        _Prop2("Prop2",Float) = 0

        [Header(Title)] //标题
        _Title("Title",Float) = 0

        [PowerSlider(3.0)] //幂次滑动条
        _Shininess("Shininess",Range(0,1)) = 0

        [Enum(Zero,0,One,1,Two,2,Three,3)] //枚举
        _Number ("Number", Float) = 0

        //关键字枚举，用于shader中的判断，需要特殊处理
        [KeywordEnum(None,Add,Multiply)]
        _Overlay("OverLay Mode",Float) = 0
    }

    //渲染设置和标签设置，如果不设置则会使用默认的设置


    // SubShader 可以写很多个 显卡运行效果的时候,从第一个SubShader开始,如果第一个 SubShader里面的效果可以实现,
    // 那么就使用第一个 SubShader ,如果显卡这个 SubShader 里面的某些效果它实现不理,它会自动去实现第二个SubShader
    // 如果所有的 SubShader 都无法运行,那么将运行  Fallback "" 中的shader
    SubShader{
    // 此处是定义子着色器的代码。
        // 至少有一个Pass
        Pass{
        // 此处是定义通道的代码。
            // 使用 CG 语言编写 Shader 代码
            CGPROGRAM

            // 顶点函数,这里只是声明了顶点函数的函数名
            // 基本作用是 完成顶点坐标从模型空间到剪裁空间的转换(从游戏环境转换到视野相机屏幕上)
            #pragma vertex vert

            // 片元函数,这里只是声明了片元函数的片元名
            // 基本作用是返回模型对应的屏幕的每一个像素的颜色值
            #pragma fragment frag

            // 从应用程序传递到 顶点函数的所有语义
            struct a2v{

                // 告诉Unity把模型空间下的顶点坐标填充给 vertex
                float4 vertex : POSITION;

                // 告诉Unity把模型空间下的法线方向填充给 normal
                float4 normal : NORMAL;

                // 告诉Unity把模型空间下的切线方向填充给 tangent  (TANGENT 0~n)
                float4 tangent : TANGENT;

                // 告诉Unity把第一套纹理坐标填充给 texcoord   (TEXCOORD 0~n)
                float4 texcoord : TEXCOORD0;

                // 告诉Unity把模型空间下的顶点颜色填充给 color (COLOR 0~n)
                fixed3 color : COLOR0;
            };

            // 从顶点函数 传递给 片元函数的所有语义
            struct v2f{

                // 裁剪空间中的顶点坐标(一般是系统直接使用)
                float4 position:SV_POSITION;

                // 不一定传递颜色,可以传递一组4个的值
                fixed3 color :COLOR0;

                // 不一定传递颜色,可以传递一组4个的值 (TEXCOORD 0~7)
                float4 texcoord:TEXCOORD0;
            };

            // 通过语义告诉系统,我这个参数是干嘛的,比如 POSITION 是告诉系统我需要顶点坐标
            // SV_POSITION这个语义用来解释说明返回值,意思是返回值是剪裁空间下的顶点坐标
            // v2f vert(a2v v : POSITION):SV_POSITION{}
            v2f vert(a2v v){
                v2f f = (v2f)0;
                f.position = UnityObjectToClipPos(v.vertex);

                // 这里场景中可以建一个正方体,它的模型空间下 法线(1,0,0)为红色 法线(0,1,0)为绿色 法线(0,0,1)为蓝色e
                // 其他法线方向是负数所以为黑色 过渡系统会自动进行插值运算
                f.color = v.normal;

                return f;
            }

            // 片元函数传递给 系统的所有语义
            // SV_TARGET 这个语义用来解释说明返回值,意思是返回值是模型对应的屏幕的每一个像素的颜色值
            fixed4 frag(v2f f):SV_TARGET{

                // 模型显示法线颜色
                return fixed4(f.color, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
