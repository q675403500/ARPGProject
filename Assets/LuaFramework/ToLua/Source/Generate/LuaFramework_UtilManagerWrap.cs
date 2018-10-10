﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class LuaFramework_UtilManagerWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(LuaFramework.UtilManager), typeof(Manager));
		L.RegFunction("SetSprite", SetSprite);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int SetSprite(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			LuaFramework.UtilManager obj = (LuaFramework.UtilManager)ToLua.CheckObject<LuaFramework.UtilManager>(L, 1);
			UnityEngine.GameObject arg0 = (UnityEngine.GameObject)ToLua.CheckObject(L, 2, typeof(UnityEngine.GameObject));
			string arg1 = ToLua.CheckString(L, 3);
			string arg2 = ToLua.CheckString(L, 4);
			obj.SetSprite(arg0, arg1, arg2);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int op_Equality(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.Object arg0 = (UnityEngine.Object)ToLua.ToObject(L, 1);
			UnityEngine.Object arg1 = (UnityEngine.Object)ToLua.ToObject(L, 2);
			bool o = arg0 == arg1;
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

