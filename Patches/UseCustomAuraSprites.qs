

function UseCustomAuraSprites()
{
    var offset = pe.halfStringVa("effect\\ring_blue.tga");
    if (offset === -1)
    {
        return "Failed in Step 1 - ring_blue.tga not found";
    }

    var rblue = " 68" + offset.packToHex(4);

    offset = pe.halfStringVa("effect\\pikapika2.bmp");
    if (offset === -1)
    {
        return "Failed in Step 1 - pikapika2.bmp not found";
    }

    var ppika2 = " 68" + offset.packToHex(4);

    var strings = ["effect\\aurafloat.tga", "effect\\auraring.bmp"];
    var code = strings.join("\x00") + "\x00";

    var free = alloc.find(code.length);
    if (free === -1)
    {
        return "Failed in Step 1 - Not enough free space";
    }

    pe.insertHexAt(free, code.length, code.toHex());

    var afloat = pe.rawToVa(free).packToHex(4);
    var aring = pe.rawToVa(free + strings[0].length + 1).packToHex(4);

    var code1 =
    rblue +
  " 8B ??" +
  " E8 ?? ?? ?? ??" +
  " E9 ?? ?? ?? ??";

    var code2 = code1.replace(rblue, ppika2);
    var roff = code1.hexlength() + 2;

    offset = pe.findCode(code1 + " ??" + code2);
    if (offset === -1)
    {
        offset = pe.findCode(code1 + " 6A 00" + code2);
        roff++;
    }

    if (offset === -1)
    {
        return "Failed in Step 2";
    }

    pe.replaceHex(offset + 1, afloat);
    pe.replaceHex(offset + roff, aring);

    code =
        " 56" +
        " 8B F1" +
        " E8 ?? ?? FF FF" +
        " 8B CE" +
        " 5E" +
        " E9 ?? ?? FF FF";

    var offsets = pe.findCodes(code);
    var offsetR = -1;
    var offsetP = -1;

    for (var i = 0; i < offsets.length; i++)
    {
        offset = offsets[i] + 8 +  pe.fetchDWord(offsets[i] + 4);
        offsetP = pe.find(ppika2, offset, offset + 0x100);

        offset = offsets[i] + 16 + pe.fetchDWord(offsets[i] + 12);
        offsetR = pe.find(rblue, offset, offset + 0x120);

        if (offsetP !== -1 && offsetR !== -1) break;
    }

    if (offsetP !== -1 && offsetR !== -1)
    {
        pe.replaceHex(offsetP + 1, aring);
        pe.replaceHex(offsetR + 1, afloat);
    }

    return true;
}
