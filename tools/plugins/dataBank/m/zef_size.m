function [size1, size2] = zef_size(data, field)
% --- Zeffiro documentation header ---
% zef_size — Zef size.
%
% Purpose:
%   Zef size.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   data
%   field
%
% Outputs:
%   size1
%   size2
%
% Calls (project):
%   zef_size
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[[size1, size2]] = zef_size(data, field)` with project root and `src` on the path.
% --- End Zeffiro documentation header

if isobject(data)
    sizeOfField=size(data, field);
else
    sizeOfField=size(data.(field));
end

size1=sizeOfField(1);
size2=sizeOfField(2);

end
