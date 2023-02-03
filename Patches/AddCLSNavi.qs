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

function AddCLSNavi()
{
    if (IsSakray())
    {
        lua.loadBefore("Lua Files\\Navigation\\Navi_Map_krSak", ["lua files\\cls\\navi_map"]);
        if (pe.stringRaw("Lua Files\\Navigation\\Navi_Npc_krSak") !== -1 || table.get(table.packetVersion) > 20190400)
        {
            lua.loadBefore("Lua Files\\Navigation\\Navi_Npc_krSak", ["lua files\\cls\\navi_npc"]);
        }
        lua.loadBefore("Lua Files\\Navigation\\Navi_Mob_krSak", ["lua files\\cls\\navi_mob"]);
        lua.loadBefore("Lua Files\\Navigation\\Navi_Link_krSak", ["lua files\\cls\\navi_link"]);
        lua.loadBefore("Lua Files\\Navigation\\Navi_LinkDistance_krSak", ["lua files\\cls\\navi_linkdistance"]);
        lua.loadBefore("Lua Files\\Navigation\\Navi_NpcDistance_krSak", ["lua files\\cls\\navi_npcdistance"]);
        if (pe.stringRaw("Lua Files\\Navigation\\navi_picknpc_krSak") !== -1 || table.get(table.packetVersion) > 20190400)
        {
            lua.loadBefore("Lua Files\\Navigation\\navi_picknpc_krSak", ["lua files\\cls\\navi_picknpc"]);
        }
        lua.loadBefore("Lua Files\\Navigation\\Navi_Scroll_krSak", ["lua files\\cls\\navi_scroll"]);
    }
    else
    {
        lua.loadBefore("Lua Files\\Navigation\\Navi_Map_krpri", ["lua files\\cls\\navi_map"]);
        if (pe.stringRaw("Lua Files\\Navigation\\Navi_Npc_krpri") !== -1 || table.get(table.packetVersion) > 20190400)
        {
            lua.loadBefore("Lua Files\\Navigation\\Navi_Npc_krpri", ["lua files\\cls\\navi_npc"]);
        }
        lua.loadBefore("Lua Files\\Navigation\\Navi_Mob_krpri", ["lua files\\cls\\navi_mob"]);
        lua.loadBefore("Lua Files\\Navigation\\Navi_Link_krpri", ["lua files\\cls\\navi_link"]);
        lua.loadBefore("Lua Files\\Navigation\\Navi_LinkDistance_krpri", ["lua files\\cls\\navi_linkdistance"]);
        lua.loadBefore("Lua Files\\Navigation\\Navi_NpcDistance_krpri", ["lua files\\cls\\navi_npcdistance"]);
        if (pe.stringRaw("Lua Files\\Navigation\\navi_picknpc_krpri") !== -1 || table.get(table.packetVersion) > 20190400)
        {
            lua.loadBefore("Lua Files\\Navigation\\navi_picknpc_krpri", ["lua files\\cls\\navi_picknpc"]);
        }
        lua.loadBefore("Lua Files\\Navigation\\Navi_Scroll_krpri", ["lua files\\cls\\navi_scroll"]);
    }

    return true;
}

function AddCLSNavi_()
{
    if (table.get(table.packetVersion) > 20180404)
    {
        return true;
    }
    if (IsSakray())
    {
        return pe.stringRaw("Lua Files\\Navigation\\Navi_Map_krSak") !== -1;
    }

    return pe.stringRaw("Lua Files\\Navigation\\Navi_Map_krpri") !== -1;
}
