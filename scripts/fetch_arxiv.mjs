// Fetch arXiv abstract pages and extract metadata (title, authors, journal-ref)
// Usage: node scripts/fetch_arxiv.mjs
import { execSync } from 'node:child_process';
import { mkdirSync, readFileSync, writeFileSync, existsSync } from 'node:fs';
import { join } from 'node:path';

const tmpDir = '/tmp/arxiv_html';
mkdirSync(tmpDir, { recursive: true });

const IDs = [
  // 3DGS foundations
  '2308.04079', // 3DGS (Kerbl)
  '2312.00109', // Scaffold-GS
  '2311.16493', // Mip-Splatting
  '2402.00525', // StopThePop
  '2311.12775', // SuGaR (skip if unavailable)
  '2403.17888', // 2DGS
  // classic 3DGS-SLAM
  '2312.06741', // MonoGS / Gaussian Splatting SLAM
  '2312.02126', // SplaTAM
  '2311.11700', // GS-SLAM
  '2311.16728', // Photo-SLAM
  '2408.10154', // LoopSplat
  '2402.09944', // Loopy-SLAM
  // NeRF-SLAM
  '2103.12316', // iMAP
  '2202.03576', // NICE-SLAM
  '2302.14376', // Co-SLAM
  '2304.04278', // Point-SLAM
  '2311.01786', // GO-SLAM
  '2210.13641', // NeRF-SLAM
  // LiDAR-Inertial(-Visual) odometry
  '2007.00258', // FAST-LIO
  '2210.03343', // FAST-LIO2
  '2408.14035', // FAST-LIVO2
  '2310.02640', // R3LIVE
  '2310.00695', // Faster-LIO
  '2501.13876', // FAST-LIVO2 edge (skip if not needed)
  // continuous-time
  '2201.05509', // CT-ICP
  '2404.18669', // Bootstrap-GS (skip)
];

function extract(html, id) {
  const title = (html.match(/<title>\[[^\]]+\]\s*([^<]+)<\/title>/) || [])[1]?.trim() || '';
  // authors: from the citation_author spans
  const authors = [...html.matchAll(/citation_author[^>]*content="([^"]+)"/g)].map(m => m[1]);
  const jref = (html.match(/citation_publication_date[^>]*content="([^"]+)"/) || [])[1] || '';
  return { id, title, authors: authors.join('; '), date: jref };
}

let output = {};
for (const id of IDs) {
  const f = join(tmpDir, id.replace(/\./g, '_') + '.html');
  try {
    if (!existsSync(f)) {
      execSync(`curl -sSL -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36" "https://arxiv.org/abs/${id}" -o "${f}"`, { stdio: 'pipe' });
    }
    const html = readFileSync(f, 'utf8');
    output[id] = extract(html, id);
    // basic delay to be gentle
    await new Promise(r => setTimeout(r, 1200));
  } catch (e) {
    output[id] = { id, error: e.message };
  }
}
writeFileSync('/tmp/arxiv_meta.json', JSON.stringify(output, null, 2));
console.log(JSON.stringify(output, null, 2));
