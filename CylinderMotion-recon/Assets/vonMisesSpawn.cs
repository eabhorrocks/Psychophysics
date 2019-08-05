using System;
using System.IO;
using System.Linq;
using System.Text;
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
    int nPos;
    public double[] angleVec;
    Vector3[,] posArray;
    float[] lifes;

    string vmdistPath;
    string dotposPath;
    private string dotlifePath;
    private StreamWriter _sw3;
    private StreamWriter _sw4;
    private StreamWriter _sw5;
    
    

    void Awake()
    {
        paramsRef = FindObjectOfType<GetTrialParams>();
        vmdistPath = string.Concat(paramsRef.savePath, "vmdist.txt");
        dotposPath = string.Concat(paramsRef.savePath, "dotPos.txt");
        dotlifePath = string.Concat(paramsRef.savePath, "inilife.txt");
        _sw3 = System.IO.File.AppendText(vmdistPath);
        _sw4 = System.IO.File.AppendText(dotposPath);
        _sw5 = System.IO.File.AppendText(dotlifePath);

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

        _sw3.WriteLine("trial {0} , {1}, {2}",
            paramsRef.trialNum, vel, astring);
        _sw3.Close();
        // dump to .txt file here

        nPos = (int)Math.Ceiling(paramsRef.trialDuration / paramsRef.dotLifetime) + 1;

        posArray = new Vector3[nPos,numDots];
        lifes = new float[numDots];

        for (int i = 0; i < numDots; i++)
        {
            for (int ipos = 0; ipos < nPos; ipos++)
            {
                posArray[ipos,i] = Random.insideUnitSphere * theSpace.transform.localScale[0] / 2; //random pos within the sphere
                //Vector3 j = posArray[ipos, i];
                //Debug.Log(j);
            }
            lifes[i] = Random.Range(0, dotLifetime);
        }

        string lifeString = String.Join(",", lifes.Select(p => p.ToString()).ToArray());
        _sw5.WriteLine("trial {0} , {1} ",
            paramsRef.trialNum, lifeString);
        _sw5.Close();

        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < numDots; i++)
        {
            for (int ipos = 0; ipos < nPos; ipos++)
            {
                sb.Append(posArray[ipos, i].x).Append(" ").Append(posArray[ipos, i].y).Append(" ").Append(posArray[ipos, i].z).Append(" ");
            }

            sb.Append("|");
        }

        if (sb.Length > 0)
        {
            // remove last "|"
            sb.Remove(sb.Length - 1, 1);
        }
        sb.ToString();
        _sw4.WriteLine("trial {0} | {1} ", 
            paramsRef.trialNum, sb);
        _sw4.Close();


        //string posString = String.Join(" ", posArray.ToString());
        
        for (int i = 0; i < numDots; i++)
        {
            Instantiate(ObjectToSpawn, posArray[0,i], transform.rotation);
            
            Vector3 tempVel = new Vector3(Mathf.Sin((float) angleVec[i]), 0f, Mathf.Cos((float) angleVec[i]));
            tempVel.Normalize(); // unit vector
            tempVel = tempVel * vel; // vel magnitude


            var motionScript = ObjectToSpawn.GetComponent<DotMotionVecTel>();
            motionScript.life = lifes[i];
            motionScript.Vel = tempVel;
            motionScript.poses = Enumerable.Range(0, posArray.GetLength(0))
                .Select(x => posArray[x, i])
                .ToArray();
            //Debug.Log(motionScript.poses[0]);
            ObjectToSpawn.transform.localScale = new Vector3(dotsize, dotsize, dotsize);
            motionScript.dotLifetime = paramsRef.dotLifetime;
            motionScript.enabled = true;

        }
    }
    

    void OnApplicationQuit()
    {

        // saveData = false  
    }
}