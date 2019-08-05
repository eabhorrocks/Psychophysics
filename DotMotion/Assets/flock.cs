using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class flock : MonoBehaviour
{

    public float speed;
    public float pushspeed;
    float rotationSpeed = 4.0f;
    Vector3 averageHeading;
    Vector3 averagePosition;
    public float neighbourdistance;

    public Rigidbody rb;

    bool turning = false;

    float dist;

    // Use this for initialization
    void Start()
    {
    }

    // Update is called once per frame
    void FixedUpdate()
    {
         //if outside the boundary

        //{
        //    turning = true; //set turning
        //}
        //else
        //    turning = false;

        //if (turning)
        //{
        //    Vector3 direction = Vector3.zero - transform.position; // sets turning direction
        //    transform.rotation = Quaternion.Slerp(transform.rotation, // slerp to new direction
        //                                          Quaternion.LookRotation(direction),
        //                                          rotationSpeed * Time.deltaTime);

        //    speed = Random.Range(0.5f, 1); // new random speed
        //}
            //else
            //{


                if (Random.Range(0, 5) < 1)
                   ApplyRules();
        transform.Translate(0, 0, Time.deltaTime * speed);
           // }

        }

    void ApplyRules()

    {
        GameObject[,] gos;
        gos = dotSpawnWall.allDots;

        Vector3 vcentre = Vector3.zero;
        Vector3 vavoid = Vector3.zero;
        float gSpeed = 0.1f;

        Vector3 goalPos = dotSpawnWall.goalpos;

        int groupSize = 0;
        foreach (GameObject go in gos)
        {
            if(go != this.gameObject)
            {
               dist = Vector3.Distance(go.transform.position, this.transform.position);

                if(dist < neighbourdistance)
                    {
                        vavoid = vavoid + (this.transform.position - go.transform.position);
                   }

                }

        }
        // need forces to be dependent on how close the dot is
        vavoid.Normalize();

        rb.velocity = new Vector3(0, 0, Time.deltaTime * speed);

        rb.AddForce(vavoid * pushspeed, ForceMode.VelocityChange);

        float ypos = transform.position[1];
        if (ypos <= -25)
        {
            rb.AddForce(0, 1 * pushspeed, 0, ForceMode.VelocityChange);
        }
        else
            if (ypos >= 25)
        {
            rb.AddForce(0, -1 * pushspeed, 0, ForceMode.VelocityChange);
        }


        //if(groupSize > 0)
        //{
        //    vcentre = goalPos;
        //    speed = gSpeed / groupSize;

        //    Vector3 direction = (vcentre + vavoid) - transform.position;
        //    if (direction != Vector3.zero)
        //        transform.rotation = Quaternion.Slerp(transform.rotation,
        //                                              Quaternion.LookRotation(direction),
        //                                              rotationSpeed * Time.deltaTime);
        //}

    }
}
