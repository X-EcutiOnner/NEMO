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

function input_createDialog()
{
    function InputControl(id, varName)
    {
        this.id = id;
        this.varName = varName;
    }

    function InputLayout(id, varName)
    {
        InputControl.call(this, id, varName);
    }

    InputControl.prototype.addControl = function addControl(type, varName, title, def, min, max, other)
    {
        var id = input.addControl(this.id, type, varName, title, def, min, max, other);
        return new InputControl(id, varName);
    };

    InputControl.prototype.addLayout = function addLayout(type, varName, title, def, min, max, other)
    {
        var id = input.addControl(this.id, type, varName, title, def, min, max, other);
        return new InputLayout(id, varName);
    };

    InputLayout.prototype = Object.create(InputControl.prototype);
    InputLayout.prototype.constructor = InputLayout;

    InputLayout.prototype.addTextBox = function addTextBox(varName, def, max, step)
    {
        return this.addControl(Control.TextBox, varName, "", def, 0, max, step);
    };

    InputLayout.prototype.addCheckBox = function addCheckBox(varName, title, def)
    {
        return this.addControl(Control.CheckBox, varName, title, def);
    };

    InputLayout.prototype.addInt = function addInt(varName, def, min, max, step)
    {
        return this.addControl(Control.IntSpinBox, varName, "", def, min, max, step);
    };

    InputLayout.prototype.addColorPicker = function addColorPicker(varName, def)
    {
        return this.addControl(Control.ColorPicker, varName, "", def, 0, 0, 0);
    };

    InputLayout.prototype.addHBox = function addHBox()
    {
        return this.addLayout(Control.HBox, "");
    };

    InputLayout.prototype.addVBox = function addVBox()
    {
        return this.addLayout(Control.VBox, "");
    };

    InputLayout.prototype.addLabel = function addLabel(title)
    {
        return this.addControl(Control.Label, "", title);
    };

    InputLayout.prototype.addButtonOk = function addButtonOk(varName)
    {
        return this.addControl(Control.ButtonOk);
    };

    InputLayout.prototype.addButtonCancel = function addButtonCancel(varName)
    {
        return this.addControl(Control.ButtonCancel);
    };

    InputLayout.prototype.addOkCancel = function addOkCancel(varName)
    {
        var box = this.addHBox();
        box.addButtonOk();
        box.addButtonCancel();
        return box;
    };

    InputLayout.prototype.addLabelText = function addLabelText(varName, label, def, max, mask)
    {
        var box = this.addVBox();
        box.addLabel(label);
        box.addTextBox(varName, def, max, mask);
        return box;
    };

    InputLayout.prototype.addShortLabelText = function addShortLabelText(varName, label, def, max, mask)
    {
        var box = this.addHBox();
        box.addLabel(label);
        box.addTextBox(varName, def, max, mask);
        return box;
    };

    InputLayout.prototype.addLabelInt = function addLabelInt(varName, label, def, min, max, step)
    {
        var box = this.addVBox();
        box.addLabel(label);
        box.addInt(varName, def, min, max, step);
        return box;
    };

    InputLayout.prototype.addShortLabelInt = function addShortLabelInt(varName, label, def, min, max, step)
    {
        var box = this.addHBox();
        box.addLabel(label);
        box.addInt(varName, def, min, max, step);
        return box;
    };

    InputLayout.prototype.addShortLabelInt2 = function addShortLabelInt2(varName, label, def1, def2, min, max, step)
    {
        var box = this.addHBox();
        box.addLabel(label);
        box.addInt(varName + "_1", def1, min, max, step);
        box.addInt(varName + "_2", def2, min, max, step);
        return box;
    };

    InputLayout.prototype.addLabelColorPicker = function addLabelColorPicker(varName, label, def)
    {
        var box = this.addVBox();
        box.addLabel(label);
        box.addColorPicker(varName, def);
        return box;
    };

    function InputDialog()
    {
        InputControl.call(this, 0, "");
    }

    InputDialog.prototype = Object.create(InputLayout.prototype);
    InputDialog.prototype.constructor = InputDialog;

    InputDialog.prototype.show = function show()
    {
        return input.show();
    };

    InputDialog.prototype.setTitle = function setTitle(title)
    {
        return input.setWindowTitle(title);
    };

    InputDialog.prototype.setMinimumSize = function setMinimumSize(dx, dy)
    {
        return input.setMinimumSize(dx, dy);
    };

    InputDialog.prototype.setMaximumSize = function setMaximumSize(dx, dy)
    {
        return input.setMaximumSize(dx, dy);
    };

    input.newDialog();
    return new InputDialog();
}

function registerControls()
{
    input.createDialog = input_createDialog;
}
