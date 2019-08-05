using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class dotSpawnWall : MonoBehaviour {

    public GameObject dot;
    public GameObject goalPrefab;
    public static int tankSize = 50;
    public float binsize = 5;

    public static int ybins = 10;
    public static int zbins = 30;
    public float posvar = 1f;
    public static GameObject[,] allDots = new GameObject[ybins,zbins];

    public static Vector3 goalpos = new Vector3(0, 0, -10000);

    // Use this for initialization
    void Start()
    {


        float xpos = transform.position[0];
        float zmin = transform.position[2] - transform.localScale[2] / 2;
        float ymin = transform.position[1] - transform.localScale[1] / 2;

            for (int iy = 0; iy < ybins; iy++)
            {
            for (int iz = 0; iz < zbins; iz++)
            {
                Vector3 pos = new Vector3(xpos,
                                          ymin + iy * binsize + binsize/2 + Random.Range(-posvar, posvar), 
                                          zmin + iz * binsize + binsize/2 + Random.Range(-posvar, posvar));
                allDots[iy, iz] = (GameObject) Instantiate(dot, pos, Quaternion.identity);
            }
            }
    }
	
	// Update is called once per frame
	void Update () {
		
	}
}
