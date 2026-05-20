function [processed_data] = zef_simple_ica_cleaning(f, ica_reference_channels)
% --- Zeffiro documentation header ---
% zef_simple_ica_cleaning — Zef simple ica cleaning.
%
% Purpose:
%   Zef simple ica cleaning.
%   Folder: Individual Zeffiro plugins (inverse GUIs, data bank, Kalman, SESAME, etc.) registered via profile INI files.
%
% Inputs:
%   f
%   ica_reference_channels
%
% Outputs:
%   processed_data
%
% Calls (project):
%   zef_simple_ica_cleaning
%   zef_waitbar
%
% Workflow:
%   GUI: Used indirectly through tools, menus, or `zef_update` refresh chains.
%   Programmatic: `[processed_data] = zef_simple_ica_cleaning(f, ica_reference_channels)` with project root and `src` on the path.
% --- End Zeffiro documentation header

%Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%This function processes the N-by-M data array f for N channels and M time
%steps. The other arguments can be controlled via the ZI user interface.
%The desctiption and argument definitions shown in ZI are listed below.
%Description: Simple ICA for data cleaning
%Input: 1 ICA reference channel indices [Default: ]
%Output: Data cleaned via ICA.

%Conversion between string and numeric data types.
if isstr(ica_reference_channels)
    ica_reference_channels = str2num(ica_reference_channels);
end
%End of conversion.

size_f = size(f,1);
f = f';
n_ica = length(ica_reference_channels)+1;

f_2 = zeros(size(f));

h = zef_waitbar(0,1,['Simple ICA filter.']);

for i = 1 : size_f

    Mdl = rica(f(:,[i ica_reference_channels]),n_ica);
    aux_vec = transform(Mdl,f(:,[i ica_reference_channels]));
    f_2(:,i) = aux_vec(:,1);
    zef_waitbar(i,size_f,h,['Simple ICA filter.']);

end

close(h);

processed_data = f_2';
