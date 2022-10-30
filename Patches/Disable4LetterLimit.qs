

function Disable4LetterLimit(index)
{
    var code;
    var offset;
    var offset2;

    if (!IsZero() && pe.getDate() < 20181113)
    {
        code =
            " E8 ?? ?? ?? FF" +
            " 83 F8 04" +
            " 7C";

        var offsets = pe.findCodes(code);

        code = code.replaceAt(-3, " 0F 8C ?? ?? 00 00");
        offsets = offsets.concat(pe.findCodes(code));

        if (offsets.length < 3)
        {
            return "Failed in Step 1 - Not enough matches found";
        }

        code =
            " E8 ?? ?? ?? FF" +
            " 83 F8 04";

        var csize = code.hexlength();

        for (var idp = 0; idp < offsets.length; idp++)
        {
            offset2 = pe.find(code, offsets[idp] + csize, offsets[idp] + csize + 30 + csize);
            if (offset2 !== -1) break;
        }

        if (offset2 === -1)
        {
            return "Failed in Step 1 - ID+Pass check not found";
        }

        switch (index)
        {
            case 0:
            {
                for (var i = 0; i < offsets.length; i++)
                {
                    if (i === idp || offsets[i] === offset2) continue;
                    pe.replaceHex(offsets[i] + csize - 1, " 00");
                }
                break;
            }
            case 1:
            {
                pe.replaceHex(offsets[idp] + csize - 1, " 00");
                break;
            }
            case 2:
            {
                pe.replaceHex(offset2 + csize - 1, " 00");
                break;
            }
            default:
                break;
        }
    }
    else
    {
        code =
            " E8 ?? ?? ?? FF" +
            " 83 F8 04" +
            " 0F 8C ?? ?? 00 00";

        switch (index)
        {
            case 0:
            {
                var ref = pe.findCode(" 68 06 0D 00 00");
                if (ref === -1)
                {
                    return "Failed in Step 1 - UIChangeNameWnd::SendMsg not found";
                }

                offset = pe.find(code, ref, ref + 0xFF);
                if (offset === -1)
                {
                    return "Failed in Step 1 - UIChangeNameWnd::SendMsg:CharNameCheck not found";
                }

                ref = pe.findCode(" 68 C7 00 00 00 E8");
                if (ref === -1)
                {
                    return "Failed in Step 1 - UINewMakeCharWnd::SendMsg not found";
                }

                code = code.replace(" 0F 8C ?? ?? 00 00", " 7D ??");
                offset2 = pe.find(code, ref - 0X400, ref);
                if (offset === -1)
                {
                    return "Failed in Step 1 - UINewMakeCharWnd::SendMsg:CharNameCheck not found";
                }

                pe.replaceHex(offset + 7, " 00");
                pe.replaceHex(offset2 + 7, " 00");
                break;
            }
            case 1:
            {
                code = code.replace(" 04", " 06");
                offset = pe.findCode(code);
                if (offset === -1)
                {
                    return "Failed in Step 1 - Pass check not found.";
                }

                pe.replaceHex(offset + 7, " 00");
                break;
            }
            case 2:
            {
                var passCode = code.replace(" 04", " 06");
                offset = pe.findCode(passCode);
                if (offset === -1)
                {
                    return "Failed in Step 1 - Pass check not found.";
                }

                offset2 = pe.find(code, offset, offset + 0xFF);
                if (offset2 === -1)
                {
                    return "Failed in Step 1 - ID check not found.";
                }

                code = code.replace(" 0F 8C ?? ?? 00 00", " 7D ??");
                var offset3 = pe.find(code, offset, offset + 0xFF);
                if (offset3 === -1)
                {
                    return "Failed in Step 1 - ID check not found.";
                }

                pe.replaceHex(offset2 + 7, " 00");
                pe.replaceHex(offset3 + 7, " 00");
                break;
            }
            default:
                break;
        }
    }
    return true;
}

function Disable4LetterCharnameLimit()
{
    return Disable4LetterLimit(0);
}

function Disable4LetterPasswordLimit()
{
    return Disable4LetterLimit(1);
}

function Disable4LetterUsernameLimit()
{
    return Disable4LetterLimit(2);
}
