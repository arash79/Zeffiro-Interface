function [point] = myAffine3d(point, matrix)
%MYAFFINE3D  Apply a 4×4 affine to N-by-3 points (homogeneous).
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   point = myAffine3d(point, matrix)
%
%   Appends a row of ones, left-multiplies by matrix, returns the first
%   three rows as N-by-3. Used by scriptForAlignment. Not MATLAB affine3d.
%
%   See also scriptForAlignment.

[N, ~]=size(point);

point=point';
point=vertcat(point, ones(1,N));

point=matrix*point;

point=point(1:3,:);

point=point';

end
