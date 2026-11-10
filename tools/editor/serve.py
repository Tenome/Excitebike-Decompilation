#!/usr/bin/env python3
"""Start the Excitebike editors (track, tiles, music) in your browser.
  python tools/editor/serve.py [path/to/excitebike.nes]
Builds editor/data.js from your own ROM first (it holds the game's graphics and tracks, so it is never shipped), then serves this folder on localhost."""
import http.server, os, socketserver, subprocess, sys, threading, webbrowser
HERE = os.path.dirname(os.path.abspath(__file__)); ROOT = os.path.abspath(os.path.join(HERE, '..', '..'))
rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, 'orig', 'excitebike_us.nes')
sys.path.insert(0, os.path.join(ROOT, 'tools')); import ebdesign
ebdesign.ROM_PATH = rom
if os.path.exists(rom):
    d = os.path.join(HERE, 'data.js'); ppu = os.path.join(ROOT, 'build', 'port', 'race.ppu')
    for exe in (os.path.join(ROOT, 'build', 'port', 'excitebike.exe'), os.path.join(ROOT, 'excitebike.exe'), os.path.join(ROOT, 'excitebike')):   # colours come from a real race frame of the port
        if os.path.exists(exe) and not os.path.exists(ppu):
            os.makedirs(os.path.dirname(ppu), exist_ok=True)
            subprocess.run([exe, rom, '--frames', '1500', '--press', '200=08,260=01', '--shot', os.path.join(os.path.dirname(ppu), 'serve_tmp.bmp'), '--dump-ppu', ppu], capture_output=True)
    import json
    open(d, 'w').write('window.EB_DATA = ' + json.dumps(ebdesign.editor_data(ppu if os.path.exists(ppu) else None)) + ';\n'); print('data.js built from', rom)
else: print('ROM not found (%s): the editors start without the game data' % rom)
os.chdir(HERE)
class H(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *a): pass
with socketserver.TCPServer(('127.0.0.1', 0), H) as srv:
    port = srv.server_address[1]; url = 'http://127.0.0.1:%d/index.html' % port
    print('editors at', url, '(music.html, tiles.html too); Ctrl+C stops'); threading.Timer(0.5, lambda: webbrowser.open(url)).start()
    try: srv.serve_forever()
    except KeyboardInterrupt: pass
