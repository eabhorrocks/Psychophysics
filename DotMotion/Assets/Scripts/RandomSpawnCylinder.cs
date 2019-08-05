using System;
using System.IO;
using System.Linq;
using Accord.Math;
using UnityEngine;
using Valve.VR;
using Accord.Statistics.Distributions.Univariate;
using Random = UnityEngine.Random;
using Vector3 = UnityEngine.Vector3;


public class RandomSpawnCylinder : MonoBehaviour
{
    public GameObject ObjectToSpawn;
    public float radius;
    public float zPosMin;
    public float zPosMax;
    public int numDots;
    public float dotsize;
    public float dotLifetime;
    public float vel;
    public double kappa;
    public double[] angleVec;
    private double mean;
    public float dotlifetime;

    GetTrialParams paramsRef;
    string vmdistPath;
    StreamWriter _sw3;

    void Awake()
    {
        paramsRef = FindObjectOfType<GetTrialParams>();
        vmdistPath = string.Concat(paramsRef.savePath, "vmdist.txt");
        _sw3 = System.IO.File.AppendText(vmdistPath);
    }

    void Start()
    {

        if (kappa > 0)
        {
            mean = Math.PI;
        }
        else
        {
            mean = 0;
            kappa = kappa * -1;
        }

        var vonMises = new VonMisesDistribution(mean: mean, concentration: kappa);
        angleVec = vonMises.Generate(numDots);

        string astring = String.Join(",", angleVec.Select(p => p.ToString()).ToArray());

        //_sw3.WriteLine("trial {0} t {1} d {2} ",
       //     paramsRef.trialNum, Time.time, astring);
       // _sw3.Close();

        for (int i=0; i<numDots; i++)
        {
            Vector2 circRand= Random.insideUnitCircle.normalized* radius; //random x-y pos on circle
            float zPos = Random.Range(zPosMin, zPosMax); // random z pos
            Vector3 rndPos = new Vector3(circRand[0], circRand[1], zPos);
     
            Instantiate(ObjectToSpawn, rndPos, transform.rotation);

            var motionScript = ObjectToSpawn.GetComponent<dotCylVel>();
            Vector3 tempVel = new Vector3(Mathf.Sin((float)angleVec[i]), 0f, Mathf.Cos((float)angleVec[i])); //
            tempVel.Normalize(); // unit vector
            tempVel = tempVel * vel; // vel magnitude
            tempVel = new Vector3(tempVel[0]/radius * 57.3f, tempVel[1], tempVel[2]); // convert to appropriate angular vel

            motionScript.Vel = tempVel;
            motionScript.life = Random.Range(0f, dotLifetime);

            ObjectToSpawn.transform.localScale = new Vector3(dotsize, dotsize, dotsize);


        }
    }
}