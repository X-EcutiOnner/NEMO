//
// Copyright (C) 2020-2023 Andrei Karas (4144)
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

function storage_set(varName, value)
{
    storage[varName] = value;
}

function storage_get(varName)
{
    return storage[varName];
}

function storage_getZero()
{
    return storage.zero;
}

function storage_setZero(value)
{
    storage.zero = value;
}

function storage_adjustZero(value)
{
    storage.zero += value;
}

function storage_init()
{
    for (var key in storage)
    {
        if (storage.hasOwnProperty(key))
        {
            delete storage[key];
        }
    }

    storage.hooks = {};
    storage.zero = 0;
    storage.multiHooks = {};
}

function registerStorage()
{
    storage_init();

    storage.set = storage_set;
    storage.get = storage_get;
    storage.getZero = storage_getZero;
    storage.setZero = storage_setZero;
    storage.adjustZero = storage_adjustZero;
}
