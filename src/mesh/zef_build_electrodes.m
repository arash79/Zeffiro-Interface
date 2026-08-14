function [A, B, C] = zef_build_electrodes(nodes, electrode_model, impedance_vec, impedance_inf, ele_ind, A)
%ZEF_BUILD_ELECTRODES  Couple PEM/CEM electrodes into the stiffness system.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).
%
%   Completes the FEM system used by EEG/EIT/TES lead fields after
%   zef_stiffness_matrix. The P1 stiffness A (N×N) is augmented with
%   electrode contact terms; B (N×E) and C (E×E) are the blocks in the
%   Somersalo–Cheney–Isaacson complete-electrode-model form
%   https://iopscience.iop.org/article/10.1088/0031-9155/57/4/999
%
%   Callers: zef_lead_field_eeg_fem, zef_lead_field_tes_fem (and EIT FEM).
%   ele_ind is produced in those files: PEM snaps each electrode xyz to the
%   nearest node; CEM uses the 4-column attachment table, then zef_pem2cem
%   turns interior hits into boundary triangles.
%
%   [A, B, C] = zef_build_electrodes(nodes, electrode_model, impedance_vec, impedance_inf, ele_ind, A)
%
%   Inputs
%     nodes           - N×3 vertex coordinates (metres in the lead-field
%                       path). Only used for CEM triangle areas.
%     electrode_model - 'CEM' or 'PEM'. Anything else returns B=[], C=[]
%                       and leaves A unchanged (warning issued).
%     impedance_vec   - E×1 contact impedances (ohm). If impedance_inf is
%                       true this is overwritten with ones.
%     impedance_inf   - scalar 0/1. True: PEM uses a Dirichlet node and
%                       C = I; CEM currently prints a message and returns
%                       without finishing C (stimulation path).
%     ele_ind         - PEM: E×1 1-based node indices (one node per electrode).
%                       CEM: R×4 rows [electrode_id, n1, n2, n3]. Rows with
%                       n3>0 are surface triangles. Rows with n3==0 fall
%                       back to a point-contact using n1 as the node and
%                       n2 as a scalar weight.
%     A               - N×N sparse stiffness. Must be returned as an output
%                       so MATLAB can update it in place (copy-on-write).
%
%   Outputs
%     A  - N×N, plus CEM triangle mass / Z or PEM 1/Z on the contact node.
%          Infinite-impedance PEM also zeros row/column 1 of the first
%          electrode node and sets A(n1,n1)=1.
%     B  - N×E. CEM: (area/(3Z)) at each triangle vertex. PEM: 1/Z or 1
%          at the contact node.
%     C  - E×E. CEM: diagonal of total area/Z (plus 1/Z for point fallback).
%          PEM finite Z: diagonal 1/Z at electrode indices; infinite Z: I.
%
%   CEM triangle integrals (linear hats on a triangle of area ala)
%     B_i  += ala/(3Z),  A_ii += ala/(6Z),  A_ij += ala/(12Z) for i≠j,
%     C_ee += ala/Z, with Z scaled by the electrode's total triangle area
%     when that area is positive.
%
%   Side effects: waitbar (closed by onCleanup).
%
%   See also zef_stiffness_matrix, zef_pem2cem, zef_lead_field_eeg_fem.

% zef_build_elecrodes: constructs the matrices B and C [*] from given nodes,
% impedances, a stiffness matrix A and electrode indices. Notice that the
% stiffness matrix A is also returned from the function, to avoid the
% copy-on-write behaviour of Matlab functions due to assignment in place [†].
% In other words, the function needs to be called with
%
%     [A, B, C] = zef_build_elecrodes(A, ele_ind, n_of_nodes, n_of_electrodes);
%
% to possibly prevent the copying of the stiffness matrix A.
%
% [*]: https://iopscience.iop.org/article/10.1088/0031-9155/57/4/999/meta#pmb407475app1
%
% [†]: MathWorks, Avoid unnecessary copies of data,
% URL: https://se.mathworks.com/help/matlab/matlab_prog/avoid-unnecessary-copies-of-data.html

% Wait bar and its progress index

funtitle = 'Electrode matrices';

wb = zef_waitbar(0,1,funtitle);
wbi = 0;

% Cleanup operations

cleanup_fn = @(h) close(h);
cleanup_obj = onCleanup(@() cleanup_fn(wb));

% Consider the PEM case

if impedance_inf
    impedance_vec = ones(size(impedance_vec));
end

% Preallocate electrode matrices

n_of_nodes = size(nodes, 1);
n_of_electrodes = size(impedance_vec, 1);

B = spalloc(n_of_nodes,n_of_electrodes,0);
C = spalloc(n_of_electrodes,n_of_electrodes,0);

% Choose electrode model

cemtitle = strcat(funtitle, ' (CEM)');
pemtitle = strcat(funtitle, ' (PEM)');

if isequal(electrode_model, 'CEM')

    zef_waitbar(0,1, wb, strcat(cemtitle, ': current triangles'));

    % Triangle rows: column 4 is the third vertex (0 means point fallback).
    I_triangles = find(ele_ind(:,4)>0);
    ala = zeros(1,size(ele_ind,1));

    % Triangle area = ½ ||(n3-n2)×(n4-n2)||.
    ala(I_triangles) = 1/2 * sqrt(               ...
        sum(                                     ...
        cross(                               ...
        nodes(ele_ind(I_triangles,3),:)' ...
        -                                ...
        nodes(ele_ind(I_triangles,2),:)' ...
        ,                                    ...
        nodes(ele_ind(I_triangles,4),:)' ...
        -                                ...
        nodes(ele_ind(I_triangles,2),:)' ...
        ).^2                                 ...
        )                                        ...
        );

    zef_waitbar(1,1, wb);
    zef_waitbar(0,1,wb, strcat(cemtitle, ': initial B and C'));

    for ele_loop_ind = 1 : n_of_electrodes

        I = find(ele_ind(:,1) == ele_loop_ind);
        sum_ala = sum(ala(I));

        if sum_ala > 0

            % Absorb electrode area into Z so later ala/Z has the right scale.
            impedance_vec(ele_loop_ind) = impedance_vec(ele_loop_ind) * sum_ala;

        else

            for i = 1 : length(I)

                B(ele_ind(I(i),2), ele_ind(I(i),1)) ...
                    =                                   ...
                    B(ele_ind(I(i),2), ele_ind(I(i),1)) ...
                    +                                   ...
                    ele_ind(I(i),3)                     ...
                    ./                                  ...
                    impedance_vec(ele_loop_ind);

                for j = 1 : length(I)

                    % TODO: Check if this indexing into A induces the
                    % copy-on-write behaviour of Matlab. If this was just
                    % A = something, there would not be an issue, as A is
                    % returned from the function.

                    A(ele_ind(I(i),2),ele_ind(I(j),2)) ...
                        =                                  ...
                        A(ele_ind(I(i),2),ele_ind(I(j),2)) ...
                        +                                  ...
                        ele_ind(I(i),3)                    ...
                        *                                  ...
                        ele_ind(I(j),3)                    ...
                        ./                                 ...
                        impedance_vec(ele_loop_ind);

                end
            end

            C(ele_loop_ind, ele_loop_ind) = 1 ./ impedance_vec(ele_loop_ind);

        end

        wbi = wbi + 1;
        zef_waitbar(wbi , n_of_electrodes, wb);

    end

    wbi = 0;

    zef_waitbar(wbi,3, wb, strcat(cemtitle, ': updating B at active electrodes'));

    entry_vec = (1./impedance_vec(ele_ind(I_triangles,1))) .* ala(I_triangles)';

    % P1 load on a triangle: each vertex gets ala/(3Z).
    for i = 1 : 3

        B = B + sparse(              ...
            ele_ind(I_triangles,i+1) ...
            ,                            ...
            ele_ind(I_triangles,1)   ...
            ,                            ...
            (1/3) * entry_vec        ...
            ,                            ...
            n_of_nodes               ...
            ,                            ...
            n_of_electrodes          ...
            );

        zef_waitbar(wbi , 3, wb);

    end

    wbi = 0;

    if impedance_inf == 0

        zef_waitbar(wbi,3, wb, strcat(cemtitle, ': modifying stiffness matrix at active electrodes'));

        for i = 1 : 3

            for j = i : 3

                if i == j

                    % Diagonal of the linear-triangle mass matrix: ala/(6Z).
                    A_part = sparse(                ...
                        ele_ind(I_triangles,i+1)    ...
                        ,                               ...
                        ele_ind(I_triangles,j+1)    ...
                        ,                               ...
                        (1/6) * entry_vec           ...
                        ,                               ...
                        n_of_nodes                  ...
                        ,                               ...
                        n_of_nodes                  ...
                        );

                    A = A + A_part;

                else

                    % Off-diagonal mass: ala/(12Z), then add the transpose.
                    A_part = sparse(                ...
                        ele_ind(I_triangles,i+1)    ...
                        ,                               ...
                        ele_ind(I_triangles,j+1)    ...
                        ,                               ...
                        (1/12) * entry_vec          ...
                        ,                               ...
                        n_of_nodes                  ...
                        ,                               ...
                        n_of_nodes                  ...
                        );

                    A = A + A_part + A_part';

                end
            end

            wbi = wbi + 1;
            zef_waitbar(wbi , 3, wb);

        end

    else

        'Cannot use infinite impedance for stimulation'
        return

    end

    wbi = 0;
    zef_waitbar(wbi,1, wb, strcat(cemtitle, ': updating C at active electrodes.'));

    % Update triangle patches

    C = C + sparse(            ...
        ele_ind(I_triangles,1) ...
        ,                          ...
        ele_ind(I_triangles,1) ...
        ,                          ...
        entry_vec              ...
        ,                          ...
        n_of_electrodes        ...
        ,                          ...
        n_of_electrodes        ...
        );

    zef_waitbar(1,1,wb);

elseif isequal(electrode_model, 'PEM')

    zef_waitbar(0,1, wb, pemtitle);

    if impedance_inf == 0

        entry_vec = (1./impedance_vec(ele_ind(:,1)));

        for i = 1 : n_of_electrodes
            B(ele_ind(i),i) = entry_vec;
            A(ele_ind(i),ele_ind(i)) = A(ele_ind(i),ele_ind(i)) + entry_vec;
        end

        C = sparse(ele_ind(:,1), ele_ind(:,1), entry_vec, n_of_electrodes, n_of_electrodes);

    else

        for i = 1 : n_of_electrodes
            B(ele_ind(i),i) = 1;
        end

        % Dirichlet boundary condition for a single node.

        % Dirichlet at the first electrode node (reference potential).
        A(ele_ind(1),:) = 0;
        A(:,ele_ind(1)) = 0;
        A(ele_ind(1),ele_ind(1)) = 1;

        C = eye(n_of_electrodes);

    end

    zef_waitbar(1,1, wb);

else

    warning('Unrecognised electrode model in zef_build_electrodes. Returning empty electrode matrices B and C...')

    B = [];
    C = [];
    return

end

zef_waitbar(1,1,wb);

end
