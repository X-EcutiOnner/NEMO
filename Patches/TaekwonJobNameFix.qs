
function TaekwonJobNameFix()
{
    var foundRef = [[], []];
    var excludeRef = [[], []];
    var found;
    var exclude;

    function searchUsage(data, name)
    {
        var res = pe.findCodes(data);
        if (res.length === 0)
        {
            throw "Reference not found for " + name;
        }
        return res;
    }

    function searchIndexBlock(code, index, refOffset, fIndex)
    {
        if (typeof fIndex === "undefined")
        {
            fIndex = 0x3f38;
        }
        var offsets = pe.findCodes(code);
        for (var i = 0; i < offsets.length; i ++)
        {
            var offset = offsets[i];
            var value = pe.fetchValue(offset, [index, 4]);
            if (value == fIndex)
            {
                found.push([offset, offset + refOffset]);
            }
            else
            {
                exclude.push([offset, offset + refOffset]);
            }
        }
    }

    function excludeBlock(code, refOffset)
    {
        var offsets = pe.findCodes(code);
        for (var i = 0; i < offsets.length; i ++)
        {
            var offset = offsets[i];
            exclude.push([offset, offset + refOffset]);
        }
    }

    function searchIndexBlock2(code, index, ref0Offset, ref1Offset, fIndex)
    {
        if (typeof fIndex === "undefined")
        {
            fIndex = 0x3f38;
        }
        var offsets = pe.findCodes(code);
        for (var i = 0; i < offsets.length; i ++)
        {
            var offset = offsets[i];
            var value = pe.fetchValue(offset, [index, 4]);
            if (value == fIndex)
            {
                foundRef[0].push([
                    offset,
                    offset + ref0Offset]);
                foundRef[1].push([
                    offset,
                    offset + ref1Offset]);
            }
            else
            {
                excludeRef[0].push([
                    offset,
                    offset + ref0Offset]);
                excludeRef[1].push([
                    offset,
                    offset + ref1Offset]);
            }
        }
    }

    function printHexAddr(text, val)
    {
    }

    var namesStr = [
        "TaeKwon Girl",
        "TaeKwon Boy",
    ];
    var enStr = [
        pe.stringHex4(namesStr[0]),
        pe.stringHex4(namesStr[1]),
    ];
    var krStr = [
        pe.stringHex4("\xC5\xC2\xB1\xC7\xBC\xD2\xB3\xE0"),
        pe.stringHex4("\xC5\xC2\xB1\xC7\xBC\xD2\xB3\xE2"),
    ];

    var allKrRef = [
        searchUsage(krStr[0], namesStr[0]),
        searchUsage(krStr[1], namesStr[1]),
    ];

    var i;

    for (i = 0; i < 2; i ++)
    {
        var ref = krStr[i];
        found = foundRef[i];
        exclude = excludeRef[i];

        searchIndexBlock(
            "C7 80 ?? ?? ?? 00 " + ref,
            2,
            6
        );
        searchIndexBlock(
            "C7 81 ?? ?? ?? 00 " + ref,
            2,
            6
        );
        searchIndexBlock(
            "C7 82 ?? ?? ?? 00 " + ref,
            2,
            6
        );
        searchIndexBlock(
            "C7 85 ?? ?? ?? 00 " + ref,
            2,
            6
        );
        searchIndexBlock(
            "C7 87 ?? ?? ?? 00 " + ref,
            2,
            6
        );

        searchIndexBlock(
            "C7 45 F0 " + ref +
            "FF 75 ?? " +
            "C7 45 EC ?? ?? ?? 00 ",
            13,
            3,
            0xfce
        );
        searchIndexBlock(
            "68 ?? ?? ?? 00 " +
            "8B CF " +
            "C7 00 " + ref +
            "E8 ",
            1,
            9
        );
        searchIndexBlock(
            "B9 " + ref +
            "89 8D ?? ?? ?? 00 ",
            7,
            1
        );
        searchIndexBlock(
            "BA " + ref +
            "89 93 ?? ?? ?? 00 ",
            7,
            1
        );

        excludeBlock(
            "6A ?? " +
            "8B CE " +
            "C7 00 " + ref +
            "E8 ",
            6
        );
        excludeBlock(
            "6A ?? " +
            "8B CF " +
            "C7 00 " + ref +
            "E8 ",
            6
        );
        excludeBlock(
            "B9 " + ref +
            "E9 ?? ?? 00 00 ",
            1
        );
        excludeBlock(
            "BA " + ref +
            "E9 ?? ?? 00 00 ",
            1
        );
        excludeBlock(
            "8B 06 " +
            "C7 45 ?? " + ref +
            "C7 80 ",
            5
        );

        excludeBlock(
            "C7 80 9C 02 00 00 ?? 00 00 00 ",
            4
        );
        excludeBlock(
            "E8 ?? ?? 00 00 " +
            "83 C4 ",
            0
        );
        excludeBlock(
            "0F 85 ?? 00 00 00 " +
            "3D ?? 00 00 00 ",
            5
        );
        excludeBlock(
            "E9 ?? 00 00 00 " +
            "3D ?? 00 00 00 " +
            "74 ",
            4
        );
        excludeBlock(
            "E9 ?? ?? 00 00 " +
            "3D ?? 00 00 00 " +
            "0F 84 ?? ?? 00 00 ",
            4
        );
    }

    searchIndexBlock2(
        "81 FF ?? ?? ?? 00 " +
        "0F 85 ?? ?? ?? 00 " +
        "85 F6 " +
        "BA " + krStr[0] +
        "B8 " + krStr[1] +
        "0F 45 D0 ",
        2,
        15, 20,
        0xfce
    );
    searchIndexBlock2(
        "B8 " + krStr[1] +
        "85 FF " +
        "B9 " + krStr[0] +
        "0F 45 C8 " +
        "A1 ?? ?? ?? ?? " +
        "5F " +
        "89 88 ?? ?? ?? 00 ",
        23,
        8, 1
    );
    searchIndexBlock2(
        "B8 " + krStr[1] +
        "B9 " + krStr[0] +
        "0F 45 C8 " +
        "A1 ?? ?? ?? ?? " +
        "5F " +
        "89 88 ?? ?? ?? 00 ",
        21,
        6, 1
    );
    searchIndexBlock2(
        "B9 " + krStr[0] +
        "BA " + krStr[1] +
        "0F 45 CA " +
        "89 88 ?? ?? ?? 00 ",
        15,
        1, 6
    );

    var isError = false;
    var j;
    var val;
    for (i = 0; i < 2; i ++)
    {
        found = [];
        var foundCnt = 0;
        var excludeCnt = 0;
        for (j = 0; j < foundRef[i].length; j ++)
        {
            val = foundRef[i][j][1];
            if (allKrRef[i].indexOf(val) >= 0)
            {
                printHexAddr(" Found ref", val);
                found.push(val);
                foundCnt += 1;
            }
        }
        for (j = 0; j < excludeRef[i].length; j ++)
        {
            val = excludeRef[i][j][1];
            if (allKrRef[i].indexOf(val) >= 0)
            {
                printHexAddr(" Exclude ref", val);
                found.push(val);
                excludeCnt += 1;
            }
        }
        for (j = 0; j < allKrRef[i].length; j ++)
        {
            val = allKrRef[i][j];
            if (found.indexOf(val) < 0)
            {
                printHexAddr(" Missing ref", val);
                isError = true;
            }
        }
        var cnt = foundCnt + excludeCnt;
        if (cnt !== allKrRef[i].length)
        {
            throw "Found " + cnt + " from " + allKrRef[i].length + " referenced for index " + i;
        }
    }
    if (isError === true)
    {
        throw "Found not all references";
    }
    for (i = 0; i < 2; i ++)
    {
        for (j = 0; j < foundRef[i].length; j ++)
        {
            var addr = foundRef[i][j][1];
            pe.replaceHex(addr, enStr[i]);
        }
    }

    return true;
}
