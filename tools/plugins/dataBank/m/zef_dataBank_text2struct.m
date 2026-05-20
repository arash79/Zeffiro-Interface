function [struct_out] = zef_dataBank_text2struct(text)
% --- Zeffiro documentation header ---
% zef_dataBank_text2struct — Zef data Bank text2struct.
%
% Purpose:
%   Zef data Bank text2struct.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   text
%
% Outputs:
%   struct_out
%
% Calls (project):
%   zef_dataBank_text2struct
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[struct_out] = zef_dataBank_text2struct(text)` with project root and `src` on the path.
% --- End Zeffiro documentation header


struct_out=[];
for i=1:length(text)
    struct_out.(text{i})=[];
end

end
