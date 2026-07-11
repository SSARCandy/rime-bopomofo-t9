# 下載測試台相依（librime 引擎、essay 詞彙表、語法模型）到 tests/deps/
# 用法：python tests/setup_bench.py
# 需要：pip install py7zr
import io
import os
import urllib.request

DEPS = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'deps')

LIBRIME_URL = ('https://github.com/rime/librime/releases/download/'
               '1.17.0/rime-33e7814-Windows-msvc-x64.7z')
ESSAY_URL = 'https://raw.githubusercontent.com/rime/rime-essay/master/essay.txt'
GRAM_URL = ('https://github.com/lotem/rime-octagram-data/raw/hant/'
            'zh-hant-t-essay-bgw.gram')


def fetch(url, dest):
    if os.path.exists(dest):
        print(f'already exists: {dest}')
        return
    print(f'downloading {url}')
    tmp = dest + '.part'
    urllib.request.urlretrieve(url, tmp)
    os.replace(tmp, dest)
    print(f'  -> {dest} ({os.path.getsize(dest)} bytes)')


def main():
    os.makedirs(DEPS, exist_ok=True)

    fetch(ESSAY_URL, os.path.join(DEPS, 'essay.txt'))
    fetch(GRAM_URL, os.path.join(DEPS, 'zh-hant-t-essay-bgw.gram'))

    dll = os.path.join(DEPS, 'librime', 'dist', 'lib', 'rime.dll')
    if os.path.exists(dll):
        print(f'already exists: {dll}')
    else:
        archive = os.path.join(DEPS, 'librime.7z')
        fetch(LIBRIME_URL, archive)
        import py7zr  # pip install py7zr
        with py7zr.SevenZipFile(archive) as z:
            z.extractall(os.path.join(DEPS, 'librime'))
        os.remove(archive)
        print(f'  -> {dll}')

    print('setup complete')


if __name__ == '__main__':
    main()
