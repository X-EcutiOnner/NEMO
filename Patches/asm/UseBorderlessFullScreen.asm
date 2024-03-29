;
; Copyright (C) 2021  Andrei Karas (4144)
;
; Hercules is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation, either version 3 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with this program.  If not, see <http://www.gnu.org/licenses/>.

%include CreateWindowExA_params
%include win32_constants
%import GetSystemMetrics, user32.dll

cmp dword ptr [tmpVar], 0
jnz skip

inc dword ptr [tmpVar]

push SM_CXSCREEN
call dword ptr [GetSystemMetrics]
cmp dword ptr [esp + width], eax
jl skip
mov dword ptr [tmpVar], eax
push SM_CYSCREEN
call dword ptr [GetSystemMetrics]
cmp dword ptr [esp + height], eax
jl skip

mov dword ptr [esp + height], eax
mov dword ptr [esp + dwStyle], WS_POPUP + WS_VISIBLE
mov dword ptr [esp + x], 0
mov dword ptr [esp + y], 0
mov eax, dword ptr [tmpVar]
mov dword ptr [esp + width], eax

jmp skip

tmpVar:
long 0

skip:
