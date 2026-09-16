function [nodes, tetra, domain_labels, hex_converted, original_ids] = convert_mesh(raw)
%CONVERT_MESH  Nodes, tetrahedra, and remapped domain labels from DUNEuro.
%
%   Zeffiro Interface.
%   Copyright © 2018- Sampsa Pursiainen & ZI Development Team
%   See: https://github.com/sampsapursiainen/zeffiro_interface
%   Licensed under the GNU General Public License v3.0 (see LICENSE).

    nodes = [];
    tetra = [];
    domain_labels = [];
    hex_converted = false;
    original_ids = [];

    mesh = [];
    if isfield(raw, 'mesh') && isstruct(raw.mesh)
        mesh = raw.mesh;
    elseif isfield(raw, 'volume_conductor') && isstruct(raw.volume_conductor)
        if isfield(raw.volume_conductor, 'grid')
            mesh = raw.volume_conductor.grid;
        else
            mesh = raw.volume_conductor;
        end
    end

    node_src = [];
    elem_src = [];
    label_src = [];
    if isstruct(mesh)
        node_src = first_existing_field(mesh, {'nodes', 'pos', 'pnt', 'vertices'});
        elem_src = first_existing_field(mesh, {'elements', 'tet', 'tetra', 'hexa', 'hex', 'elm'});
        label_src = first_existing_field(mesh, {'labels', 'label', 'tissue', 'domain', 'tag'});
    end
    if isempty(node_src)
        node_src = find_named(raw, {'nodes', 'pos'}, 1);
    end
    if isempty(elem_src)
        elem_src = find_named(raw, {'elements', 'tetra', 'tet', 'hexa'}, 1);
    end
    if isempty(label_src)
        label_src = find_named(raw, {'labels', 'label', 'tissue', 'domain', 'tag'}, 1);
    end
    if ~isempty(label_src) && ~isnumeric(label_src)
        label_src = [];
    end
    if isempty(node_src) || isempty(elem_src)
        return
    end

    nodes = as_n_by_k(node_src, 3, 'mesh nodes');
    if ~all(isfinite(nodes(:)))
        error('duneuro2zef:InvalidMesh', 'Mesh nodes contain non-finite coordinates.');
    end

    n_nodes = size(nodes, 1);
    elem = double(elem_src);
    if size(elem, 1) ~= 4 && size(elem, 1) ~= 8 && size(elem, 2) ~= 4 && size(elem, 2) ~= 8
        error('duneuro2zef:InvalidMesh', ...
            'Mesh elements must be tetrahedra (4 nodes) or hexahedra (8 nodes), got size %s.', ...
            mat2str(size(elem)));
    end
    if size(elem, 1) == 4 || size(elem, 1) == 8
        elem = elem.';
    end

    if min(elem(:)) == 0
        elem = elem + 1;
    end
    if min(elem(:)) < 1 || max(elem(:)) > n_nodes
        error('duneuro2zef:InvalidMesh', ...
            'Element indices [%g, %g] fall outside 1:%d nodes.', ...
            min(elem(:)), max(elem(:)), n_nodes);
    end

    if size(elem, 2) == 8
        labels_hex = labels_for_elements(label_src, size(elem, 1));
        [tetra, domain_labels] = hex_to_tet(nodes, elem, labels_hex);
        hex_converted = true;
    else
        tetra = elem;
        domain_labels = labels_for_elements(label_src, size(elem, 1));
    end
    domain_labels = domain_labels(:);
    assert_nondegenerate(nodes, tetra);
    [domain_labels, original_ids] = remap_domain_labels(domain_labels);
end

function labels = labels_for_elements(label_src, n_elem)
    if isempty(label_src)
        labels = ones(n_elem, 1);
        return
    end
    labels = double(label_src(:));
    if isscalar(labels)
        labels = labels * ones(n_elem, 1);
        return
    end
    if numel(labels) ~= n_elem
        error('duneuro2zef:InvalidMesh', ...
            'Mesh has %d elements but %d tissue labels.', n_elem, numel(labels));
    end
end

function [mapped, original_ids] = remap_domain_labels(labels)
    original_ids = unique(labels);
    original_ids = original_ids(:)';
    mapped = zeros(size(labels));
    for i = 1:numel(original_ids)
        mapped(labels == original_ids(i)) = i;
    end
end

function [tetra, labels_tetra] = hex_to_tet(nodes, hexa, labels_hex)
    % zef_hexa_to_tetra expects DUNE / ndgrid corner order (1–4 bottom, 5–8
    % top). FieldTrip hex dumps often use VTK order (bottom 1 2 4 3). If
    % the DUNE split is degenerate, retry VTK column permutation.
    [tetra, labels_tetra] = zef_hexa_to_tetra(hexa, labels_hex);
    if ~has_degenerate(nodes, tetra)
        return
    end
    vtk = hexa(:, [1 2 4 3 5 6 8 7]);
    [tetra, labels_tetra] = zef_hexa_to_tetra(vtk, labels_hex);
    if has_degenerate(nodes, tetra)
        error('duneuro2zef:InvalidMesh', ...
            ['Hexahedral elements produced degenerate tetrahedra under both ' ...
            'DUNE and VTK vertex orderings.']);
    end
end

function assert_nondegenerate(nodes, tetra)
    if has_degenerate(nodes, tetra)
        error('duneuro2zef:InvalidMesh', ...
            'Imported tetrahedra include degenerate (zero-volume) elements.');
    end
end

function tf = has_degenerate(nodes, tetra)
    tf = false;
    if isempty(tetra) || size(tetra, 1) < 1
        return
    end
    vol = zef_tetra_volume(nodes, tetra, false);
    typical = median(abs(vol));
    if ~isfinite(typical) || typical <= 0
        typical = max(abs(vol));
    end
    if ~isfinite(typical) || typical <= 0
        tf = true;
        return
    end
    tf = any(abs(vol) < 1e-12 * typical);
end

function val = first_existing_field(s, names)
    val = [];
    for i = 1:numel(names)
        if isfield(s, names{i}) && ~isempty(s.(names{i}))
            val = s.(names{i});
            return
        end
    end
end
