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

function AddCLSNPC()
{
    lua.replace("Lua Files\\DataInfo\\jobName_F", ["lua files\\cls\\jobname_f"]);
    if (pe.stringRaw("Lua Files\\DataInfo\\ShadowTable_F") !== -1 || table.get(table.packetVersion) > 20120800)
    {
        lua.replace("Lua Files\\DataInfo\\ShadowTable_F", ["lua files\\cls\\shadowtable_f"]);
    }

    lua.loadBefore("Lua Files\\DataInfo\\jobName", ["lua files\\cls\\jobname"]);
    lua.loadBefore("Lua Files\\DataInfo\\NPCIdentity", ["lua files\\cls\\npcidentity"]);
    if (pe.stringRaw("Lua Files\\DataInfo\\PetInfo") !== -1 || table.get(table.packetVersion) > 20101200)
    {
        lua.loadBefore("Lua Files\\DataInfo\\PetInfo", ["lua files\\cls\\petinfo"]);
    }
    if (pe.stringRaw("Lua Files\\DataInfo\\ShadowTable") !== -1 || table.get(table.packetVersion) > 20120700)
    {
        lua.loadBefore("Lua Files\\DataInfo\\ShadowTable", ["lua files\\cls\\shadowtable"]);
    }

    return true;
}

function AddCLSNPC_()
{
    return pe.stringRaw("Lua Files\\DataInfo\\jobName_F") !== -1 || table.get(table.packetVersion) > 20100200;
}
