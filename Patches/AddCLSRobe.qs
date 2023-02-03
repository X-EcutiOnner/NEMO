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

function AddCLSRobe()
{
    lua.replace("Lua Files\\DataInfo\\SpriteRobeName_F", ["lua files\\cls\\spriterobename_f"]);
    if (pe.stringRaw("Lua Files\\transparentItem\\transparentItem_f") !== -1 || table.get(table.packetVersion) > 20171000)
    {
        lua.replace("Lua Files\\transparentItem\\transparentItem_f", ["lua files\\cls\\transparentitem_f"]);
    }

    lua.loadBefore("Lua Files\\DataInfo\\SpriteRobeId", ["lua files\\cls\\spriterobeid"]);
    lua.loadBefore("Lua Files\\DataInfo\\SpriteRobeName", ["lua files\\cls\\spriterobename"]);
    if (pe.stringRaw("Lua Files\\transparentItem\\transparentItem") !== -1 || table.get(table.packetVersion) > 20171000)
    {
        lua.loadBefore("Lua Files\\transparentItem\\transparentItem", ["lua files\\cls\\transparentitem"]);
    }

    return true;
}

function AddCLSRobe_()
{
    return pe.stringRaw("Lua Files\\DataInfo\\SpriteRobeName_F") !== -1 || table.get(table.packetVersion) > 20110200;
}
