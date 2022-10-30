function Enable44khzAudio()
{
    var code =
        "C7 86 ?? ?? 00 00 40 1F 00 00 " +
        "EB 16 " +
        "C7 86 ?? ?? 00 00 11 2B 00 00 " +
        "EB 0A " +
        "C7 86 ?? ?? 00 00 22 56 00 00 ";

    var patchOffset = 30;
    var offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    pe.replaceHex(offset + patchOffset, " 44 AC 00 00");

    return true;
}
