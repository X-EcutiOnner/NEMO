

function OverwriteString(srcString, tgtString)
{
    var offset = pe.stringRaw(srcString);

    if (offset === -1)
    {
        throw "String " + srcString + " not found";
    }

    pe.replace(offset, tgtString);

    return pe.rawToVa(offset);
}

function CheckEoT(opcode, modrm, offset, details, assigner)
{
    if (typeof assigner === "undefined")
    {
        assigner = -1;
    }

    if (opcode === 0x2B && pe.fetchUByte(offset + 2) === 0xC1 && pe.fetchUByte(offset + 4) === 0x02)
    {
        return true;
    }

    if (opcode === 0x68 && pe.fetchDWord(offset + 1) === 0x524C)
    {
        return true;
    }

    if (opcode === 0x50 && modrm === 0x6A && (pe.fetchByte(offset + 2) === 0x02 || pe.fetchByte(offset + 2) === 0x05))
    {
        return true;
    }

    if (opcode === 0xE8 && (assigner === -1 || details.tgtImm !== (assigner - (offset + 5))))
    {
        return true;
    }

    if (opcode === 0x8B && modrm === 0x47 && details.tgtImm === 0x4)
    {
        return true;
    }

    if (opcode === 0xFF && modrm === 0x15)
    {
        return true;
    }

    if (opcode === 0x83 && (modrm & 0xF8) === 0xC8 && pe.fetchUByte(offset + 2) === 0xFF)
    {
        return true;
    }

    if (opcode === 0x8B && modrm === 0xFF)
    {
        return true;
    }

    return false;
}

MaxJob = 4400;

function WriteLoader(hookLoc, curReg, suffix, reqAddr, mapAddr, jmpLoc, extraData)
{
    var prefixes = [];
    var templates = [];
    var fnNames = ["Req" + suffix, "Map" + suffix];
    var fnAddrs = [reqAddr, mapAddr];
    var argFormats = ["d>s", "d>d"];

    prefixes[0] =
        " 33 FF" +
        " BB 2C 00 00 00";

    if (suffix.indexOf("Name") === -1)
    {
        prefixes[1] =
            " 90" +
            " BF 33 00 00 00" +
            " BB" + (MaxJob - 3950).packToHex(4);
    }
    else
    {
        prefixes[1] =
            " 90" +
            " BF A1 0F 00 00" +
            " BB" + MaxJob.packToHex(4);
    }

    templates[0] =
        " PrepVars" +
        " GenCaller" +
        " 85 C0" +
        " 74 12" +
        " 8A 08" +
        " 84 C9" +
        " 74 07" +
        " 8B 4C 24 20" +
        " 89 04 B9" +
        " 47" +
        " 39 DF" +
        " 7E ToGenCaller";

    templates[1] =
        " PrepVars" +
        " GenCaller" +
        " 85 C0" +
        " 78 0A" +
        " 8B 4C 24 20" +
        " 8B 04 81" +
        " 89 04 B9" +
        " 47" +
        " 39 DF" +
        " 7E ToGenCaller";

    var code;
    if (curReg > 7)
    {
        code = " FF 35" + curReg.packToHex(4);
    }
    else
    {
        code = (0x50 + curReg).packToHex(1);
    }

    code += " 60";

    for (var i = 0; i < templates.length; i++)
    {
        for (var j = 0; j < prefixes.length; j++)
        {
            var coff = code.hexlength() + prefixes[j].hexlength();

            code += templates[i].replace(" PrepVars", prefixes[j]);
            var result = GenLuaCaller(hookLoc + coff, fnNames[i], fnAddrs[i], argFormats[i], " 57");
            if (result.indexOf("LUA:") !== -1)
            {
                return result;
            }

            code = code.replace(" GenCaller", result);

            code = code.replace(" ToGenCaller", "");
            code += (coff - (code.hexlength() + 1)).packToHex(1);
        }
    }

    code +=
        " 61" +
      " 83 C4 04" +
      extraData;
    if (jmpLoc === -1)
    {
        code += " C3";
    }
    else
    {
        code += " E9" + (jmpLoc - (hookLoc + code.hexlength() + 5)).packToHex(4);
    }

    pe.replaceHex(hookLoc, code);

    return code;
}

function EnableCustomJobs()
{
    var refPath = pe.stringVa("\xB1\xC3\xBC\xF6");
    if (refPath === -1)
    {
        return "Failed in Step 1 - Path prefix missing";
    }

    var refHand = pe.stringVa("\xB1\xC3\xBC\xF6\\\xB1\xC3\xBC\xF6");
    if (refHand === -1)
    {
        return "Failed in Step 1 - Hand prefix missing";
    }

    var refName = pe.stringVa("Acolyte");
    if (refName === -1)
    {
        return "Failed in Step 1 - Name prefix missing";
    }

    var hooks = pe.findCodes("C7 ?? 0C" + refPath.packToHex(4));
    var assigner;
    var offset;

    if (hooks.length === 2)
    {
        offset = pe.findCode(" C7 00" + refPath.packToHex(4) + " E8");
        if (offset === -1)
        {
            return "Failed in Step 1 - Palette reference is missing";
        }

        assigner = (offset + 11) + pe.fetchDWord(offset + 7);

        hooks[2] = offset - 4;

        offset = pe.find(" 6A 03", hooks[2] - 0x12, hooks[2]);
        pe.replaceByte(offset + 1, 0);
    }
    if (hooks.length !== 3)
    {
        return "Failed in Step 1 - Prefix reference missing or extra";
    }

    offset = pe.findCode("C7 ?? 0C" + refHand.packToHex(4));
    if (offset === -1)
    {
        return "Failed in Step 1 - Hand reference missing";
    }

    hooks[3] = offset;

    offset = pe.findCode("C7 ?? 10" + refName.packToHex(4));
    if (offset === -1)
    {
        return "Failed in Step 1 - Name reference missing";
    }

    hooks[4] = offset;

    var LANGTYPE = GetLangType();
    if (LANGTYPE.length === 1)
    {
        return "Failed in Step 2 - " + LANGTYPE[0];
    }

    var details = [];
    var curRegs = [];

    for (var i = 0; i < hooks.length; i++)
    {
        var modrm;
        var refOff;

        if (pe.fetchByte(hooks[i] - 2) === 0)
        {
            modrm  = pe.fetchByte(hooks[i] - 5);
            refOff = pe.fetchDWord(hooks[i] - 4);
        }
        else if (pe.fetchByte(hooks[i]) === 0x6A)
        {
            modrm  = 0x6;
            refOff = 0;
        }
        else
        {
            modrm  = pe.fetchByte(hooks[i] - 1);
            refOff = 0;
        }
        var refReg = modrm & 0x7;
        curRegs[i] = (modrm & 0x38) >> 3;

        details[i] = FetchTillEnd(hooks[i], refReg, refOff, curRegs[i], LANGTYPE, CheckEoT, assigner);
    }

    var Funcs = [];

    Funcs[0]  = OverwriteString("Professor",     "ReqPCPath");
    Funcs[1]  = OverwriteString("Blacksmith",    "MapPCPath\x00");
    Funcs[2]  = OverwriteString("Swordman",      "ReqPCImf");
    Funcs[3]  = OverwriteString("Assassin",      "MapPCImf");
    Funcs[4]  = OverwriteString("Magician",      "ReqPCPal");
    Funcs[5]  = OverwriteString("Crusader",      "MapPCPal");
    Funcs[6]  = OverwriteString("Swordman High", "ReqPCHandPath");
    Funcs[7]  = OverwriteString("Magician High", "MapPCHandPath");
    Funcs[8]  = OverwriteString("White Smith_W", "ReqPCJobName_M");
    Funcs[9]  = OverwriteString("High Wizard_W", "MapPCJobName_M");
    Funcs[10] = OverwriteString("High Priest_W", "ReqPCJobName_F");
    Funcs[11] = OverwriteString("Lord Knight_W", "MapPCJobName_F");
    Funcs[12] = OverwriteString("Alchemist",     "GetHalter");
    Funcs[13] = OverwriteString("Acolyte",       "IsDwarf");

    WriteLoader(hooks[0], curRegs[0], "PCPath", Funcs[0], Funcs[1], details[0].endOff, details[0].code);
    WriteLoader(hooks[1], curRegs[1], "PCImf", Funcs[2], Funcs[3], details[1].endOff, details[1].code);
    WriteLoader(hooks[2], curRegs[2], "PCPal", Funcs[4], Funcs[5], details[2].endOff, details[2].code);
    WriteLoader(hooks[3], curRegs[3], "PCHandPath", Funcs[6], Funcs[7], details[3].endOff, details[3].code);

    var code =
        details[4].code +
      " E9";

    code += (details[4].endOff - (hooks[4] + code.hexlength() + 4)).packToHex(4);

    pe.replaceHex(hooks[4], code);

    hooks[4] += code.hexlength();

    offset = pe.stringVa("TaeKwon Girl");
    if (offset === -1)
    {
        return "Failed in Step 5 - 'TaeKwon Girl' missing";
    }

    code =
        " 85 C0" +
        " 75 ??" +
        " A1 ?? ?? ?? 00" +
        " C7 ?? 38 3F 00 00" + offset.packToHex(4);
    var gJobName = 5;
    var offset2 = pe.findCode(code);

    if (offset2 === -1)
    {
        code = code.replace(" A1", " 8B ??");
        gJobName = 6;
        offset2 = pe.findCode(code);
    }

    if (offset2 === -1)
    {
        code =
            " 85 C0" +
            " A1 ?? ?? ?? 00" +
            " ??" + offset.packToHex(4);
        gJobName = 3;
        offset2 = pe.findCode(code);
    }

    if (offset2 === -1)
    {
        code =
            " 85 C0" +
            " 75 ??" +
            " A1 ?? ?? ?? 00" +
            " C7 ?? 38 3F 00 00" + offset.packToHex(4);
        gJobName = 5;
        offset2 = pe.findCode(code);
    }

    if (offset2 === -1)
    {
        code =
            " 85 ??" +
            " B9 " + offset.packToHex(4) +
            " 0F ?? ??" +
            " A1 ?? ?? ?? 01" +
            " ??" +
            " 89 ?? 38 3F 00 00";
        gJobName = 13;
        offset2 = pe.findCode(code);
    }

    if (offset2 === -1)
    {
        code =
            " 85 ??" +
            " B9 " + offset.packToHex(4) +
            " 0F ?? ??" +
            " A1 ?? ?? ?? 00" +
            " ??" +
            " 89 ?? 38 3F 00 00";
        gJobName = 13;
        offset2 = pe.findCode(code);
    }

    if (offset2 === -1)
    {
        return "Failed in Step 5 - 'TaeKwon Girl' reference missing";
    }

    gJobName = pe.fetchDWord(offset2 + gJobName);

    code =
        " 83 3D" + LANGTYPE + " 00" +
        getEcxSessionHex() +
        " 75";
    offset = pe.find(code, offset2 - 0x80, offset2);

    if (offset === -1)
    {
        code =
            " A1" + LANGTYPE +
            " B9 ?? ?? ?? 00" +
            " 85 C0" +
            " 75";
        offset = pe.find(code, offset2 - 0x80, offset2);
    }

    if (offset === -1)
    {
        code =
            " A1" + LANGTYPE +
            " 85 C0" +
            " 75";
        offset = pe.find(code, offset2 - 0x90, offset2);
    }

    if (offset === -1)
    {
        return "Failed in Step 5 - LangType comparison missing";
    }

    pe.replaceByte(offset + code.hexlength() - 1, 0xEB);

    offset = offset2;

    code =
        " 83 F8 0C" +
        " 74 0E" +
        " 83 F8 05" +
        " 74 09" +
        " 83 F8 06" +
        " 0F 85";

    offset2 = pe.find(code, offset + 0x10, offset + 0x100);
    if (offset2 === -1)
    {
        code =
            " 83 F8 0C" +
            " 74 29" +
            " 83 F8 05" +
            " 74 24" +
            " 83 F8 06" +
            " 74 1F";

        offset2 = pe.find(code, offset - 0x20, offset + 0x100);
    }
    if (offset2 === -1)
    {
        return "Failed in Step 5 - 2nd LangType comparison missing";
    }

    var push1 = pe.fetchUByte(offset2 - 1);
    if (push1 < 0x50 || push1 > 0x57)
    {
        push1 = 0x90;
    }

    var push2 = pe.fetchUByte(offset2 - 2);
    if (push2 < 0x50 || push2 > 0x57)
    {
        push2 = 0x90;
    }

    if (push2 === 0x90 && push1 === 0x90)
    {
        push1 = 0x56;
    }

    offset2 += code.hexlength();
    offset2 += 4 + pe.fetchDWord(offset2);

    if (pe.rawToVa(offset2) == -1)
    {
        return "Failed in Step 5g - wrong offset.";
    }

    pe.replaceHex(offset2, push2.packToHex(1) + push1.packToHex(1) + " 90 90 E9");

    offset2 -= 5;

    code =
        " 85 C0" +
        " 0F 85" + GenVarHex(1);

    var csize = code.hexlength();

    csize += WriteLoader(offset + csize, gJobName, "PCJobName_F", Funcs[10], Funcs[11], offset2, "").hexlength();

    WriteLoader(offset + csize, gJobName, "PCJobName_M", Funcs[8], Funcs[9], offset2, "");

    code = ReplaceVarHex(code, 1, csize - code.hexlength());

    pe.replaceHex(offset, code);

    var retVal = InjectLuaFiles(
        "Lua Files\\DataInfo\\NPCIdentity",
        [
            "Lua Files\\Admin\\PCIds",
            "Lua Files\\Admin\\PCPaths",
            "Lua Files\\Admin\\PCImfs",
            "Lua Files\\Admin\\PCHands",
            "Lua Files\\Admin\\PCPals",
            "Lua Files\\Admin\\PCNames",
            "Lua Files\\Admin\\PCFuncs",
        ],
        hooks[4]
    );
    if (typeof retVal === "string")
    {
        return retVal;
    }

    var fpEnb = HasFramePointer();

    code =
        " 83 F8 19" +
        " 75 ??" +
        " B8 12 10 00 00";
    offset = pe.findCode(code);

    var result;

    if (offset !== -1)
    {
        result = GenLuaCaller(offset + 1, "GetHalter", Funcs[12], "d>d", " 50");
        if (result.indexOf("LUA:") !== -1)
        {
            return result;
        }

        code =
            " 52" +
            result +
            " 5A";

        if (fpEnb)
        {
            code += " 5D";
        }

        code += " C2 04 00";

        pe.replaceHex(offset, code);
    }

    if (fpEnb)
    {
        code = " 8B ?? 08";
        csize = 3;
    }
    else
    {
        code = " 8B ?? 24 04";
        csize = 4;
    }

    code +=
        " 3D B7 0F 00 00" +
        " 7C ??" +
        " 3D BD 0F 00 00";
    offset2 = " 50";
    offset = pe.findCode(code);

    if (offset === -1)
    {
        code = code.replace(/ 3D/g, " 81 ??");
        offset2 = "";
        offset = pe.findCode(code);
    }

    if (offset !== -1)
    {
        offset += csize;

        if (offset2 === "")
        {
            offset2 = (0x50 + (pe.fetchByte(offset + 1) & 0x7)).packToHex(1);
        }

        result = GenLuaCaller(offset + 1, "IsDwarf", Funcs[13], "d>d", offset2);
        if (result.indexOf("LUA:") !== -1)
        {
            return result;
        }

        code =
            " 52" +
            result +
            " 5A";

        if (fpEnb)
        {
            code += " 5D";
        }

        code += " C2 04 00";

        pe.replaceHex(offset, code);
    }

    return true;
}
