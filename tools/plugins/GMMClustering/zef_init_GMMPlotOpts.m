% --- Zeffiro documentation header ---
% if ~isfield(zef,'GMM_comp_ord') — If ~isfield(zef,'GMM comp ord').
%
% Purpose:
%   If ~isfield(zef,'GMM comp ord').
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.GMM_colors (read, write)
%   zef.GMM_comp_ord (read, write)
%   zef.GMM_dip_comp (read, write)
%   zef.GMM_dip_num (read, write)
%   zef.GMM_ellip_coloring (read, write)
%   zef.GMM_ellip_comp (read, write)
%   zef.GMM_ellip_num (read, write)
%   zef.GMModel (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if ~isfield(zef,'GMM_comp_ord')` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

if ~isfield(zef,'GMM_comp_ord')
    zef.GMM_comp_ord = 1;
end
if ~isfield(zef,'GMM_dip_comp')
    zef.GMM_dip_comp = [];
end
if ~isfield(zef,'GMM_ellip_comp')
    zef.GMM_ellip_comp = [];
end
if ~isfield(zef,'GMM_dip_num')
    if isfield(zef,'GMModel')
        if iscell(zef.GMModel)
            zef.GMM_dip_num = zef.GMModel{find(~cellfun(@isempty,zef.GMModel),1)}.NumComponents;
        else
            zef.GMM_dip_num = zef.GMModel.NumComponents;
        end
    else
        zef.GMM_dip_num = [];
    end
end
if ~isfield(zef,'GMM_ellip_num')
    if isfield(zef,'GMModel')
        if iscell(zef.GMModel)
            zef.GMM_ellip_num = zef.GMModel{find(~cellfun(@isempty,zef.GMModel),1)}.NumComponents;
        else
            zef.GMM_ellip_num = zef.GMModel.NumComponents;
        end
    else
        zef.GMM_ellip_num = [];
    end
end
if ~isfield(zef,'GMM_ellip_coloring')
    zef.GMM_ellip_coloring = 1;
end
if ~isfield(zef,'GMM_colors')
    zef.GMM_colors = [];
end
