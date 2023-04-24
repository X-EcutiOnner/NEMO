; Copyright (C) 2021-2023 Andrei Karas (4144)
;
; Patch is licensed under a
; Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
;
; You should have received a copy of the license along with this
; work. If not, see <http://creativecommons.org/licenses/by-nc-nd/4.0/>.
;

push ecx

call _label_call
_label_call:
pop ecx
add ecx, _label_ret - _label_call

%insasm pushes
push ecx
mov ecx, dword ptr [esp + retOffset]

%inshex stolenCode
push func
ret

_label_ret:
%insasm addesp
pop ecx
