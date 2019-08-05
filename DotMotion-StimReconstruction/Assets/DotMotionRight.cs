using UnityEngine;

public class DotMotionRight : MonoBehaviour
{

    // This is a reference to the Rigidbody component called "rb"
    public Rigidbody rb;
    public Vector3 Vel;
    public GameObject theSpace;
    //public float dotLifetime;
    private float life;

    private void Awake()
    {
        //FindObjectOfType<GetTrialParams>();
        //Vel = paramsRef.velocity;
    }

    void Start()
    {
        rb.AddForce(Vel[0], Vel[1], Vel[2], ForceMode.VelocityChange);
        //life = Random.Range(0, dotLifetime);
        //Debug.Log(life);
    }

    private void Update()
    {
        //life += Time.deltaTime;
        //if (life >= dotLifetime)
        //{
        //    life = 0;
        //    Teleport();
        //}
    }

    //void Teleport()
    //{
    //    Vector3 rndPosWithin;
    //    rndPosWithin = Random.insideUnitSphere * theSpace.transform.localScale[0] / 2; //random pos within the sphere
    //    rb.position = rndPosWithin;
    //}
}