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

function AddCLSQuest()
{
    lua.replace("Lua Files\\DataInfo\\QuestInfo_f", ["lua files\\cls\\questinfo_f"]);

    return true;
}

function AddCLSQuest_()
{
    return pe.stringRaw("Lua Files\\DataInfo\\QuestInfo_f") !== -1 || table.get(table.packetVersion) > 20180400;
}
