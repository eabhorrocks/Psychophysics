using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class getSocketInput : MonoBehaviour {

    GetTrialParams paramsRef;

    public void Awake()
    {
        paramsRef = FindObjectOfType<GetTrialParams>();
    }

    public void GetPortInput(string port)
    {
        Debug.Log("selected por t" + port);
        paramsRef.connectionPort = int.Parse(port);
    }

    public void GetIPInput(string IPaddress)
    {
        Debug.Log("selected IP address " + IPaddress);
        paramsRef.connectionIP = IPaddress;
    }
}
