function [dev] = zef_lattice_deviation(X,varargin)
%ZEF_LATTICE_DEVIATION  Local 2-D Taylor deviation of a lattice field.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Finite-difference gradient and Hessian of the 2-D array X, then the
%   absolute second-order Taylor increment along ±e1, ±e2, and
%   ±(e1+e2)/sqrt(2) at step r (default 0.5). 'avg' (default) means the
%   mean of those six values; 'max' the maximum. Optional i_idx and j_idx
%   restrict the output to a subset of rows/columns (still indexing into
%   the full difference arrays).
%
%   Only first-party caller is the tES plugin
%   zef_ES_optimizer_properties_show, which scores optimizer-table fields
%   at (sr, sc) with both 'avg' and 'max'.
%
%   dev = zef_lattice_deviation(X)
%   dev = zef_lattice_deviation(X, dev_type, r, i_idx, j_idx)
%
%   Inputs
%     X         - 2-D real array.
%     dev_type  - 'avg' or 'max' (default 'avg').
%     r         - step length (default 0.5).
%     i_idx, j_idx - row/column indices (default 1:size(X,1/2)).
%
%   Output
%     dev - numel(i_idx)-by-numel(j_idx) deviation map.
%
%   See also zef_ES_optimizer_properties_show.
dev_type = 'avg';
r = 0.5;
i_idx = [1 : size(X,1)];
j_idx = [1 : size(X,2)];

if not(isempty(varargin))
    dev_type = varargin{1};
    if length(varargin)>1
        r = varargin{2};
    end
    if length(varargin)>2
        i_idx = varargin{3};
    end
    if length(varargin)>3
        j_idx = varargin{4};
    end
end

dev = zeros(length(i_idx),length(j_idx));

F = zeros(size(X,1)+2,size(X,2)+2);
F(2:end-1,1) = X(:,1);
F(2:end-1,end) = X(:,end);
F(1,2:end-1) = X(1,:);
F(end,2:end-1) = X(end,:);
F(2:end-1,2:end-1) = X;

dFdx = F(2:end-1,3:end) - F(2:end-1,1:end-2);
dFdy = F(3:end,2:end-1) - F(1:end-2,2:end-1);

dFdx0 = zeros(size(X,1)+2,size(X,2)+2);
dFdx0(2:end-1,1) = dFdx(:,1);
dFdx0(2:end-1,end) = dFdx(:,end);
dFdx0(1,2:end-1) = dFdx(1,:);
dFdx0(end,2:end-1) = dFdx(end,:);
dFdx0(2:end-1,2:end-1) = dFdx;

dFdy0 = zeros(size(X,1)+2,size(X,2)+2);
dFdy0(2:end-1,1) = dFdy(:,1);
dFdy0(2:end-1,end) = dFdy(:,end);
dFdy0(1,2:end-1) = dFdy(1,:);
dFdy0(end,2:end-1) = dFdy(end,:);
dFdy0(2:end-1,2:end-1) = dFdy;

dFdx2 = F(2:end-1,3:end) - 2*F(2:end-1,2:end-1) + F(2:end-1,1:end-2);
dFdy2 = F(3:end,2:end-1) - 2*F(2:end-1,2:end-1) + F(1:end-2,2:end-1);
dFdxdy =  dFdx0(3:end,2:end-1) - dFdx0(1:end-2,2:end-1);
dFdydx =  dFdy0(3:end,2:end-1) - dFdy0(1:end-2,2:end-1);

for i = 1 : length(i_idx)
    for j = 1 : length(j_idx)

        g = [dFdx(i_idx(i),j_idx(j));dFdy(i_idx(i),j_idx(j))];
        % Both Hessian rows are [d2F/dx2, d2F/dxdy]; dFdy2 and dFdydx are unused.
        H = [dFdx2(i_idx(i),j_idx(j)) dFdxdy(i_idx(i),j_idx(j)); dFdx2(i_idx(i),j_idx(j)) dFdxdy(i_idx(i),j_idx(j))];
        v_1 = [1 ; 0];
        v_2 = [0 ; 1];
        v_3 = [1 ; 1]/sqrt(2);

        if isequal(dev_type,'max')

            dev(i,j) = max([abs(g'*v_1*r + 0.5*v_1'*H*v_1*r^2),...
                abs(-g'*v_1*r + 0.5*v_1'*H*v_1*r^2),...
                abs(g'*v_2*r + 0.5*v_1'*H*v_2*r^2),...
                abs(-g'*v_2*r + 0.5*v_2'*H*v_2*r^2)...
                abs(g'*v_3*r + 0.5*v_3'*H*v_3*r^2),...
                abs(-g'*v_3*r + 0.5*v_3'*H*v_3*r^2)]);

        else


            dev(i,j) = mean([abs(g'*v_1*r + 0.5*v_1'*H*v_1*r^2),...
                abs(-g'*v_1*r + 0.5*v_1'*H*v_1*r^2),...
                abs(g'*v_2*r + 0.5*v_1'*H*v_2*r^2),...
                abs(-g'*v_2*r + 0.5*v_2'*H*v_2*r^2)...
                abs(g'*v_3*r + 0.5*v_3'*H*v_3*r^2),...
                abs(-g'*v_3*r + 0.5*v_3'*H*v_3*r^2)]);
        end

    end
end

end
