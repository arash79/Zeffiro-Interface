%CREAT_POINTS  Convert one FreeSurfer all-aparc ASCII table to lh_point.dat.
%
%   Zeffiro Interface helper for the bundled multicompartment head sample.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Script. Filename is the historical misspelling of create_points.
%   Loads lh.all_aparc.2009s from the current directory, skips two header
%   rows, keeps columns 1–4, and saves lh_point.dat.
%
%   See also create_points, create_colortable.

a = load ('lh.all_aparc.2009s');
c = a([3:end],[1:4]);
save lh_point.dat c
