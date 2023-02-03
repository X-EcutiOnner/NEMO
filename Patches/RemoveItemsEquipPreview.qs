//
// This file is part of NEMO (Neo Exe Modification Organizer).
// http://nemo.herc.ws - http://gitlab.com/4144/Nemo
//
// Copyright (C) 2021-2023 Andrei Karas (4144)
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

function RemoveItemsEquipPreview()
{
    var offset = pe.stringVa("IsEffectHatItem");

    if (offset === -1)
    {
        return "Failed in Step 1 - String not found";
    }

    var strHex = offset.packToHex(4);

    var code =
        "68 " + strHex +
        "C6 01 00 " +
        "E8 ?? ?? ?? ?? " +
        "C7 45 ?? ?? ?? 00 00 " +
        "FF 35 ?? ?? ?? ?? " +
        "C7 45 ?? FF FF FF FF " +
        "E8 ?? ?? ?? ?? " +
        "83 C4 28 " +
        "80 BD ?? ?? ?? FF 01 " +
        "0F 84 ?? ?? ?? ?? " +
        "68 ?? ?? 00 00 " +
        "E8 ?? ?? ?? ?? " +
        "83 C4 04 " +
        "89 85 ?? ?? ?? FF " +
        "C7 45 ?? ?? ?? 00 00 " +
        "85 C0 " +
        "74 09 " +
        "8B C8 " +
        "E8 ?? ?? ?? ?? " +
        "EB ";

    var repLoc = 48;
    offset = pe.findCode(code);

    if (offset === -1)
    {
        return "Failed in Step 2 - Pattern not found";
    }

    pe.replaceHex(offset + repLoc, "90 E9 ");

    return true;
}

function RemoveItemsEquipPreview_()
{
    return pe.stringRaw("IsEffectHatItem") !== -1;
}
