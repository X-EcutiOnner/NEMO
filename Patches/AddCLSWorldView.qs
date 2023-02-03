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

function AddCLSWorldView()
{
    lua.replace("Lua Files\\worldviewdata\\worldviewdata_f", ["lua files\\cls\\worldviewdata_f"]);

    lua.loadBefore("Lua Files\\worldviewdata\\worldviewdata_Language", ["lua files\\cls\\worldviewdata_language"]);
    lua.loadBefore("Lua Files\\worldviewdata\\worldviewdata_list", ["lua files\\cls\\worldviewdata_list"]);
    lua.loadBefore("Lua Files\\worldviewdata\\worldviewdata_table", ["lua files\\cls\\worldviewdata_table"]);

    return true;
}

function AddCLSWorldView_()
{
    return pe.stringRaw("Lua Files\\worldviewdata\\worldviewdata_f") !== -1 || table.get(table.packetVersion) > 20140000;
}
