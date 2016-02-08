using UnityEngine;
using System.Collections;

[RequireComponent(typeof(STAA))]
[ExecuteInEditMode]
public class STAAResolve : MonoBehaviour {

    void OnRenderImage(RenderTexture src, RenderTexture dest) {
        STAA staa = GetComponent<STAA>();
        if (staa.enabled)
        {
            GetComponent<STAA>().Resolve(src, dest);
        }
        else
        {
            Graphics.Blit(src, dest);
        }
    }
}
