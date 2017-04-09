using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateSelf : MonoBehaviour {
	[SerializeField]
	private float m_rotateAngle = 10f;

	private Transform trans;
	// Use this for initialization
	void Start () {
		trans = GetComponent<Transform> ();
	}
	
	// Update is called once per frame
	void Update () {
		trans.Rotate (Vector3.up * m_rotateAngle * Time.deltaTime, Space.Self);
	}
}
