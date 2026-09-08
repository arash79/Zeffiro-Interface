/** Verified publications that introduce, use, evaluate, or extend Zeffiro Interface. */
export const publications = [
  {
    id: "he-2019",
    category: "Software",
    year: 2019,
    title:
      "Zeffiro User Interface for Electromagnetic Brain Imaging: a GPU Accelerated FEM Tool for Forward and Inverse Computations in Matlab",
    authors: "He, Q., Rezaei, A., & Pursiainen, S.",
    journal: "Neuroinformatics",
    extra: "18(2), 237–250",
    doi: "10.1007/s12021-019-09436-9",
    pmid: "31598847",
    pmc: "PMC7083809",
    note: "Original publication introducing the Zeffiro Interface code package.",
  },
  {
    id: "rezaei-2020",
    category: "Methods",
    year: 2020,
    title:
      "Randomized Multiresolution Scanning in Focal and Fast E/MEG Sensing of Brain Activity with a Variable Depth",
    authors: "Rezaei, A., Koulouri, A., & Pursiainen, S.",
    journal: "Brain Topography",
    extra: "33(2), 161–175",
    doi: "10.1007/s10548-020-00755-8",
    note: "RAMUS inverse method implemented in Zeffiro Interface.",
  },
  {
    id: "rezaei-2021",
    category: "Methods",
    year: 2021,
    title:
      "Reconstructing subcortical and cortical somatosensory activity via the RAMUS inverse source analysis technique using median nerve SEP data",
    authors:
      "Rezaei, A., Lahtinen, J., Neugebauer, F., Antonakakis, M., Piastra, M. C., Koulouri, A., Wolters, C. H., & Pursiainen, S.",
    journal: "NeuroImage",
    extra: "245, 118726",
    doi: "10.1016/j.neuroimage.2021.118726",
    note: "RAMUS source analysis listed among official Zeffiro Interface references.",
  },
  {
    id: "lahtinen-halpr-2024",
    category: "Methods",
    year: 2024,
    title:
      "Standardized hierarchical adaptive Lp regression for noise robust focal epilepsy source reconstructions",
    authors:
      "Lahtinen, J., Koulouri, A., Rampp, S., Wellmer, J., Wolters, C., & Pursiainen, S.",
    journal: "Clinical Neurophysiology",
    extra: "159, 24–40",
    doi: "10.1016/j.clinph.2023.12.001",
    note: "HALpR / SHALpR method implemented as a Zeffiro Interface inverse solver.",
  },
  {
    id: "lahtinen-kalman-2024",
    category: "Methods",
    year: 2024,
    title:
      "Standardized Kalman filtering for dynamical source localization of concurrent subcortical and cortical brain activity",
    authors:
      "Lahtinen, J., Ronni, P., Puthanmadam Subramaniyam, N., Koulouri, A., Wolters, C., & Pursiainen, S.",
    journal: "Clinical Neurophysiology",
    extra: "168, 15–24",
    doi: "10.1016/j.clinph.2024.09.021",
    note: "Standardized Kalman lineage implemented in Zeffiro Interface.",
  },
  {
    id: "he-2021",
    category: "Extensions",
    year: 2021,
    title:
      "An extended application ‘Brain Q’ processing EEG and MEG data of finger stimulation extended from ‘Zeffiro’ based on machine learning and signal processing",
    authors: "He, Q., & Pursiainen, S.",
    journal: "Cognitive Systems Research",
    extra: "69, 50–66",
    doi: "10.1016/j.cogsys.2020.08.006",
    note: "Application extended from Zeffiro for EEG/MEG finger-stimulation data.",
  },
  {
    id: "miinalainen-2019",
    category: "Foundations",
    year: 2019,
    title:
      "A realistic, accurate and fast source modeling approach for the EEG forward problem",
    authors:
      "Miinalainen, T., Rezaei, A., Us, D., Nüßing, A., Engwer, C., Wolters, C. H., & Pursiainen, S.",
    journal: "NeuroImage",
    extra: "184, 56–67",
    doi: "10.1016/j.neuroimage.2018.08.054",
    note: "H(div) source-modeling technique used by Zeffiro Interface, listed in the official project references.",
  },
];

export function doiUrl(doi) {
  return `https://doi.org/${doi}`;
}

export function pubmedUrl(pmid) {
  return `https://pubmed.ncbi.nlm.nih.gov/${pmid}/`;
}

export function pmcUrl(pmc) {
  return `https://www.ncbi.nlm.nih.gov/pmc/articles/${pmc}/`;
}
