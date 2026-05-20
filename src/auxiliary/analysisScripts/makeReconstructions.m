% --- Zeffiro documentation header ---
% [zef.reconstruction, zef — [zef.reconstruction, zef.
%
% Purpose:
%   [zef.reconstruction, zef.
%   Folder: Main procedural runtime (`zef_*`): GUI tools, mesh, forward lead fields, inverse orchestration, I/O, and visualization. Added via `genpath` from `zeffiro_interface`.
%
% Zef fields (observed):
%   zef.beamformer (read)
%   zef.bf_var_loc (read)
%   zef.reconstruction (read)
%   zef.reconstruction_information (read)
%
% Calls (project):
%   zef_ramus_iteration
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `[zef.reconstruction, zef` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

[zef.reconstruction, zef.reconstruction_information]=zef_find_mne_reconstruction;
zef_dataBank_addButtonPress;

%sLoreta

[zef.reconstruction, zef.reconstruction_information]=zef_CSM_iteration;
zef_dataBank_addButtonPress;

%ramus
zef_update_ramus_inversion_tool;
[zef.reconstruction, zef.reconstruction_information]  = zef_ramus_iteration([]);
zef_dataBank_addButtonPress;

%dipole
[zef.reconstruction, zef.reconstruction_information]=zef_dipoleScan;
zef_dataBank_addButtonPress;

%beamformer
if strcmp(zef.beamformer.estimation_attr.Value,'1')
    [zef.reconstruction,~, zef.reconstruction_information] = zef_beamformer;
elseif strcmp(zef.beamformer.estimation_attr.Value,'2')
    [~,zef.reconstruction, zef.reconstruction_information] = zef_beamformer;
else; [zef.reconstruction,zef.bf_var_loc, zef.reconstruction_information] = zef_beamformer;
end
zef_dataBank_addButtonPress;
