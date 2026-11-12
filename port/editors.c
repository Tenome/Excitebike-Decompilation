/* Excitebike Editors: starts the browser editors (track, tiles, music) by running tools/editor/serve.py with Python 3. Windows only; a small program so there is
 * nothing to open from a command line. It looks for Python through the launcher ("py -3") and then "python". */
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <shellapi.h>
#include <stdio.h>

static int try_run(const char *exe, const char *args, const char *dir) {
    HINSTANCE r = ShellExecuteA(NULL, "open", exe, args, dir, SW_HIDE);
    return (INT_PTR)r > 32;
}

int WINAPI WinMain(HINSTANCE inst, HINSTANCE prev, LPSTR cmd, int show) {
    (void)inst; (void)prev; (void)cmd; (void)show;
    char dir[MAX_PATH]; GetModuleFileNameA(NULL, dir, MAX_PATH);
    char *slash = strrchr(dir, '\\'); if (slash) *slash = 0;
    char script[MAX_PATH * 2]; snprintf(script, sizeof script, "%s\\tools\\editor\\serve.py", dir);
    if (GetFileAttributesA(script) == INVALID_FILE_ATTRIBUTES) { MessageBoxA(NULL, "tools\\editor\\serve.py was not found next to this program.", "Excitebike Editors", MB_ICONERROR); return 1; }
    char args[MAX_PATH * 3]; snprintf(args, sizeof args, "-3 \"%s\" excitebike.nes", script);
    if (try_run("py", args, dir)) return 0;
    snprintf(args, sizeof args, "\"%s\" excitebike.nes", script);
    if (try_run("python", args, dir)) return 0;
    MessageBoxA(NULL, "The editors need Python 3 (https://www.python.org/downloads/). Install it, then start this program again.\n\nThe game itself does not need Python.", "Excitebike Editors", MB_ICONERROR);
    return 1;
}
