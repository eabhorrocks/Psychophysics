using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public class saveHMDpos : MonoBehaviour
{
    public float samplingRate = 1f; // sample rate in Hz
    public string outputFilePath;
    public bool saveData = true;
    public int trialNum = 0;
    SD_GetTrialParams paramsRef;

    private StreamWriter _sw;

    public void Awake(){
        paramsRef = FindObjectOfType<SD_GetTrialParams>();
        saveData = true;
    }

    public void Start()
    {
        
    }

    public void OnEnable()
    {
        trialNum = paramsRef.trialNum;
        outputFilePath = paramsRef.savePath; // if = string.empty, set some default 
        if (saveData)
        {
            _sw = System.IO.File.AppendText(outputFilePath);
            InvokeRepeating("SampleNow", 0, 1 / samplingRate);
        }
    }

    public void OnDisable()
    {
        if (saveData)
        {
            _sw.Close();
            CancelInvoke();
        }
    }

    public void SampleNow()
    {
        _sw.WriteLine("trial {0} t {1} x {2} y {3} z {4} rx {5} ry {6} rz {7}",
            trialNum, Time.time, transform.position.x, transform.position.y, transform.position.z, transform.rotation.x, transform.rotation.y, transform.rotation.z);
    }
}
