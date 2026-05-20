function [processed_data] = zef_electrode_reference(f,electrode_index)
% --- Zeffiro documentation header ---
% zef_electrode_reference — Zef electrode reference.
%
% Purpose:
%   Zef electrode reference.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   f
%   electrode_index
%
% Outputs:
%   processed_data
%
% Calls (project):
%   zef_electrode_reference
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[processed_data] = zef_electrode_reference(f, electrode_index)` with project root and `src` on the path.
% --- End Zeffiro documentation header

%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%This function processes the N-by-M data array f for N channels and M time
%steps. The other arguments can be controlled via the ZI user interface.
%The desctiption and argument definitions shown in ZI are listed below.
%Description: Set a given electrode as a reference
%Input: 1 Electrode index [Default: 1],
%Output: Data with zero reference level set by the electrode with the given index.

ref_f = f(electrode_index,:);
processed_data = f - ref_f(ones(size(f,1),1),:);
