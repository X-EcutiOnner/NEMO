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

function input_createDialog()
{
    function InputControl(id, varName)
    {
        this.id = id;
        this.varName = varName;
    }

    InputControl.prototype.addControl = function(type, varName, title, def, min, max, other)
    {
        var id = input.addControl(this.id, type, varName, title, def, min, max, other);
        return new InputControl(id, varName);
    }

    InputControl.prototype.addLayout = function(type, varName, title, def, min, max, other)
    {
        var id = input.addControl(this.id, type, varName, title, def, min, max, other);
        return new InputLayout(id, varName);
    }

    function InputLayout(id, varName)
    {
        InputControl.call(this, id, varName);
    }

    InputLayout.prototype = Object.create(InputControl.prototype);
    InputLayout.prototype.constructor = InputLayout;

    InputLayout.prototype.addTextBox = function(varName, def, max, step)
    {
        return this.addControl(Control.TextBox, varName, "", def, 0, max, step);
    }

    InputLayout.prototype.addCheckBox = function(varName, title, def)
    {
        return this.addControl(Control.CheckBox, varName, title, def);
    }

    InputLayout.prototype.addHBox = function()
    {
        return this.addLayout(Control.HBox, "");
    }

    InputLayout.prototype.addVBox = function()
    {
        return this.addLayout(Control.VBox, "");
    }

    InputLayout.prototype.addLabel = function(title)
    {
        return this.addControl(Control.Label, "", title);
    }

    InputLayout.prototype.addButtonOk = function(varName)
    {
        return this.addControl(Control.ButtonOk);
    }

    InputLayout.prototype.addButtonCancel = function(varName)
    {
        return this.addControl(Control.ButtonCancel);
    }

    InputLayout.prototype.addOkCancel = function(varName)
    {
        var box = this.addHBox();
        box.addButtonOk();
        box.addButtonCancel();
        return box;
    }

    InputLayout.prototype.addLabelText = function(varName, label, def, max, mask)
    {
        var box = this.addVBox();
        box.addLabel(label);
        box.addTextBox(varName, def, max, mask);
        return box;
    }

    function InputDialog()
    {
        InputControl.call(this, 0, "");
    }

    InputDialog.prototype = Object.create(InputLayout.prototype);
    InputDialog.prototype.constructor = InputDialog;

    InputDialog.prototype.show = function()
    {
        return input.show();
    }

    InputDialog.prototype.setTitle = function(title)
    {
        return input.setWindowTitle(title);
    }

    InputDialog.prototype.setMinimumSize = function(dx, dy)
    {
        return input.setMinimumSize(dx, dy);
    }

    InputDialog.prototype.setMaximumSize = function(dx, dy)
    {
        return input.setMaximumSize(dx, dy);
    }

    input.newDialog();
    return new InputDialog();
}

function registerControls()
{
    input.createDialog = input_createDialog;
}
