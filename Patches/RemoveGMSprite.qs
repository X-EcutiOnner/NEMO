

function RemoveGMSprite()
{
    var code =
        " 68 ?? ?? ?? 00" +
        " 6A 05" +
        " 8B ??" +
        " E8 ?? ?? FF FF";
    var len = code.hexlength();

    code += code;

    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code = code.replace(" 8B ??");
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    offset += code.hexlength() - len;

    var funcs = [];
    funcs[0] = offset + pe.fetchDWord(offset - 4);
    funcs[1] = offset + len + pe.fetchDWord(offset + len - 4);

    code =
        " E8 ?? ?? ?? ??" +
        " 83 C4 04" +
        " 84 C0" +
        " 0F 84";

    for (var i = 0; i < funcs.length; i++)
    {
        offset = pe.find(code, funcs[i]);
        if (offset === -1)
        {
            return "Failed in Step 2 - Iteration No." + i;
        }

        pe.replaceHex(offset + code.hexlength() - 2, " 90 E9");
    }

    return true;
}
