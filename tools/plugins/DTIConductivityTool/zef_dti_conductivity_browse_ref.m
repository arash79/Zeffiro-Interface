%Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%
%ZEF_DTI_CONDUCTIVITY_BROWSE_REF
%
%Browse for reference MRI file (e.g. orig.mgz from FreeSurfer recon-all).
%The reference MRI provides the coordinate geometry needed to transform
%between Zeffiro's mesh display space and the FA voxel space.
%
%Supported formats:
%  - MGZ/MGH (FreeSurfer native)
%  - NIfTI (.nii, .nii.gz)
%
%After selection, the file path is stored in zef. The actual geometry
%extraction happens when the user clicks the 'Load' button, which calls
%zef_dti_conductivity_load_freesurfer.
% --- Zeffiro documentation header ---
% function zef_dti_conductivity_browse_ref — Function zef dti conductivity browse ref.
%
% Purpose:
%   Function zef dti conductivity browse ref.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.dti_ref_mri_file (read, write)
%   zef.freesurfer_fa_file (read)
%   zef.h_dti_ref_mri_file (read)
%   zef.save_file_path (read)
%
% Calls (project):
%   zef_dti_conductivity_browse_ref
%
% Side effects:
%   - base/caller workspace
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Invoked from a menu, button, or table callback in the Zeffiro tools.
%   Programmatic: Call `function zef_dti_conductivity_browse_ref` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header

function zef_dti_conductivity_browse_ref


zef = evalin('base','zef');

% Get default path (try same directory as FA file, then save path, then pwd)
default_path = '';
if isfield(zef,'dti_ref_mri_file') && ~isempty(zef.dti_ref_mri_file)
    [default_path, ~, ~] = fileparts(zef.dti_ref_mri_file);
elseif isfield(zef,'freesurfer_fa_file') && ~isempty(zef.freesurfer_fa_file)
    [default_path, ~, ~] = fileparts(zef.freesurfer_fa_file);
elseif isfield(zef,'save_file_path') && ~isempty(zef.save_file_path)
    default_path = zef.save_file_path;
else
    default_path = pwd;
end

% Open file selection dialog
[file_name, path_name] = uigetfile( ...
    {'*.mgz;*.mgh', 'FreeSurfer Volumes (*.mgz, *.mgh)'; ...
     '*.nii.gz;*.nii', 'NIfTI Files (*.nii.gz, *.nii)'; ...
     '*.*', 'All Files'}, ...
    'Select Reference MRI (e.g. orig.mgz)', default_path);

if file_name ~= 0
    full_path = fullfile(path_name, file_name);
    zef.dti_ref_mri_file = full_path;
    if isfield(zef,'h_dti_ref_mri_file') && isvalid(zef.h_dti_ref_mri_file)
        zef.h_dti_ref_mri_file.Value = full_path;
    end
    assignin('base','zef',zef);
end

end
