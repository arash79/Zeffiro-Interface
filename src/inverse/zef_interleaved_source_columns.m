function [ix, iy, iz] = zef_interleaved_source_columns(src_inds)
%ZEF_INTERLEAVED_SOURCE_COLUMNS  (x,y,z) columns of an interleaved lead field.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Class-path L after zef_process_inversion is interleaved:
%   columns 3k-2, 3k-1, 3k are the Cartesian components of source k.
%   Plugin-path L from zef_processLeadfields is blocked (x-block, y-block,
%   z-block) and must not use this helper.
%
%   [ix, iy, iz] = zef_interleaved_source_columns(src_inds)
%
%   src_inds  - 1-based source indices (k = 1…n_sources).
%   ix,iy,iz  - corresponding column indices into interleaved L.

src_inds = src_inds(:);
ix = 3 * src_inds - 2;
iy = 3 * src_inds - 1;
iz = 3 * src_inds;

end
