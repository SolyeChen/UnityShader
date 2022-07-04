using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;

[CustomEditor(typeof(ShaderMenuExtend))]
public class ShaderMenuExtend : Editor {
    public override void OnInspectorGUI() {
        base.OnInspectorGUI();
    }
    //制作Unity顶部菜单栏
    [MenuItem("Shader/CreateShaderAssets")]
    static void ShaderCreateMenu()
    {
        Debug.Log("CreateShaderAssets");
    }

}

public class CreateTest
{
    [MenuItem ("CreateTest/Create ExampleAssets")]
    static void CreateExampleAssets ()
    {
        var material = new Material (Shader.Find ("Standard"));
        ProjectWindowUtil.CreateAsset (material, "New Material.mat");
    }
}
// public class CreateMaterial
// {
//     [MenuItem ("Assets/Create Material")]
//     static void CreateExampleAssets ()
//     {
//         var material = new Material (Shader.Find ("Standard"));
//         var instanceID = material.GetInstanceID ();

//         var icon = AssetPreview.GetMiniThumbnail (material);

//         var endNameEditAction =
//             ScriptableObject.CreateInstance<DoCreateMaterialAsset> ();

//         ProjectWindowUtil.StartNameEditingIfProjectWindowExists (instanceID,
//             endNameEditAction, "New Material.mat", icon, "");
//     }
// }
// public class DoCreateMaterialAsset : EndNameEditAction
// {
//     public override void Action (int instanceId, string pathName, string resourceFile)
//     {
//         var mat = (Material)EditorUtility.InstanceIDToObject (instanceId);

//         mat.color = Color.red;

//         AssetDatabase.CreateAsset (mat, pathName);
//         AssetDatabase.ImportAsset (pathName);
//         ProjectWindowUtil.ShowCreatedAsset (mat);
//     }
// }

// public class DoCreateScriptAsset : EndNameEditAction
// {
//     public override void Action (int instanceId, string pathName, string resourceFile)
//     {
//         var text = File.ReadAllText (resourceFile);

//         var className = Path.GetFileNameWithoutExtension (pathName);

//         //清除空格
//         className = className.Replace (" ", "");


//         text ="//Programer: "+"porgramerName"+"\n//code date:"+DateTime.Now.Date.ToShortDateString()+"\n"
//         +text.Replace ("#SCRIPTNAME#", className);

//         text += "\n//自己添加Something！"+"\n";

//         //utf8
//         var encoding = new UTF8Encoding (true, false);

//         File.WriteAllText (pathName, text, encoding);

//         AssetDatabase.ImportAsset (pathName);
//         var asset = AssetDatabase.LoadAssetAtPath<MonoScript> (pathName);
//         ProjectWindowUtil.ShowCreatedAsset (asset);
//     }
// }


// public class CreateAssets : EditorWindow
// {

//     [MenuItem("Window/CreatAssets")]
//     static void Open ()
//     {
//         GetWindow<CreateAssets> ();
//     }

//     public string scriptName,materialName;
//     void OnGUI()
//     {
//         var options = new []{GUILayout.Width (100), GUILayout.Height (20)};

//         GUILayout.Label ("CreateScripts");
//         EditorGUILayout.Space ();
//         EditorGUILayout.BeginHorizontal ();
//         EditorGUILayout.LabelField ("ScriptName",options);
//         scriptName= EditorGUILayout.TextArea (scriptName);
//         EditorGUILayout.EndHorizontal ();


//         if (GUILayout.Button ("Create")) {

//             CreateScript (scriptName);
//         }

//         GUILayout.Label ("CreateMaterial");
//         EditorGUILayout .Space ();
//         EditorGUILayout.BeginHorizontal ();
//         EditorGUILayout.LabelField ("materialName",options);
//         materialName=   EditorGUILayout.TextArea (materialName);
//         EditorGUILayout.EndHorizontal ();


//         if (GUILayout.Button ("Create")) {
//             CreateMaterial (materialName);
//         }

//     }
// //  新建自定义脚本
//     static void CreateScript (string scriptName)
//     {
//         var resourceFile = Path.Combine (EditorApplication.applicationContentsPath,
//             "Resources/ScriptTemplates/81-C# Script-NewBehaviourScript.cs.txt");

//         Debug.Log (resourceFile);
//         Texture2D csIcon =
//             EditorGUIUtility.IconContent ("cs Script Icon").image as Texture2D;

//         var endNameEditAction =
//             ScriptableObject.CreateInstance<DoCreateScriptAsset> ();

//         ProjectWindowUtil.StartNameEditingIfProjectWindowExists (0, endNameEditAction,
//             scriptName+".cs", csIcon, resourceFile);
//     }

//     //新建Material
//     static void CreateMaterial (string materialName)
//     {
//         var material = new Material (Shader.Find ("Standard"));
//         var instanceID = material.GetInstanceID ();
//         var icon = AssetPreview.GetMiniThumbnail (material);

//         var endNameEditAction =
//             ScriptableObject.CreateInstance<DoCreateMaterialAsset> ();

//         ProjectWindowUtil.StartNameEditingIfProjectWindowExists (instanceID,
//             endNameEditAction, materialName+".mat", icon, "");
//     }

// }