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

function MsgStringTable_patch()
{
    var offset = table.getRawValidated(table.initMsgStrings_jmp);

    var code =
        "75 ?? ";
    var addrOffset = [1, 1];

    var found = pe.match(code, offset);
    if (found !== true)
    {
        throw "Error: jmp not matched";
    }

    var addr = pe.fetchRelativeValue(offset, addrOffset);

    var vars = {
        "addr": addr,
    };

    pe.replaceAsmFile(offset, "", vars, 2);
}

function ReadMsgstringtabledottxt()
{
    MsgStringTable_patch();
    return true;
}
