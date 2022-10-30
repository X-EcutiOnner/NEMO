// ###################################################################################
// # Purpose: Make client skip over the Cash Shop Icon UIWindow creation (ID = 0xBE) #
// ###################################################################################

function HideCashShop()
{
    var code =
        " 68 BE 00 00 00" +
        getEcxWindowMgrHex() +
        " E8";

    var offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Patch Cancelled - Cash Shop already hidden";
    }

    pe.replaceHex(offset, "31 C0 EB 0B");
    return true;
}

function HideCashShop_()
{
    return pe.stringRaw("NC_CashShop") !== -1;
}
