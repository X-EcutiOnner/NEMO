//
// This file is part of NEMO (Neo Exe Modification Organizer).
// http://nemo.herc.ws - http://gitlab.com/4144/Nemo
//
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

function DisableBlindEffect()
{
    var code =
        "0F 85 ?? 01 00 00 " +
        "83 EC 0C " +
        "8B D3 " +
        "8B CC " +
        "8B C3 " +
        "6A 47 " +
        "89 5D ?? " +
        "89 11 " +
        "89 5D ?? " +
        "89 5D ?? " +
        "89 ?? 04 " +
        "89 ?? 08 " +
        "8B CE " +
        "E8 ?? ?? ?? ?? " +
        "A3 ?? ?? ?? 00 " +
        "?? 88 ?? ?? 00 00 ";

    var repLoc = 52;

    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            "0F 85 ?? 01 00 00 " +
            "83 EC 0C " +
            "8B D3 " +
            "8B CC " +
            "8B C3 " +
            "6A 47 " +
            "89 5D ?? " +
            "89 11 " +
            "89 5D ?? " +
            "89 5D ?? " +
            "89 ?? 04 " +
            "89 ?? 08 " +
            "8B CE " +
            "E8 ?? ?? ?? ?? " +
            "89 ?? ?? ?? ?? 00 " +
            "?? 88 ?? ?? 00 00 ";

        repLoc = 53;

        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            "0F 85 ?? 01 00 00 " +
            "D9 EE " +
            "83 EC 0C " +
            "8B C4 " +
            "D9 54 24 ?? " +
            "8B 4C 24 ?? " +
            "D9 54 24 ?? " +
            "8B 54 24 ?? " +
            "D9 5C 24 ?? " +
            "89 08 " +
            "8B 4C 24 ?? " +
            "89 ?? 04 " +
            "89 ?? 08 " +
            "6A 47 " +
            "8B CE " +
            "E8 ?? ?? ?? ?? " +
            "89 ?? ?? ?? ?? 00 " +
            "?? 88 ?? ?? 00 00 00 02 00 00 ";

        repLoc = 70;

        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            "0F 85 ?? 01 00 00 " +
            "D9 EE " +
            "83 EC 0C " +
            "8B C4 " +
            "D9 55 ?? " +
            "8B 4D ?? " +
            "D9 55 ?? " +
            "8B 55 ?? " +
            "D9 5D ?? " +
            "89 08 " +
            "8B 4D ?? " +
            "89 ?? 04 " +
            "89 ?? 08 " +
            "6A 47 " +
            "8B CE " +
            "E8 ?? ?? ?? ?? " +
            "89 ?? ?? ?? ?? 00 " +
            "?? 88 ?? ?? 00 00 00 02 00 00 ";

        repLoc = 64;

        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            "0F 85 ?? 01 00 00 " +
            "83 EC 0C " +
            "8B CC " +
            "C7 45 ?? 00 00 00 00 " +
            "C7 45 ?? 00 00 00 00 " +
            "F3 0F 7E 45 ?? " +
            "C7 45 ?? 00 00 00 00 " +
            "8B 45 ?? " +
            "66 0F D6 01 " +
            "89 ?? 08 " +
            "6A 47 " +
            "8B CE " +
            "E8 ?? ?? ?? ?? " +
            "89 ?? ?? ?? ?? 00 " +
            "?? 88 ?? ?? 00 00 00 02 00 00 ";

        repLoc = 72;

        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        code =
            "0F 85 ?? 01 00 00 " +
            "83 EC 0C " +
            "C7 45 ?? 00 00 00 00 " +
            "8B 45 ?? " +
            "8B CC " +
            "0F 57 C0 " +
            "0F 14 C0 " +
            "6A 47 " +
            "66 0F D6 01 " +
            "89 ?? 08 " +
            "8B CE " +
            "E8 ?? ?? ?? ?? " +
            "89 ?? ?? ?? ?? 00 " +
            "BA 04 00 00 00 " +
            "?? 88 ?? ?? 00 00 00 02 00 00 ";

        repLoc = 64;

        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in Step 1 - Pattern not found";
    }

    pe.replaceHex(offset + code.hexlength() - repLoc, "90 E9 ");

    return true;
}

function DisableBlindEffect_()
{
    return pe.getDate() > 20020000;
}
