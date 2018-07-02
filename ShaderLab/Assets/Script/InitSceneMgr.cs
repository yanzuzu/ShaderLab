using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class InitSceneMgr : MonoBehaviour 
{
	[SerializeField]
	private Text m_effectName;
	private int m_currentIdx = 0;

	private List<string> m_scenes = new List<string>()
	{
		{"AdvancedLightingScene"},
		{"AdvancedTextureMap"},
		{"BasicScene"},
		{"BasicTexture"},
		{"Glass"},
		{"GrayPostEffect"},
		{"Hologram"},
		{"MotionBlur"},
		{"outline"},
		{"PhysicBasedRendering"},
		{"Plasma"},
		{"StencilBuffer"},
		{"VertexExtrude"},
		{"Water"},
		{"Wave"},
	};

	void Start () 
	{
		loadScene ();
	}

	void loadScene()
	{
		SceneManager.LoadScene (m_scenes[m_currentIdx]);
		m_effectName.text = string.Format("{0}. {1}",m_currentIdx +1 , m_scenes [m_currentIdx] );
	}

	public void OnClickNext()
	{
		m_currentIdx++;
		m_currentIdx = m_currentIdx % m_scenes.Count;
		loadScene ();
	}

	public void OnClickLast()
	{
		m_currentIdx--;
		if (m_currentIdx < 0)
		{
			m_currentIdx = m_scenes.Count - 1;
		}
		loadScene ();
	}
}
