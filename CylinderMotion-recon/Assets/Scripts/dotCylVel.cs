using System.Collections;
using System.Collections.Generic;
using System.Data.Common;
using Accord.Math;
using UnityEngine;
using Vector3 = UnityEngine.Vector3;

public class dotCylVel : MonoBehaviour
{
    public Vector3 Vel;
    private Vector3 axisVec;
    private float zPos;

    public float life;
    public float dotLifetime;
    public Vector3[] poses;
    private int telNum = 0;

    private Vector3 mytransform;

    // Start is called before the first frame update
    void Start()
    {
        telNum = 0;
    }

    // Update is called once per frame
    void Update()
    {
        life += Time.deltaTime;
        if (life >= dotLifetime)
        { 
            life = 0;
            Teleport();
        }
        
        // movement calculation
        transform.Translate(new Vector3(0, 0,Vel[2])*Time.deltaTime);
        zPos = transform.position.z;
        axisVec = new Vector3(0, 0, zPos);
        transform.RotateAround(axisVec, Vector3.forward, Vel[0] * Time.deltaTime);
        if (zPos < 0)
        {
           mytransform = new Vector3 (transform.position[0], transform.position[1], transform.position[2] + 200);
            transform.position = mytransform;
        }
        else if (zPos > 200)
        {
            mytransform = new Vector3(transform.position[0], transform.position[1], transform.position[2] - 200);
            transform.position = mytransform;
        }
    }

    void Teleport()
    {
        telNum++;
        //transform.position = poses[telNum];
        Vector2 circRand = Random.insideUnitCircle.normalized * 35; //random x-y pos on circle
        float zPos = Random.Range(0, 200); // random z pos
        transform.position = new Vector3(circRand[0], circRand[1], zPos);
    }
}
