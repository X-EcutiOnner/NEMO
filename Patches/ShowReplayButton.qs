

function _SRB_FixupButton(btnImg, suffix, suffix2)
{
    var offset = pe.halfStringVa(btnImg);
    if (offset === -1)
    {
        return "0 - Button String missing";
    }

    var code = offset.packToHex(4);
    offset = pe.findCode(code + " C7");

    if (offset === -1)
    {
        offset = pe.findCode(code + " 89");
    }

    if (offset === -1)
    {
        offset = pe.findCode(code + "?? ?? ?? ?? C7");
    }

    if (offset === -1)
    {
        return "1 - OnCreate function missing";
    }

    offset += 5;

    var offset2 = pe.find(" EA 00 00 00", offset, offset + 0x50);
    if (offset2 === -1)
    {
        return "2 - 2nd Button asssignment missing";
    }

    var type = 1;
    code =
        " 89 ?? 24 ??" +
        " 89 ?? 24 ??";

    var jmpAddr = pe.find(code + suffix, offset2, offset2 + 0x50);

    if (jmpAddr === -1)
    {
        type = 2;
        code =
            " 89 ?? ??" +
            " 89 ?? ??";

        jmpAddr = pe.find(code + suffix, offset2, offset2 + 0x50);
    }

    if (jmpAddr === -1)
    {
        type = 3;
        code =
          " C7 45 ?? 9C FF FF FF" +
          " C7 45 ?? 9C FF FF FF";

        jmpAddr = pe.find(code + suffix2, offset2, offset2 + 0x50);
    }

    if (jmpAddr === -1)
    {
        type = 4;
        jmpAddr = pe.find(code + suffix, offset2, offset2 + 0x50);
    }

    if (jmpAddr === -1)
    {
        return "3 - Coordinate assignment missing";
    }

    var retAddr = jmpAddr + code.hexlength();

    switch (type)
    {
        case 1:
        {
            offset2 = pe.fetchByte(jmpAddr + 3);
            code =
                " C7 44 24" + offset2.packToHex(1) + " 04 00 00 00" +
                " 89 44 24" + (offset2 + 4).packToHex(1) +
                " E9" + GenVarHex(1);
            break;
        }
        case 2:
        {
            offset2 = pe.fetchByte(jmpAddr + 2);
            code =
                " 50" +
                " 8B 45" + (offset2 - 20).packToHex(1) +
                " C7 45" + offset2.packToHex(1) + " 04 00 00 00" +
                " 89 45" + (offset2 + 4).packToHex(1) +
                " 58" +
                " E9" + GenVarHex(1);
            break;
        }
        case 3:
        {
            code =
                " 04 00 00 00" +
                " 89 45" + pe.fetchHex(retAddr - 5, 1) +
                " 90 90 90 90";
            break;
        }
        case 4:
        {
            offset = pe.find(" 8D 45 ??", jmpAddr - 0xFF, jmpAddr);
            if (offset === -1)
            {
                return "4";
            }
            var varCode = pe.fetchHex(offset, 3);
            code =
                " 04 00 00 00" +
                " 89 45" + pe.fetchHex(retAddr - 5, 1) +
                varCode +
                " 90";
            pe.replaceHex(offset, " 90 90 90");
            break;
        }
        default:
            break;
    }

    var size = code.hexlength();
    if (type === 3 || type === 4)
    {
        pe.replaceHex(retAddr - size, code);
    }
    else
    {
        var free = alloc.find(size);
        if (free === -1)
        {
            return "5 - Not enough free space";
        }

        code = ReplaceVarHex(code, 1, pe.rawToVa(retAddr) - pe.rawToVa(free + size));

        pe.insertHexAt(free, size, code);

        pe.replaceHex(jmpAddr, "E9" + (pe.rawToVa(free) - pe.rawToVa(jmpAddr + 5)).packToHex(4));
    }

    return jmpAddr;
}

function ShowReplayButton()
{
    var result = _SRB_FixupButton("replay_interface\\btn_selectserver_b", " C7", " 89");
    if (typeof result === "string")
    {
        return "Failed in Step 1." + result;
    }

    result = _SRB_FixupButton("replay_interface\\btn_replay_b", " E8", " E8");
    if (typeof result === "string")
    {
        return "Failed in Step 2." + result;
    }

    var code =
        " 83 78 04 1E" +
        " 75";
    var offset = pe.find(code, result, result + 0x40);
    var free;
    if (offset === -1)
    {
        code =
            " E8 ?? ?? ?? ??" +
            " 8D 45 ??";
        offset = pe.find(code, result, result + 0x20);
        if (offset === -1)
        {
            return "Failed in Step 2.6 - Mode comparison missing";
        }

        var jumpfunc = pe.rawToVa(offset + 5) + pe.fetchDWord(offset + 1);
        var varCode = pe.fetchHex(result, 14);
        var retAddr = offset + 5;

        var ins =
            " E8" + GenVarHex(3) +
            " 83 78 04 06" +
            " 75 0E" +
            varCode +
            " 68" + pe.rawToVa(retAddr).packToHex(4) +
            " C3";

        var size = ins.hexlength();
        free = alloc.find(size + 4);
        if (free === -1)
        {
            return "Failed in Step 2.7 - No enough free space";
        }

        ins = ReplaceVarHex(ins, 3, jumpfunc - pe.rawToVa(free + 5));

        code = " E9" + (pe.rawToVa(free) - pe.rawToVa(offset + 5)).packToHex(4);

        pe.insertHexAt(free, size + 4, ins);
        pe.replaceHex(offset, code);
    }
    else
    {
        pe.replaceByte(offset + 3, 6);
    }

    code =
        " 6A 00" +
        " 68 29 27 00 00";

    offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 3 - Select Server case missing";
    }

    offset += code.hexlength();

    code =
        " C6 40 ?? 01" +
        " C7 ?? 0C 1B 00 00 00";
    var assignedLen = 4;

    var offset2 = pe.findCode(code);
    if (offset2 === -1)
    {
        code =
            " C6 80 ?? ?? 00 00 01" +
            " C7 ?? 0C 1B 00 00 00";
        assignedLen = 7;
        offset2 = pe.findCode(code);
    }
    if (offset2 === -1)
    {
        code =
            " C6 40 ?? 01" +
            " 33 C0" +
            " C7 ?? 0C 1B 00 00 00";
        assignedLen = 4;
        offset2 = pe.findCode(code);
    }
    if (offset2 === -1)
    {
        code =
            " C6 80 ?? ?? 00 00 01" +
            " 33 C0" +
            " C7 ?? 0C 1B 00 00 00";
        assignedLen = 7;
        offset2 = pe.findCode(code);
    }
    if (offset2 === -1)
    {
        return "Failed in Step 3 - Replay mode setter missing";
    }

    var func = pe.rawToVa(offset2) + pe.fetchDWord(offset2 - 4);

    var assigner = pe.fetchHex(offset2, assignedLen).replace(" 01", " 00");

    code =
        " 60" +
        " E8" + GenVarHex(1) +
        assigner +
        " 61" +
        " 68 22 27 00 00" +
        " E9" + GenVarHex(2);

    free = alloc.find(code.hexlength());
    if (free === -1)
    {
        return "Failed in Step 4 - Not enough free space";
    }

    var freeRva = pe.rawToVa(free);

    code = ReplaceVarHex(code, 1, func - (freeRva + 6));
    code = ReplaceVarHex(code, 2, pe.rawToVa(offset) - (freeRva + code.hexlength()));

    pe.insertHexAt(free, code.hexlength(), code);

    pe.replaceHex(offset - 5, "E9" + (freeRva - pe.rawToVa(offset)).packToHex(4));

    return true;
}

function ShowReplayButton_()
{
    return pe.halfStringRaw("replay_interface\\btn_replay_b") !== -1;
}
