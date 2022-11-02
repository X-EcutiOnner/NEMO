

function IncreaseViewID()
{
    var offset = pe.stringVa("ReqAccName");
    if (offset === -1)
    {
        return "Failed in Step 1 - Can't find ReqAccName";
    }

    offset = pe.findCode(" 68" + offset.packToHex(4));
    if (offset === -1)
    {
        return "Failed in Step 1 - Can't find Function reference";
    }

    var oldValue;
    if (pe.getDate() > 20200325)
    {
        oldValue = 3000;
    }
    else if (pe.getDate() > 20130000)
    {
        oldValue = 2000;
    }
    else
    {
        oldValue = 1000;
    }

    var newValue = exe.getUserInput("$newValue", XTYPE_DWORD, _("Number input"), _("Enter the new Max Headgear View ID"), oldValue, oldValue, 32000);
    if (newValue === oldValue)
    {
        return "Patch Cancelled - New value is same as old";
    }

    var offsets = pe.findAll(oldValue.packToHex(4), offset - 0xA0, offset + 0x50);

    if (offsets.length === 0)
    {
        return "Failed in Step 2 - No match found";
    }

    if (offsets.length > 3)
    {
        return "Failed in Step 2 - Extra matches found";
    }

    for (var i = 0; i < offsets.length; i++)
    {
        pe.replaceDWord(offsets[i], newValue);
    }

    return true;
}

function IncreaseViewID_()
{
    return pe.stringRaw("ReqAccName") !== -1;
}
