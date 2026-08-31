#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") [--lut LUT_PATH] <subject_id> <mgz_file> <output_dir>

  subject_id   : FreeSurfer subject ID (looks in \$SUBJECTS_DIR/\$subject_id/mri/)
  mgz_file     : Filename in that folder (e.g. aseg.mgz, wm.mgz, aparc.mgz, etc.)
  output_dir   : Where individual .asc masks will be written

Options:
  --lut PATH   : Path to FreeSurferColorLUT.txt
                   (default: \$FREESURFER_HOME/FreeSurferColorLUT.txt)
EOF
  exit 1
}

lut_path=""
# Parse optional --lut flag
while [[ $# -gt 0 ]]; do
  case "$1" in
    --lut)
      [[ $# -lt 2 ]] && usage
      lut_path="$2"
      shift 2
      ;;
    --) shift; break ;;
    -*)
      echo "ERROR: Unknown option: $1" >&2
      usage
      ;;
    *) break ;;
  esac
done

# Require exactly 3 positional args now
[[ $# -ne 3 ]] && usage
subject_id="$1"; mgz_file="$2"; output_dir="$3"

# Ensure necessary env vars
: "${SUBJECTS_DIR:?"\$SUBJECTS_DIR must be set"}"
if [[ -z "$lut_path" ]]; then
  : "${FREESURFER_HOME:?"\$FREESURFER_HOME must be set or use --lut"}"
  lut_path="${FREESURFER_HOME}/FreeSurferColorLUT.txt"
fi

# Ensure required executables are on PATH
for cmd in mri_segstats mri_mc; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "ERROR: '$cmd' not found in PATH. Did you source \$FREESURFER_HOME/SetUpFreeSurfer.sh?" >&2
    exit 3
  fi
done

# Check that files exist and are readable
aseg_path="${SUBJECTS_DIR}/${subject_id}/mri/${mgz_file}"
[[ -r "$aseg_path" ]] || {
  echo "ERROR: MGZ file not found or unreadable: $aseg_path" >&2
  exit 2
}
[[ -r "$lut_path" ]] || {
  echo "ERROR: LUT file not found or unreadable: $lut_path" >&2
  exit 2
}

mkdir -p "$output_dir"
mkdir -p "$output_dir/ascii" 
mkdir -p "$output_dir/mesh"

echo "STEP 1: Reading color LUT from $lut_path"
echo "STEP 2: Computing labels present in $mgz_file"

# Get segment list
tmpstats=$(mktemp)
trap 'rm -f "$tmpstats"' EXIT

mri_segstats --seg "$aseg_path" --sum "$tmpstats" >/dev/null 2>&1

# SegId is in column 1; build a Bash array portably
# xargs turns lines into a single space-delimited string
read -r -a label_list <<< "$(
  awk 'NR>2 {print $2}' "$tmpstats" |
  sort -n -u |
  xargs
)"

# print available labels
# echo "Available labels in $mgz_file:"
# for lbl in "${label_list[@]}"; do
#     echo "  - $lbl"
# done
count=${#label_list[@]}
echo "Found $count labels. Segmenting…"
echo

# Loop over each label
for lbl in "${label_list[@]}"; do
  # skip background
  [[ ! "$lbl" =~ ^[0-9]+$ ]] && continue

  # lookup name in LUT
  name=$(awk -v id="$lbl" '$1==id {print $2; exit}' "$lut_path")
  [[ -z "$name" ]] && name="label${lbl}"

  echo "Processing label $lbl: $name"

  # sanitize to [A-Za-z0-9_]+
  safe_name=$(printf '%s' "$name" | tr -c '[:alnum:]slicer' '_')
  asc_out_file="${output_dir}/ascii/${safe_name}.asc"

  echo "→ Label $lbl ($name) → $asc_out_file"
  if ! mri_mc "$aseg_path" "$lbl" "$asc_out_file"; then
    echo "  [WARN] mri_mc failed for label $lbl; attempting binarize+retry…" >&2

    # create a temp file for the binarized volume
    tmp_mgz=$(mktemp "${TMPDIR:-/tmp}/tmp.XXXXXX.mgz")

    # ensure cleanup on exit
    trap 'rm -f "$tmp_mgz"' EXIT

    # binarize only this label into the temp file
    mri_binarize \
      --i "$aseg_path" \
      --match "$lbl" \
      --o "$tmp_mgz" || {
        echo "  [ERROR] mri_binarize also failed for label $lbl" >&2
    #    exit 1
      }

    # retry mri_mc on the binarized volume (value 1)
    if mri_mc "$tmp_mgz" 1 "$asc_out_file"; then
      echo "  [OK] recovered mri_mc via binarization"
    else
      echo "  [ERROR] mri_mc still failed after binarization for label $lbl" >&2
    #  exit 1
    fi

    # cleanup (trap will also catch any other exit)
    rm -f "$tmp_mgz"
    trap - EXIT
  fi

  # Convert to mesh
  mesh_out_file="${output_dir}/mesh/${safe_name}.stl"
  echo "→ Converting to mesh: $mesh_out_file"
  if ! mris_convert "$asc_out_file" "$mesh_out_file"; then
    echo "  [ERROR] mris_convert failed for label $lbl" >&2
  fi

done


# if [[ "$mgz_file" != *Thalamic* ]]; then

inner_skull_ascii_file="${output_dir}/ascii/inner_skull.asc"
echo "→ Converting to ascii: $inner_skull_ascii_file"
if ! mris_convert "${SUBJECTS_DIR}/${subject_id}/surf_inner_skull_surface" "$inner_skull_ascii_file"; then
echo "  [ERROR] mris_convert failed for label $inner_skull_ascii_file" >&2
fi

inner_skull_mesh_file="${output_dir}/mesh/inner_skull.stl"
echo "→ Converting to ascii: $inner_skull_mesh_file"
if ! mris_convert "${SUBJECTS_DIR}/${subject_id}/surf_inner_skull_surface" "$inner_skull_mesh_file"; then
echo "  [ERROR] mris_convert failed for label $inner_skull_mesh_file" >&2
fi

outer_skull_ascii_file="${output_dir}/ascii/outer_skull.asc"
echo "→ Converting to ascii: $outer_skull_ascii_file"
if ! mris_convert "${SUBJECTS_DIR}/${subject_id}/surf_outer_skull_surface" "$outer_skull_ascii_file"; then
echo "  [ERROR] mris_convert failed for label $outer_skull_ascii_file" >&2
fi

outer_skull_mesh_file="${output_dir}/mesh/outer_skull.stl"
echo "→ Converting to ascii: $outer_skull_mesh_file"
if ! mris_convert "${SUBJECTS_DIR}/${subject_id}/surf_outer_skull_surface" "$outer_skull_mesh_file"; then
echo "  [ERROR] mris_convert failed for label $outer_skull_mesh_file" >&2
fi

outer_skin_ascii_file="${output_dir}/ascii/outer_skin.asc"
echo "→ Converting to ascii: $outer_skin_ascii_file"
if ! mris_convert "${SUBJECTS_DIR}/${subject_id}/surf_outer_skin_surface" "$outer_skin_ascii_file"; then
echo "  [ERROR] mris_convert failed for label $outer_skin_ascii_file" >&2
fi

outer_skin_mesh_file="${output_dir}/mesh/outer_skin.stl"
echo "→ Converting to ascii: $outer_skin_mesh_file"
if ! mris_convert "${SUBJECTS_DIR}/${subject_id}/surf_outer_skin_surface" "$outer_skin_mesh_file"; then
echo "  [ERROR] mris_convert failed for label $outer_skin_mesh_file" >&2
fi

# fi

echo

echo "All available regions have been segmented in $output_dir."
