//
// This file is part of NEMO (Neo Exe Modification Organizer).
// http://nemo.herc.ws - http://gitlab.com/4144/Nemo
//
// Copyright (C) 2023 Jittapan (Secret)
// Copyright (C) 2023 Andrei Karas (4144)
//
// Hercules is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
//

function RemoveTraitStatusButton()
{
    var offset = table.getRawValidated(table.trait_button_add_patch) - 1;
    var free = pe.insertHex(asm.retHex(4));
    pe.setJmpRaw(offset, free, "call", 5);

    return true;
}

function RemoveTraitStatusButton_()
{
    return pe.halfStringRaw("\\statuswnd\\expand_on_normal.bmp") !== -1;
}
