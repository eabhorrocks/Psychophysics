using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Accord.Math;
using Accord.Statistics.Distributions.Univariate;

public class vonMisesTest : MonoBehaviour

    
{
    // Start is called before the first frame update
    void Start()
    {
        var vonMises = new VonMisesDistribution(mean: 0, concentration: 20);
        var randCheck = vonMises.Generate(50);
        for (int i = 0; i < 50; i++)
        {
            //Debug.Log(randCheck[i]);
            //Debug.Log("X = " + (float)Math.Cos(randCheck[i]));
            //Debug.Log("Z = " + (float)Math.Sin(randCheck[i]));

        }

        double angle = Math.PI;
        Debug.Log(angle);
        Debug.Log("Cos(pi) = " + (float)System.Math.Cos(angle));


    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
