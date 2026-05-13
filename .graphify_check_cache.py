import json
from pathlib import Path
from graphify.detect import detect
from graphify.cache import check_semantic_cache

r = json.loads(Path('.graphify_detect.json').read_text()) if Path('.graphify_detect.json').exists() else detect(Path('.'))
all_files = [f for files in r.get('files', {}).values() for f in files]
cached_nodes, cached_edges, cached_hyperedges, uncached = check_semantic_cache(all_files)
Path('.graphify_cached.json').write_text(json.dumps({'nodes': cached_nodes, 'edges': cached_edges, 'hyperedges': cached_hyperedges}, indent=2))
Path('.graphify_uncached.txt').write_text('\n'.join(uncached))
print(f'Cache hit: {len(all_files)-len(uncached)} files, uncached: {len(uncached)} files')
