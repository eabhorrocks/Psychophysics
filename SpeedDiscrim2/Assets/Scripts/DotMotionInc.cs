using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DotMotionInc : MonoBehaviour {


    public Rigidbody rb;
    public float Vel;
    public GameObject theSpace;
    private Vector3 direction;
    public float dotLifetime;
    private float life;


    void Awake()
    {
        direction = new Vector3(Random.Range(-1.00f, 1.00f), Random.Range(-1.00f, 1.00f), Random.Range(-1.00f, 1.00f)).normalized;

    }

    void Start ()
    {
        rb.AddForce(direction[0] * Vel, direction[1] * Vel, direction[2] * Vel, ForceMode.VelocityChange);
        life = Random.Range(0, dotLifetime);
    }
	
	// Update is called once per frame
	void Update () {
        life += Time.deltaTime;
        if (life >= dotLifetime)
        {
            life = 0;
            Teleport();
        }
    }

    void Teleport()
    {
        Vector3 rndPosWithin = Random.insideUnitSphere * theSpace.transform.localScale[0] / 2; //random pos within the sphere
        rb.position = rndPosWithin;
    }
}
