//
// Copyright (C) 2018-2023 Andrei Karas (4144)
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

function FixAchievementCounters()
{
    var countersStr = pe.stringVa("%d/%d");

    if (countersStr === -1)
    {
        return "Failed in Step 1 - '%d/%d' string missing";
    }

    var code =
        "8B 57 ?? " +
        "8B 42 04 " +
        "8B 48 ?? " +
        "8B 02 " +
        "51 " +
        "FF 70 ?? " +
        "8D 45 ?? " +
        "68 " + countersStr.packToHex(4) +
        "50 " +
        "E8 ";
    var type1Offset = 5;
    var offset = pe.findCode(code);
    var addr1;

    if (offset === -1)
    {
        if (pe.getDate() < 20170000)
        {
            return "Failed in step 2 - pattern not found";
        }

        addr1 = false;
    }
    else
    {
        addr1 = offset + type1Offset;
    }

    code =
        "8B 57 ?? " +
        "8B 42 04 " +
        "8B 48 ?? " +
        "8B 42 ?? " +
        "51 " +
        "FF 70 ?? " +
        "8D 45 ?? " +
        "68 " + countersStr.packToHex(4) +
        "50 " +
        "E8 ";

    type1Offset = 5;
    var type2Offset = 11;
    var offsets = pe.findCodes(code);

    if (offsets.length === 0)
    {
        return "Failed in step 3 - pattern not found";
    }
    if (offsets.length !== 5)
    {
        return "Failed in step 3 - found wrong number of patterns: " + offsets.length;
    }

    if (addr1 !== false)
    {
        if (addr1 > offsets[0] || addr1 + 0x200 < offsets[0])
        {
            return "Failed in step 3 - found wrong offsets";
        }
    }

    var msgOffsets = [];
    var msgIds = [];
    var type1Offsets = [];
    var type2Offsets = [];

    var msgOffset = 1;

    for (var i = 0; i < offsets.length; i++)
    {
        code =
            "68 ?? ?? 00 00 " +
            "C7 45 ?? 0F 00 00 00 " +
            "C7 45 ?? 00 00 00 00 " +
            "C6 45 ?? 00 " +
            "E8 ?? ?? ?? ?? " +
            "83 C4 04 " +
            "8B CF " +
            "50 ";
        offset = pe.find(code, offsets[i] - 0x40, offsets[i]);
        if (offset === -1)
        {
            return "Failed in step 4: pattern not found, offset " + i;
        }
        msgOffsets[i] = offset;
        msgIds[i] = pe.fetchDWord(msgOffsets[i] + msgOffset);
        type1Offsets[i] = pe.fetchUByte(offsets[i] + type1Offset);
        type2Offsets[i] = pe.fetchUByte(offsets[i] + type2Offset);
    }

    if (addr1 !== false)
    {
        pe.replaceByte(addr1, 0);
    }

    pe.replaceHex(offsets[0] + type1Offset, type2Offsets[1].packToHex(1));
    pe.replaceHex(offsets[0] + type2Offset, type2Offsets[1].packToHex(1));
    pe.replaceHex(msgOffsets[0] + msgOffset, msgIds[1].packToHex(4));

    pe.replaceHex(offsets[1] + type1Offset, type2Offsets[3].packToHex(1));
    pe.replaceHex(offsets[1] + type2Offset, type2Offsets[3].packToHex(1));
    pe.replaceHex(msgOffsets[1] + msgOffset, msgIds[3].packToHex(4));

    pe.replaceHex(offsets[2] + type1Offset, type2Offsets[0].packToHex(1));
    pe.replaceHex(offsets[2] + type2Offset, type2Offsets[0].packToHex(1));
    pe.replaceHex(msgOffsets[2] + msgOffset, msgIds[0].packToHex(4));

    pe.replaceHex(offsets[3] + type1Offset, type2Offsets[2].packToHex(1));
    pe.replaceHex(offsets[3] + type2Offset, type2Offsets[2].packToHex(1));
    pe.replaceHex(msgOffsets[3] + msgOffset, msgIds[2].packToHex(4));

    pe.replaceHex(offsets[4] + type1Offset, type2Offsets[4].packToHex(1));

    return true;
}
