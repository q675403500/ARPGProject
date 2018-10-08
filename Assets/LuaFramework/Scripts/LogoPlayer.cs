using UnityEngine;
using System.Collections;
using UnityEngine.UI;
using UnityEngine.Video;

public class LogoPlayer : MonoBehaviour {

    //电影纹理  
    public VideoPlayer player;
    bool played = false;
    // Use this for initialization
    void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
        if (player.isPlaying && !played)
        {
            played = player.isPlaying;
        }

        if (played && !player.isPlaying)
        {
            UnityEngine.SceneManagement.SceneManager.LoadScene(1);
        }

        if (Input.GetMouseButtonDown(0))
        {
            UnityEngine.SceneManagement.SceneManager.LoadScene(1);
        }
    }
}
