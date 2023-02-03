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

function AddCLSHeadgear()
{
    lua.replace("Lua Files\\DataInfo\\accName_F", ["lua files\\cls\\accname_f"]);

    lua.loadBefore("Lua Files\\DataInfo\\accName", ["lua files\\cls\\accname"]);
    lua.loadBefore("Lua Files\\DataInfo\\AccessoryId", ["lua files\\cls\\accessoryid"]);
    if (pe.stringRaw("Lua Files\\DataInfo\\TB_Layer_Priority") !== -1 || table.get(table.packetVersion) > 20180000)
    {
        lua.loadBefore("Lua Files\\DataInfo\\TB_Layer_Priority", ["lua files\\cls\\tb_layer_priority"]);
    }

    return true;
}

function AddCLSHeadgear_()
{
    return pe.stringRaw("Lua Files\\DataInfo\\accName_F") !== -1 || table.get(table.packetVersion) > 20100303;
}
