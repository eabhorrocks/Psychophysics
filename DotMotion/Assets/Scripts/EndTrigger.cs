using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class EndTrigger : MonoBehaviour {

    GetTrialParams paramsRef;
    GoToTrial goToTrialRef;
    public float timer;
    bool keepTiming = true;

    private void Awake()
    {
        paramsRef = FindObjectOfType<GetTrialParams>();
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
                SceneManager.LoadScene("TrialSelect");
                paramsRef.EndTrial();
                
            }
        }

    }

 
}
