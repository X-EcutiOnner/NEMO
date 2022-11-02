

function IncreaseZoomOut(newvalue)
{
    var code =
        " 00 00 66 43" +
        " 00 00 C8 43" +
        " 00 00 96 43";

    var offset = pe.find(code);
    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    pe.replaceHex(offset + 4, newvalue);

    if (pe.stringRaw("/zoom") !== -1)
    {
        var zoom2 = pe.rawToVa(offset + 4).packToHex(4);

        var code1 = " C7 05 " + zoom2 + " 00 00 F0 43";
        var offsets = pe.findCodes(code1);
        if (offsets.length === 0)
        {
            return "Failed in Step 3. Enabled /zoom usage not found";
        }
        if (offsets.length !== 2 && offsets.length !== 3)
        {
            return "Failed in Step 3. Found wrong number of enabled /zoom usage count.";
        }
        for (var i = 0; i < offsets.length; i++)
        {
            pe.replaceHex(offsets[i] + 6, newvalue);
        }

        var code2 = " C7 05 " + zoom2 + " 00 00 C8 43";
        offsets = pe.findCodes(code2);
        if (offsets.length === 0)
        {
            return "Failed in Step 3. Disabled /zoom usage not found";
        }
        if (offsets.length !== 2 && offsets.length !== 3)
        {
            return "Failed in Step 3. Found wrong number of disabled /zoom usage count.";
        }
        for (i = 0; i < offsets.length; i++)
        {
            pe.replaceHex(offsets[i] + 6, newvalue);
        }

        code =
            "F3 0F 10 0D ?? ?? ?? ??" +
            "EB 08" +
            "F3 0F 10 0D ?? ?? ?? ??" +
            "F3 0F 10 05 ?? ?? ?? ??" +
            "F3 0F 10 15 ?? ?? ?? ??" +
            "0F 2F C2" +
            "F3 0F 11 0D " + zoom2;
        var enabledOffset = [4, 4];
        var disabledOffset = [14, 4];
        offset = pe.findCode(code);
        if (offset === -1)
        {
            code =
            "F3 0F 10 0D ?? ?? ?? ??" +
            code1 +
            "EB 12" +
            "F3 0F 10 0D ?? ?? ?? ??" +
            code2 +
            "F3 0F 10 05 ?? ?? ?? ??" +
            "F3 0F 10 15 ?? ?? ?? ??" +
            "0F 2F C2";
            enabledOffset = [4, 4];
            disabledOffset = [24, 4];
            offset = pe.findCode(code);
        }
        if (offset === -1)
        {
            return "Failed in Step 4";
        }

        var valueAddr = pe.rawToVa(pe.insertHex(newvalue));
        pe.setValue(offset, enabledOffset, valueAddr);
        pe.setValue(offset, disabledOffset, valueAddr);
    }

    return true;
}

function IncreaseZoomOut25Per()
{
    return IncreaseZoomOut("00 00 80 43");
}

function IncreaseZoomOut50Per()
{
    return IncreaseZoomOut("00 00 FF 43");
}

function IncreaseZoomOut75Per()
{
    return IncreaseZoomOut("00 00 4C 44");
}

function IncreaseZoomOutMax()
{
    return IncreaseZoomOut("00 00 99 44");
}

function IncreaseZoomOutCustom()
{
    var zoomOut = exe.getUserInput("$zoomOut", XTYPE_DWORD, _("Number Input"), _("Enter zoom out level value (256 - 25%, 510 - 50%, 816 - 75%):"), 1224);
    return IncreaseZoomOut(floatToHex(zoomOut));
}
