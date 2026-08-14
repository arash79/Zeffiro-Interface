function zef_dti_conductivity_browse_ref
%ZEF_DTI_CONDUCTIVITY_BROWSE_REF  uigetfile reference MRI → zef.dti_ref_mri_file.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Browse button on the DTI Conductivity Tool. Filters: *.mgz/*.mgh then
%   *.nii.gz/*.nii. Starting folder is the current reference path, else the
%   FA file folder, else zef.save_file_path, else pwd. Writes the path to
%   zef.dti_ref_mri_file and the path edit if it exists. Geometry is not
%   read here — Load → zef_dti_conductivity_load_freesurfer.
%
%   Script-style: evalin/assignin base zef. Cancel leaves zef unchanged.
%
%   See also zef_dti_conductivity_browse_fa, zef_dti_conductivity_load_freesurfer.

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
