function weighting = zef_barycentric_weighting(weighting_type)
%ZEF_BARYCENTRIC_WEIGHTING  Quadrature weights for P1 products on tets/triangles.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Exact integrals of products of linear hats on a reference tet/triangle,
%   factored so assemblers only multiply by volume or area.
%
%     FF  - ∫ ψ_i ψ_j dV: 1/10 on the diagonal (i=j), 1/20 off (i≠j).
%           (Reference tet volume 1; times |V| in the assembler.)
%     GG  - ∫ ∇ψ_i·∇ψ_j is constant per tet, weight 1 (gradients already
%           include 1/V scaling from zef_volume_barycentric).
%     FG  - ∫ ψ ∇ψ, weight 1/4 (mean of ψ is 1/4).
%     uFG - same pair as FF, used by the matrix-free u·F·G kernel.
%     surface_FF - ∫_Δ ψ_i ψ_j dS: 1/6 diagonal, 1/12 off (area=1 triangle).
%     surface_FG - ∫_Δ ψ ∇ψ dS, weight 1/3.
%
%   weighting = zef_barycentric_weighting(weighting_type)
%
%   Output: scalar or 1×2 [same_vertex, cross_vertex]. Unmatched types
%   leave weighting undefined (MATLAB error on use).
%
%   See also zef_volume_scalar_matrix, zef_surface_scalar_matrix.

switch weighting_type

    case 'FF'
        weighting = [1/10 1/20];
    case 'GG'
        weighting = [1];
    case 'FG'
        weighting = [1/4];
    case 'uFG'
        weighting = [1/10 1/20];
    case 'surface_FF'
        weighting = [1/6 1/12];
    case 'surface_FG'
        weighting = [1/3];
end

end
