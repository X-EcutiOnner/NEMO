//
// This file is part of NEMO (Neo Exe Modification Organizer).
// http://nemo.herc.ws - http://gitlab.com/4144/Nemo
//
// Copyright (C) 2017 Secret
// Copyright (C) 2017-2023 Andrei Karas (4144)
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

function AlwaysReadKrExtSettings()
{
    var filePath = "Lua Files\\service_korea\\ExternalSettings_kr";

    if (IsZero())
    {
        filePath = "Lua Files\\service_korea\\zero_server\\ExternalSettings_kr";
    }

    var offset = pe.stringVa(filePath);

    if (offset === -1)
    {
        return "Failed in Step 1 - String not found";
    }

    var korea_ref_offset = pe.findCode("68 " + offset.packToHex(4));

    if (korea_ref_offset === -1)
    {
        return "Failed in Step 2 - Pattern not found";
    }

    var LANGTYPE = GetLangType();

    var code =
        "8B F9 " +
        "A1 " + LANGTYPE +
        "83 F8 12 ";

    offset = pe.find(code, korea_ref_offset - 0x50, korea_ref_offset);

    if (offset !== -1)
    {
        offset += code.hexlength();

        var diff = korea_ref_offset - offset - 2;

        pe.replaceHex(offset, "EB " + diff.packToHex(1));

        return true;
    }

    code =
        "8B F9 " +
        "A1 " + LANGTYPE +
        "83 F8 ?? " +
        "0F 87 ?? ?? ?? ?? " +
        "0F B6 80 ?? ?? ?? ?? " +
        "FF 24 85 ";

    var patchOffset = 2;
    var switch1Offset = 19;
    var switch2Offset = 26;

    offset = pe.find(code, korea_ref_offset - 0x100, korea_ref_offset);

    if (offset === -1)
    {
        code =
            "8B F9 " +
            "A1 " + LANGTYPE +
            "83 F8 ?? " +
            "0F 87 ?? ?? ?? ?? " +
            "FF 24 85 ";

        patchOffset = 2;
        switch1Offset = 0;
        switch2Offset = 19;

        offset = pe.find(code, korea_ref_offset - 0x60, korea_ref_offset);
    }

    if (offset === -1)
    {
        return "Failed in Step 3 - Pattern not found";
    }

    var addr2;
    var offset1;
    if (switch1Offset === 0)
    {
        addr2 = pe.vaToRaw(pe.fetchDWord(offset + switch2Offset));
        offset1 = 0;
    }
    else
    {
        var addr1 = pe.vaToRaw(pe.fetchDWord(offset + switch1Offset));
        addr2 = pe.vaToRaw(pe.fetchDWord(offset + switch2Offset));
        offset1 = pe.fetchUByte(addr1);
    }
    var jmpAddr = pe.fetchDWord(addr2 + 4 * offset1);

    code =
        "B8 " + jmpAddr.packToHex(4) +
        "FF E0 ";

    pe.replaceHex(offset + patchOffset, code);

    return true;
}

function AlwaysReadKrExtSettings_()
{
    var filePath = "Lua Files\\service_korea\\ExternalSettings_kr";

    if (IsZero())
    {
        filePath = "Lua Files\\service_korea\\zero_server\\ExternalSettings_kr";
    }

    return pe.stringRaw(filePath) !== -1;
}
