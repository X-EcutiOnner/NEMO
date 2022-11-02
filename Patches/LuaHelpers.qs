

delete D2S;
delete D2D;
delete EspAlloc;
delete StrAlloc;
delete AllocType;
delete LuaState;
delete LuaFnCaller;

function _GetLuaAddrs()
{
    var offset = pe.stringVa("d>s");
    if (offset === -1)
    {
        return "LUA: d>s not found";
    }

    D2S = offset.packToHex(4);

    offset = pe.stringVa("d>d");
    if (offset === -1)
    {
        return "LUA: d>d not found";
    }

    D2D = offset.packToHex(4);

    offset = pe.stringVa("ReqJobName");
    if (offset === -1)
    {
        return "LUA: ReqJobName not found";
    }

    offset = pe.findCode("68" + offset.packToHex(4));
    if (offset === -1)
    {
        return "LUA: ReqJobName reference missing";
    }

    var code =
        " 83 EC ??" +
        " 8B CC";
    var offset2 = pe.find(code, offset - 0x28, offset);
    if (offset2 === -1)
    {
        return "LUA: ESP allocation missing";
    }

    EspAlloc = pe.fetchByte(offset2 + 2);

    switch (pe.fetchUByte(offset + 5))
    {
        case 0xFF: {
            offset += 11;
            StrAlloc = pe.fetchHex(offset - 4, 4);
            AllocType = 0;
            break;
        }
        case 0xE8: {
            offset += 10;
            StrAlloc = pe.rawToVa(offset) + pe.fetchDWord(offset - 4);
            AllocType = 1;
            break;
        }
        case 0xC6: {
            offset += 13;
            StrAlloc = pe.rawToVa(offset) + pe.fetchDWord(offset - 4);
            AllocType = 2;
            break;
        }
        default: {
            return "LUA: Unexpected Opcode after ReqJobName";
        }
    }

    code = "8B ?? ?? ?? ?? 00";
    offset2 = pe.find(code, offset, offset + 0x10);

    if (offset2 === -1)
    {
        code = "FF 35 ?? ?? ?? 00";
        offset2 = pe.find(code, offset, offset + 0x10);
    }

    if (offset2 === -1)
    {
        code = "A1 ?? ?? ?? 00";
        offset2 = pe.find(code, offset, offset + 0x10);
    }

    if (offset2 === -1)
    {
        return "LUA: Lua_state assignment missing";
    }

    offset2 += code.hexlength();

    LuaState = pe.fetchHex(offset2 - 4, 4);

    offset = pe.find(" E8 ?? ?? ?? FF", offset2, offset2 + 0x10);
    if (offset === -1)
    {
        return "LUA: Lua Function caller missing";
    }

    LuaFnCaller = pe.rawToVa(offset + 5) + pe.fetchDWord(offset + 1);

    return true;
}

function GenLuaCaller(addr, name, nameAddr, format, inReg)
{
    if (typeof LuaFnCaller === "undefined")
    {
        var result = _GetLuaAddrs();
        if (typeof result === "string")
        {
            return result;
        }
    }

    var fmtAddr;
    if (format === "d>s")
    {
        fmtAddr = D2S;
    }
    else
    {
        fmtAddr = D2D;
    }

    if (typeof nameAddr === "number")
    {
        nameAddr = nameAddr.packToHex(4);
    }

    var code =
        " PrePush" +
        " 6A 00" +
        " 54" +
        inReg +
        " 68" + fmtAddr +
        " 83 EC" + EspAlloc.packToHex(1) +
        " 8B CC" +
        " StrAllocPrep" +
        " 68" + nameAddr +
        " FF 15" + StrAlloc +
        " FF 35" + LuaState +
        " E8" + GenVarHex(1);

    if (AllocType === 1)
    {
        code = code.replace(" PrePush", " 6A" + name.length.packToHex(1));
    }
    else
    {
        code = code.replace(" PrePush", "");
    }

    if (AllocType === 1)
    {
        code = code.replace(
            " StrAllocPrep",
            " 8D 44 24" + (EspAlloc + 16).packToHex(1) +
    " 50"
        );
    }
    else if (AllocType === 2)
    {
        code = code.replace(
            " StrAllocPrep",
            " C7 41 14 0F 00 00 00" +
    " C7 41 10 00 00 00 00" +
    " C6 01 00" +
    " 6A" + name.length.packToHex(1)
        );
    }
    else
    {
        code = code.replace(" StrAllocPrep", "");
    }

    if (AllocType !== 0)
    {
        code = code.replace(" FF 15" + StrAlloc, " E8" + (StrAlloc - pe.rawToVa(addr + code.hexlength() - 12)).packToHex(4));
    }

    code = ReplaceVarHex(code, 1, LuaFnCaller - pe.rawToVa(addr + code.hexlength()));

    code +=
        " 83 C4" + (EspAlloc + 16).packToHex(1) +
        " 58";

    if (AllocType === 1)
    {
        code += " 83 C4 04";
    }

    return code;
}

function InjectLuaFiles(origFile, nameList, free, loadBefore)
{
    var origOffset = pe.stringVa(origFile);
    if (origOffset === -1)
    {
        return "LUAFL: Filename missing";
    }

    var strHex = origOffset.packToHex(4);

    var type = table.get(table.CLua_Load_type);
    if (type === 0)
    {
        throw "CLua_Load type not set";
    }

    if (typeof loadBefore === "undefined")
    {
        loadBefore = true;
    }

    var mLuaAbsHex = table.getSessionAbsHex4(table.CSession_m_lua_offset);
    var mLuaHex = table.getHex4(table.CSession_m_lua_offset);
    var CLua_Load = table.get(table.CLua_Load);
    var code;
    var moveOffset;
    var pushFlagsOffset;
    var strPushOffset;
    var postOffset;

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
        strPushOffset = 10;
        postOffset = 20;

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
            strPushOffset = 10;
            postOffset = 20;

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
            strPushOffset = 9;
            postOffset = 19;

            callOffset = [15, 4];
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
        strPushOffset = 8;
        postOffset = 18;

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
            strPushOffset = 8;
            postOffset = 18;

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
        strPushOffset = 6;
        postOffset = 16;

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
            strPushOffset = 6;
            postOffset = 16;

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
            strPushOffset = 9;
            postOffset = 19;

            callOffset = [15, 4];
            hookLoader = pe.find(code);
        }
    }
    else
    {
        throw "Unsupported CLua_Load type";
    }

    if (hookLoader === -1)
    {
        return "LUAFL: CLua_Load call missing";
    }

    var retLoader = hookLoader + postOffset;

    var callValue = pe.fetchRelativeValue(hookLoader, callOffset);
    if (callValue !== CLua_Load)
    {
        throw "LUAFL: found wrong call function";
    }

    var allStolenCode = pe.fetchHex(hookLoader, strPushOffset);
    var movStolenCode = pe.fetchHexBytes(hookLoader, moveOffset);
    var pushFlagsStolenCode = "";
    if (pushFlagsOffset !== 0)
    {
        pushFlagsStolenCode = pe.fetchHexBytes(hookLoader, pushFlagsOffset);
    }
    var shortStolenCode = movStolenCode + pushFlagsStolenCode;

    var stringsCode = "";
    var i;
    for (i = 0; i < nameList.length; i++)
    {
        stringsCode = asm.combine(
            stringsCode,
            "var" + i + ":",
            asm.stringToAsm(nameList[i] + "\x00")
        );
    }

    var asmCode = "";
    if (loadBefore === false)
    {
        asmCode = asm.combine(
            asm.hexToAsm(allStolenCode),
            "push offset",
            "call CLua_Load"
        );
    }
    for (i = 0; i < nameList.length; i++)
    {
        asmCode = asm.combine(
            asmCode,
            asm.hexToAsm(shortStolenCode),
            "push var" + i,
            "call CLua_Load"
        );
    }

    var text;
    if (loadBefore === true)
    {
        text = asm.combine(
            asmCode,
            asm.hexToAsm(allStolenCode),
            "push offset",
            "call CLua_Load",
            "jmp continueAddr",
            asm.hexToAsm("00"),
            stringsCode
        );
    }
    else
    {
        text = asm.combine(
            asmCode,
            "jmp continueAddr",
            asm.hexToAsm("00"),
            stringsCode
        );
    }
    var vars = {
        "offset": origOffset,
        "CLua_Load": CLua_Load,
        "continueAddr": pe.rawToVa(retLoader),
    };

    if (typeof free === "undefined" || free === -1)
    {
        var obj = pe.insertAsmTextObj(text, vars);
        free = obj.free;
    }
    else
    {
        pe.replaceAsmText(free, text, vars);
    }

    pe.setJmpRaw(hookLoader, free, "jmp", 6);

    return true;
}
