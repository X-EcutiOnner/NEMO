//
// This file is part of NEMO (Neo Exe Modification Organizer).
// http://nemo.herc.ws - http://gitlab.com/4144/Nemo
//
// Copyright (C) 2018-2023 Andrei Karas (4144)
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

function DisableCDGuard()
{
    var code =
        "8B 0D ?? ?? ?? ?? " +
        "E8 ?? ?? ?? ?? " +
        "3C 01 " +
        "A1 ?? ?? ?? ?? " +
        "0F 94 C1 " +
        "68 ?? ?? ?? ?? " +
        "88 48 05 " +
        "E8 ?? ?? ?? ?? " +
        "8B C8 " +
        "E8 ";

    var cmpOffset = 12;
    var cheatDefenderMgrOffsets = [2, 14];
    var offsets = pe.findCodes(code);

    if (offsets.length === 0)
    {
        code =
            "8B 0D ?? ?? ?? ?? " +
            "E8 ?? ?? ?? ?? " +
            "3C 01 " +
            "A1 ?? ?? ?? ?? " +
            "68 ?? ?? ?? ?? " +
            "0F 94 C1 " +
            "88 48 05 " +
            "E8 ?? ?? ?? ?? " +
            "8B C8 " +
            "E8 ";

        cmpOffset = 12;
        cheatDefenderMgrOffsets = [2, 14];
        offsets = pe.findCodes(code);
    }

    if (offsets.length === 0)
    {
        return "Failed in Step 1a - Pattern not found";
    }

    if (offsets.length < 1 || offsets.length > 2)
    {
        return "Failed in Step 1a - Found wrong offset number";
    }

    var offset;
    for (var i = 0; i < offsets.length; i++)
    {
        offset = offsets[i];

        pe.replaceByte(offset + cmpOffset, 0);
    }

    var CCheatDefenderMgr = pe.fetchDWord(offsets[0] + cheatDefenderMgrOffsets[0]).packToHex(4);

    code =
        "A1 " + CCheatDefenderMgr +
        "C6 40 05 01 " +
        "B8 ?? ?? ?? 00 ";

    var enableOffset = 8;
    offset = pe.find(code, offsets[1], offsets[1] + 0x150);

    if (offset === -1)
    {
        return "Failed in Step 2a - Pattern not found";
    }

    pe.replaceByte(offset + enableOffset, 0);

    return true;
}

function DisableCDGuard_()
{
    return pe.stringRaw("CDClient.dll") !== -1;
}
