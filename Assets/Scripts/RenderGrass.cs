using UnityEngine;


public class RenderGrass : MonoBehaviour
{
    [SerializeField] int shells = 6;
    [SerializeField] Vector2 resolution = new Vector2(100.0f, 100.0f);
    [SerializeField] float minLength = 0.0f;
    [SerializeField] float maxLength = 1.0f;
    [SerializeField] float frequency = 1.0f;
    [SerializeField] float magnitude = 1.0f;
    [SerializeField] int seed = 0;
    [SerializeField] Color shellColour = Color.green;
    [SerializeField] Color tipColour = Color.green;
    [SerializeField] Color baseColour = Color.green;
    [SerializeField] GameObject planeObject;

    void Update()
    {
        foreach (Transform t in transform)
        {
            DestroyImmediate(t.gameObject);
        }

        GameObject shellInstance;
        for (int i = 0; i < shells; i++)
        {
            shellInstance = Instantiate(planeObject, new Vector3(0.0f, 0.0f, 0.0f), Quaternion.identity, this.transform);
            Material shellMaterial = shellInstance.GetComponent<MeshRenderer>().material;
            shellMaterial.SetFloat("_Index", (float)i);
            shellMaterial.SetFloat("_Shells", (float)shells);
            shellMaterial.SetFloat("_MaxLength", maxLength);
            shellMaterial.SetFloat("_MinLength", minLength);
            shellMaterial.SetFloat("_Frequency", frequency);
            shellMaterial.SetFloat("_Magnitude", magnitude);
            shellMaterial.SetInteger("_Seed", seed);
            shellMaterial.SetVector("_Resolution", new Vector4(resolution.x, resolution.y, 0.0f, 0.0f));
            shellMaterial.SetColor("_ShellColour", shellColour);
            shellMaterial.SetColor("_TipColour", tipColour);
            shellMaterial.SetColor("_BaseColour", baseColour);
        }
    }
}
