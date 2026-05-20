%Copyright © 2018- Joonas Lahtinen, Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% zef_ind = find(strcmp(zef.GMM.parameters — Zef ind = find(strcmp(zef.GMM.parameters.
%
% Purpose:
%   Zef ind = find(strcmp(zef.GMM.parameters.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.GMM (read)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `zef_ind = find(strcmp(zef.GMM.parameters` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

%Update script for possibly hidden advanced plot options for GMM app.




zef_ind = find(strcmp(zef.GMM.parameters.Tags,'dip_num'));
if isempty(zef.GMM.parameters.Values{zef_ind})
    zef.GMM.parameters.Values{zef_ind} = zef.GMM.parameters.Values{1};
end

zef_ind = find(strcmp(zef.GMM.parameters.Tags,'ellip_num'));
if isempty(zef.GMM.parameters.Values{zef_ind})
    zef.GMM.parameters.Values{zef_ind} = zef.GMM.parameters.Values{1};
end

clear zef_ind
