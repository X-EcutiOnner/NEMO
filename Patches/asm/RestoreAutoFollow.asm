; Copyright (C) 2021-2022 Andrei Karas (4144)
;
; Patch is licensed under a
; Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
;
; You should have received a copy of the license along with this
; work. If not, see <http://creativecommons.org/licenses/by-nc-nd/4.0/>.
;

%tablevar CGameMode_ProcessAutoFollow

call CGameMode_ProcessInput
mov ecx, {gameModeReg}
call CGameMode_ProcessAutoFollow
ret
