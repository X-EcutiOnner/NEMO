//
// Copyright (C) 2022-2023 Andrei Karas (4144)
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

function random_getRange(min, max)
{
    return parseInt(Math.random() * (max - min) + min);
}

function random_getRangeHex(min, max)
{
    return parseInt(Math.random() * (max - min) + min).toString(16);
}

function random_getDWord()
{
    return random_getRange(0, 0x7fffffff);
}

function random_getUDWord()
{
    return random_getRange(0, 0xffffffff);
}

function registerRandom()
{
    random = Object();

    random.getRange = random_getRange;
    random.getRangeHex = random_getRangeHex;
    random.getDWord = random_getDWord;
    random.getUDWord = random_getUDWord;
}
