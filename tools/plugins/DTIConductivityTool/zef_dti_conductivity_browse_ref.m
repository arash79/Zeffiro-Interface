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
