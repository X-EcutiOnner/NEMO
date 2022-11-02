//
// Copyright (C) 2020  CH.C
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

function RestoreSongsEffect()
{
    var code =
        " E8 ?? ?? ?? ??" +
        " 83 C0 82" +
        " 3D ?? 00 00 00" +
        " 0F 87 ?? ?? ?? ??" +
        " 0F B6 80 ?? ?? ?? ??" +
        " FF 24 85 ?? ?? ?? ??";

    var switch1Offset = 22;

    var offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 1 - CSkill::OnProcess not found";
    }

    var iswTable = pe.fetchDWord(offset + switch1Offset);

    code =
        " 83 BE ?? ?? 00 00 00" +
        " 0F 85 ?? ?? ?? ??" +
        " 83 EC 10" +
        " 8B CC" +
        " C7 44 24 ?? 00 00 00 00" +
        " 68 F2 00 00 00" +
        " E9";
    var patchOffset = 26;

    offset = pe.findCode(code);
    if (offset === -1)
    {
        code =
            " 8B 8E ?? ?? 00 00" +
            " 85 C9" +
            " 0F 85 ?? ?? ?? ??" +
            " 83 EC 10" +
            " 89 4C 24 ??" +
            " 8B CC" +
            " 68 F2 00 00 00" +
            " E9";
        patchOffset = 23;
        offset = pe.findCode(code);
    }
    if (offset === -1)
    {
        code =
            " 8B 8E ?? ?? 00 00" +
            " 85 C9" +
            " 0F 85 ?? ?? ?? ??" +
            " 83 EC 10" +
            " 89 4D ??" +
            " 8B 45 ??" +
            " 89 4C 24 ??" +
            " 8B CC" +
            " 68 F2 00 00 00" +
            " E9";
        patchOffset = 29;
        offset = pe.findCode(code);
    }
    if (offset === -1)
    {
        return "Failed in Step 2 - Borrow code not found";
    }

    var patchAddr = offset + patchOffset;
    var retAddr = pe.rawToVa(patchAddr + 5).packToHex(4);

    var sidOffset = table.getValidated(table.CGameActor_m_job).packToHex(4);

    var effectID = [242, 278, 279, 280, 281, 282, 283, 284, 285, 277, 286, 287, 288, 289, 290, 291, 292, 293, 294];

    var ins =
        " 50" +
        " 8B 86" + sidOffset +
        " 2D 9D 00 00 00" +
        " FF 24 85 XX XX XX XX";

    var case1Offset = ins.hexlength();
    var size = case1Offset + (effectID.length * 16);
    var free = alloc.find(size + 4);
    if (free === -1)
    {
        return "Failed in Step 4 - No enough free space";
    }

    var freeRva = pe.rawToVa(free);
    var swTable = free + case1Offset + (effectID.length * 12);
    ins = ins.replace(" XX XX XX XX", pe.rawToVa(swTable).packToHex(4));

    var i;
    for (i = 0; i < effectID.length; i++)
    {
        code =
            " 58" +
            " 68" + effectID[i].packToHex(4) +
            " 68" + retAddr +
            " C3";

        ins += code;
    }

    for (i = 0; i < effectID.length; i++)
    {
        var swAddr = free + case1Offset + (i * 12);
        ins += pe.rawToVa(swAddr).packToHex(4);
    }

    code = " E9" + (freeRva - pe.rawToVa(patchAddr + 5)).packToHex(4);

    pe.insertHexAt(free, size, ins);
    pe.replaceHex(patchAddr, code);

    var firstUnitID = 126;
    var LPUnirID = 157;
    var firstSongUnitID = 158;
    var LPtblOffset = pe.fetchHex(pe.vaToRaw(iswTable + (LPUnirID - firstUnitID)), 1);

    code = LPtblOffset.repeat(effectID.length - 1);

    pe.replaceHex(pe.vaToRaw(iswTable + (firstSongUnitID - firstUnitID)), code);

    return true;
}
