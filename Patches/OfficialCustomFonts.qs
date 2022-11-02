

function OfficialCustomFonts_match()
{
    var LANGTYPE = GetLangType();
    if (LANGTYPE.length === 1)
    {
        return "LANGTYPE error: " + LANGTYPE[0];
    }

    var urlOffset = pe.stringHex4("http://www.ragnarok.co.kr");

    var code = [
        [
            "83 3D " + LANGTYPE + "00 " +
            "?? " +
            "0F 85 ?? 00 00 00 " +
            "E8 ?? ?? ?? ?? " +
            "68 " + urlOffset +
            "E8 ?? ?? ?? ?? " +
            "6A 00 ",
            {
                "replaceOffset": [8, 6],
                "jmpOffset": [10, 4],
            },
        ],
        [
            "A1 " + LANGTYPE +
            "?? " +
            "85 C0 " +
            "0F 85 ?? 00 00 00 " +
            "E8 ?? ?? ?? ?? " +
            "68 " + urlOffset +
            "E8 ?? ?? ?? ?? " +
            "6A 00 ",
            {
                "replaceOffset": [8, 6],
                "jmpOffset": [10, 4],
            },
        ],
        [
            "83 3D " + LANGTYPE + " 00 " +
            "5F " +
            "5E " +
            "0F 85 ?? 00 00 00 " +
            "E8 ?? ?? ?? ?? " +
            "68 " + urlOffset +
            "E8 ?? ?? ?? ?? " +
            "6A 00 ",
            {
                "replaceOffset": [9, 6],
                "jmpOffset": [11, 4],
            },
        ],
    ];

    var offsetObj = pe.findAnyCode(code);

    if (offsetObj === -1)
    {
        throw "Pattern not found";
    }

    var offset = offsetObj.offset;

    var obj = hooks.createHookObj();

    obj.stolenCode = "";
    obj.stolenCode1 = "";
    obj.retCode = "";
    obj.endHook = false;

    obj.offset = offset;
    obj.replaceOffset = offsetObj.replaceOffset;
    obj.jmpOffset = offsetObj.jmpOffset;
    return obj;
}

function EnableOfficialCustomFonts()
{
    var obj = OfficialCustomFonts_match();
    pe.setNopsValueRange(obj.offset, obj.replaceOffset);

    return true;
}

function DisableOfficialCustomFonts()
{
    var obj = OfficialCustomFonts_match();

    var jmpAddr = pe.fetchRelativeValue(obj.offset, obj.jmpOffset);
    pe.setJmpVa(obj.offset + obj.replaceOffset[0], jmpAddr, "jmp", obj.replaceOffset[1]);

    return true;
}
