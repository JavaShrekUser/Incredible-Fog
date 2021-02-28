using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class LoadScene : MonoBehaviour {
    private int nextScene;
    private void Start(){
        nextScene = SceneManager.GetActiveScene().buildIndex + 1;
    }

    private void OnTriggerEnter2D(Collider2D collison){
        if(collison.tag == "Player") { 
            SceneManager.LoadScene(nextScene);
            }
    }
}