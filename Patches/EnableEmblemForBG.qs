

function EnableEmblemForBG_Normal(offset)
{
    var code =
        getEcxSessionHex() +
        "E8 ?? ?? ?? 00 " +
        "85 C0 " +
        "74 ?? " +
        getEcxSessionHex() +
        "E8 ?? ?? ?? 00 " +
        "85 C0 " +
        "75 ?? ";
    var jmp1 = 12;
    var jmp1Offset = 28;
    var jmp2 = 26;

    var found = pe.match(code, offset);
    if (found !== true)
    {
        throw "Pattern not found";
    }

    pe.setShortJmpRaw(offset + jmp1, offset + jmp1Offset, "jnz");

    pe.replaceByte(offset + jmp2, 0x74);
}

function EnableEmblemForBG_Small(offset)
{
    var code =
        getEcxSessionHex() +
        "E8 ?? ?? ?? 00 " +
        "85 C0 " +
        "74 ?? ";
    var patchOffset = 5;
    var IsSiegeModeOffset = 6;
    var continueOffset = 13;
    var drawOffset = 14;

    var found = pe.match(code, offset);
    if (found !== true)
    {
        throw "Pattern not found";
    }

    var vars = {
        "continueAddr": pe.fetchRelativeValue(offset, [continueOffset, 1]),
        "drawAddr": pe.rawToVa(offset + drawOffset),
        "CSession_IsSiegeMode": pe.fetchRelativeValue(offset, [IsSiegeModeOffset, 4]),
    };
    var data = pe.insertAsmFile("", vars);

    pe.setJmpRaw(offset + patchOffset, data.free);
}

function EnableEmblemForBG()
{
    var check1 = table.getRaw(table.bgCheck1);
    var flag = table.get(table.bgCheck2);
    var check2 = table.getRaw(table.bgCheck2);

    if (flag === 1)
    {
        EnableEmblemForBG_Small(check1);
    }
    else if (flag === 0)
    {
        EnableEmblemForBG_Normal(check1);
    }

    if (flag > 1)
    {
        EnableEmblemForBG_Normal(check1);
        EnableEmblemForBG_Normal(check2);
    }

    return true;
}

function EnableEmblemForBG_()
{
    return true;
}
