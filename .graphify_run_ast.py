import json
from pathlib import Path
from graphify.detect import detect

from graphify.extract import collect_files, extract


def main():
    d = detect(Path('.'))
    code_files = []
    for f in d.get('files', {}).get('code', []):
        p = Path(f)
        if p.is_dir():
            code_files.extend(list(collect_files(p)))
        else:
            code_files.append(p)

    if code_files:
        # extract expects Path objects; limit workers on Windows
        try:
            res = extract(code_files, max_workers=1)
        except TypeError:
            res = extract(code_files)
    else:
        res = {'nodes': [], 'edges': [], 'input_tokens': 0, 'output_tokens': 0}

    Path('.graphify_ast.json').write_text(json.dumps(res, indent=2))
    print('AST: {} nodes, {} edges'.format(len(res.get('nodes', [])), len(res.get('edges', []))))


if __name__ == '__main__':
    try:
        from multiprocessing import freeze_support
        freeze_support()
    except Exception:
        pass
    main()
