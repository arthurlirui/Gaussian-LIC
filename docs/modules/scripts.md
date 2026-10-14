# Module Reference: `scripts/` — Utility Scripts

The `scripts/` directory contains standalone utility scripts for research and maintenance tasks.

---

## Files

### `fetch_arxiv.mjs`

An ESM Node.js script that scrapes metadata for a curated bibliography of related papers from arXiv.

**What it does:**
1. Creates a temp directory `/tmp/arxiv_html`
2. Iterates over a hardcoded list of ~24 arXiv IDs, grouped by topic:
   - 3DGS foundations (3DGS, Scaffold-GS, Mip-Splatting, StopThePop, SuGaR, 2DGS)
   - Classic 3DGS-SLAM (MonoGS, SplaTAM, GS-SLAM, Photo-SLAM, LoopSplat, Loopy-SLAM)
   - NeRF-SLAM (iMAP, NICE-SLAM, Co-SLAM, Point-SLAM, GO-SLAM, NeRF-SLAM)
   - LiDAR-Inertial(-Visual) odometry (FAST-LIO, FAST-LIO2, FAST-LIVO2, R3LIVE, Faster-LIO)
   - Continuous-time (CT-ICP, Bootstrap-GS)
3. For each ID: if not cached locally, `curl`s `https://arxiv.org/abs/<id>` with a Chrome user-agent and saves the page; sleeps ~1200 ms between requests (rate limiting)
4. Parses the saved HTML with regex to extract: title, authors (from `citation_author` meta spans), and publication date
5. Writes the aggregated JSON to `/tmp/arxiv_meta.json` and prints to stdout

**Usage:**
```bash
node scripts/fetch_arxiv.mjs
```

**Output:** `/tmp/arxiv_meta.json` — a JSON object mapping arXiv IDs to `{ title, authors, date }` metadata.

**Purpose:** Builds a metadata file for the project's related-work references, used in the survey and paper drafts under `latex/`.
