using UnityEngine;

public class RandomSpawnDiscrim : MonoBehaviour
{
    public GameObject LeftWallObject;
    public GameObject RightWallObject;
    public GameObject LeftWall;
    public GameObject RightWall;

    public float xpos = 40;

    public float dotsize = 2;
    public float binsize = 3;

    float zmin = -500;
    float zmax = 0;
    float ymin = -25;
    float ymax = 25;


    // number of sections to divide wall into

    //private float dotsPerSection = 500 / 20;
    //private float xpos = 15;



    void Start()
    {
        //float n_ybins = ((ymax - ymin) / binsize);
        //float n_zbins = ((zmax - zmin) / binsize);


        //for (int iybin = 0; iybin < n_ybins; iybin++)
        //{
        //    for (int izbin = 0; izbin < n_zbins; izbin++)
        //    {
        //        float zpos = (float)(zmin + binsize * izbin);
        //        float ypos = (float)(ymin + binsize * iybin);

        //        Vector3 binpos = new Vector3(xpos, ypos, zpos);
        //        Vector3 posnoise = new Vector3(0f, Random.Range(-1f, 1f), Random.Range(-1f, 1f)) * 0.5f;
        //        Vector3 actpos = binpos + posnoise;

        //        Instantiate(LeftWallObject, actpos, transform.rotation);
        //        LeftWallObject.transform.localScale = new Vector3(dotsize, dotsize, dotsize);

        //    }
        //}
             


        float nSections = 20;
        float dotsPerSection = 500 / nSections;

        for (float iSection = 0; iSection <= nSections; iSection++)
        {

            for (int i = 0; i <= dotsPerSection; i++)
            {
                // calculate section area
                float beginning = -500 + iSection * (500 / 20);
                float End = beginning + 500 / 20; // 1000 is length of wall

                float z = Random.Range(beginning, End);
                float y = Random.Range(-25, 25);

                Vector3 rndPosWall = new Vector3(-xpos, y, z);

                Instantiate(LeftWallObject, rndPosWall, transform.rotation);
                LeftWallObject.transform.localScale = new Vector3(dotsize, dotsize, dotsize);

            }

        }

  
    }
}