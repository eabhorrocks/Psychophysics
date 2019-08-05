using UnityEngine;

public class DotMotionVecTel : MonoBehaviour
{

    // This is a reference to the Rigidbody component called "rb"
    public Rigidbody rb;
    public Vector3 Vel;
    public GameObject theSpace;
    public float dotLifetime;
    public float life;
    public Vector3[] poses;
    private int telNum = 0;

    private void Awake()
    {
        //Vel = paramsRef.velocity;
    }

    void Start()
    {
        rb.AddForce(Vel[0], Vel[1], Vel[2], ForceMode.VelocityChange);
        //life = Random.Range(0, dotLifetime);
        telNum = 0;
        //Debug.Log(life);
    }

    private void Update()
    {
        life += Time.deltaTime;
        if (life >= dotLifetime)
        {
            life = 0;
            Teleport();
        }
    }

    void Teleport()
    {
        telNum++;
        //Debug.Log("telnum: " + telNum);
        //Vector3 rndPosWithin = Random.insideUnitSphere * theSpace.transform.localScale[0] / 2; //random pos within the sphere
        rb.position = poses[telNum];
        //Debug.Log(poses[telNum]);
    }
}