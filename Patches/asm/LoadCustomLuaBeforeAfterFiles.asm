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

push ecx
%insasm asmCopyArgs
push esi
push edi
mov esi, dword ptr [esp + 0x8]
mov edi, buffer
call simple_strcpy
mov esi, str_before
call simple_strcpy
mov dword ptr [esp + 0x8], buffer
pop edi
pop esi
push _normal_label
%inshex stolenCode
jmp continueItemAddr

_normal_label:
pop ecx
push ecx
%insasm asmCopyArgs
push _after_label
%inshex stolenCode
jmp continueItemAddr

_after_label:
pop ecx
push eax
%insasm asmCopyArgs
push esi
push edi
mov esi, dword ptr [esp + 0x8]
mov edi, buffer
call simple_strcpy
mov esi, str_after
call simple_strcpy
mov dword ptr [esp + 0x8], buffer
pop edi
pop esi
push _exit_label
%inshex stolenCode
jmp continueItemAddr

_exit_label:
pop eax
ret argsOffset

%include simple_strcpy

str_before:
asciz "_before"
str_after:
asciz "_after"
