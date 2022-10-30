

function FixCameraAngles(newvalue)
{
    var code =
        " 6A 01" +
      " 6A 5D" +
      " EB";
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            " C7 45 ?? 00 00 A0 41" +
            " 8B";

        var offsets = pe.findCodes(code);
        if (offsets.length === 0 || offsets.length > 2)
        {
            return "Failed in Step 4 - No or Too Many matches";
        }

        for (var i = 0; i < offsets.length; i++)
        {
            pe.replaceHex(offsets[i] + 3, newvalue);
        }

        code =
            " 00 00 C8 C1" +
          " 00 00 82 C2";

        offset = pe.find(code, pe.sectionRaw(CODE)[1]);
        if (offset === -1)
        {
            return "Failed in Step 5";
        }

        code =
            " 00 00 80 BF" +
          " 00 00 B2 C2";

        pe.replaceHex(offset, code);
    }
    else
    {
        code =
                "8B CE " +
                "E8 ?? ?? ?? ?? " +
                "?? " +
                "8B CE " +
                "E8 ";
        var ProcessRBtnOffset = 3;

        offset = pe.find(code, offset - 0x80, offset);
        if (offset === -1)
        {
            return "Failed in Step 1 - Function Call Missing";
        }

        offset = pe.vaToRaw(pe.fetchRelativeValue(offset, [ProcessRBtnOffset, 4]));

        code =
            " 74 ??" +
            " D9 05 ?? ?? ?? 00";
        var angleOffset = 4;
        var offset2 = pe.find(code, offset, offset + 0x800);

        if (offset2 === -1)
        {
            code =
                " 74 ??" +
                " F3 0F 10 ?? ?? ?? ?? 00";
            angleOffset = 6;
            offset2 = pe.find(code, offset, offset + 0x800);
        }

        if (offset2 === -1)
        {
            return "Failed in Step 2 - Angle Address missing";
        }

        offset2 += angleOffset;

        var free = pe.insertHex(newvalue);

        pe.replaceDWord(offset2, pe.rawToVa(free));
    }

    return true;
}

function FixCameraAnglesRecomm()
{
    return FixCameraAngles(floatToHex(42.0));
}

function FixCameraAnglesLess()
{
    return FixCameraAngles(floatToHex(29.50));
}

function FixCameraAnglesFull()
{
    return FixCameraAngles(floatToHex(65.0));
}

function FixCameraAnglesCustom()
{
    var angle = exe.getUserInput("$cameraAngle", XTYPE_DWORD, _("Number Input"), _("Enter max camera angle value (43 - recommended, 29.5 - less, 65 - full):"), 43);
    return FixCameraAngles(floatToHex(angle));
}
