

function CustomWindowTitle()
{
    var oldTitle;
    var titleOffset;
    if (IsZero())
    {
        oldTitle = "Ragnarok : Zero";
        titleOffset = pe.stringVa(oldTitle);
        if (titleOffset === -1)
        {
            oldTitle = "Ragnarok";
            titleOffset = pe.stringVa(oldTitle);
        }
    }
    else
    {
        oldTitle = "Ragnarok";
        titleOffset = pe.stringVa(oldTitle);
    }
    if (titleOffset === -1)
    {
        return "Old title not found";
    }

    var title = input.getString(
        "$customWindowTitle",
        _("String Input - maximum 200 characters"),
        _("Enter the new window Title"),
        oldTitle,
        200
    );
    if (title.trim() === oldTitle)
    {
        return "Patch Cancelled - New Title is same as old";
    }

    var newTitle = pe.insert(title);

    var code = " C7 05 ?? ?? ?? 00" + titleOffset.packToHex(4);
    var offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 2";
    }

    pe.replaceDWord(offset + code.hexlength() - 4, pe.rawToVa(newTitle));

    return true;
}
