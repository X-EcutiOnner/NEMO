//
// This file is part of NEMO (Neo Exe Modification Organizer).
// http://nemo.herc.ws - http://gitlab.com/4144/Nemo
//
// Copyright (C) 2020 CH.C (jchcc)
// Copyright (C) 2020-2023 Andrei Karas (4144)
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
    var code = [
        [
            "89 8E ?? ?? ?? 00 ",
            {
                "stolenCode": [0, 6],
                "reg": "ecx",
            },
        ],
    ];
    var obj = pe.matchAny(code, offset);

    if (obj === false)
    {
        throw "Pattern not found";
    }

    var continueOffset = pe.rawToVa(offset) + obj.stolenCode[1];

    var hookObj = hooks.createHookObj();
    hookObj.patchAddr = offset;
    hookObj.stolenCode = pe.fetchHexBytes(offset, obj.stolenCode);
    hookObj.stolenCode1 = hookObj.stolenCode;
    hookObj.retCode = "68 " + continueOffset.packToHex(4) + " c3";
    hookObj.reg = obj.reg;
    hookObj.endHook = true;
    hookObj.offset = offset;

    return hookObj;
}

function RemoveEquipmentTitleUI()
{
    var code =
        "E8 ?? ?? ?? FF " +
        "83 BF ?? ?? 00 00 00 " +
        "75 19 " +
        "68 7D 0A 00 00 " +
        "E8 ?? ?? ?? ?? " +
        "8B 8F ?? ?? 00 00 " +
        "83 C4 04 " +
        "50 " +
        "E8 ";
    var repLoc = 12;
    var lastTab = true;
    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            "E8 ?? ?? ?? FF " +
            "83 BE ?? ?? 00 00 00 " +
            "75 19 " +
            "68 7D 0A 00 00 " +
            "E8 ?? ?? ?? ?? " +
            "8B 8E ?? ?? 00 00 " +
            "83 C4 04 " +
            "50 " +
            "E8 ";
        repLoc = 12;
        lastTab = true;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            "E8 ?? ?? ?? FF " +
            "83 BE ?? ?? 00 00 00 " +
            "75 27 " +
            "68 58 0C 00 00 " +
            "E8 ?? ?? ?? ?? " +
            "83 C4 04 " +
            "50 " +
            "68 7D 0A 00 00 " +
            "E8 ?? ?? ?? ?? " +
            "8B 8E ?? ?? 00 00 " +
            "83 C4 04 " +
            "50 " +
            "E8 ";
        repLoc = 12;
        lastTab = false;
        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 1 - Pattern not found";
    }

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

function RemoveEquipmentTitleUI_()
{
    return (pe.getDate() >= 20141126 && IsSakray()) || pe.getDate() >= 20150225;
}
