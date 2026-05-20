%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
% --- Zeffiro documentation header ---
% if not(isfield(zef,'top_regularization_parameter')); — If not(isfield(zef,'top regularization parameter'));.
%
% Purpose:
%   If not(isfield(zef,'top regularization parameter'));.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Zef fields (observed):
%   zef.h_top_data_segment (read)
%   zef.h_top_high_cut_frequency (read)
%   zef.h_top_low_cut_frequency (read)
%   zef.h_top_normalize_data (read)
%   zef.h_top_number_of_frames (read)
%   zef.h_top_pcg_tol (read)
%   zef.h_top_regularization_parameter (read)
%   zef.h_top_sampling_frequency (read)
%   zef.h_top_time_1 (read)
%   zef.h_top_time_2 (read)
%   zef.h_top_time_3 (read)
%   zef.inv_data_segment (read)
%   zef.inv_high_cut_frequency (read)
%   zef.inv_low_cut_frequency (read)
%   zef.inv_sampling_frequency (read)
%   … (15 more)
%
% Side effects:
%   - reads/updates `zef` struct fields
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: Call `if not(isfield(zef,'top_regularization_parameter'));` from MATLAB with the project root on the path.
% --- End Zeffiro documentation header




if not(isfield(zef,'top_regularization_parameter'));
    zef.top_regularization_parameter = 5;
end;

zef.top_sampling_frequency = zef.inv_sampling_frequency;
zef.top_low_cut_frequency = zef.inv_low_cut_frequency;
zef.top_high_cut_frequency = zef.inv_high_cut_frequency ;

if not(isfield(zef,'top_data_segment'));
    zef.top_data_segment = zef.inv_data_segment;
end;
if not(isfield(zef,'top_normalize_data'));
    zef.top_normalize_data = 1;
end;

zef.top_time_1 = zef.inv_time_1;
zef.top_time_2 = zef.inv_time_2;
zef.top_time_3 = zef.inv_time_3;
zef.top_number_of_frames = zef.number_of_frames;


% set(zef.h_top_pcg_tol ,'string',num2str(zef.top_pcg_tol));
set(zef.h_top_regularization_parameter ,'string',num2str(zef.top_regularization_parameter));
set(zef.h_top_sampling_frequency ,'string',num2str(zef.top_sampling_frequency));
set(zef.h_top_low_cut_frequency ,'string',num2str(zef.top_low_cut_frequency));
set(zef.h_top_high_cut_frequency ,'string',num2str(zef.top_high_cut_frequency));
set(zef.h_top_data_segment ,'string',num2str(zef.top_data_segment));
set(zef.h_top_normalize_data ,'value',zef.top_normalize_data);
set(zef.h_top_time_1 ,'string',num2str(zef.top_time_1));
set(zef.h_top_time_2 ,'string',num2str(zef.top_time_2));
set(zef.h_top_time_3 ,'string',num2str(zef.top_time_3));
set(zef.h_top_number_of_frames ,'string',num2str(zef.top_number_of_frames));
