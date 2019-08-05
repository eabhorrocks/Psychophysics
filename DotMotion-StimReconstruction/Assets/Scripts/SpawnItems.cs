using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpawnItems : MonoBehaviour {

    public Transform[] SpawnPoints;
    public float spawnTime = 0.5f;

    //public GameObject Dots
    public GameObject[] Dots;


	// Use this for initialization
	void Start ()
    {
        InvokeRepeating("SpawnDots", spawnTime, spawnTime);
	}
	
	// Update is called once per frame
	void Update () {
		
	}

    void SpawnDots()
    {
        int spawnIndex = Random.Range(0, SpawnPoints.Length);
        // set the index number of the array randomly


        Instantiate(Dots[0], SpawnPoints[spawnIndex].position, SpawnPoints[spawnIndex].rotation);
    }
}
