using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;
using System.Threading;
using Random = UnityEngine.Random;

public class SpeedTracker_cyl : MonoBehaviour
{
    private float lastPosx;
    private float lastPosz;
    private float lastTime;

    private float dposx;
    private float dposz;
    private float dpossq;
    private float dtime;
    private float cTime;
    public float walkthreshold = 0.05f;
    public float stillthreshold = 0.01f;

    public float hmdvelsq;
    public List<float> hmdvellistsq = new List<float>(4);
    public bool walkstate;

    //private Thread speedThread;

    // Start is called before the first frame update
    void Start()
    {
        walkthreshold = 0.05f;
        stillthreshold = 0.01f;
        lastPosx = this.transform.position.x;
        lastPosz = this.transform.position.z;
        lastTime = Time.time;
        hmdvellistsq.Add((float)0.0);
        hmdvellistsq.Add((float)0.0);
        InvokeRepeating("getSpeed", 0, 1f / 4f);
    }


    // Update is called once per frame
    void Update()
    {
    }

    void getSpeed()
    {
        dposx = this.transform.position.x - lastPosx;
        dposz = this.transform.position.z - lastPosz;
        dpossq = dposx * dposx + dposz * dposz;
        cTime = Time.time;
        dtime = cTime - lastTime;
        hmdvelsq = dpossq / dtime;
        //hmdvelsq = Random.Range(0.7f, 3.0f);
        hmdvellistsq.RemoveAt(0);
        hmdvellistsq.Add(hmdvelsq);
        lastPosx = this.transform.position.x;
        lastPosz = this.transform.position.z;
        lastTime = cTime;

        //if (hmdvellistsq.Min() > walkthreshold)
        //{
        //    walkstate = true;
        //}
        //else
        //{
        //   walkstate = false;
        //}
    }


    //public void samplenow()
    //{
    //    _sw.writeline("trial {0} t {1} x {2} y {3} z {4} rx {5} ry {6} rz {7}",
    //        trialNum, time.time, transform.position.x, transform.position.y, transform.position.z, transform.rotation.x, transform.rotation.y, transform.rotation.z);
    //}
}
