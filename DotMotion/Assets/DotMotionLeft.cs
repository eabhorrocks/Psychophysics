using UnityEngine;

public class DotMotionLeft : MonoBehaviour
{

    // This is a reference to the Rigidbody component called "rb"
    public Rigidbody rb;
    public Vector3 Vel;
    public GameObject theSpace;
    //public float dotLifetime;
    private float life;

    public float radius = 2;
    public float power = 1f;


    private void Awake()
    {
        //FindObjectOfType<GetTrialParams>();
        //Vel = paramsRef.velocity;s
    }

    void Start()
    {
        rb.AddForce(Vel[0], Vel[1], Vel[2], ForceMode.VelocityChange);
        //life = Random.Range(0, dotLifetime);
        //Debug.Log(life);

    }

	//private void FixedUpdate()
	//{
 //       rb.velocity = new Vector3 (0, 0, Vel[2]);
                 
 //       Collider[] colliders = Physics.OverlapSphere(transform.position, radius);
 //       foreach (Collider hit in colliders)
 //       {
 //           Rigidbody otherdot = hit.GetComponent<Rigidbody>();

 //           Vector3 forceVec = transform.position - otherdot.transform.position;
 //           forceVec = forceVec.normalized;
 //           otherdot.AddForce(-forceVec * power, ForceMode.VelocityChange);
 //       }
	//}


	//void Teleport()
    //{
     //   Vector3 rndPosWithin;
    //    rndPosWithin = Random.insideUnitSphere * theSpace.transform.localScale[0] / 2; //random pos within the sphere
    //    rb.position = rndPosWithin;
   // }
}