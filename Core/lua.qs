//
// Copyright (C) 2021-2023 Andrei Karas (4144)
//
// Hercules is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

function registerLua()
{
    function lua_loadBefore(existingName, newNamesList, free)
    {
        checkArgs("lua.loadBefore", arguments, [["String", "Object"], ["String", "Object", "Number"]]);
        return lua.load(existingName, newNamesList, [], true, free);
    }

    function lua_loadAfter(existingName, newNamesList, free)
    {
        checkArgs("lua.loadAfter", arguments, [["String", "Object"], ["String", "Object", "Number"]]);
        return lua.load(existingName, [], newNamesList, true, free);
    }

    function lua_replace(existingName, newNamesList, free)
    {
        checkArgs("lua.replace", arguments, [["String", "Object"], ["String", "Object", "Number"]]);
        return lua.load(existingName, newNamesList, [], false, free);
    }

    function lua_getCLuaLoadInfo(stackOffset)
    {
        checkArgs("lua.getCLuaLoadInfo", arguments, [["Number"]]);
        var type = table.getValidated(table.CLua_Load_type);
        var obj = {};
        obj.type = type;
        obj.pushLine = "push dword ptr [esp + argsOffset + " + stackOffset + "]";
        if (type == 4)
        {
            obj.asmCopyArgs = asm.combine(
                obj.pushLine,
                obj.pushLine,
                obj.pushLine
            );
            obj.argsOffset = 0xc;
        }
        else if (type == 3)
        {
            obj.asmCopyArgs = asm.combine(
                obj.pushLine,
                obj.pushLine
            );
            obj.argsOffset = 0x8;
        }
        else if (type == 2)
        {
            obj.asmCopyArgs = asm.combine(obj.pushLine);
            obj.argsOffset = 0x4;
        }
        else
        {
            fatalError("Unsupported CLua_Load type");
        }

        return obj;
    }

    function lua_getLoadObj(origFile, beforeNameList, afterNameList, loadDefault)
    {
        checkArgs(
            "lua.getLoadObj",
            arguments,
            [
                ["String", "Object", "Object", "Boolean"],
                ["String", "Array", "Array", "Boolean"],
            ]
        );

        var origOffset = pe.stringVa(origFile);
        if (origOffset === -1)
        {
            throw "LUAFL: Filename missing: " + origFile;
        }

        var strHex = origOffset.packToHex(4);

        var type = table.getValidated(table.CLua_Load_type);
        var mLuaAbsHex = table.getSessionAbsHex4(table.CSession_m_lua_offset);
        var mLuaHex = table.getHex4(table.CSession_m_lua_offset);
        var CLua_Load = table.get(table.CLua_Load);
        var code;
        var moveOffset;
        var pushFlagsOffset;
        var afterStolenCodeOffset;
        var postOffset;
        var otherOffset;
        var otherOffset2;
        var callOffset;
        var hookLoader;

        if (type == 4)
        {
            code =
                "8B 8E " + mLuaHex +
                "6A ?? " +
                "6A ?? " +
                "68 " + strHex +
                "E8 ";
            moveOffset = [0, 6];
            pushFlagsOffset = [6, 4];
            afterStolenCodeOffset = 10;
            postOffset = 20;
            otherOffset = 0;
            otherOffset2 = 0;
            callOffset = [16, 4];
            hookLoader = pe.find(code);
            if (hookLoader === -1)
            {
                code =
                    "8B 0D " + mLuaAbsHex +
                    "6A ?? " +
                    "6A ?? " +
                    "68 " + strHex +
                    "E8 ";
                moveOffset = [0, 6];
                pushFlagsOffset = [6, 4];
                afterStolenCodeOffset = 10;
                postOffset = 20;
                otherOffset = 0;
                otherOffset2 = 0;
                callOffset = [16, 4];
                hookLoader = pe.find(code);
            }
            if (hookLoader === -1)
            {
                code =
                    "8B 8E " + mLuaHex +
                    "53 " +
                    "6A ?? " +
                    "68 " + strHex +
                    "E8 ";
                moveOffset = [0, 6];
                pushFlagsOffset = [6, 3];
                afterStolenCodeOffset = 9;
                postOffset = 19;
                otherOffset = 0;
                otherOffset2 = 0;
                callOffset = [15, 4];
                hookLoader = pe.find(code);
            }
            if (hookLoader === -1)
            {
                code =
                    "6A ?? " +
                    "6A ?? " +
                    "68 " + strHex +
                    "8B CE " +
                    "E8 ";
                moveOffset = [9, 2];
                pushFlagsOffset = [0, 4];
                afterStolenCodeOffset = 0;
                postOffset = 16;
                otherOffset = 0;
                otherOffset2 = 0;
                callOffset = [12, 4];
                hookLoader = pe.find(code);
            }
            if (hookLoader === -1)
            {
                code =
                    "8B CE " +
                    "6A ?? " +
                    "6A ?? " +
                    "68 " + strHex +
                    "89 B5 ?? ?? ?? FF " +
                    "E8 ";
                moveOffset = [0, 2];
                pushFlagsOffset = [2, 4];
                afterStolenCodeOffset = 6;
                postOffset = 22;
                otherOffset = [11, 6];
                otherOffset2 = 0;
                callOffset = [18, 4];
                hookLoader = pe.find(code);
            }
            if (hookLoader === -1)
            {
                code =
                    "6A ?? " +
                    "6A ?? " +
                    "68 " + strHex +
                    "8B CF " +
                    "E8 ";
                moveOffset = [9, 2];
                pushFlagsOffset = [0, 4];
                afterStolenCodeOffset = 0;
                postOffset = 16;
                otherOffset = 0;
                otherOffset2 = 0;
                callOffset = [12, 4];
                hookLoader = pe.find(code);
            }
            if (hookLoader === -1)
            {
                code =
                    "53 " +
                    "6A ?? " +
                    "68 " + strHex +
                    "8B CE " +
                    "E8 ";
                moveOffset = [8, 2];
                pushFlagsOffset = [0, 3];
                afterStolenCodeOffset = 0;
                postOffset = 15;
                otherOffset = 0;
                otherOffset2 = 0;
                callOffset = [11, 4];
                hookLoader = pe.find(code);
            }
            if (hookLoader === -1)
            {
                code =
                    "53 " +
                    "6A ?? " +
                    "89 8D ?? ?? ?? FF " +
                    "68 " + strHex +
                    "8B CE " +
                    "89 B5 ?? ?? ?? FF " +
                    "E8 ";
                moveOffset = [14, 2];
                pushFlagsOffset = [0, 3];
                afterStolenCodeOffset = 0;
                postOffset = 27;
                otherOffset = [3, 6];
                otherOffset2 = [16, 6];
                callOffset = [23, 4];
                hookLoader = pe.find(code);
            }
            if (hookLoader === -1)
            {
                code =
                    "6A ?? " +
                    "6A ?? " +
                    "68 " + strHex +
                    "8B CF " +
                    "89 BD ?? ?? ?? FF " +
                    "E8 ";
                moveOffset = [9, 2];
                pushFlagsOffset = [0, 4];
                afterStolenCodeOffset = 0;
                postOffset = 22;
                otherOffset = [11, 6];
                otherOffset2 = 0;
                callOffset = [18, 4];
                hookLoader = pe.find(code);
            }
        }
        else if (type == 3)
        {
            code =
                "8B 8E " + mLuaHex +
                "6A ?? " +
                "68 " + strHex +
                "E8 ";
            moveOffset = [0, 6];
            pushFlagsOffset = [6, 2];
            afterStolenCodeOffset = 8;
            postOffset = 18;
            otherOffset = 0;
            otherOffset2 = 0;
            callOffset = [14, 4];
            hookLoader = pe.find(code);
            if (hookLoader === -1)
            {
                code =
                    "8B 0D " + mLuaAbsHex +
                    "6A ?? " +
                    "68 " + strHex +
                    "E8 ";
                moveOffset = [0, 6];
                pushFlagsOffset = [6, 2];
                afterStolenCodeOffset = 8;
                postOffset = 18;
                otherOffset = 0;
                otherOffset2 = 0;
                callOffset = [14, 4];
                hookLoader = pe.find(code);
            }
        }
        else if (type == 2)
        {
            code =
                "8B 8E " + mLuaHex +
                "68 " + strHex +
                "E8 ";
            moveOffset = [0, 6];
            pushFlagsOffset = 0;
            afterStolenCodeOffset = 6;
            postOffset = 16;
            otherOffset = 0;
            otherOffset2 = 0;
            callOffset = [12, 4];
            hookLoader = pe.find(code);
            if (hookLoader === -1)
            {
                code =
                    "8B 0D " + mLuaAbsHex +
                    "68 " + strHex +
                    "E8 ";
                moveOffset = [0, 6];
                pushFlagsOffset = 0;
                afterStolenCodeOffset = 6;
                postOffset = 16;
                otherOffset = 0;
                otherOffset2 = 0;
                callOffset = [12, 4];
                hookLoader = pe.find(code);
            }
            if (hookLoader === -1)
            {
                code =
                    "8B 8E " + mLuaHex +
                    "83 C4 ?? " +
                    "68 " + strHex +
                    "E8 ";
                moveOffset = [0, 6];
                pushFlagsOffset = 0;
                afterStolenCodeOffset = 9;
                postOffset = 19;
                otherOffset = [6, 3];
                otherOffset2 = 0;
                callOffset = [15, 4];
                hookLoader = pe.find(code);
            }
        }
        else
        {
            fatalError("Unsupported CLua_Load type");
        }

        if (hookLoader === -1)
        {
            throw "LUAFL: CLua_Load call missing: " + origFile;
        }

        var retLoader = hookLoader + postOffset;

        var callValue = pe.fetchRelativeValue(hookLoader, callOffset);
        if (callValue !== CLua_Load)
        {
            throw "LUAFL: found wrong call function: " + origFile;
        }

        var movStolenCode = "";
        if (moveOffset !== 0)
        {
            movStolenCode = pe.fetchHexBytes(hookLoader, moveOffset);
        }
        var pushFlagsStolenCode = "";
        if (pushFlagsOffset !== 0)
        {
            pushFlagsStolenCode = pe.fetchHexBytes(hookLoader, pushFlagsOffset);
        }
        var customStolenCode = movStolenCode + pushFlagsStolenCode;
        var otherStoleCode = "";
        if (otherOffset !== 0)
        {
            otherStoleCode = pe.fetchHexBytes(hookLoader, otherOffset);
        }
        if (otherOffset2 !== 0)
        {
            otherStoleCode += pe.fetchHexBytes(hookLoader, otherOffset2);
        }
        var defaultStolenCode = customStolenCode;
        if (afterStolenCodeOffset != 0)
        {
            defaultStolenCode = pe.fetchHex(hookLoader, afterStolenCodeOffset);
        }

        var stringsCode = "";
        var i;
        for (i = 0; i < beforeNameList.length; i++)
        {
            stringsCode = asm.combine(
                stringsCode,
                "varb" + i + ":",
                asm.stringToAsm(beforeNameList[i] + "\x00")
            );
        }
        for (i = 0; i < afterNameList.length; i++)
        {
            stringsCode = asm.combine(
                stringsCode,
                "vara" + i + ":",
                asm.stringToAsm(afterNameList[i] + "\x00")
            );
        }

        var asmCode = asm.hexToAsm(otherStoleCode);

        for (i = 0; i < beforeNameList.length; i++)
        {
            asmCode = asm.combine(
                asmCode,
                asm.hexToAsm(customStolenCode),
                "push varb" + i,
                "call CLua_Load"
            );
        }

        if (loadDefault === true)
        {
            asmCode = asm.combine(
                asmCode,
                asm.hexToAsm(defaultStolenCode),
                "push offset",
                "call CLua_Load"
            );
        }

        for (i = 0; i < afterNameList.length; i++)
        {
            asmCode = asm.combine(
                asmCode,
                asm.hexToAsm(customStolenCode),
                "push vara" + i,
                "call CLua_Load"
            );
        }

        var text = asm.combine(
            asmCode,
            "jmp continueAddr",
            asm.hexToAsm("00"),
            stringsCode
        );

        var vars = {
            "offset": origOffset,
            "CLua_Load": CLua_Load,
            "continueAddr": pe.rawToVa(retLoader),
        };

        var obj = Object();
        obj.hookAddrRaw = hookLoader;
        obj.asmText = text;
        obj.vars = vars;
        return obj;
    }

    function lua_load(origFile, beforeNameList, afterNameList, loadDefault, free)
    {
        checkArgs(
            "lua.load",
            arguments,
            [
                ["String", "Object", "Object", "Boolean"],
                ["String", "Array", "Array", "Boolean"],
                ["String", "Object", "Object", "Boolean", "Number"],
                ["String", "Array", "Array", "Boolean", "Number"],
                ["String", "Object", "Object", "Boolean", "Undefined"],
                ["String", "Array", "Array", "Boolean", "Undefined"],
            ]
        );

        var loadObj = lua.getLoadObj(origFile, beforeNameList, afterNameList, loadDefault);

        if (typeof free === "undefined" || free === -1)
        {
            var obj = pe.insertAsmTextObj(loadObj.asmText, loadObj.vars);
            free = obj.free;
        }
        else
        {
            pe.replaceAsmText(free, loadObj.asmText, loadObj.vars);
        }

        pe.setJmpRaw(loadObj.hookAddrRaw, free, "jmp", 6);

        return true;
    }

    lua = {};
    lua.loadBefore = lua_loadBefore;
    lua.loadAfter = lua_loadAfter;
    lua.replace = lua_replace;
    lua.getCLuaLoadInfo = lua_getCLuaLoadInfo;
    lua.getLoadObj = lua_getLoadObj;
    lua.load = lua_load;
}
