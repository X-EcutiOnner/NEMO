//
// Copyright (C) 2020-2023 Andrei Karas (4144)
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

function ChangeSecondCharCreateJob()
{
    var code =
        "8B 83 ?? ?? ?? 00 " +
        "83 E8 00 " +
        "74 1B " +
        "48 " +
        "75 21 " +
        "B8 7A 10 00 00 " +
        "8B CB " +
        "66 89 83 ?? ?? ?? 00 " +
        "E8 ?? ?? ?? ?? " +
        "E9 ?? ?? ?? ?? " +
        "33 C0 " +
        "66 89 83 ?? ?? ?? 00 " +
        "8B CB " +
        "E8 ?? ?? ?? ?? " +
        "E9 ";
    var doramJobOffset = 15;

    var offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            "8B 86 ?? ?? ?? 00 " +
            "83 E8 00 " +
            "74 1D " +
            "83 E8 01 " +
            "75 21 " +
            "B8 7A 10 00 00 " +
            "8B CE " +
            "66 89 86 ?? ?? ?? 00 " +
            "E8 ?? ?? ?? ?? " +
            "E9 ?? ?? ?? ?? " +
            "33 C0 " +
            "66 89 86 ?? ?? ?? 00 " +
            "8B CE " +
            "E8 ?? ?? ?? ?? " +
            "E9 ";

        doramJobOffset = 17;

        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in step 1 - pattern not found";
    }

    doramJobOffset = offset + doramJobOffset;

    code =
        "33 DB " +
        "83 BF ?? ?? ?? 00 01 " +
        "B8 7A 10 00 00 " +
        "0F 44 D8 " +
        "33 C0 " +
        "38 87 ?? ?? ?? 00 " +
        "89 9D ?? ?? ?? FF " +
        "0F 95 C0 ";
    var doramIconJobOffset = 10;

    offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            "33 C0 " +
            "BE 7A 10 00 00 " +
            "83 BF ?? ?? ?? 00 01 " +
            "0F 45 F0 " +
            "38 87 ?? ?? ?? 00 " +
            "89 B5 ?? ?? ?? FF " +
            "0F 95 C0 ";

        doramIconJobOffset = 3;

        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "Failed in step 2 - pattern not found";
    }

    doramIconJobOffset = offset + doramIconJobOffset;

    offset = pe.stringVa("\xC0\xAF\xC0\xFA\xC0\xCE\xC5\xCD\xC6\xE4\xC0\xCC\xBD\xBA\x5C\x6D" +
        "\x61\x6B\x65\x5F\x63\x68\x61\x72\x61\x63\x74\x65\x72\x5F\x76\x65" +
        "\x72\x32\x5C\x69\x6D\x67\x5F\x68\x61\x69\x72\x53\x74\x79\x6C\x65" +
        "\x5F\x64\x6F\x72\x61\x6D\x47\x69\x72\x6C\x25\x30\x32\x64\x2E\x62" +
        "\x6D\x70");
    if (offset === -1)
    {
        return "doram girl string not found";
    }
    var girlHex = offset.packToHex(4);

    code =
        "83 F8 01 " +
        "75 ?? " +
        "83 BE ?? ?? ?? 00 05 " +
        "8B 8E ?? ?? ?? 00 " +
        "7F ?? " +
        "8B 01 " +
        "6A 01 " +
        "FF 90 ?? ?? 00 00 " +
        "8B 86 ?? ?? ?? 00 " +
        "40 " +
        "83 BE ?? ?? ?? 00 00 " +
        "50 " +
        "8D 85 ?? ?? ?? FF " +
        "75 07 " +
        "68 " + girlHex +
        "EB ";
    var hairLimitOffset = 11;

    offset = pe.findCode(code);

    if (offset === -1)
    {
        code =
            "83 F8 01 " +
            "75 ?? " +
            "83 BE ?? ?? ?? 00 05 " +
            "8B 8E ?? ?? ?? 00 " +
            "7F ?? " +
            "8B 01 " +
            "6A 01 " +
            "FF 90 ?? ?? 00 00 " +
            "8B 86 ?? ?? ?? 00 " +
            "40 " +
            "83 BE ?? ?? ?? 00 00 " +
            "50 " +
            "75 ?? " +
            "68 " + girlHex +
            "EB ";

        hairLimitOffset = 11;

        offset = pe.findCode(code);
    }

    if (offset === -1)
    {
        return "doram hair images limit not found";
    }

    hairLimitOffset = offset + hairLimitOffset;

    var newJob = exe.getUserInput("$secondJob", XTYPE_DWORD, _("Number Input"), _("Enter second job for char creation (character):"), 0x107A);
    if (newJob === 0x107A)
    {
        return "New job is same with old. Patch cancelled";
    }

    var newIconJob = exe.getUserInput("$secondIconJob", XTYPE_DWORD, _("Number Input"), _("Enter second job for char creation (icon):"), newJob);
    if (newIconJob === 0x107A)
    {
        return "New job is same with old. Patch cancelled";
    }

    var newHairLimit = exe.getUserInput("$secondJobHairLimit", XTYPE_DWORD, _("Number Input"), _("Enter second job images hair limit:"), 6, 1, 30);
    if (newHairLimit === 6)
    {
        return "New hair limit is same with old. Patch cancelled";
    }

    pe.replaceDWord(doramJobOffset, newJob);
    pe.replaceDWord(doramIconJobOffset, newIconJob);

    pe.replaceByte(hairLimitOffset, newHairLimit - 1);

    return true;
}

function ChangeSecondCharCreateJob_()
{
    return pe.getDate() > 20170614;
}
