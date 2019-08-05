﻿using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;
using System.Linq;
using ViveSR.anipal.Eye;


public class SD_GoToTrial : MonoBehaviour
{
    SD_GetTrialParams paramsRef;
    SD_SpeedTracker spdTracker;
    LoggingScript logScript;
    public GameObject dotscoh;
    public GameObject GeometricSpace;
    public GameObject endTrial;
    public GameObject walkText;
    public GameObject stillText;
    public GameObject expEndedText;
    public GameObject correctFeedback;
    public GameObject incorrectFeedback;
    public GameObject pauseText;
    public GameObject endBlockText;

    DotMotion dmRef;
    DotMotionInc dmIncRef;
    EndTrigger endTrigRef;

    Transform dotsCohTransform;
    Transform dotsIncTransform;

    double speedDifference;
    Vector3 velocity;
    string walk;

    float dotLifetime;
    float dotsize;
    float trialDuration;
    float ISI;
    bool updateFlag = true;
    bool pausing = false;

    void Awake()
    {
        paramsRef = FindObjectOfType<SD_GetTrialParams>();
        spdTracker = FindObjectOfType<SD_SpeedTracker>();
        logScript = FindObjectOfType<LoggingScript>();
    }

    private void Start()
    {
        
    }

    void Update()
    {
        // on x launch eye calibration
        if ((Input.GetKeyDown(KeyCode.X)))// && (Input.GetKeyUp(KeyCode.LeftControl)))
        {
            logScript._sw3.WriteLine("trial {0} t {1} e {2} ",
                paramsRef.trialNum, Time.time, "eyec");
            SRanipal_Eye.LaunchEyeCalibration();
        }


        if (paramsRef.expEnded == true)
        {
            StartCoroutine(LoadMainMenu());
        }

        if (paramsRef.showFeedback)
        {
            if (paramsRef.trialCorrect == 1)
            {
                correctFeedback.SetActive(true);
                paramsRef.trialCorrect = 9;
            }

            if (paramsRef.trialCorrect == 0)
            {
                incorrectFeedback.SetActive(true);
                paramsRef.trialCorrect = 9;
            }
        }

        if (updateFlag == true)
        {
            // assign global vars here.

            speedDifference = (float)paramsRef.speedDifference;
            velocity = paramsRef.velocity;
            walk = paramsRef.walk;

            // add dot number requirement, or move the assignment somewhere better
            if (velocity != Vector3.zero && walk != string.Empty && speedDifference != 0) //check new params available
            {
                //Debug.Log("params not empty");
                // set velocities of dots
                dotscoh.GetComponent<DotMotion>().Vel = -velocity;

                // get global experiment params from GetTrialParams
                dotLifetime = paramsRef.dotLifetime;
                dotsize = paramsRef.dotsize;
                trialDuration = paramsRef.trialDuration;
                ISI = paramsRef.ISI;

                // set global params: numDots, dotsize, dotLifetime, trialDuration
                GeometricSpace.GetComponent<RandomSpawn>().dotsize = dotsize;
                GeometricSpace.GetComponent<RandomSpawn>().numDots = paramsRef.numDots;

                dotscoh.GetComponent<DotMotion>().dotLifetime = dotLifetime;
                endTrial.GetComponent<EndTrigger>().timer = trialDuration;

                
                if (paramsRef.trialNum % paramsRef.pauseN == 0)
                {
                    pauseText.SetActive(true);
                    pausing = true;
                }

                if (Input.GetKeyDown(KeyCode.P))
                    {
                        pausing = false;
                        pauseText.SetActive(false);
                    }

                if (pausing == false)
                {
                    updateFlag = false;
                    StartCoroutine(LoadStimulusScene());
                }
            }
        }
    }

    IEnumerator LoadStimulusScene() // some stuff here for when doing still and walk
    {
        paramsRef.trialNum++;
        if (paramsRef.trialNum % 2 == 1)
        {
            endBlockText.SetActive(true);
            yield return new WaitUntil(() => (Input.GetKeyDown(KeyCode.RightControl)));
            endBlockText.SetActive(false);
        }

        if (walk == "s")
        {
            //    correctFeedback.SetActive(false);
            //    incorrectFeedback.SetActive(false);
            //paramsRef.trialNum++;
            //if (paramsRef.trialNum % 1 == 1)
            {
            //yield return new WaitUntil(() => (Input.GetMouseButtonDown(2)));
            //    yield return new WaitUntil(() => (Input.GetKeyDown(KeyCode.RightControl)));
                stillText.SetActive(true);
                yield return new WaitForSeconds((float)0.3);
            }
            yield return new WaitUntil(() => spdTracker.hmdvellistsq.Max() < spdTracker.stillthreshold);
            stillText.SetActive(false);
            yield return new WaitForSeconds((float)0.15);

            paramsRef.stimNum = 1;
            SceneManager.LoadScene("Stimulus_SD"); // change this load scene

        }
        else if (walk == "w")
        {
            //correctFeedback.SetActive(false);
            //incorrectFeedback.SetActive(false);
            //paramsRef.trialNum++;
            //if (paramsRef.trialNum % 1 == 1)
            {
                //yield return new WaitUntil(() => (Input.GetMouseButtonDown(2)));
            //    yield return new WaitUntil(() => (Input.GetKeyDown(KeyCode.RightControl)));
                walkText.SetActive(true);
            }
            yield return new WaitUntil(() => spdTracker.hmdvellistsq.Min() > spdTracker.walkthreshold);
            walkText.SetActive(false);
            yield return new WaitForSeconds((float)0.15);

            paramsRef.stimNum = 1;
            SceneManager.LoadScene("Stimulus_SD"); // change this load scene
        }

        //yield return new WaitForSeconds((float)0.2);
        //paramsRef.trialNum++;
        //SceneManager.LoadScene("Stimulus_VonMises");
    }

    IEnumerator Pausing()
    {
        //Debug.Log("pausing");
        pauseText.SetActive(true);
        bool done = false;
        while (!done)
        {
            if (Input.GetKeyDown(KeyCode.RightControl))
            {
                pauseText.SetActive(false);
                done = true;
            }
            
        }
        yield return null;
    }
        
    IEnumerator LoadMainMenu()
    {
        expEndedText.SetActive(true);

        yield return new WaitForSeconds(4);
        paramsRef.expEnded = false;
        paramsRef.trialNum = 0;
        paramsRef.trialCorrect = 9;
        paramsRef.showFeedback = false;
        SceneManager.LoadScene("Main Menu");
    }
}
 