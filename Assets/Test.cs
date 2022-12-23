using System.Collections;
using System.Collections.Generic;
using UnityEngine;


//参考文章https://zhuanlan.zhihu.com/p/43588045
public class Test : MonoBehaviour
{
    public RenderTexture rt;

    public Transform cubeTransform;
    public Mesh cubeMesh;
    public Material pureColorMat;

    void Start()
    {
        rt = new RenderTexture(Screen.width, Screen.height, 24);
    }


    //摄像机处理完回调
    private void OnPostRender() {
        Camera cam = Camera.current;
        Graphics.SetRenderTarget(rt);
        GL.Clear(true, true, Color.gray);

        pureColorMat.color = new Color(0, 0.5f, 0.8f);
        pureColorMat.SetPass(0);
        Graphics.DrawMeshNow(cubeMesh, cubeTransform.localToWorldMatrix);
        var a = cam.targetTexture;
        Graphics.Blit(rt, cam.targetTexture);
    }
    // Update is called once per frame
    // void Update()
    // {
        
    // }
}
