// ######################################################################
// #        Purpose: Fix Item Description '[' Bug                       #
// ######################################################################

function FixItemDescBug()
{
    var code =
        " 80 3E 5B" +
        " 75 ??" +
        " 8B";
    var patchLoc = 3;
    var offset = pe.findCode(code);
    if (offset === -1)
    {
        code =
            " 3C 5B" +
            " 75 ??" +
            " 8B";
        patchLoc = 2;
        offset = pe.findCode(code);
    }
    if (offset === -1)
    {
        return "Failed in Step 1 - '[' string compare missing";
    }

    pe.replaceByte(offset + patchLoc, 0xEB);

    return true;
}

