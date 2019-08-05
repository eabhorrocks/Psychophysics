using System;
using System.Collections;
using System.Collections.Generic;
using System.Net;
using System.Net.Sockets;
using System.Text;
using UnityEngine;
using System.Threading;
using UnityEngine.SceneManagement;


public class SD_GetTrialParams : MonoBehaviour
{
    // Global Experiment Parameters
    public double numDots;
    public float dotLifetime;
    public float dotsize;
    public float trialDuration;
    public float ISI;

    // Trial Parameter Variables 
    public Vector3 velocity;
    public double speedDifference;
    public double lastSpeedDifference;
    public string walk;

    // Response and other socket variables
    public char lastKey;
    byte[] trialResult;
    byte[] startSig;

    // Object references
    string sceneName;
    public GameObject dotscoh;
    public GameObject GeometricSpace;
    DotMotion dmRef;
    public bool expEnded = false;
    public int trialNum = 0;
    public int stimNum = 1;
    public int trialCorrect = 9;
    public bool showFeedback = false;
    public float pauseN;
    public string savePath;

    // Maintain socket object accross scenes
    public static SD_GetTrialParams Instance { get; private set; }

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }


    void OnEnable()
    {
        //Tell our 'OnLevelFinishedLoading' function to start listening for a scene change as soon as this script is enabled.
        SceneManager.sceneLoaded += OnLevelFinishedLoading;
    }

    void OnDisable()
    {
        //Tell our 'OnLevelFinishedLoading' function to stop listening for a scene change as soon as this script is disabled. Remember to always have an unsubscription for every delegate you subscribe to!
        SceneManager.sceneLoaded -= OnLevelFinishedLoading;
    }

    void OnLevelFinishedLoading(Scene scene, LoadSceneMode mode)
    {
        sceneName = scene.name;
        if (sceneName == "TrialSelect") // if in TrialSelect scene, empty all the variables
        {
            velocity = Vector3.zero;
            speedDifference = 0;
            walk = string.Empty;
        }
    }


    // TCP connection stuff
    Thread mThread;
    public string connectionIP = "127.0.0.1";
    public int connectionPort = 10061;
    IPAddress localAdd;
    TcpListener listener;
    TcpClient client;
    bool running;
    string[] exData; //var for extracted Data from TCP as a string

    private void Start()
    {
        ThreadStart ts = new ThreadStart(GetInfo);
        mThread = new Thread(ts);
        mThread.Start();
    }

    public static string GetLocalIPAddress()
    {
        var host = Dns.GetHostEntry(Dns.GetHostName());
        foreach (var ip in host.AddressList)
        {
            if (ip.AddressFamily == AddressFamily.InterNetwork)
            {
                return ip.ToString();
            }
        }

        throw new System.Exception("No network adapters with an IPv4 address in the system!");
    }

    void GetInfo()
    {
        localAdd = IPAddress.Parse(connectionIP);
        listener = new TcpListener(IPAddress.Any, connectionPort);
        listener.Start();
        client = listener.AcceptTcpClient();
        running = true;
        while (running)
        {
            Connection();
        }

        listener.Stop();
    }

    void Connection()
    {
        NetworkStream nwStream = client.GetStream();
        byte[] buffer = new byte[client.ReceiveBufferSize];
        int bytesRead = nwStream.Read(buffer, 0, client.ReceiveBufferSize);
        string dataReceived = Encoding.UTF8.GetString(buffer, 0, bytesRead);

        // extract data from string TCP 
        exData = ExtractfromSock(dataReceived); //custom function below
        if (exData[0] == "gp")
        {
            //set global params
            Debug.Log("setting global parameters");
            numDots = Convert.ToDouble(exData[1]);
            trialDuration = float.Parse(exData[2]);
            dotLifetime = float.Parse(exData[3]);
            dotsize = float.Parse(exData[4]);
            ISI = float.Parse(exData[5]);
            float tfb = float.Parse(exData[6]);
            pauseN = float.Parse(exData[7]);
            if (tfb == 1)
            {
                showFeedback = true;
            }

        }
        else if (exData[0] == "end")
        {
            //Debug.Log("end of experiment");
            expEnded = true;
        }
        else if (exData[0] == "spath")
        {
            savePath = exData[1];
        }
        else
        {
            velocity.x = float.Parse(exData[0]);
            velocity.y = float.Parse(exData[1]);
            velocity.z = float.Parse(exData[2]);
            walk = (exData[3]);
            speedDifference = Convert.ToDouble(exData[4]);
            lastSpeedDifference = speedDifference;
        }

        if (dataReceived != null) //this is currently redundant
        {
            if (dataReceived == "stop")
            {
                running = false;
            }
        }
    }

    // simple function to generate string array from TCP string
    public static string[] ExtractfromSock(string sVector)
    {
        // Remove the parentheses
        if (sVector.StartsWith("(") && sVector.EndsWith(")"))
        {
            sVector = sVector.Substring(1, sVector.Length - 2);
        }

        // split the items
        string[] sArray = sVector.Split(',');
        return sArray;
    }


    // End Trial function
    public void EndTrial()
    {
        dmRef = FindObjectOfType<DotMotion>();
        //Debug.Log("Trial Complete");
        StartCoroutine(EndOfTrial2());
    }

    private IEnumerator EndOfTrial2()
    {
        // Wait for key press and make sure valid
        lastKey = '\0';
        bool done = false;
        while (!done)
        {
            //if (Input.GetKeyDown(KeyCode.F))
            if (Input.GetMouseButtonDown(0))
            {
                lastKey = 'f';
            }

            //if (Input.GetKeyDown(KeyCode.B))
            if (Input.GetMouseButtonDown(1))
            {
                lastKey = 'b';
            }

            if (lastKey == 'b' | lastKey == 'f')
            {
                if ((lastSpeedDifference > 0 & lastKey == 'b') | (lastSpeedDifference < 0 & lastKey == 'f'))
                {
                    trialCorrect = 1;
                }
                else
                {
                    trialCorrect = 0;
                }

                done = true;
            }

            yield return null; // wait until next frame, then continue execution from here (loop continues)
        }

        // Process key press, check trial result, send to Matlab
        NetworkStream nwStream = client.GetStream();
        if (lastKey == 'f')
        {
            trialResult = new byte[] {0};
        }
        else if (lastKey == 'b')
        {
            trialResult = new byte[] {1};
        }

        nwStream.Write(trialResult, 0, 1);
        lastKey = '\0';
        //SceneManager.LoadScene("TrialSelect");
    }


    // Start button function
    public void StartButtonSockmsg()
    {
        //NetworkStream nwStream = client.GetStream();
        //startSig = new byte[] { 9 };
        //nwStream.Write(startSig, 0, 1);
        StartCoroutine(StartExperiment());

    }

    IEnumerator StartExperiment()
    {
        yield return new WaitForSeconds(3);
        NetworkStream nwStream = client.GetStream();
        startSig = new byte[] {9};
        nwStream.Write(startSig, 0, 1);
    }
}


