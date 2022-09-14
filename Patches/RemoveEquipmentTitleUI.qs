//
// This file is part of NEMO (Neo Exe Modification Organizer).
// http://nemo.herc.ws - http://gitlab.com/4144/Nemo
//
// Copyright (C) 2020 CH.C (jchcc)
// Copyright (C) 2020-2022 Andrei Karas (4144)
// Copyright (C) 2020-2021 X-EcutiOnner (xex.ecutionner@gmail.com)
//
// Hercules is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
//

function UIEquipWndSendMsgSetTab_Match(storageKey, offset)
{
    consoleLog("Match UIEquipWndSendMsgSetTab");

    var code = [
        [
            "89 8E ?? ?? ?? 00 ",         // 0 mov [esi+UIEquipWnd.m_curTab], ecx
            {
                "stolenCode": [0, 6],
                "curTab": [2, 4],
                "reg": "ecx"
            }
        ],
    ];
    var obj = pe.matchAny(code, offset);

    if (obj === false)
        throw "Pattern not found";

    logField("UIEquipWnd::m_curTab", offset, obj.curTab);

    var continueOffset = pe.rawToVa(offset) + obj.stolenCode[1];

    var hookObj = hooks.createHookObj();
    hookObj.patchAddr = offset;
    hookObj.stolenCode = pe.fetchHexBytes(offset, obj.stolenCode);
    hookObj.stolenCode1 = hookObj.stolenCode;
    hookObj.retCode = "68 " + continueOffset.packToHex(4) + " c3";  // push addr; ret
    hookObj.reg = obj.reg;
    hookObj.endHook = true;
    hookObj.offset = offset;

    return hookObj;
}

function RemoveEquipmentTitleUI()
{
    consoleLog("Step 1 - Find the location where equipment function is called");
    var code =
        "E8 ?? ?? ?? FF " +           // 0 call UITabControl_SetTabString
        "83 BF ?? ?? 00 00 00 " +     // 5 cmp [edi+UIEquipWnd.m_typeWnd], 0
        "75 19 " +                    // 12 jnz short loc_5C54F6
        "68 7D 0A 00 00 " +           // 14 push 0A7Dh
        "E8 ?? ?? ?? ?? " +           // 19 call MsgStr
        "8B 8F ?? ?? 00 00 " +        // 24 mov ecx, [edi+UIEquipWnd.m_tabs]
        "83 C4 04 " +                 // 30 add esp, 4
        "50 " +                       // 33 push eax
        "E8 ";                        // 34 call UITabControl_SetTabString
    var repLoc = 12;
    var addTabOffsets = [1, 35];
    var typeWndOffset = [7, 4];
    var msgStrOffsets = [20];
    var tabsOffset = [26, 4];
    var lastTab = true;
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            "E8 ?? ?? ?? FF " +           // 0 call UITabControl_SetTabString
            "83 BE ?? ?? 00 00 00 " +     // 5 cmp [esi+UIEquipWnd.m_typeWnd], 0
            "75 19 " +                    // 12 jnz short loc_589D62
            "68 7D 0A 00 00 " +           // 14 push 0A7Dh
            "E8 ?? ?? ?? ?? " +           // 19 call MsgStr
            "8B 8E ?? ?? 00 00 " +        // 24 mov ecx, [esi+UIEquipWnd.m_tabs]
            "83 C4 04 " +                 // 30 add esp, 4
            "50 " +                       // 33 push eax
            "E8 "                         // 34 call UITabControl_SetTabString
        repLoc = 12;
        addTabOffsets = [1, 35];
        typeWndOffset = [7, 4];
        msgStrOffsets = [20];
        tabsOffset = [26, 4];
        lastTab = true;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            "E8 ?? ?? ?? FF " +           // 0 call UITabControl_SetTabString
            "83 BE ?? ?? 00 00 00 " +     // 5 cmp [esi+UIEquipWnd.m_typeWnd], 0
            "75 27 " +                    // 12 jnz short loc_58A14C
            "68 58 0C 00 00 " +           // 14 push 0C58h
            "E8 ?? ?? ?? ?? " +           // 19 call MsgStr
            "83 C4 04 " +                 // 24 add esp, 4
            "50 " +                       // 27 push eax
            "68 7D 0A 00 00 " +           // 28 push 0A7Dh
            "E8 ?? ?? ?? ?? " +           // 33 call MsgStr
            "8B 8E ?? ?? 00 00 " +        // 38 mov ecx, [esi+UIEquipWnd.m_tabs]
            "83 C4 04 " +                 // 44 add esp, 4
            "50 " +                       // 47 push eax
            "E8 "                         // 48 call UITabControl_SetTabString
        repLoc = 12;
        addTabOffsets = [1, 49];
        typeWndOffset = [7, 4];
        msgStrOffsets = [20, 34];
        tabsOffset = [40, 4];
        lastTab = false;
        offset = pe.findCode(code);
    }

    if (offset === -1)
        return "Failed in Step 1 - Pattern not found";

    for (var i = 0; i < addTabOffsets.length; i++)
    {
        logRawFunc("UITabControl_SetTabString", offset, addTabOffsets[i]);
    }
    logField("UIEquipWnd::m_typeWnd", offset, typeWndOffset);
    for (var i = 0; i < msgStrOffsets.length; i++)
    {
        logRawFunc("MsgStr", offset, msgStrOffsets[i]);
    }
    logField("UIEquipWnd::m_tabs", offset, tabsOffset);

    pe.replaceByte(offset + repLoc, 0xEB);

    if (lastTab === false)
    {
        var varId = table.UIEquipWnd_SendMsg_TAB;
        var hook = hooks.initHook(varId, UIEquipWndSendMsgSetTab_Match, table.varToHook);
        var vars = {
            "reg": hook.reg,
        };
        hook.addFilePre("", vars);
        hook.validate();
    }

    return true;
}

//=======================================================//
// Disable for Unsupported Clients - Check for Reference //
//=======================================================//
function RemoveEquipmentTitleUI_()
{
    return (pe.getDate() >= 20141126 && IsSakray()) || pe.getDate() >= 20150225;
}
