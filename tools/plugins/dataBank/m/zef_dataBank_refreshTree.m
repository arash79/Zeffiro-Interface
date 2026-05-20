function zef = zef_dataBank_refreshTree(zef)
% --- Zeffiro documentation header ---
% zef_dataBank_refreshTree — Zef data Bank refresh Tree.
%
% Purpose:
%   Zef data Bank refresh Tree.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.dataBank (read)
%
% Calls (project):
%   zef_dataBank_hash2tree
%   zef_dataBank_refreshTree
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_dataBank_refreshTree(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef');
end

zef.dataBank.app.Tree.Children.delete;
zef = zef_dataBank_hash2tree(zef);

if nargout == 0
    assignin('base','zef',zef);
end

end
