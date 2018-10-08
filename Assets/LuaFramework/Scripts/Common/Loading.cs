using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Loading : MonoBehaviour {
    public Image Progress;
    public Text text_Load;
    public static Loading _instance;
    // Use this for initialization
    void Start () {
        _instance = this;
        Progress.fillAmount = 0;
    }
	
	// Update is called once per frame
	void Update () {
		
	}
    public void ProgressBar(float current, float end,string str)
    {
        float sum = current / end;
        Progress.fillAmount = sum;
        text_Load.text = str;
        if (current == end && current == 9999)
        {
            StartCoroutine("Sleep");
        }
    }
    IEnumerator Sleep()
    {
        yield return new WaitForSeconds(1);
        this.gameObject.SetActive(false);
    }
}
