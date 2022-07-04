Shader "Custom/Simple Surface Shader"
{
    Properties
    {
        //Number
        _Int("Int", Int) = 1
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

        void surf(Input IN, inout SurfaceOutput o)
        {
            o.Albedo = 1;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
