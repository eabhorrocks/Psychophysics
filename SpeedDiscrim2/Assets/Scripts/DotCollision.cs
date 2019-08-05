using UnityEngine;

public class DotCollision : MonoBehaviour {

    public GameObject theSpace;
    

    private void OnTriggerExit()
    {
        
        Vector3 newPos = Random.insideUnitSphere * theSpace.transform.localScale[0] / 2;
        transform.position = newPos;
    }
}
