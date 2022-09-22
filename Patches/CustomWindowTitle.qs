//##############################################################################
//# Purpose: Switch "Ragnarok" reference with address of User specified Window #
//#          Title which will be that of unused URL string that is overwritten #
//##############################################################################

function CustomWindowTitle()
{
    consoleLog("Search old title");
    if (IsZero())
    {
        var oldTitle = "Ragnarok : Zero";
        var titleOffset = pe.stringVa(oldTitle);
        if (titleOffset === -1)
        {
            oldTitle = "Ragnarok";
            titleOffset = pe.stringVa(oldTitle);
        }
    }
    else
    {
        var oldTitle = "Ragnarok";
        var titleOffset = pe.stringVa(oldTitle);
    }
    if (titleOffset === -1)
        return "Old title not found";

    consoleLog("Request new title");
    var title = input.getString("$customWindowTitle",
        _("String Input - maximum 200 characters"),
        _("Enter the new window Title"),
        oldTitle,
        200);
    if (title.trim() === oldTitle)
        return "Patch Cancelled - New Title is same as old";

    consoleLog("Store new title");
    var newTitle = pe.insert(title);

    consoleLog("Search title usage");
    var code = " C7 05 ?? ?? ?? 00" + titleOffset.packToHex(4); //MOV DWORD PTR DS:[g_title], OFFSET addr; ASCII "Ragnarok"
    var offset = pe.findCode(code);
    if (offset === -1)
        return "Failed in Step 2";

    consoleLog("Update title address");
    pe.replaceDWord(offset + code.hexlength() - 4, pe.rawToVa(newTitle));

    return true;
}
