"""Refresh linked, circular README avatars using GitHub contributor counts."""
import html
import io
import json
import os
from pathlib import Path
import subprocess
from urllib.request import urlopen

from PIL import Image, ImageDraw, ImageOps

ROOT = Path(__file__).resolve().parents[1]
START = '<!-- CONTRIBUTORS:START -->'
END = '<!-- CONTRIBUTORS:END -->'


def main():
    repo = os.environ.get('GITHUB_REPOSITORY', 'muzzammil763/Rafeeq')
    pages = json.loads(subprocess.check_output([
        'gh', 'api', '--paginate', '--slurp',
        f'repos/{repo}/contributors?per_page=100',
    ], text=True))
    contributors = sorted(
        (user for page in pages for user in page if user.get('type') == 'User'),
        key=lambda user: (-user['contributions'], user['login'].lower()),
    )
    if not contributors:
        raise RuntimeError('No contributors returned; preserving existing README.')
    readme = ROOT / 'README.md'
    before, remaining = readme.read_text().split(START, 1)
    _, after = remaining.split(END, 1)
    output = ROOT / '.github/readme/contributors'
    output.mkdir(parents=True, exist_ok=True)
    lines = ['<p>']
    for user in contributors:
        login = html.escape(user['login'], quote=True)
        filename = f"{int(user['id'])}.png"
        # Render transparency into the image: GitHub strips border-radius CSS.
        with urlopen(user['avatar_url'], timeout=30) as response:
            avatar = ImageOps.fit(Image.open(io.BytesIO(response.read())).convert('RGBA'), (256, 256))
        mask = Image.new('L', (256, 256), 0)
        ImageDraw.Draw(mask).ellipse((0, 0, 255, 255), fill=255)
        avatar.putalpha(mask)
        avatar.resize((128, 128), Image.Resampling.LANCZOS).save(output / filename)
        lines.append(
            f'  <a href="https://github.com/{login}"><img '
            f'src=".github/readme/contributors/{filename}" '
            f'alt="{login}" title="{login}" width="64" height="64"></a>'
        )
    lines.append('</p>')
    readme.write_text(before + START + '\n' + '\n'.join(lines) + '\n' + END + after)
    print(f'Updated {len(contributors)} contributors in descending contribution order.')


if __name__ == '__main__':
    main()
