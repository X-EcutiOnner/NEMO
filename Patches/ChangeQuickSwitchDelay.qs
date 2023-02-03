// Change hardcoded quick item switch delay
// Author: mrjnumber1

function ChangeQuickSwitchDelay()
{
    var tick = 10;
    var tick_ms = tick * 1000;
    var code =
        " 3D " + tick_ms.packToHex(4) +
        " 0F 83 ?? ?? 00 00" +
        " 8B ?? ?? ?? ?? 00";

    var offsets = pe.findCodes(code);

    if (offsets.length === 0)
    {
        code =
            " 3D " + tick_ms.packToHex(4) +
            " 0F 83 ?? ?? 00 00" +
            " 8B ?? ?? ?? ?? 01";
        offsets = pe.findCodes(code);
    }

    var size = offsets.length;

    if (size === 0)
    {
        return "Failed in Step 1 - Find Quickswitch Tick";
    }

    var g_qsTick = pe.fetchDWord(offsets[0] + 13);

    var new_tick = exe.getUserInput("$my_new_tick", XTYPE_BYTE, _("Number - (0-255)"), _("Enter the new Quickswitch delay"), tick, 0, 255);
    if (tick == new_tick)
    {
        return "Patch Cancelled - New value is same as old";
    }

    var new_tick_ms = new_tick * 1000;

    for (var i = 0; i < size; ++i)
    {
        pe.replaceDWord(offsets[i] + 1, new_tick_ms);

        var start = offsets[i] + 17;
        var end = start + 50;
        code = " B8" + tick.packToHex(4);
        var offset = pe.find(code, start, end);
        if (offset === -1)
        {
            return "Failed in Step 2 - Find delay subtraction for spot " + i;
        }
        pe.replaceDWord(offset + 1, new_tick);
    }

    code = " 8B ?? " + g_qsTick.packToHex(4);
    var ui_offset = pe.findCode(code);
    if (ui_offset === -1)
    {
        return "Failed in Step 3a - Find UI quickswitch offset";
    }

    code = " 3D " + tick_ms.packToHex(4);
    offset = pe.find(code, ui_offset + 6, ui_offset + 30);
    if (offset === -1)
    {
        return "Failed in Step 3b - Find Compare to " + tick_ms;
    }
    if (offsets.indexOf(offset) === -1)
    {
        pe.replaceDWord(offset + 1, new_tick_ms);
    }
    return true;
}

function ChangeQuickSwitchDelay_()
{
    return pe.getDate() >= 20170517;
}
