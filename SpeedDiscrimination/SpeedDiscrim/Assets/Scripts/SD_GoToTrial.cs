using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SD_GoToTrial : MonoBehaviour
{
    SD_GetTrialParams paramsRef;
    SD_EndTrigger endRef;
    public GameObject dotscoh;
    public GameObject GeometricSpace;
    public GameObject endTrial;
    public GameObject walkText;
    public GameObject stillText;
    public GameObject expEndedText;
    public GameObject correctFeedback;
    public GameObject incorrectFeedback;
    public GameObject pauseText;

    DotMotion dmRef;

    Transform dotsCohTransform;
    Transform dotsIncTransform;

    float speedDifference;
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
    }


    void Update()
    {
        if (paramsRef.expEnded == true)
        {
            StartCoroutine(LoadMainMenu());
        }


        if (updateFlag == true)
        {

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
            // assign global vars here.

            speedDifference = (float)paramsRef.speedDifference;
            velocity = paramsRef.velocity;
            walk = paramsRef.walk;

            // add dot number requirement, or move the assignment somewhere better
            if (velocity != Vector3.zero && walk != string.Empty && speedDifference != 0) //check new params available
            {
                //Debug.Log("params not empty");
                // set velocities of dots
                velocity = velocity - velocity * (speedDifference/2f); // speed difference is fraction of base velocity. i.e. +- 0.5*vel
                dotscoh.GetComponent<DotMotion>().Vel = -velocity;

                // get global experiment params from GetTrialParams
                dotLifetime = paramsRef.dotLifetime;
                dotsize = paramsRef.dotsize;
                trialDuration = paramsRef.trialDuration;
                ISI = paramsRef.ISI;


                GeometricSpace.GetComponent<RandomSpawn>().dotsize = dotsize;
                GeometricSpace.GetComponent<RandomSpawn>().numDots = paramsRef.numDots;
                dotscoh.GetComponent<DotMotion>().dotLifetime = dotLifetime;

                if (paramsRef.trialNum % paramsRef.pauseN == 0)
                {
                    pauseText.SetActive(true);
                    pausing = true;
                }

                if (Input.GetMouseButtonDown(0))
                {
                    pausing = false;
                    pauseText.SetActive(false);
                }

                if (Input.GetMouseButtonDown(1))
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

    IEnumerator LoadStimulusScene()
    {
        //if (walk == "s")
        //{
        //    correctFeedback.SetActive(false);
        //    incorrectFeedback.SetActive(false);
        //    stillText.SetActive(true);
        //    walkText.SetActive(false);
        //    yield return new WaitForSeconds((float)0.6);
        //    stillText.SetActive(false);

        //}
        //if (walk == "w")
        //{
        //    correctFeedback.SetActive(false);
        //    incorrectFeedback.SetActive(false);
        //    stillText.SetActive(false);
        //    walkText.SetActive(true);
        //    yield return new WaitForSeconds((float)0.6);
        //    walkText.SetActive(false);
        //}

        yield return new WaitForSeconds((float)0.5);
        paramsRef.trialNum++;
        paramsRef.stimNum = 1;
        SceneManager.LoadScene("Stimulus_SD"); // change this load scene
    }

    IEnumerator LoadMainMenu()
    {
        expEndedText.SetActive(true);

        yield return new WaitForSeconds(4);

        SceneManager.LoadScene("Main Menu");
    }
}
