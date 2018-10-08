using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LuaFramework;

public class HandleConfig{

	public void BuildMap() {
        Packager.AddBuildMap("Login" + AppConst.ExtName, "*.prefab", "Assets/LuaFramework/AssetsPackage/UI/Prefabs");
        Packager.AddBuildMap("SignUp" + AppConst.ExtName, "*.prefab", "Assets/LuaFramework/AssetsPackage/UI/Prefabs");
    }
}
