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

function OpeningToServiceSelect()
{
    var code = " 68 D5 0B 00 00 E8";

    var offset = pe.findCode(code);
    if (offset === -1)
    {
        return "Failed in Step 1 - MsgString ID Missing";
    }

    code =
      " 0F B6 80 ?? ?? ?? ??" +
    " FF 24 85 ?? ?? ?? ??";
    offset = pe.find(code, offset - 0x300, offset);
    if (offset === -1)
    {
        return "Failed in Step 2 - Switch Table Missing";
    }

    var switchTable = pe.fetchDWord(offset + 3);

    var opOffset = switchTable + 100;

    pe.replaceByte(pe.vaToRaw(opOffset), 0);

    return true;
}

function OpeningToServiceSelect_()
{
    return pe.findCode(" 68 D5 0B 00 00 E8") !== -1;
}
