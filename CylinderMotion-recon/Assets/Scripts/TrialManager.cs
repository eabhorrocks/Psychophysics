using UnityEngine;
using UnityEngine.SceneManagement;

public class TrialManager : MonoBehaviour {

    bool trialHasEnded = false;

    public float coherence;
    public string direction;
    public string walk;

    public float restartDelay = 1f;

    private void Start()
    {

    }

    public void EndTrial()
    {


            // do stuff

            Debug.Log("Trial complete");
            SceneManager.LoadScene("TrialSelect");

    }
}
    

