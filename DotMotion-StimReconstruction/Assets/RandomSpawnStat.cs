using UnityEngine;

public class RandomSpawnStat : MonoBehaviour
{
    public GameObject ObjectToSpawn;
    public GameObject theSpace;
    public double numDots;
    public float dotsize;
    public float dotLifetime;


    void Start()
    {

        for (int i = 0; i < numDots; i++)
        {
            Vector3 rndPosWithin;
            rndPosWithin = Random.insideUnitSphere * theSpace.transform.localScale[0] / 2; //random pos within the sphere
            Instantiate(ObjectToSpawn, rndPosWithin, transform.rotation);
            ObjectToSpawn.transform.localScale = new Vector3(dotsize, dotsize, dotsize);


        }
    }
}