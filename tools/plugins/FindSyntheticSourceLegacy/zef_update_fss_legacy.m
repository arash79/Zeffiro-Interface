%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
function zef = zef_update_fss_legacy(zef)
% --- Zeffiro documentation header ---
% zef_update_fss_legacy — Syncs GUI control values into `zef` for fss_legacy.
%
% Purpose:
%   Syncs GUI control values into `zef` for fss_legacy.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   zef
%
% Outputs:
%   zef
%
% Zef fields (observed):
%   zef.h_inv_synth_source_1 (read)
%   zef.h_inv_synth_source_10 (read)
%   zef.h_inv_synth_source_2 (read)
%   zef.h_inv_synth_source_3 (read)
%   zef.h_inv_synth_source_4 (read)
%   zef.h_inv_synth_source_5 (read)
%   zef.h_inv_synth_source_6 (read)
%   zef.h_inv_synth_source_7 (read)
%   zef.h_inv_synth_source_8 (read)
%   zef.h_inv_synth_source_9 (read)
%   zef.inv_synth_source (read, write)
%
% Calls (project):
%   zef_update_fss_legacy
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[zef] = zef_update_fss_legacy(zef)` with project root and `src` on the path.
% --- End Zeffiro documentation header


zef.inv_synth_source = str2num(get(zef.h_inv_synth_source_1 ,'string'));
zef.inv_synth_source = zef.inv_synth_source(:);
zef.inv_synth_source = [ zef.inv_synth_source ...
    reshape(str2num(get(zef.h_inv_synth_source_2 ,'string')),size(zef.inv_synth_source,1),size(zef.inv_synth_source,2)) ...
    reshape(str2num(get(zef.h_inv_synth_source_3 ,'string')),size(zef.inv_synth_source,1),size(zef.inv_synth_source,2)) ...
    reshape(str2num(get(zef.h_inv_synth_source_4 ,'string')),size(zef.inv_synth_source,1),size(zef.inv_synth_source,2)) ...
    reshape(str2num(get(zef.h_inv_synth_source_5 ,'string')),size(zef.inv_synth_source,1),size(zef.inv_synth_source,2)) ...
    reshape(str2num(get(zef.h_inv_synth_source_6 ,'string')),size(zef.inv_synth_source,1),size(zef.inv_synth_source,2)) ...
    reshape(str2num(get(zef.h_inv_synth_source_7 ,'string')),size(zef.inv_synth_source,1),size(zef.inv_synth_source,2)) ...
    repmat(str2num(get(zef.h_inv_synth_source_8 ,'string')),size(zef.inv_synth_source,1),1) ...
    repmat(str2num(get(zef.h_inv_synth_source_9 ,'string')),size(zef.inv_synth_source,1),1) ...
    repmat(get(zef.h_inv_synth_source_10 ,'value'),size(zef.inv_synth_source,1),1) ...
    ];
zef.inv_synth_source(:,4:6) = zef.inv_synth_source(:,4:6)./repmat(sqrt(sum(zef.inv_synth_source(:,4:6).^2,2)),1,3);

end
