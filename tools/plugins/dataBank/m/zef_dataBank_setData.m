function zef = zef_dataBank_setData(zef)
% --- Zeffiro documentation header ---
% zef_dataBank_setData — Zef data Bank set Data.
%
% Purpose:
%   Zef data Bank set Data.
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
%   zef_dataBank_setData
%   zef_load_GMM
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_dataBank_setData(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


if nargin == 0
    zef = evalin('base','zef')
end

dbFieldNames=fieldnames(zef.dataBank.tree.(zef.dataBank.hash).data);

for dbi=1:length(dbFieldNames)
    if strcmp(zef.dataBank.tree.(zef.dataBank.hash).type, 'gmm')

        zef_load_GMM(zef.dataBank.tree.(zef.dataBank.hash).data);
        zef_GMM_update;

    else

        if ~(startsWith(dbFieldNames{dbi}, 'Properties')||startsWith(dbFieldNames{dbi}, 'type')) %prevents the copy of the properties if the data is an matObject
            zef.(dbFieldNames{dbi})=zef.dataBank.tree.(zef.dataBank.hash).data.(dbFieldNames{dbi});
        end

    end

end

if zef.dataBank.loadParents

    zef.dataBank.hash=reverse(zef.dataBank.hash);
    zef.dataBank.hash=extractAfter(zef.dataBank.hash, '_');
    zef.dataBank.hash=reverse(zef.dataBank.hash);

    if ~strcmp(zef.dataBank.hash, 'node')
        zef_dataBank_setData;
    end

end

if nargout == 0
    assignin('base','zef',zef);
end

end
