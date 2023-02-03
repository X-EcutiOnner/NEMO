//
// Copyright (C) 2021-2023 Andrei Karas (4144)
//
// Hercules is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

function SetWalkToDelayCmd()
{
    var value1 = exe.getUserInput("$walkDelayCmdDelay1", XTYPE_WORD, _("Number Input"), _("Enter the new walk delay (0-1000) - snaps to closest valid value"), 150, 1, 1000);
    var value2 = 0;
    if (pe.getDate() > 20170329)
    {
        value2 = exe.getUserInput("$walkDelayCmdDelay2", XTYPE_WORD, _("Number Input"), _("Enter the new walk delay 2 (0-1000) - snaps to closest valid value"), 150, 0, 1000);
    }

    var textColor = exe.getUserInput(
        "$walkDelayCmdColor", XTYPE_COLOR,
        _("Color input"),
        _("Select walk delay chat message color"),
        0xffff.reverseRGB()
    ).reverseRGB();
    var cmdText = exe.getUserInput(
        "$walkDelayCmd", XTYPE_STRING,
        _("String input"),
        _("Enter walk delay enable/disable chat command)"),
        "/walkdelay",
        2
    );

    var offsetObj = ChangeWalkToDelay_Match();
    var offset = offsetObj.offset;
    var patchOffset = offsetObj.delayCmdOffset;

    var delayVar1 = pe.rawToVa(pe.insertDWord(value1));
    var vars = {
        "reg": "ecx",
        "delay": delayVar1,
    };
    pe.replaceAsmFile(offset + patchOffset[0], "WalkToDelayAssign", vars, patchOffset[1]);

    var delayVar2 = 0;
    if (pe.getDate() > 20170329)
    {
        offsetObj = ChangeWalkToDelay_Match2();
        offset = offsetObj.offset;
        patchOffset = offsetObj.delayCmdOffset;

        delayVar2 = pe.rawToVa(pe.insertDWord(value2));
        vars = {
            "reg": "ecx",
            "delay": delayVar2,
        };
        pe.replaceAsmFile(offset + patchOffset[0], "WalkToDelayAssign", vars, patchOffset[1]);
    }

    var cmdOffset = pe.rawToVa(pe.insertString(cmdText));

    if (pe.getDate() > 20170329)
    {
        vars = {
            "delay1": delayVar1,
            "delay2": delayVar2,
            "command": cmdOffset,
            "value1": value1,
            "value2": value2,
            "textColor": textColor,
        };
    }
    else
    {
        vars = {
            "delay1": delayVar1,
            "command": cmdOffset,
            "value1": value1,
            "textColor": textColor,
        };
    }

    var hook = hooks.initTableEndHook(table.CSession_GetTalkType_ret);
    hook.addFilePost("", vars);
    hook.validate();

    return true;
}
