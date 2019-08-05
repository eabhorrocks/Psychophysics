using UnityEngine;
using UnityEngine.SceneManagement;

public class ChangeScenes : MonoBehaviour {

	// Use this for initialization
	void Start () {
		
	}




// Update is called once per frame
void Update () {
        if (Input.GetKeyDown(KeyCode.Q))
        {
            SceneManager.LoadScene(0);
        }

	}
}
