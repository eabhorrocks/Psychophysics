﻿using System.Collections;
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
    public double dotlifetime;

    private Vector3 mytransform;

    // Start is called before the first frame update
    void Start()
    {
        Debug.Log("start");
    }

    // Update is called once per frame
    void Update()
    {
        dotlifetime = 0.5f;
        life += Time.deltaTime;
        if (life >= dotlifetime)
        { 
            life = 0;
            //Teleport();
        }
    
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
        Vector2 circRand = Random.insideUnitCircle.normalized * 50; //random pos within the sphere
        float zPos = Random.Range(0, 200);
        transform.position = new Vector3(circRand[0], circRand[1], zPos);
    }
}