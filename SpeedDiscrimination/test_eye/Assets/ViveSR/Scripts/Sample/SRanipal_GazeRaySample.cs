//========= Copyright 2018, HTC Corporation. All rights reserved. ===========
using UnityEngine;
using UnityEngine.Assertions;

namespace ViveSR
{
    namespace anipal
    {
        namespace Eye
        {

            
            
            public class SRanipal_GazeRaySample : MonoBehaviour
            {
                public int LengthOfRay = 25;
                [SerializeField] private LineRenderer GazeRayRenderer;
                EyeData EyeData_;


                private void Start()
                {
                    if (!SRanipal_Eye_Framework.Instance.EnableEye)
                    {
                        enabled = false;
                        return;
                    }
                    Assert.IsNotNull(GazeRayRenderer);
                }

                private void Update()
                {
                    
                    if (SRanipal_Eye_Framework.Status != SRanipal_Eye_Framework.FrameworkStatus.WORKING &&
                        SRanipal_Eye_Framework.Status != SRanipal_Eye_Framework.FrameworkStatus.NOT_SUPPORT) return;
                    Vector3 GazeOriginCombinedLocal, GazeDirectionCombinedLocal;
                    if (SRanipal_Eye.GetGazeRay(GazeIndex.COMBINE, out GazeOriginCombinedLocal, out GazeDirectionCombinedLocal)) { }
                    else if (SRanipal_Eye.GetGazeRay(GazeIndex.LEFT, out GazeOriginCombinedLocal, out GazeDirectionCombinedLocal)) { }
                    else if (SRanipal_Eye.GetGazeRay(GazeIndex.RIGHT, out GazeOriginCombinedLocal, out GazeDirectionCombinedLocal)) { }
                    else return;
                    Vector3 GazeDirectionCombined = Camera.main.transform.TransformDirection(GazeDirectionCombinedLocal);
                    GazeRayRenderer.SetPosition(0, Camera.main.transform.position - Camera.main.transform.up * 0.05f);
                    GazeRayRenderer.SetPosition(1, Camera.main.transform.position + GazeDirectionCombined * LengthOfRay);
                    Vector2 test;
                    float openness;
                    SRanipal_Eye.GetEyeOpenness(EyeIndex.LEFT, out openness);

                    SingleEyeData[] eyesData = new SingleEyeData[2];
                    eyesData[(int)EyeIndex.LEFT] = EyeData_.verbose_data.left;
                    eyesData[(int)EyeIndex.RIGHT] = EyeData_.verbose_data.right;
                    SRanipal_Eye.GetEyeData(ref EyeData_);
                    float pupild;
                    pupild = eyesData[0].pupil_diameter_mm;
                    Debug.Log(pupild);

                }
            }
             
        }
    }
}
