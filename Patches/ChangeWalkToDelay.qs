

function ChangeWalkToDelay_Match()
{
    var timeGetTimeHex = imports.ptrHexValidated("timeGetTime", "winmm.dll");

    var code = [
        [
            "FF 15 " + timeGetTimeHex +
            "8B 8B ?? ?? ?? 00 " +
            "81 C1 58 02 00 00 " +
            "3B C1 " +
            "8B 83 ?? ?? ?? 00 " +
            "0F 97 C1 " +
            "8B 40 ?? " +
            "83 8B ?? ?? ?? 00 00 ",
            {
                "delayOffset": [14, 4],
                "delayCmdOffset": [12, 6],
            },
        ],
        [
            "8B 2D " + timeGetTimeHex +
            "FF D5 " +
            "8B 8E ?? ?? ?? 00 " +
            "8B 96 ?? ?? ?? 00 " +
            "81 C1 58 02 00 00 " +
            "3B C1 " +
            "8B 42 ?? " +
            "0F 97 C1 " +
            "83 B8 ?? ?? ?? 00 00 ",
            {
                "delayOffset": [22, 4],
                "delayCmdOffset": [20, 6],
            },
        ],
        [
            "FF 15 " + timeGetTimeHex +
            "8B 93 ?? ?? ?? 00 " +
            "81 C2 58 02 00 00 " +
            "3B C2 " +
            "8B 83 ?? ?? ?? 00 " +
            "0F 97 C1 " +
            "8B 50 ?? " +
            "8B 82 ?? ?? ?? 00 " +
            "85 C0 ",
            {
                "delayOffset": [14, 4],
                "delayCmdOffset": [12, 6],
            },
        ],
        [
            "8B 2D " + timeGetTimeHex +
            "FF D5 " +
            "8B 8E ?? ?? ?? 00 " +
            "8B 96 ?? ?? ?? 00 " +
            "81 C1 58 02 00 00 " +
            "3B C1 " +
            "8B 42 ?? " +
            "0F 97 C1 " +
            "39 B8 ?? ?? ?? 00 ",
            {
                "delayOffset": [22, 4],
                "delayCmdOffset": [20, 6],
            },
        ],
        [
            "FF 15 " + timeGetTimeHex +
            "8B 8E ?? ?? ?? 00 " +
            "8B 96 ?? ?? ?? 00 " +
            "81 C1 58 02 00 00 " +
            "3B C1 " +
            "8B 42 ?? " +
            "0F 97 C1 " +
            "83 B8 ?? ?? ?? 00 00 ",
            {
                "delayOffset": [20, 4],
                "delayCmdOffset": [18, 6],
            },
        ],
        [
            "FF 15 " + timeGetTimeHex +
            "8B 8E ?? ?? ?? 00 " +
            "81 C1 58 02 00 00 " +
            "3B C1 " +
            "8B 86 ?? ?? ?? 00 " +
            "0F 97 C1 " +
            "8B 40 ?? " +
            "83 B8 ?? ?? ?? 00 00 ",
            {
                "delayOffset": [14, 4],
                "delayCmdOffset": [12, 6],
            },
        ],
        [
            "FF 15 " + timeGetTimeHex +
            "8B 8B ?? ?? ?? 00 " +
            "81 C1 58 02 00 00 " +
            "3B C1 " +
            "8B 83 ?? ?? ?? 00 " +
            "0F 97 C1 " +
            "8B 40 ?? " +
            "83 B8 ?? ?? ?? 00 00 ",
            {
                "delayOffset": [14, 4],
                "delayCmdOffset": [12, 6],
            },
        ],
        [
            "FF 15 " + timeGetTimeHex +
            "8B 8B ?? ?? ?? 00 " +
            "8B 15 ?? ?? ?? ?? " +
            "81 C1 58 02 00 00 " +
            "3B C1 " +
            "8B 83 ?? ?? ?? 00 " +
            "8B 0D ?? ?? ?? ?? " +
            "8B 40 ?? " +
            "0F 97 45 ?? " +
            "83 B8 ?? ?? ?? 00 00 ",
            {
                "delayOffset": [20, 4],
                "delayCmdOffset": [18, 6],
            },
        ],
        [
            "FF 15 " + timeGetTimeHex +
            "8B 8E ?? ?? ?? 00 " +
            "8B 15 ?? ?? ?? ?? " +
            "81 C1 58 02 00 00 " +
            "3B C1 " +
            "8B 86 ?? ?? ?? 00 " +
            "8B 0D ?? ?? ?? ?? " +
            "8B 40 ?? " +
            "0F 97 45 ?? " +
            "83 B8 ?? ?? ?? 00 00 ",
            {
                "delayOffset": [20, 4],
                "delayCmdOffset": [18, 6],
            },
        ],
        [
            "FF 15 " + timeGetTimeHex +
            "8B 8F ?? ?? ?? 00 " +
            "81 C1 58 02 00 00 " +
            "3B C1 " +
            "8B 87 ?? ?? ?? 00 " +
            "0F 97 C1 " +
            "8B 40 ?? " +
            "83 B8 ?? ?? ?? 00 00 ",
            {
                "delayOffset": [14, 4],
                "delayCmdOffset": [12, 6],
            },
        ],
    ];
    var offsetObj = pe.findAnyCode(code);

    if (offsetObj === -1)
    {
        throw "Failed in Step 1a - Pattern not found";
    }

    var offset = offsetObj.offset;

    var obj = hooks.createHookObj();

    obj.stolenCode = "";
    obj.stolenCode1 = "";
    obj.retCode = "";
    obj.endHook = false;

    obj.offset = offset;
    obj.delayOffset = offsetObj.delayOffset;
    obj.delayCmdOffset = offsetObj.delayCmdOffset;
    return obj;
}

function ChangeWalkToDelay_Match2()
{
    var code =
        "81 C1 5E 01 00 00 " +
        "3B C1 ";
    var delayOffset = [2, 4];
    var delayCmdOffset = [0, 6];
    var reg = "ecx";
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        throw "Failed in second delay search: Pattern not found";
    }

    var obj = hooks.createHookObj();

    obj.stolenCode = "";
    obj.stolenCode1 = "";
    obj.retCode = "";
    obj.endHook = false;

    obj.offset = offset;
    obj.delayOffset = delayOffset;
    obj.delayCmdOffset = delayCmdOffset;
    obj.reg = reg;
    return obj;
}

function ChangeWalkToDelay(value1, value2)
{
    var offsetObj = ChangeWalkToDelay_Match();
    var offset = offsetObj.offset;

    pe.setValue(offset, offsetObj.delayOffset, value1);

    if (pe.getDate() > 20170329)
    {
        offsetObj = ChangeWalkToDelay_Match2();
        offset = offsetObj.offset;

        pe.setValue(offset, offsetObj.delayOffset, value2);
    }

    return true;
}

function DisableWalkToDelay()
{
    return ChangeWalkToDelay(0, 0);
}

function SetWalkToDelay()
{
    var value1 = exe.getUserInput(
        "$walkDelay", XTYPE_WORD,
        _("Number Input"),
        _("Enter the new walk delay (0-1000) - snaps to closest valid value"),
        150, 0, 1000
    );
    var value2;
    if (pe.getDate() > 20170329)
    {
        value2 = exe.getUserInput(
            "$walkDelay2", XTYPE_WORD,
            _("Number Input"),
            _("Enter the new walk delay 2 (0-1000) - snaps to closest valid value"),
            150, 0, 1000
        );
    }
    else
    {
        value2 = 0;
    }
    return ChangeWalkToDelay(value1, value2);
}

function ChangeWalkToDelay_()
{
    return pe.getDate() > 20020729;
}
