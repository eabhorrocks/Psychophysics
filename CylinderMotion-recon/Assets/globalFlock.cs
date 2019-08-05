using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class globalFlock : MonoBehaviour {

    // spawn the dots and set changing goal position

    public GameObject dot;
    public GameObject goalPrefab;
    public static int tankSize = 50;

    public static int numDots = 200;
    public static GameObject[] allDots = new GameObject[numDots];

    public static Vector3 goalPos = Vector3.zero;

	// Use this for initialization
	void Start () {

        for (int i = 0; i < numDots; i++)
        {
            Vector3 pos = new Vector3(Random.Range(-tankSize, tankSize),
                                      Random.Range(-tankSize, tankSize),
                                      Random.Range(-tankSize, tankSize));
            allDots[i] = (GameObject) Instantiate(dot, pos, Quaternion.identity);

        }
	}
	
	// Update is called once per frame
	void Update () {

        if(Random.Range(0,10000) < 1)
        {
            goalPos = new Vector3(Random.Range(-tankSize, tankSize),
                                  Random.Range(-tankSize, tankSize),
                                  Random.Range(-tankSize, tankSize));

            goalPrefab.transform.position = goalPos;
        }
		
	}
}
