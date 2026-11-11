#!/usr/bin/env python3
"""Start the Excitebike editors (track, tiles, music) in your browser.
  python tools/editor/serve.py [path/to/excitebike.nes]
Builds editor/data.js from your own ROM first (it holds the game's graphics and tracks, so it is never shipped), then serves this folder on localhost.
With the port built (build/port/excitebike.exe, excitebike.exe or excitebike next to the repository) the editors' "Play in port" and "Send to port" buttons work: the files go
to play/ and the port is started with --watch, so later sends are picked up within a second. Only this machine can reach the server, and only requests from the editors' own pages are accepted."""
import http.server, json, os, re, socketserver, subprocess, sys, threading, webbrowser
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
rom = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'orig', 'excitebike_us.nes'))
sys.path.insert(0, os.path.join(ROOT, 'tools')); import ebdesign, levelpack, chrbmp
ebdesign.ROM_PATH = rom
PLAY = os.path.join(ROOT, 'play'); AUDIO = os.path.join(PLAY, 'audio')
EXES = [os.path.join(ROOT, 'build', 'port', 'excitebike.exe'), os.path.join(ROOT, 'excitebike.exe'), os.path.join(ROOT, 'excitebike')]
EXE = next((e for e in EXES if os.path.exists(e)), None)
PPU = os.path.join(ROOT, 'build', 'port', 'race.ppu')

if os.path.exists(rom):
    if EXE and not os.path.exists(PPU):                      # colours come from a real race frame of the port
        os.makedirs(os.path.dirname(PPU), exist_ok=True)
        subprocess.run([EXE, rom, '--frames', '1500', '--press', '200=08,260=01', '--shot', os.path.join(os.path.dirname(PPU), 'serve_tmp.bmp'), '--dump-ppu', PPU], capture_output=True)
    d = os.path.join(HERE, 'data.js')
    open(d, 'w').write('window.EB_DATA = ' + json.dumps(ebdesign.editor_data(PPU if os.path.exists(PPU) else None)) + ';\n'); print('data.js built from', rom)
else: print('ROM not found (%s): the editors start without the game data' % rom)

proc = None
def ensure_play_files():
    os.makedirs(AUDIO, exist_ok=True)
    t = os.path.join(PLAY, 'tiles.bmp')
    if not os.path.exists(t): chrbmp.write_bmp(t, chrbmp.chr_to_pixels(ebdesign.load_rom(rom)[1]))
    c = os.path.join(PLAY, 'colors.pal')
    if not os.path.exists(c): open(c, 'wb').write(bytes(v for col in levelpack.DEFAULT_PAL for v in col))
def launch():
    global proc
    if not EXE: return False, 'The port is not built yet (looked for %s).' % ', '.join(os.path.relpath(e, ROOT) for e in EXES)
    if not os.path.exists(rom): return False, 'ROM not found: ' + rom
    if proc is not None and proc.poll() is None: return True, 'Sent. The running port reloads it within a second; start a new race on track 1 to see a changed level.'
    ensure_play_files()
    proc = subprocess.Popen([EXE, rom, '--track', '1=' + os.path.join(PLAY, 'level.ebpack.json'), '--chr-bmp', os.path.join(PLAY, 'tiles.bmp'), '--palette', os.path.join(PLAY, 'colors.pal'),
                             '--audio-mod', AUDIO, '--watch', '--autostart'], cwd=ROOT)
    return True, 'Port started: it goes straight into a race on track 1.'

NAMES = re.compile(r'^(tiles\.bmp|colors\.pal|song_[0-9a-f]{2}\.ebm|level\.ebpack\.json)$')
class H(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *a): pass
    def _reply(self, code, obj):
        b = json.dumps(obj).encode(); self.send_response(code); self.send_header('Content-Type', 'application/json'); self.send_header('Content-Length', str(len(b))); self.end_headers(); self.wfile.write(b)
    def _allowed(self):                                      # same-origin requests from our own pages only (no other website or DNS-rebinding host can drive this)
        port = self.server.server_address[1]; host = self.headers.get('Host', '')
        if host not in ('127.0.0.1:%d' % port, 'localhost:%d' % port): return False
        o = self.headers.get('Origin')
        if o is not None and o not in ('http://127.0.0.1:%d' % port, 'http://localhost:%d' % port): return False
        return self.headers.get('X-Eb-Editor') == '1'
    def do_POST(self):
        if not self._allowed(): return self._reply(403, dict(ok=False, message='refused'))
        n = int(self.headers.get('Content-Length', 0) or 0)
        if n > 400000: return self._reply(413, dict(ok=False, message='too large'))
        body = self.rfile.read(n); path, _, qs = self.path.partition('?')
        if path == '/api/put':
            m = re.search(r'name=([^&]+)', qs); name = m.group(1) if m else ''
            if not NAMES.match(name): return self._reply(400, dict(ok=False, message='file name not allowed'))
            ensure_play_files(); dest = os.path.join(AUDIO if name.endswith('.ebm') else PLAY, name)
            if name.endswith('.ebm') and not body.startswith(b'EBM1'): return self._reply(400, dict(ok=False, message='not an .ebm song'))
            open(dest, 'wb').write(body); ok, msg = launch(); return self._reply(200, dict(ok=ok, message=msg))
        if path == '/api/play':
            try: p = json.loads(body.decode('utf-8'))
            except Exception: return self._reply(400, dict(ok=False, message='not JSON'))
            e = levelpack.problems(p)
            if e: return self._reply(200, dict(ok=False, message='Cannot play yet: ' + '; '.join(e)))
            ensure_play_files(); open(os.path.join(PLAY, 'level.ebpack.json'), 'w', encoding='utf-8').write(json.dumps(p, indent=2) + '\n')
            ok, msg = launch(); return self._reply(200, dict(ok=ok, message=msg))
        self._reply(404, dict(ok=False, message='unknown'))
os.chdir(HERE)
if __name__ == '__main__':
    with socketserver.TCPServer(('127.0.0.1', 0), H) as srv:
        port = srv.server_address[1]; url = 'http://127.0.0.1:%d/index.html' % port
        print('editors at', url, '(music.html, tiles.html too); Ctrl+C stops'); threading.Timer(0.5, lambda: webbrowser.open(url)).start()
        try: srv.serve_forever()
        except KeyboardInterrupt: pass
