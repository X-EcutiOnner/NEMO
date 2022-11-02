

function EnableTitleBarMenu()
{
    var offset = imports.ptrValidated("CreateWindowExA", "USER32.dll");

    var code = " 68 00 00 C2 02";
    var offsets = pe.findCodes(code);
    if (offsets.length === 0)
    {
        return "Failed in Step 1 - Style not found";
    }

    code = " FF 15" + offset.packToHex(4);

    for (var i = 0; i < offsets.length; i++)
    {
        offset = pe.find(code, offsets[i] + 8, offsets[i] + 29);
        if (offset !== -1)
        {
            offset = offsets[i];
            break;
        }
    }

    if (offset === -1)
    {
        return "Failed in Step 1 - Function call not found";
    }

    pe.replaceByte(offset + 3, 0xCA);

    return true;
}
