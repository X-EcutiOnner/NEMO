

function MoveItemCountUpwards()
{
    var code =
        " 68 FF FF FF 00" +
        " 0F BF CE";
    var type = 1;
    var offsets = pe.findCodes(code);

    if (offsets.length === 0)
    {
        code =
            " 68 FF FF FF 00" +
            " 6A 0B" +
            " 6A 00" +
            " 0F";
        if (HasFramePointer())
        {
            type = 3;
        }
        else
        {
            type = 2;
        }
        offsets = pe.findCodes(code);
    }

    if (offsets.length === 0)
    {
        code =
            " 68 FF FF FF 00" +
            " B8 0E 00 00 00" +
            " 0F 4D C1" +
            " 6A 0B" +
            " 98";
        type = 4;
        offsets = pe.findCodes(code);
    }

    if (offsets.length === 0)
    {
        return "Failed in Step 1 - No Patterns matched";
    }

    if (type === 1)
    {
        code =
            " 8A 45 18" +
            " 83 C4 0C" +
            " 84 C0";
    }
    else if (type === 2)
    {
        code = " 80 7C 24 3C 00";
    }
    else
    {
        code = " 80 7D 18 00";
    }

    if (type === 4)
    {
        code += " 6A 00";
    }

    code += " 74";

    var offset = -1;
    for (var i = 0; i < offsets.length; i++)
    {
        offset = pe.find(code, offsets[i] - 0x50, offsets[i]);
        if (offset !== -1)
        {
            break;
        }
    }
    if (offset === -1)
    {
        return "Failed in Step 2 - Comparison missing";
    }

    pe.replaceByte(offset + code.hexlength() - 1, 0xEB);
    return true;
}
