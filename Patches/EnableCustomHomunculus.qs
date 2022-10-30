

function CheckHomunEoT(opcode, modrm, offset)
{
    if (opcode === 0x2B && pe.fetchUByte(offset + 2) === 0xC1 && pe.fetchUByte(offset + 4) === 0x02)
    {
        return true;
    }

    if (opcode === 0x85 && pe.fetchUByte(offset + 2) === 0x74)
    {
        return true;
    }

    return false;
}

MaxHomun = 7000;

function EnableCustomHomunculus()
{
    var offset = pe.stringVa("LIF");
    if (offset === -1)
    {
        return "Failed in Step 1 - LIF not found";
    }

    var code = " C7 ?? C4 5D 00 00" + offset.packToHex(4);

    var hookLoc = pe.findCode(code);
    if (hookLoc === -1)
    {
        return "Failed in Step 1 - homun code not found";
    }

    var LANGTYPE = GetLangType();
    if (LANGTYPE.length === 1)
    {
        return "Failed in Step 1 - " + LANGTYPE[0];
    }

    var modrm;
    var refOff;
    if (pe.fetchByte(hookLoc - 2) === 0)
    {
        modrm = pe.fetchByte(hookLoc - 5);
        refOff = pe.fetchDWord(hookLoc - 4);
    }
    else
    {
        modrm = pe.fetchByte(hookLoc - 1);
        refOff = 0;
    }
    var refReg = modrm & 0x7;
    var curReg = (modrm & 0x38) >> 3;

    var details = FetchTillEnd(hookLoc + code.hexlength(), refReg, refOff, curReg, LANGTYPE, CheckHomunEoT);

    offset = pe.stringVa("ReqJobName");
    if (offset === -1)
    {
        return "Failed in Step 2 - ReqJobName not found";
    }

    code =
        (0x50 + curReg).packToHex(1) +
        " 60" +
        " BF 71 17 00 00" +
        " BB" + MaxHomun.packToHex(4);
    var csize = code.hexlength();

    var result = GenLuaCaller(hookLoc + csize, "RegJobName", offset, "d>s", " 57");
    if (result.indexOf("LUA:") !== -1)
    {
        return result;
    }

    code += result;

    code +=
        " 8A 08" +
        " 84 C9" +
        " 74 07" +
        " 8B 4C 24 20" +
        " 89 04 B9" +
        " 47" +
        " 39 DF" +
        " 7E";

    code += (csize - (code.hexlength() + 1)).packToHex(1);

    code +=
        " 61" +
        " 83 C4 04" +
        details.code;
    var codeSize = code.hexlength();
    code += " E9" + (details.endOff - (hookLoc + codeSize + 5)).packToHex(4);

    pe.replaceHex(hookLoc, code);

    code =
        " 05 8F E8 FF FF" +
        " B9 33 00 00 00";

    offset = pe.findCode(code);
    if (offset !== -1)
    {
        pe.replaceHex(offset + 6, (MaxHomun - 6001).packToHex(4));
        return true;
    }

    code =
        " 3D 70 17 00 00" +
        " 7E 10" +
        " 3D A5 17 00 00";

    offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 4";
    }

    pe.replaceHex(offset + code.hexlength() - 4, MaxHomun.packToHex(4));

    return true;
}
