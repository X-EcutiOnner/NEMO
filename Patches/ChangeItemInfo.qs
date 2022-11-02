

function ChangeItemInfo()
{
    var offset;
    if (IsSakray())
    {
        offset = pe.stringInfoVa(
            "System/iteminfo_Sak.lub",
            "System\\iteminfo_Sak.lub"
        );
    }
    else
    {
        offset = pe.stringInfoVa(
            "System/iteminfo.lub",
            "System/iteminfo_true.lub",
            "System\\iteminfo_true.lub"
        );
    }
    if (offset === -1)
    {
        return "Failed in Step 1 - iteminfo file name not found";
    }

    var iiName = offset[0];
    offset = offset[1];

    offset = pe.findCode("68" + offset.packToHex(4));
    if (offset === -1)
    {
        return "Failed in Step 1 - iteminfo reference not found";
    }

    var myfile = input.getString(
        "$newItemInfo",
        _("String input - maximum 28 characters including folder name/"),
        _("Enter the new ItemInfo path (should be relative to RO folder)"),
        iiName,
        28
    );

    if (myfile === iiName)
    {
        return "Patch Cancelled - New value is same as old";
    }

    var free = pe.insert(myfile);
    pe.replaceDWord(offset + 1, pe.rawToVa(free));

    return true;
}

function ChangeItemInfo_()
{
    if (IsSakray())
    {
        return pe.stringAnyRaw(
            "System/iteminfo_Sak.lub",
            "System\\iteminfo_Sak.lub"
        ) !== -1;
    }

    return pe.stringAnyRaw(
        "System/iteminfo.lub",
        "System/iteminfo_true.lub",
        "System\\iteminfo_true.lub"
    ) !== -1;
}
