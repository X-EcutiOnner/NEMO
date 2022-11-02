

function AllowSpaceInGuildName()
{
    var code =
        " 6A 20" +
        " ??" +
        " FF ??" +
        " 83 C4 08" +
        " 85 C0";

    var offset = pe.findCode(code);
    if (offset === -1)
    {
        code =
            " 6A 20" +
            " ??" +
            " E8 ?? ?? ?? ??" +
            " 83 C4 08" +
            " 85 C0";
        offset = pe.findCode(code);
    }
    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    offset += code.hexlength();

    code = "";
    switch (pe.fetchUByte(offset))
    {
        case 0x74:
        {
            code = "EB";
            break;
        }
        case 0x75:
        {
            code = "90 90";
            break;
        }
        case 0x0F:
        {
            switch (pe.fetchUByte(offset + 1))
            {
                case 0x84:
                {
                    code = "90 E9";
                    break;
                }
                case 0x85:
                {
                    code = " EB 04";
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }

    if (code === "")
    {
        return "Failed in Step 2 - No JMP forms follow code";
    }

    pe.replaceHex(offset, code);

    return true;
}

function AllowSpaceInGuildName_()
{
    return pe.getDate() >= 20120207;
}
