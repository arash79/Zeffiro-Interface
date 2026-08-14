function [processed_data] = zef_simple_ica_cleaning(f, ica_reference_channels)
%ZEF_SIMPLE_ICA_CLEANING  Pipeline stage: rica on channels, drop components matching reference indices.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Add Input: ICA reference channel indices. Writes cleaned f'.
%
%Description: Simple ICA for data cleaning
%Input: 1 ICA reference channel indices [Default: ]
%Output: Data cleaned via ICA.
%

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
