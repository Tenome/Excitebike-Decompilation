#!/usr/bin/env python3
"""Tests for the editor server's local API (needs no ROM and never starts the port).  python tests/test_serve.py"""
import http.client, json, os, socketserver, sys, tempfile, threading, unittest
ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
sys.path.insert(0, os.path.join(ROOT, 'tools', 'editor')); sys.path.insert(0, os.path.join(ROOT, 'tools'))
sys.argv = [sys.argv[0], os.path.join(ROOT, 'no-such-rom.nes')]
import serve, levelpack, ebdesign

class Api(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.tmp = tempfile.TemporaryDirectory(); serve.PLAY = cls.tmp.name; serve.AUDIO = os.path.join(cls.tmp.name, 'audio'); serve.EXE = None
        serve.ensure_play_files = lambda: os.makedirs(serve.AUDIO, exist_ok=True)
        cls.srv = socketserver.TCPServer(('127.0.0.1', 0), serve.H); cls.port = cls.srv.server_address[1]
        threading.Thread(target=cls.srv.serve_forever, daemon=True).start()
    @classmethod
    def tearDownClass(cls): cls.srv.shutdown(); cls.srv.server_close(); cls.tmp.cleanup()
    def post(self, path, body, headers=None, host=None):
        c = http.client.HTTPConnection('127.0.0.1', self.port); h = {'X-Eb-Editor': '1', 'Host': host or '127.0.0.1:%d' % self.port}; h.update(headers or {})
        c.request('POST', path, body=body, headers=h); r = c.getresponse(); return r.status, json.loads(r.read() or b'{}')
    def test_put_song(self):
        s, j = self.post('/api/put?name=song_01.ebm', b'EBM1\nvoice tri\nn 48 4\n'); self.assertEqual(s, 200); self.assertFalse(j['ok'])   # saved, but no port to start
        self.assertTrue(os.path.exists(os.path.join(serve.AUDIO, 'song_01.ebm')))
    def test_refusals(self):
        self.assertEqual(self.post('/api/put?name=song_01.ebm', b'EBM1', headers={'X-Eb-Editor': '0'})[0], 403)
        self.assertEqual(self.post('/api/put?name=song_01.ebm', b'EBM1', host='evil.example:80')[0], 403)
        self.assertEqual(self.post('/api/put?name=song_01.ebm', b'EBM1', headers={'Origin': 'http://evil.example'})[0], 403)
        self.assertEqual(self.post('/api/put?name=../x.bmp', b'x')[0], 400); self.assertEqual(self.post('/api/put?name=song_01.ebm', b'not a song')[0], 400)
    def test_play(self):
        p = levelpack.make_pack(ebdesign.serialize(1, [('run', 0, 4), ('piece', 9, False)]), 'Play Me', 'me')
        s, j = self.post('/api/play', json.dumps(p).encode()); self.assertEqual(s, 200); self.assertTrue(os.path.exists(os.path.join(serve.PLAY, 'level.ebpack.json')))
        bad = dict(p, title=''); s, j = self.post('/api/play', json.dumps(bad).encode()); self.assertFalse(j['ok']); self.assertIn('title', j['message'])
if __name__ == '__main__': unittest.main(argv=[sys.argv[0]])
