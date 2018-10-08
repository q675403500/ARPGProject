﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class OpenWindow : MonoBehaviour {

    public Color backgroundColor = new Color(10.0f / 255.0f, 10.0f / 255.0f, 10.0f / 255.0f, 0.6f);

    public float destroyTime = 0.5f;

    private GameObject m_background;

    public void Open(string path)
    {
        AddBackground(path);
    }

    public void Close()
    {
        var animator = GetComponent<Animator>();
        if (animator.GetCurrentAnimatorStateInfo(0).IsName("Open"))
            animator.Play("Close");

        RemoveBackground();
        StartCoroutine(RunPopupDestroy());
    }

    // We destroy the popup automatically 0.5 seconds after closing it.
    // The destruction is performed asynchronously via a coroutine. If you
    // want to destroy the popup at the exact time its closing animation is
    // finished, you can use an animation event instead.
    private IEnumerator RunPopupDestroy()
    {
        yield return new WaitForSeconds(destroyTime);
        Destroy(m_background);
        Destroy(gameObject);
    }

    private void AddBackground(string path)
    {
        var bgTex = new Texture2D(1, 1);
        bgTex.SetPixel(0, 0, backgroundColor);
        bgTex.Apply();

        m_background = new GameObject("PopupBackground");
        var image = m_background.AddComponent<Image>();
        var rect = new Rect(0, 0, bgTex.width, bgTex.height);
        var sprite = Sprite.Create(bgTex, rect, new Vector2(0.5f, 0.5f), 1);
        image.material.mainTexture = bgTex;
        image.sprite = sprite;
        var newColor = image.color;
        image.color = newColor;
        image.canvasRenderer.SetAlpha(0.0f);
        image.CrossFadeAlpha(1.0f, 0.4f, false);

        var canvas = GameObject.Find("Canvas/GuiCamera/"+ path + "Layer");
        m_background.transform.localScale = new Vector3(1, 1, 1);
        m_background.GetComponent<RectTransform>().sizeDelta = canvas.GetComponent<RectTransform>().sizeDelta;
        m_background.transform.SetParent(canvas.transform, false);
        m_background.transform.SetSiblingIndex(transform.GetSiblingIndex());
    }

    private void RemoveBackground()
    {
        var image = m_background.GetComponent<Image>();
        if (image != null)
            image.CrossFadeAlpha(0.0f, 0.2f, false);
    }
}
