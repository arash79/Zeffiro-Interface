%Copyright © 2024- Sampsa Pursiainen & ZI Development Team
%See: https://github.com/sampsapursiainen/zeffiro_interface
%
%ZEF_DTI_PRINT_ANISOTROPY_REPORT
%
%Prints a per-compartment anisotropy summary to the command window.
%Can be called standalone or is invoked automatically after "Apply to Mesh".
%
%The report includes:
%  - Number of tetrahedra per active compartment
%  - Number and percentage with anisotropic conductivity
%  - Sample eigenvalue decompositions from the most anisotropic compartment
%
%Inputs:
%   zef  - Zeffiro struct (optional; reads from base workspace if not provided)
%   opts - Optional struct with:
%          .aniso_tol   - Min eigenvalue spread to count as anisotropic (default 0.05)
%          .n_samples   - Number of sample tensors to display (default 5)
%          .verbose     - If false, suppress sample tensor output (default true)
%
%Usage:
%   zef_dti_print_anisotropy_report();          % uses base workspace
%   zef_dti_print_anisotropy_report(zef);       % uses provided zef
%   zef_dti_print_anisotropy_report(zef, struct('n_samples', 10));

function zef_dti_print_anisotropy_report(zef, opts)

arguments
    zef (1,1) struct = struct()
    opts (1,1) struct = struct()
end

% Get zef from base if empty
if isempty(fieldnames(zef))
    try
        zef = evalin('base', 'zef');
    catch
        fprintf(2, 'Cannot get zef from base workspace.\n');
        return;
    end
end

% Options
aniso_tol = 0.05;
if isfield(opts, 'aniso_tol') && isnumeric(opts.aniso_tol)
    aniso_tol = opts.aniso_tol;
end
n_samples = 5;
if isfield(opts, 'n_samples') && isnumeric(opts.n_samples)
    n_samples = max(1, min(20, round(opts.n_samples)));
end
verbose = true;
if isfield(opts, 'verbose') && islogical(opts.verbose)
    verbose = opts.verbose;
end

% Prerequisites
if ~isfield(zef, 'sigma_anisotropy') || isempty(zef.sigma_anisotropy)
    fprintf(2, 'sigma_anisotropy not set. Run "Apply to Mesh" first.\n');
    return;
end
if ~isfield(zef, 'compartment_tags') || isempty(zef.compartment_tags)
    fprintf(2, 'compartment_tags not available.\n');
    return;
end

sigma = zef.sigma_anisotropy;  % M x 6
M = size(sigma, 1);

has_labels = isfield(zef, 'domain_labels') && ~isempty(zef.domain_labels);

% Vectorized anisotropy detection (avoids per-element loop)
diag_spread = max(sigma(:, 1:3), [], 2) - min(sigma(:, 1:3), [], 2);
offdiag_norm = sqrt(sigma(:, 4).^2 + sigma(:, 5).^2 + sigma(:, 6).^2);
is_aniso = (diag_spread >= aniso_tol) | (offdiag_norm >= aniso_tol);

% Build active compartment mapping
tags = zef.compartment_tags;
active_idx = 0;
comp_info = struct('tag', {}, 'label', {}, 'n_tet', {}, 'n_aniso', {});

for k = 1:length(tags)
    tag = tags{k};
    if isfield(zef, [tag '_on']) && zef.([tag '_on'])
        active_idx = active_idx + 1;
        ci = struct();
        ci.tag = tag;
        ci.label = active_idx;
        if has_labels
            mask = (zef.domain_labels == active_idx);
            ci.n_tet = sum(mask);
            ci.n_aniso = sum(is_aniso & mask);
        else
            ci.n_tet = 0;
            ci.n_aniso = 0;
        end
        comp_info(end + 1) = ci; %#ok<AGROW>
    end
end

% Print header
fprintf('\n');
fprintf('==========================================================================\n');
fprintf('  DTI ANISOTROPY REPORT\n');
fprintf('==========================================================================\n');

if isfield(zef, 'dti_conductivity_metadata') && isstruct(zef.dti_conductivity_metadata)
    md = zef.dti_conductivity_metadata;
    if isfield(md, 'model_type')
        model_names = {'Volume Fraction (Tuch-style)', 'Effective Medium (Tuch linear)', 'Direct Scaling'};
        if md.model_type >= 1 && md.model_type <= 3
            fprintf('  Model:          %s\n', model_names{md.model_type});
        end
    end
    if isfield(md, 'interpolation_mode')
        fprintf('  Interpolation:  %s\n', md.interpolation_mode);
    end
    if isfield(md, 'anisotropy_threshold')
        fprintf('  FA threshold:   %.2f\n', md.anisotropy_threshold);
    end
    if isfield(md, 'applied_to_compartments') && ~isempty(md.applied_to_compartments)
        fprintf('  Target compts:  %s\n', strjoin(md.applied_to_compartments, ', '));
    end
end

fprintf('----------------------------------------------------------------------------------------\n');
fprintf('  %-10s %-40s %10s %10s %10s\n', 'Lbl', 'Compartment', 'N_tetra', 'N_aniso', '%_aniso');
fprintf('----------------------------------------------------------------------------------------\n');

best_comp_idx = 0;
best_comp_ratio = 0;

for j = 1:length(comp_info)
    ci = comp_info(j);
    if ci.n_tet > 0
        pct = 100 * ci.n_aniso / ci.n_tet;
        fprintf('  %-10d %-40s %10d %10d %9.1f%%\n', ...
            ci.label, zef.([ci.tag, '_name']), ci.n_tet, ci.n_aniso, pct);
        if pct > best_comp_ratio && ci.n_aniso > 0
            best_comp_ratio = pct;
            best_comp_idx = j;
        end
    else
        fprintf('  %-10d %-40s %10d %10s %10s\n', ...
            ci.label, zef.([ci.tag, '_name']), ci.n_tet, '-', '-');
    end
end

total_aniso = sum(is_aniso);
fprintf('----------------------------------------------------------------------------------------\n');
fprintf('  %-4s %-25s %10d %10d %9.1f%%\n', ...
    '', 'TOTAL', M, total_aniso, 100 * total_aniso / max(M, 1));
fprintf('========================================================================================\n');

% Sample eigenvalue decompositions from the most anisotropic compartment
if verbose && best_comp_idx > 0
    ci = comp_info(best_comp_idx);
    if has_labels
        comp_mask = (zef.domain_labels == ci.label);
    else
        comp_mask = true(M, 1);
    end
    aniso_in_comp = find(is_aniso & comp_mask);

    if ~isempty(aniso_in_comp)
        n_show = min(n_samples, length(aniso_in_comp));
        rng(42);
        sample = aniso_in_comp(randperm(length(aniso_in_comp), n_show));

        fprintf('\n  Sample tensors from "%s" (%d random anisotropic tetrahedra):\n', ci.tag, n_show);
        fprintf('  %-8s  %-12s %-12s %-12s  %-10s  %-6s\n', ...
            'Tetra', 'EV1', 'EV2', 'EV3', 'Ratio', 'PD');
        fprintf('  %s\n', repmat('-', 1, 68));

        for j = 1:n_show
            idx = sample(j);
            s = sigma(idx, :);
            T = [s(1) s(4) s(5); ...
                 s(4) s(2) s(6); ...
                 s(5) s(6) s(3)];
            ev = sort(eig(T), 'descend');
            is_pd = all(ev > 0);
            if ev(3) > 0
                ratio_str = sprintf('%.1f:1', ev(1) / ev(3));
            else
                ratio_str = 'Inf:1';
            end
            pd_str = 'Yes';
            if ~is_pd
                pd_str = 'NO!';
            end
            fprintf('  %-8d  %-12.4f %-12.4f %-12.4f  %-10s  %-6s\n', ...
                idx, ev(1), ev(2), ev(3), ratio_str, pd_str);
        end
        fprintf('\n');
    end
end

end
