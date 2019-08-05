using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SD_EndTrigger : MonoBehaviour
{

    SD_GetTrialParams paramsRef;
    public float timer;
    bool keepTiming = true;

    private void Awake()
    {
        paramsRef = FindObjectOfType<SD_GetTrialParams>();
        timer = paramsRef.trialDuration;
    }

    private void Update()
    {
        if (keepTiming)
        {
            timer -= Time.deltaTime;
            if (timer <= 0)
            {
                keepTiming = false;
                if (paramsRef.stimNum == 2)
                {
                    SceneManager.LoadScene("TrialSelect");
                    paramsRef.EndTrial();
                }
                else if (paramsRef.stimNum == 1)
                {
                    SceneManager.LoadScene("SD_ISI");
                }  // load ISI scene
                
            }
        }

    }


}
