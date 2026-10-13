"""Copy the validated content in data/ into the Flutter app assets (ADR-003).

- data/question-bank/questions.json, exam-structures.json  -> src/app/assets/data/
- data/sign-catalog/signs.json                              -> src/app/assets/data/
- question images / sign images                             -> src/app/assets/images/{questions,signs}/
Image paths inside the JSON are rewritten to full asset paths ("assets/images/questions/q0301.jpeg").
Writes assets/data/content_version.json (data version + SHA-256 of every JSON file) — a unit test in the app
compares it with the files, so a forgotten or partial sync fails the tests.

Run the validators first:
  python tools/validate_data/validate_questions.py && python tools/validate_data/validate_signs.py
  python tools/sync_assets.py
"""
import hashlib
import json
import os
import shutil
from datetime import date

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
APP = os.path.join(ROOT, 'src', 'app', 'assets')
QB = os.path.join(ROOT, 'data', 'question-bank')
SC = os.path.join(ROOT, 'data', 'sign-catalog')


def copy_images(src_dir, dst_dir, wanted):
    if os.path.isdir(dst_dir):
        shutil.rmtree(dst_dir)
    os.makedirs(dst_dir)
    for rel in sorted(wanted):
        shutil.copy2(os.path.join(src_dir, rel), os.path.join(dst_dir, os.path.basename(rel)))
    return len(wanted)


def main():
    os.makedirs(os.path.join(APP, 'data'), exist_ok=True)

    bank = json.load(open(os.path.join(QB, 'questions.json'), encoding='utf-8'))
    q_imgs = {p for q in bank['questions'] for p in q['images']}
    for q in bank['questions']:
        q['images'] = [f'assets/images/questions/{os.path.basename(p)}' for p in q['images']]
    n_q = copy_images(QB, os.path.join(APP, 'images', 'questions'), q_imgs)

    signs = json.load(open(os.path.join(SC, 'signs.json'), encoding='utf-8'))
    s_imgs = {p for s in signs['signs'] for p in s['images']}
    for s in signs['signs']:
        s['images'] = [f'assets/images/signs/{os.path.basename(p)}' for p in s['images']]
    n_s = copy_images(SC, os.path.join(APP, 'images', 'signs'), s_imgs)

    structures = json.load(open(os.path.join(QB, 'exam-structures.json'), encoding='utf-8'))

    hashes = {}
    for name, obj in (('questions.json', bank), ('exam-structures.json', structures), ('signs.json', signs)):
        path = os.path.join(APP, 'data', name)
        data = json.dumps(obj, ensure_ascii=False, separators=(',', ':')).encode('utf-8')
        with open(path, 'wb') as fh:
            fh.write(data)
        hashes[name] = hashlib.sha256(data).hexdigest()

    combined = hashlib.sha256(''.join(hashes[k] for k in sorted(hashes)).encode()).hexdigest()[:12]
    version = {'contentVersion': f'{date.today().isoformat()}-{combined}',
               'questionSource': bank['sourceVersion'], 'signSource': signs['source']['doc'],
               'sha256': hashes}
    with open(os.path.join(APP, 'data', 'content_version.json'), 'w', encoding='utf-8') as fh:
        json.dump(version, fh, ensure_ascii=False, indent=1)

    size = sum(os.path.getsize(os.path.join(d, f)) for d, _, fs in os.walk(APP) for f in fs) / 1e6
    print(f'{len(bank["questions"])} questions ({n_q} images), {len(signs["signs"])} signs ({n_s} images), '
          f'{len(structures["structures"])} exam structures -> {APP} ({size:.1f} MB); version {version["contentVersion"]}')


if __name__ == '__main__':
    main()
