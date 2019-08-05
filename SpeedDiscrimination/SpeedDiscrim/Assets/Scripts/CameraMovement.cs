using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraMovement : MonoBehaviour {

    public Rigidbody rb;
    public float Vel = 1f;

    // Use this for initialization
    void Start () {
        rb.AddForce(0, 0, Vel, ForceMode.VelocityChange);

    }
	
	// Update is called once per frame
	void Update () {
		
	}
}
