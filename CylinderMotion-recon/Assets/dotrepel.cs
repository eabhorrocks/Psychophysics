using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class dotrepel : MonoBehaviour
{


    public float radius = 3;
    public float power = 1;


    // Use this for initialization
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {

        Collider[] colliders = Physics.OverlapSphere(transform.position, radius);
        foreach (Collider hit in colliders)
        {
            Rigidbody otherdot = hit.GetComponent<Rigidbody>();

            Vector3 forceVec = transform.position - otherdot.transform.position;
            forceVec = forceVec.normalized;
            otherdot.AddForce(-forceVec * power, ForceMode.VelocityChange);
        }
    }
}
