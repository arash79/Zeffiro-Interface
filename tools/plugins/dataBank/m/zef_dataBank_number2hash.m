function [hash]=zef_dataBank_number2hash(number)
% --- Zeffiro documentation header ---
% zef_dataBank_number2hash — Zef data Bank number2hash.
%
% Purpose:
%   Zef data Bank number2hash.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   number
%
% Outputs:
%   hash
%
% Calls (project):
%   zef_dataBank_number2hash
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[hash] = zef_dataBank_number2hash(number)` with project root and `src` on the path.
% --- End Zeffiro documentation header

hash='node';
for i=1:length(number)
    if ~isnan(number(i)) && ~number(i)==0
        hash=strcat(hash, '_', num2str(number(i)));
    end
end

end
