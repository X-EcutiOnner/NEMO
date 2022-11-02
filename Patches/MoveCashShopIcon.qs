

function MoveCashShopIcon()
{
    if (table.get(table.UIWindowMgr_MakeWindow) === 0)
    {
        return "UIWindowMgr::MakeWindow not set";
    }

    var makeWindow = table.getRaw(table.UIWindowMgr_MakeWindow);
    if (table.get(table.UIWindowMgr_MakeWindow_ret1) == 0)
    {
        return "UIWindowMgr::MakeWindow ret not set";
    }
    var endOffset = table.getRaw(table.UIWindowMgr_MakeWindow_ret1);
    var endOffset2 = table.getRaw(table.UIWindowMgr_MakeWindow_ret2);
    if (endOffset2 > endOffset)
    {
        endOffset = endOffset2;
    }

    var code =
        " 81 EA BB 00 00 00" +
        " 52";
    var patchOffset = 0;
    var pushReg = "edx";
    var stolenCodeOffset = 0;
    var skipByte = true;
    var offset = pe.find(code, makeWindow, endOffset);

    if (offset === -1)
    {
        code =
            " 2D BB 00 00 00" +
            " 50";
        patchOffset = 0;
        pushReg = "eax";
        stolenCodeOffset = 0;
        skipByte = false;
        offset = pe.find(code, makeWindow, endOffset);
    }

    if (offset === -1)
    {
        code =
            " 2D BB 00 00 00" +
            " 6A 10" +
            " 50";
        patchOffset = 0;
        pushReg = "eax";
        stolenCodeOffset = [5, 2];
        skipByte = false;
        offset = pe.find(code, makeWindow, endOffset);
    }

    if (offset === -1)
    {
        return "Failed in Step 1 - Coord calculation missing";
    }

    var stolenCode = "";
    if (stolenCodeOffset)
    {
        stolenCode = pe.fetchHexBytes(offset, stolenCodeOffset);
    }

    var g_renderer = table.get(table.g_renderer);
    if (g_renderer === 0)
    {
        return "g_renderer not set";
    }
    var g_renderer_width = table.get(table.g_renderer_m_width);
    var g_renderer_height = table.get(table.g_renderer_m_height);

    var xCoord = exe.getUserInput("$cashShopX", XTYPE_WORD, _("Number Input"), _("Enter new X coordinate:"), -0xBB, -0xFFFF, 0xFFFF);
    var yCoord = exe.getUserInput("$cashShopY", XTYPE_WORD, _("Number Input"), _("Enter new Y coordinate:"), 0x10, -0xFFFF, 0xFFFF);

    if (xCoord === -0xBB && yCoord === 0x10)
    {
        return "Patch Cancelled - New coordinate is same as old";
    }

    var text = "";
    if (yCoord < 0)
    {
        yCoord = -yCoord;
        text = asm.combine(
            "push ecx",
            "mov ecx, dword ptr [g_renderer]",
            "mov ecx, dword ptr [ecx + g_renderer_height]",
            "sub ecx, yCoord",
            "mov dword ptr [esp + 8], ecx"
        );
    }
    else
    {
        text = asm.combine(
            "push ecx",
            "mov ecx, yCoord",
            "mov dword ptr [esp + 8], ecx"
        );
    }

    if (xCoord < 0)
    {
        xCoord = -xCoord;
        text = asm.combine(
            text,
            "mov ecx, dword ptr [g_renderer]",
            "mov ecx, dword ptr [ecx + g_renderer_width]",
            "sub ecx, xCoord",
            "mov " + pushReg + ", ecx",
            "pop ecx",
            "ret"
        );
    }
    else
    {
        text = asm.combine(
            text,
            "mov ecx, xCoord",
            "mov " + pushReg + ", ecx",
            "pop ecx",
            "ret"
        );
    }

    var vars = {
        "g_renderer": g_renderer,
        "g_renderer_width": g_renderer_width,
        "g_renderer_height": g_renderer_height,
        "xCoord": xCoord,
        "yCoord": yCoord,
    };

    var obj = pe.insertAsmTextObj(text, vars);
    var free = obj.free;

    if (skipByte)
    {
        text = asm.combine(
            asm.hexToAsm(stolenCode),
            "nop",
            "call free"
        );
    }
    else
    {
        text = asm.combine(
            asm.hexToAsm(stolenCode),
            "call free"
        );
    }

    vars = {
        "free": pe.rawToVa(free),
    };

    pe.replaceAsmText(offset + patchOffset, text, vars);

    return true;
}

function MoveCashShopIcon_()
{
    return pe.stringRaw("NC_CashShop") !== -1;
}
