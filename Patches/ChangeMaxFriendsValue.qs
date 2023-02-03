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

function ChangeMaxFriendsValue()
{
    var code =
        "8B ?? ?? " +
        "8B ?? ?? " +
        "99 " +
        "F7 F9 " +
        "89 ?? ?? 00 00 00 ";

    var offses = pe.findCode(code);

    if (offses === -1)
    {
        code =
            "8B ?? ?? 00 00 00 " +
            "8B ?? ?? " +
            "99 " +
            "F7 F9 " +
            "89 ?? ?? 00 00 00 ";

        offses = pe.findCode(code);
    }

    if (offses === -1)
    {
        code =
            "8B 87 ?? 00 00 00 " +
            "8B 40 18 " +
            "99 " +
            "F7 BF ?? ?? 00 00 " +
            "89 87 ?? 00 00 00 ";

        offses = pe.findCode(code);
    }

    if (offses === -1)
    {
        code =
            "8B 83 ?? 00 00 00 " +
            "8B 40 18 " +
            "99 " +
            "F7 BB ?? ?? 00 00 " +
            "89 83 ?? ?? 00 00 ";

        offses = pe.findCode(code);
    }

    if (offses === -1)
    {
        return "Failed in Step 1 - Pattern not found";
    }

    var offzet = pe.stringVa("%s(%d/%d)");

    if (offzet === -1)
    {
        return "Failed in Step 2 - String not found";
    }

    var strHex = offzet.packToHex(4);

    code =
        "8B 93 ?? 00 00 00 " +
        "8B 44 8D ?? " +
        "6A ?? " +
        "52 " +
        "50 " +
        "8D 8D ?? ?? FF FF " +
        "68 " + strHex +
        "51 " +
        "E8 ?? ?? ?? ?? " +
        "83 C4 14 ";
    var repLoc = 11;
    var offset = pe.find(code, offses, offses + 0xBC);

    if (offset === -1)
    {
        code =
            "8B ?? ?? 00 00 00 " +
            "8B ?? 8C ?? " +
            "6A ?? " +
            "?? " +
            "?? " +
            "8D ?? 24 ?? ?? 00 00 " +
            "68 " + strHex +
            "?? " +
            "FF 15 ?? ?? ?? ?? " +
            "83 C4 14 ";
        repLoc = 11;
        offset = pe.find(code, offses, offses + 0xBC);
    }

    if (offset === -1)
    {
        code =
            "8B 96 ?? 00 00 00 " +
            "8B 84 8D ?? ?? FF FF " +
            "6A ?? " +
            "52 " +
            "50 " +
            "8D 8D ?? ?? FF FF " +
            "68 " + strHex +
            "51 " +
            "FF 15 ?? ?? ?? ?? " +
            "83 C4 14 ";
        repLoc = 14;
        offset = pe.find(code, offses, offses + 0xBC);
    }

    if (offset === -1)
    {
        code =
            "6A ?? " +
            "FF B7 ?? 00 00 00 " +
            "FF B4 85 ?? ?? FF FF " +
            "8D 85 ?? ?? FF FF " +
            "68 " + strHex +
            "50 " +
            "FF 15 ?? ?? ?? ?? " +
            "83 C4 14 ";
        repLoc = 1;
        offset = pe.find(code, offses, offses + 0xBC);
    }

    if (offset === -1)
    {
        code =
            "6A ?? " +
            "FF B7 ?? ?? 00 00 " +
            "8D 85 ?? ?? FF FF " +
            "FF B4 8D ?? ?? FF FF " +
            "68 " + strHex +
            "50 " +
            "FF 15 ?? ?? ?? ?? " +
            "83 C4 14 ";
        repLoc = 1;
        offset = pe.find(code, offses, offses + 0xBC);
    }

    if (offset === -1)
    {
        code =
            "6A ?? " +
            "FF B7 ?? ?? 00 00 " +
            "8D 85 ?? ?? FF FF " +
            "FF B4 8D ?? ?? FF FF " +
            "68 " + strHex +
            "50 " +
            "E8 ?? ?? ?? ?? " +
            "83 C4 14 ";
        repLoc = 1;
        offset = pe.find(code, offses, offses + 0xBC);
    }

    if (offset === -1)
    {
        code =
            "6A ?? " +
            "FF B3 ?? ?? 00 00 " +
            "8D 85 ?? ?? FF FF " +
            "FF B4 8D ?? ?? FF FF " +
            "68 " + strHex +
            "50 " +
            "E8 ?? ?? ?? ?? " +
            "83 C4 14 ";
        repLoc = 1;
        offset = pe.find(code, offses, offses + 0xBC);
    }

    if (offset === -1)
    {
        return "Failed in Step 3 - Pattern not found";
    }

    var value = exe.getUserInput("$max_friends_value", XTYPE_BYTE, _("Max Friends"), _("Set Max Friends Value: (Max:127, Default:40)"), "40", 1, 127);

    pe.replaceByte(offset + repLoc, value);

    return true;
}

function ChangeMaxFriendsValue_()
{
    return pe.stringRaw("%s(%d/%d)") !== -1;
}
