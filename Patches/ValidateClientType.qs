//
// Copyright (C) 2022  Andrei Karas (4144)
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

    var errorText = exe.getUserInput(
        "$ValidateClientType_error", XTYPE_STRING,
        _("String input"),
        _("Enter error message for wrong servertype configured"),
        "Using wrong servertype in clientinfo/sclientinfo xml. Please change servertype to correct one."
    );

    var errorBuf = pe.rawToVa(pe.insertString(errorText));

    var vars = {
        "sakray": IsSakray(),
        "error": errorBuf,
        "serverType": GetServerType(),
    };
    hook.addFilePost("", vars);
    hook.validate();

    return true;
}
