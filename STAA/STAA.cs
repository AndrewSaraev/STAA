using UnityEngine;

[ExecuteInEditMode]
public class STAA : MonoBehaviour
{
    static Vector2[][] _patterns = new Vector2[][] {
    new Vector2[] // Quincunx
        {
            new Vector2(0f, 0f),
            new Vector2(1f, 1f)
        },
    new Vector2[] // 4x
        {
            new Vector2(-0.25f, 0.75f),
            new Vector2(0.25f, -0.75f),
            new Vector2(-0.75f, 0.25f),
            new Vector2(0.75f, 0.25f)
        },
    new Vector2[] // 8x
        {
            new Vector2(0.1875f, -0.3125f),
            new Vector2(-0.0625f, 0.4375f),
            new Vector2(0.6875f, 0.1875f),
            new Vector2(-0.3125f, -0.5625f),
            new Vector2(-0.5625f, 0.6875f),
            new Vector2(-0.8125f, -0.0625f),
            new Vector2(0.4375f, 0.9375f),
            new Vector2(0.9375f, -0.8125f)
        }
    };



    public Shader shader;

    public enum Pattern { quincunx = 0, x4 = 1, x8 = 2 };
    public Pattern pattern = Pattern.quincunx;

    [Range(0f, 1f)]
    public float rejection = 1f;



    RenderTexture[] _renderTextures;
    Material _material;
    int _patternPhase = 0;



    void CheckMaterial()
    {
        if (!_material)
        {
            _material = new Material(shader);
            _material.hideFlags = HideFlags.DontSave;
        }
    }

    bool CheckSupport()
    {
        if (!SystemInfo.supportsImageEffects || !SystemInfo.supportsRenderTextures)
        {
            Debug.Log("STAA: Image effects are not supported");
            return false;
        }
        if (!shader)
        {
            Debug.LogError("STAA: Shader is missing");
            return false;
        }
        if (!shader.isSupported)
        {
            Debug.Log("STAA: Shader is not supported");
            return false;
        }
        return true;
    }

    void CheckTextures()
    {
        int length = _patterns[(int)pattern].Length;
        if (_renderTextures == null)
        {
            _renderTextures = new RenderTexture[length];
        }
        else if (_renderTextures.Length != length)
        {
            ReleaseTextures();
            _renderTextures = new RenderTexture[length];
        }
    }

    void OnDisable()
    {
        ReleaseTextures();

#if UNITY_EDITOR
        DestroyImmediate(_material);
#else
        Destroy(_material);
#endif
        _material = null;
    }

    void OnPreCull()
    {
        _patternPhase++;
        if (_patternPhase >= _patterns[(int)pattern].Length)
        {
            _patternPhase = 0;
        }
        Camera cam = GetComponent<Camera>();
        Matrix4x4 newMatrix = cam.projectionMatrix;
        newMatrix[0, 2] += _patterns[(int)pattern][_patternPhase].x / cam.pixelWidth;
        newMatrix[1, 2] += _patterns[(int)pattern][_patternPhase].y / cam.pixelHeight;
        cam.projectionMatrix = newMatrix;
    }

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (!CheckSupport())
        {
            enabled = false;
            Graphics.Blit(src, dest);
            return;
        }

        CheckMaterial();
        CheckTextures();

        for (int i = 0; i < _renderTextures.Length; i++)
        {
            if (_renderTextures[i] == null)
            {
                _renderTextures[i] = RenderTexture.GetTemporary(src.width, src.height, 0, src.format);
                Graphics.Blit(src, _renderTextures[i]);
            }
            if (i == _patternPhase)
            {
                RenderTexture rt = RenderTexture.GetTemporary(src.width, src.height, 0, src.format);
                _material.SetTexture("_Tex0", _renderTextures[_patternPhase]);
                Graphics.Blit(src, rt, _material, 0);
                RenderTexture.ReleaseTemporary(_renderTextures[i]);
                _renderTextures[i] = rt;
            }
        }

        STAAResolve resolve = GetComponent<STAAResolve>();

        if (resolve && resolve.enabled)
        {
            Graphics.Blit(src, dest);
        }
        else
        {
            Resolve(src, dest);
        }
    }

    void OnPostRender()
    {
        GetComponent<Camera>().ResetProjectionMatrix();
    }

    void ReleaseTextures()
    {
        if (_renderTextures == null)
        {
            return;
        }
        for (int i = 0; i < _renderTextures.Length; i++)
        {
            if (_renderTextures[i] != null)
            {
                RenderTexture.ReleaseTemporary(_renderTextures[i]);
            }
        }
        _renderTextures = null;
    }

    public void Resolve(RenderTexture src, RenderTexture dest)
    {
        for (int i = 0; i < _renderTextures.Length; i++)
        {
            _material.SetTexture("_Tex" + i, _renderTextures[i]);
        }
        Vector2 texelSize = src.texelSize;
        _material.SetVector("_Jitter", new Vector4(-texelSize.x * 0.5f * _patterns[(int)pattern][_patternPhase].x, -texelSize.y * 0.5f * _patterns[(int)pattern][_patternPhase].y, rejection, 0f));

        Graphics.Blit(src, dest, _material, 1 + (int)pattern);
    }
}
