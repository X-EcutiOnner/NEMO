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

function ValidateClientType()
{
    var hook = hooks.initTableEndHook(table.InitClientInfo_ret);
    var message;
    if (IsSakray())
    {
        message = "Using wrong servertype in clientinfo/sclientinfo xml. Please change servertype to correct sakray: <servertype>sakray</servertype>";
    }
    else
    {
        message = "Using wrong servertype in clientinfo/sclientinfo xml. Please change servertype to correct primary: <servertype>primary</servertype>";
    }
    var errorBuf = pe.rawToVa(pe.insertString(message));
    var vars = {
        "sakray": IsSakray(),
        "error": errorBuf,
        "serverType": GetServerType(),
    };
    hook.addFilePost("", vars);
    hook.validate();

    return true;
}
