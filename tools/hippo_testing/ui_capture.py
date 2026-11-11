"""Capture an Arma client window (UI included) for run.py --ui-shots."""
import ctypes
import time
from ctypes import wintypes
from pathlib import Path

user32 = ctypes.WinDLL('user32', use_last_error=True)
gdi32 = ctypes.WinDLL('gdi32', use_last_error=True)
user32.SetProcessDPIAware()

EnumWindowsProc = ctypes.WINFUNCTYPE(wintypes.BOOL, wintypes.HWND, wintypes.LPARAM)


def find_window(pid):
    """Largest visible top-level window owned by the process."""
    found = []

    def callback(hwnd, _):
        owner = wintypes.DWORD()
        user32.GetWindowThreadProcessId(hwnd, ctypes.byref(owner))
        if owner.value == pid and user32.IsWindowVisible(hwnd):
            rect = wintypes.RECT()
            user32.GetClientRect(hwnd, ctypes.byref(rect))
            found.append((rect.right * rect.bottom, hwnd))
        return True

    user32.EnumWindows(EnumWindowsProc(callback), 0)
    return max(found)[1] if found else None


def _print_window(hwnd, width, height):
    from PIL import Image

    window_dc = user32.GetDC(hwnd)
    memory_dc = gdi32.CreateCompatibleDC(window_dc)
    bitmap = gdi32.CreateCompatibleBitmap(window_dc, width, height)
    gdi32.SelectObject(memory_dc, bitmap)
    # PW_CLIENTONLY | PW_RENDERFULLCONTENT captures DirectX swap chains.
    user32.PrintWindow(hwnd, memory_dc, 1 | 2)

    class BITMAPINFOHEADER(ctypes.Structure):
        _fields_ = [('biSize', wintypes.DWORD), ('biWidth', wintypes.LONG), ('biHeight', wintypes.LONG),
                    ('biPlanes', wintypes.WORD), ('biBitCount', wintypes.WORD), ('biCompression', wintypes.DWORD),
                    ('biSizeImage', wintypes.DWORD), ('biXPelsPerMeter', wintypes.LONG), ('biYPelsPerMeter', wintypes.LONG),
                    ('biClrUsed', wintypes.DWORD), ('biClrImportant', wintypes.DWORD)]

    header = BITMAPINFOHEADER(ctypes.sizeof(BITMAPINFOHEADER), width, -height, 1, 32, 0, 0, 0, 0, 0, 0)
    buffer = ctypes.create_string_buffer(width * height * 4)
    gdi32.GetDIBits(memory_dc, bitmap, 0, height, buffer, ctypes.byref(header), 0)
    gdi32.DeleteObject(bitmap)
    gdi32.DeleteDC(memory_dc)
    user32.ReleaseDC(hwnd, window_dc)
    return Image.frombuffer('RGB', (width, height), buffer, 'raw', 'BGRX', 0, 1).copy()


def capture(pid, path: Path):
    """Save the client area of the game window. Returns True when an image was written."""
    from PIL import ImageGrab, ImageStat

    hwnd = find_window(pid)
    if not hwnd:
        return False
    rect = wintypes.RECT()
    user32.GetClientRect(hwnd, ctypes.byref(rect))
    width, height = rect.right, rect.bottom
    if width < 16 or height < 16:
        return False
    image = _print_window(hwnd, width, height)
    if max(band[1] for band in ImageStat.Stat(image).extrema) < 8:
        # Fall back to a screen grab of the client area (window must be visible).
        origin = wintypes.POINT(0, 0)
        user32.ClientToScreen(hwnd, ctypes.byref(origin))
        user32.SetForegroundWindow(hwnd)
        time.sleep(0.3)
        image = ImageGrab.grab(bbox=(origin.x, origin.y, origin.x + width, origin.y + height), all_screens=True)
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path)
    return True


def key(pid, scan=0x1C):
    """Bring the game forward and tap one key by scan code (default Enter; DirectInput reads scan codes)."""
    hwnd = find_window(pid)
    if not hwnd:
        return False
    user32.SetForegroundWindow(hwnd)
    time.sleep(0.4)

    class KEYBDINPUT(ctypes.Structure):
        _fields_ = [('wVk', wintypes.WORD), ('wScan', wintypes.WORD), ('dwFlags', wintypes.DWORD),
                    ('time', wintypes.DWORD), ('dwExtraInfo', ctypes.c_size_t)]

    class INPUT(ctypes.Structure):
        _fields_ = [('type', wintypes.DWORD), ('ki', KEYBDINPUT), ('pad', ctypes.c_ubyte * 8)]

    for flags in (0x0008, 0x0008 | 0x0002):  # KEYEVENTF_SCANCODE, then key up
        event = INPUT(1, KEYBDINPUT(0, scan, flags, 0, 0))
        user32.SendInput(1, ctypes.byref(event), ctypes.sizeof(INPUT))
        time.sleep(0.05)
    return True


def wheel(pid, clicks=-1):
    """Bring the game forward and send a mouse-wheel tick (opens the action menu)."""
    hwnd = find_window(pid)
    if not hwnd:
        return False
    user32.SetForegroundWindow(hwnd)
    time.sleep(0.4)

    class MOUSEINPUT(ctypes.Structure):
        _fields_ = [('dx', wintypes.LONG), ('dy', wintypes.LONG), ('mouseData', wintypes.DWORD),
                    ('dwFlags', wintypes.DWORD), ('time', wintypes.DWORD), ('dwExtraInfo', ctypes.c_size_t)]

    class INPUT(ctypes.Structure):
        _fields_ = [('type', wintypes.DWORD), ('mi', MOUSEINPUT)]

    event = INPUT(0, MOUSEINPUT(0, 0, ctypes.c_uint32(120 * clicks).value, 0x0800, 0, 0))
    user32.SendInput(1, ctypes.byref(event), ctypes.sizeof(INPUT))
    return True
