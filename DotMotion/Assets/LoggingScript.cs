using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Threading;
using UnityEngine;
using UnityEngine.SceneManagement;
using ViveSR.anipal.Eye;

public class LoggingScript : MonoBehaviour
{
    public float samplingRate = 20f; // sample rate in Hz
    public int sleepTime;
    public string trackingFilePath;
    public string eventsFilePath;
    public string vmdistPath;
    public string eyeFilePath;
    public bool saveData = true;
    public int trialNum = 0;
    GetTrialParams paramsRef;

    // tracking data
    public float ttime;
    public float tx;
    public float ty;
    public float tz;
    public float rx;
    public float ry;
    public float rz;

    // eye data
    int eyetimetamp;
    bool lA;
    bool rA;
    public float pd1;
    public float pd2;
    public float eo1;
    public float eo2;
    public Vector3 gd1;
    public Vector3 gd2;
    public Vector3 go1;
    public Vector3 go2;
    public Vector2 pp1;
    public Vector2 pp2;

    //public float cdmm;
    //public bool cdv;

    private StreamWriter _sw;
    private StreamWriter _sw2;
    public StreamWriter _sw3;
    string sceneName;

    Thread logThread;


    EyeData EyeData_;
    public static LoggingScript Instance { get; private set; }
    public void Awake()
    {
        sleepTime = (int)(1f / samplingRate * 1000); // - 5 to deal with time to write data??
        paramsRef = FindObjectOfType<GetTrialParams>();
        saveData = true;
        trackingFilePath = string.Concat(paramsRef.savePath, "tracking.txt");
        eyeFilePath = string.Concat(paramsRef.savePath, "eyetracking.txt");
        eventsFilePath = string.Concat(paramsRef.savePath, "events.txt");
        //vmdistPath = string.Concat(paramsRef.savePath, "vmdist.txt");

        //logThread = new Thread(SampleNow);

        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }

        //InvokeRepeating("SampleNow", 0, 1 / samplingRate);

        SingleEyeData[] eyesData = new SingleEyeData[2]; // move as much of this as possible to Start() or Awake()
       
    }

    public void Start()
    {
        _sw = System.IO.File.AppendText(trackingFilePath);
        _sw2 = System.IO.File.AppendText(eyeFilePath);
        _sw3 = System.IO.File.AppendText(eventsFilePath);
        
        ThreadStart lthread = new ThreadStart(SampleNow);
        logThread = new Thread(lthread);
        logThread.Start();
        
    }

    public void OnEnable()
    {
        trialNum = paramsRef.trialNum;
        SceneManager.sceneLoaded += OnLevelFinishedLoading;
        
        //outputFilePath = paramsRef.savePath; // if = string.empty, set some default 
        //if (saveData)
        //{
            //_sw = System.IO.File.AppendText(outputFilePath);
            //_sw2 = System.IO.File.AppendText(eventsFilePath);
            //logThread = new Thread(SampleNow);

            //LoggingFunction();
        //}
    }

    public void OnDisable()
    {
        SceneManager.sceneLoaded -= OnLevelFinishedLoading;
        //if (saveData)
        //{
            //_sw.Close();
            //CancelInvoke();
        //}
    }

    void OnLevelFinishedLoading(Scene scene, LoadSceneMode mode)
    {
        trialNum = paramsRef.trialNum; //slows down??? do we need at all? easy enough to equate...? more of a sanity check...
        sceneName = scene.name;
        if (sceneName == "TrialSelect") // if in TrialSelect scene, empty all the variables
        {
            _sw3.WriteLine("trial {0} t {1} e {2} ",
                trialNum, Time.time, "off");
        }
        else if (sceneName == "Stimulus_VonMises")
        {
            _sw3.WriteLine("trial {0} t {1} e {2} ",
                trialNum, Time.time, "on");
            //_sw3.WriteLine("trial {0} t {1} d {2} ",
            //    paramsRef.trialNum, Time.time, vmRef.angleVec);
        }
    }

    void OnApplicationQuit()
    {

        // saveData = false  
        _sw.Close();
        _sw2.Close();
        _sw3.Close();
    }

    void Update()
    {
        ttime = Time.time;
        trialNum = paramsRef.trialNum;
        tx = this.transform.position.x;
        ty = this.transform.position.y;
        tz = this.transform.position.z;
        rx = this.transform.rotation.x;
        ry = this.transform.rotation.y;
        rz = this.transform.rotation.z;

        SingleEyeData[] eyesData = new SingleEyeData[2]; // move as much of this as possible to Start() or Awake()
        eyesData[(int)EyeIndex.LEFT] = EyeData_.verbose_data.left;
        eyesData[(int)EyeIndex.RIGHT] = EyeData_.verbose_data.right;
        

   
        SRanipal_Eye.GetEyeData(ref EyeData_);
        //eyetimetamp = EyeData_.timestamp;

        lA = eyesData[0].GetValidity(SingleEyeDataValidity.SINGLE_EYE_DATA_GAZE_ORIGIN_VALIDITY);
        rA = eyesData[1].GetValidity(SingleEyeDataValidity.SINGLE_EYE_DATA_GAZE_ORIGIN_VALIDITY);
        pd1 = eyesData[0].pupil_diameter_mm;
        pd2 = eyesData[1].pupil_diameter_mm;
        eo1 = eyesData[0].eye_openness;
        eo2 = eyesData[1].eye_openness;
        pp1 = eyesData[0].pupil_position_in_sensor_area;
        pp2 = eyesData[1].pupil_position_in_sensor_area;
        gd1 = eyesData[0].gaze_direction_normalized;
        gd2 = eyesData[1].gaze_direction_normalized;
        go1 = eyesData[0].gaze_origin_mm;
        go2 = eyesData[1].gaze_origin_mm;


        //cdmm = ceyeData.convergence_distance_mm;
        //cdv = ceyeData.convergence_distance_validity;

        



        //SampleNow();
        //LoggingFunction();
    }

    //public void LoggingFunction()
    //{
    //    Thread.Sleep(40);
    //    InvokeRepeating("SampleNow", 0, 1 / samplingRate);
    //}

    public void SampleNow()
    {
        while (saveData)
        {
            _sw.WriteLine("trial {0} t {1} x {2} y {3} z {4} rx {5} ry {6} rz {7}",
                trialNum, ttime, tx, ty, tz, rx, ry, rz);
            _sw2.WriteLine("trial {0} t{1} lA {2} rA {3} pd1 {4} pd2 {5} eo1 {6} eo2 {7} pp1 {8} pp2 {9} gd1 {10} gd2 {11} go1 {12} go2 {13}",
                trialNum, ttime, lA, rA, pd1, pd2, eo1, eo2, pp1, pp2, gd1, gd2, go1, go2);
            Thread.Sleep(sleepTime);
        }
    }

    //public void samplenow()
    //{
    //    _sw.writeline("trial {0} t {1} x {2} y {3} z {4} rx {5} ry {6} rz {7}",
    //        trialNum, time.time, transform.position.x, transform.position.y, transform.position.z, transform.rotation.x, transform.rotation.y, transform.rotation.z);
    //}
}
