using System;
using System.IO;
using System.Linq;
using Accord.Statistics.Distributions.Univariate;
using UnityEngine;
using Random = UnityEngine.Random;

public class vonMisesSpawn : MonoBehaviour
{
    public GameObject ObjectToSpawn;
    public GameObject theSpace;
    GetTrialParams paramsRef;
    public int numDots;
    public float dotsize;
    public float dotLifetime;
    public double kappa;
    public float vel;
    double mean;
    public double[] angleVec;
    string vmdistPath;
    private StreamWriter _sw3;

    void Awake()
    {
        paramsRef = FindObjectOfType<GetTrialParams>();
        vmdistPath = string.Concat(paramsRef.savePath, "vmdist.txt");
        _sw3 = System.IO.File.AppendText(vmdistPath);
    }

    void Start()
    {
        
        kappa = paramsRef.coherence;
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
        numDots = (int)paramsRef.numDots;
        vel = paramsRef.velocity.z;
        angleVec = vonMises.Generate(numDots);
        string astring = String.Join(",", angleVec.Select(p => p.ToString()).ToArray());

        _sw3.WriteLine("trial {0} t {1} d {2} ",
            paramsRef.trialNum, Time.time, astring);
        _sw3.Close();
        // dump to .txt file here

        for (int i = 0; i < numDots; i++)
        {
            Vector3 rndPosWithin = Random.insideUnitSphere * theSpace.transform.localScale[0] / 2; //random pos within the sphere
            Instantiate(ObjectToSpawn, rndPosWithin, transform.rotation);

            var motionScript = ObjectToSpawn.GetComponent<DotMotion>();
            Vector3 tempVel = new Vector3(Mathf.Sin((float)angleVec[i]), 0f, Mathf.Cos((float)angleVec[i]));
            tempVel.Normalize(); // unit vector
            tempVel = tempVel * vel; // vel magnitude
            motionScript.Vel = tempVel;
            ObjectToSpawn.transform.localScale = new Vector3(dotsize, dotsize, dotsize);

        }
    }

    void OnApplicationQuit()
    {

        // saveData = false  
    }
}