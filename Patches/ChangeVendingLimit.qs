

function ChangeVendingLimit()
{
    var offset = pe.stringVa("1,000,000,000");
    if (offset === -1)
    {
        return "Failed in Step 1 - OneB string missing";
    }

    var oneb = pe.vaToRaw(offset);

    offset = pe.findCode("68" + offset.packToHex(4));
    if (offset === -1)
    {
        return "Failed in Step 1 - OneB reference missing";
    }

    var code =
        " 00 CA 9A 3B" +
        " 7E";

    var newstyle = true;
    var offset2 = pe.find(code, offset - 0x10, offset);
    if (offset2 === -1)
    {
        code =
            " 01 CA 9A 3B" +
            " 7C";
        newstyle = false;
        offset2 = pe.find(code, offset - 0x10, offset);
    }

    if (offset2 === -1)
    {
        return "Failed in Step 1 - Comparison missing";
    }

    code =
        " 6A 01" +
        " 6A 02" +
        " 68 5C 02 00 00";
    offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 2 - MsgBox call missing";
    }

    if (newstyle)
    {
        code =
            " 00 CA 9A 3B" +
            " 7E";
    }
    else
    {
        code =
            " 01 CA 9A 3B" +
            " 7D";
    }
    var offset1 = pe.find(code, offset - 0x80, offset);

    if (offset1 === -1 && newstyle)
    {
        code = code.replace("7E", "76");
        offset1 = pe.find(code, offset - 0x80, offset);
    }

    if (offset1 === -1)
    {
        return "Failed in Step 2 - Comparison missing";
    }

    if (!newstyle)
    {
        code = code.replace("7D", "75");
        offset = pe.find(code, offset - 0x60, offset);
        if (offset === -1)
        {
            return "Failed in Step 2 - Extra Comparison missing";
        }

        pe.replaceHex(offset + 4, "EB");
    }

    var newValue = exe.getUserInput("$vendingLimit", XTYPE_DWORD, _("Number Input"), _("Enter new Vending Limit (0 - 2,147,483,647):"), 1000000000);
    if (newValue === 1000000000)
    {
        return "Patch Cancelled - Vending Limit not changed";
    }

    var str = newValue.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",") + "\0";
    pe.replace(oneb, str);

    if (!newstyle)
    {
        newValue++;
    }

    pe.replaceDWord(offset1, newValue);
    pe.replaceDWord(offset2, newValue);

    return true;
}

function ChangeVendingLimit_()
{
    return pe.stringRaw("1,000,000,000") !== -1;
}
