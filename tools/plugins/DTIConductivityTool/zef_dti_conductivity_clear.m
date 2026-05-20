%Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%
%ZEF_DTI_CONDUCTIVITY_CLEAR
%
%Clears FreeSurfer DTI data from zef struct.
%Useful for starting over or removing DTI-derived conductivity.

function zef_dti_conductivity_clear

zef = evalin('base','zef');

% Clear FreeSurfer FA data
zef.freesurfer_fa_data = [];
zef.freesurfer_fa_info = [];
zef.freesurfer_register_transform = [];
zef.freesurfer_subject_name = '';
zef.freesurfer_fa_loaded = false;
zef.dti_applied = false;
zef.dti_applied_time = [];

% Clear auto-extracted geometry
zef.dti_dwi_vox2ras_tkr = eye(4);
zef.dti_ref_vox2ras = eye(4);
zef.dti_ref_vox2ras_tkr = eye(4);
zef.dti_ref_center = [0; 0; 0];
zef.dti_fa_geometry = [];
zef.dti_ref_geometry = [];
zef.dti_matrices_approved = false;

% Note: We do NOT clear zef.sigma here because:
% 1. User may want to keep the applied conductivity
% 2. Clearing would require recomputing from compartments
% If user wants to revert, they should reload project or recompute sigma

% Update GUI
if isfield(zef,'h_dti_status_text') && isvalid(zef.h_dti_status_text)
    zef.h_dti_status_text.Text = 'No FreeSurfer FA data loaded';
    zef.h_dti_status_text.FontColor = [0.5 0.5 0.5];
end

if isfield(zef,'h_dti_ref_status') && isvalid(zef.h_dti_ref_status)
    zef.h_dti_ref_status.Text = 'No reference MRI loaded';
    zef.h_dti_ref_status.FontColor = [0.5 0.5 0.5];
end

if isfield(zef,'h_dti_info_text') && isvalid(zef.h_dti_info_text)
    zef.h_dti_info_text.Value = {'FreeSurfer data cleared.', '', 'Load new FreeSurfer data to continue.'};
end

assignin('base','zef',zef);

end
