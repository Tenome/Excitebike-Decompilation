/* Audio mods: WAV files that replace the game's music and sound effects. Files in the mod folder are named <channel>_<request hex>.wav,
 * e.g. music_01.wav, pulse1_04.wav, pulse2_01.wav, noise_02.wav (the request byte the game sends, see c/sound.inc). PCM 8/16-bit, mono or stereo, any rate.
 * A request with a file is played from the file and not sent to the original sound code. music_* loops until the next music request. */
#pragma once
#include <stdint.h>
int audiomod_load(const char *dir);                       /* returns the number of files found */
int audiomod_request(int chan, int value);                /* hook for g_hal_sound: nonzero when a file replaces the request */
void audiomod_mix(int16_t *buf, int n);                   /* adds the playing files into 44.1 kHz mono samples */
