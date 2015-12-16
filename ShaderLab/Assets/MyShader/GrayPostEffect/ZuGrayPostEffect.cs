using UnityEngine;
using System.Collections;
using UnityStandardAssets.ImageEffects;

[ExecuteInEditMode]
public class ZuGrayPostEffect : ImageEffectBase {

	void OnRenderImage(RenderTexture source, RenderTexture dest )
	{
//		if( grayImg == null )
//		{
//			grayImg = new RenderTexture(source.width, source.height , 0 );
//			grayImg.hideFlags = HideFlags.HideAndDontSave;
//			//Graphics.Blit (source, grayImg);
//		}
//		material.SetTexture ("_MainTex", grayImg);
//
//		Graphics.Blit (source, grayImg, material);
//		Graphics.Blit (grayImg, dest);
		material.SetTexture ("_MainTex", dest);
		Graphics.Blit (source, dest, material);
	}
}
