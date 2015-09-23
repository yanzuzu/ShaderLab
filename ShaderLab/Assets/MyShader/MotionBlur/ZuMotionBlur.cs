using UnityEngine;
using System.Collections;
using UnityStandardAssets.ImageEffects;

[ExecuteInEditMode]
public class ZuMotionBlur: ImageEffectBase
{
	public float BlurAmount = 0.5f;

	private RenderTexture blurTex;

	override protected void OnDisable()
	{
		base.OnDisable ();
		GameObject.DestroyImmediate (blurTex);
	}

	void OnRenderImage( RenderTexture source, RenderTexture dest )
	{
		if( blurTex == null || blurTex.width != source.width )
		{
			GameObject.DestroyImmediate(blurTex);
			blurTex = new RenderTexture(source.width, source.height , 0 );
			blurTex.hideFlags = HideFlags.HideAndDontSave;
			//Graphics.Blit (source, blurTex);
		}

		material.SetTexture ("_MainTex", blurTex);
		material.SetFloat ("_BlurAmount", BlurAmount);

		Graphics.Blit (source, blurTex, material);
		Graphics.Blit (blurTex, dest);
	}

}
