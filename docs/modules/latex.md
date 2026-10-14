# Module Reference: `latex/` — Research Papers, Survey, and Design Documents

The `latex/` directory contains LaTeX source for research papers, a survey, and design documents produced as part of the Gaussian-LIC2 project. These are academic artifacts, not build targets.

---

## Directory Structure

```
latex/
├── README.md                  # Survey bibliography index and PDF list
├── bib/
│   └── references.bib         # Shared BibTeX bibliography
├── design/
│   └── DESIGN.md              # Co-LIC2 cooperative multi-node LIV Gaussian SLAM design doc
├── paper/                     # arXiv paper draft (Gaussian-LIC2, ~15 pages)
│   ├── main.tex
│   ├── sections/              # Per-section LaTeX files
│   └── figures/               # TikZ figures (dataflow, sequence, topology)
├── mobicom/                   # MobiCom submission draft (ACM acmart sigconf, ~11 pages)
│   ├── main.tex
│   ├── sections/              # Per-section LaTeX files
│   ├── figures/               # TikZ figures (hardware, protocol, scalability, etc.)
│   └── mobicom_refs.bib
├── survey/                    # Multimodal GS-SLAM survey (~15 pages, 58 bib entries)
│   ├── main.tex
│   └── sections/              # background, comparison, future, etc.
├── papers/                    # Collection of reference paper PDFs (~110 files)
└── win_lic_paper/             # WinLIC framework paper draft (~16 pages, 5 TikZ figures)
    ├── main.tex
    ├── main.pdf
    ├── sections/
    ├── figures/
    └── refs.bib
```

---

## Paper Drafts

### `latex/paper/` — arXiv Draft

The main Gaussian-LIC2 paper, formatted for arXiv submission (~15 pages). Sections include introduction, system overview, mapping, implementation, experiments, discussion, conclusion, and appendix. Uses TikZ for dataflow, sequence, and topology figures.

### `latex/mobicom/` — MobiCom Submission

An ACM MobiCom conference submission using the `acmart` `sigconf` document class (~11 pages). Covers the cooperative multi-node LIV Gaussian SLAM system (Co-LIC2). Includes TikZ figures for hardware layout, protocol stack, time synchronization, topology, dataflow, and scalability.

### `latex/win_lic_paper/` — WinLIC Framework Paper

A paper describing the Windows-compatible offline multi-modal Gaussian Splatting framework (~16 pages, 5 TikZ figures). Includes a compiled `main.pdf`.

### `latex/survey/` — Multimodal GS-SLAM Survey

A standalone survey paper (~15 pages, 58 BibTeX entries) covering LiDAR, iToF, and monocular-depth-based Gaussian Splatting SLAM systems. Sections: introduction, background, comparison, future directions, conclusion.

---

## Design Documents

### `latex/design/DESIGN.md`

A design document for Co-LIC2 — a cooperative multi-node LiDAR-Inertial-Visual Gaussian SLAM system. Describes the architecture for multiple sensing nodes cooperating to build a shared Gaussian map.

---

## Reference Papers (`latex/papers/`)

A collection of ~110 reference paper PDFs, organized by filename convention `<Author><Year>_<ShortTitle>.pdf`. These support the survey and related-work sections of the papers.

The `latex/README.md` file (286 KB) contains a comprehensive annotated bibliography index of all collected papers.

---

## Building the Papers

Each paper directory contains a self-contained LaTeX project. To build:

```bash
cd latex/paper       # or mobicom/, survey/, win_lic_paper/
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex
```

The `win_lic_paper/` directory includes a pre-built `main.pdf`.

---

## Relationship to the Codebase

The papers describe the algorithms implemented in `src/` and `win_lic/`:
- `latex/paper/` and `latex/mobicom/` describe the core Gaussian-LIC2 / Co-LIC2 system
- `latex/win_lic_paper/` describes the WinLIC offline framework
- `latex/survey/` provides the broader context of GS-SLAM research
- `latex/papers/` contains the reference works cited by the above
