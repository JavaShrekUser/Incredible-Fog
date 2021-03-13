using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ScreenSpace : MonoBehaviour
{
  public Material postProcessingMat;
  // Start is called before the first frame update
  private void OnRenderImage(RenderTexture source, RenderTexture destination)
  {
    Graphics.Blit(source,destination,postProcessingMat);
  }
}
