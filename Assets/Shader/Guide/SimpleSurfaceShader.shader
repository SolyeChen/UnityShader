Shader "Custom/Simple Surface Shader"
{
    Properties
    {
        //定义反射率
        _albedo("Albedo", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque"}

        CGPROGRAM
        #pragma surface surf BlinnPhong

        struct Input
        {
            float4 color : Color;
        };

        float _albedo; //使用前先声明
        void surf(Input IN, inout SurfaceOutput o)
        {
            o.Albedo = _albedo;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
