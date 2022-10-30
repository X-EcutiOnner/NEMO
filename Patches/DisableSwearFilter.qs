// #####################################################################
// # Purpose: Zero out 'manner.txt' to prevent any reference bad words #
// #          from loading to compare against                          #
// #####################################################################

function DisableSwearFilter()
{
    var offset = pe.stringRaw("manner.txt");
    if (offset === -1)
    {
        return "Failed in Step 1";
    }

    pe.replaceByte(offset, 0);

    return true;
}
