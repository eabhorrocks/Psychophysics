using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SD_ISI : MonoBehaviour
{
    SD_GetTrialParams paramsRef;
    public GameObject dotscoh;
    public GameObject GeometricSpace;
    public GameObject endTrial;
    //public GameObject walkText;
    //public GameObject stillText;
    //public GameObject expEndedText;

    DotMotion dmRef;

    float speedDifference;
    Vector3 velocity;
    string walk;

    float dotLifetime;
    float dotsize;
    float trialDuration;
    float ISI;

    bool updateFlag = true;

    void Awake()
    {
        paramsRef = FindObjectOfType<SD_GetTrialParams>();
    }


    void Update()
    {

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
                velocity = velocity + velocity * speedDifference; // speed difference is fraction of base velocity. i.e. +- 0.5*vel
                dotscoh.GetComponent<DotMotion>().Vel = -velocity;

                // get global experiment params from GetTrialParams
                dotLifetime = paramsRef.dotLifetime;
                dotsize = paramsRef.dotsize;
                trialDuration = paramsRef.trialDuration;
                ISI = paramsRef.ISI;


                GeometricSpace.GetComponent<RandomSpawn>().dotsize = dotsize;
                GeometricSpace.GetComponent<RandomSpawn>().numDots = paramsRef.numDots;
                dotscoh.GetComponent<DotMotion>().dotLifetime = dotLifetime;

                updateFlag = false;
                StartCoroutine(LoadStim2());
            }
        }
    }


    IEnumerator LoadStim2()
    {
        yield return new WaitForSeconds(ISI);
        paramsRef.stimNum = 2;
        SceneManager.LoadScene("Stimulus_SD"); // change this load scene
    }
}