using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine.U2D;
using UnityEngine.UI;

namespace LuaFramework
{
    /// <summary>
    /// 对象池管理器，分普通类对象池+资源游戏对象池
    /// </summary>
    public class UtilManager : Manager
    {
        private UtilManager instance = null;
        void Start()
        {
            instance = this;
        }

        public void SetSprite(GameObject go, string asset,string name)
        {
            if (null == go)
                return;
            asset = asset + AppConst.ExtName;
            UnityEngine.UI.Image img = go.GetComponent<UnityEngine.UI.Image>();
            if (null == img)
                return;
            AssetBundle bundle = ResManager.LoadBundle(asset);

            Sprite spt = bundle.LoadAsset(name, typeof(Sprite)) as Sprite;
            if (null == spt)
            {
                Texture2D tex = bundle.LoadAsset(name, typeof(Texture2D)) as Texture2D;
                if (tex)
                    img.sprite = Sprite.Create(tex, new Rect(0, 0, tex.width, tex.height), new Vector2(0.5f, 0.5f));
            }
            else
                img.sprite = spt;
            img.SetNativeSize();
            go.SetActive(true);
        }
    }
}