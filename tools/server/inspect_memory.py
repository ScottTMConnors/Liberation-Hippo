"""Read-only large-page sampling for the server and HCs in an owned session."""
import argparse
import ctypes as c
from ctypes import wintypes as w
import json
from pathlib import Path


class Region(c.Structure):
    _fields_ = [('base', c.c_void_p), ('allocation', c.c_void_p),
                ('allocation_protect', w.DWORD), ('partition', w.WORD),
                ('size', c.c_size_t), ('state', w.DWORD),
                ('protect', w.DWORD), ('type', w.DWORD)]


class Page(c.Structure):
    _fields_ = [('address', c.c_void_p), ('flags', c.c_size_t)]


class Luid(c.Structure):
    _fields_ = [('low', w.DWORD), ('high', w.LONG)]


class Privilege(c.Structure):
    _fields_ = [('luid', Luid), ('attributes', w.DWORD)]


def lock_memory_privilege(handle, kernel):
    security = c.WinDLL('advapi32', use_last_error=True)
    security.OpenProcessToken.argtypes = [w.HANDLE, w.DWORD, c.POINTER(w.HANDLE)]
    security.GetTokenInformation.argtypes = [w.HANDLE, c.c_int, c.c_void_p, w.DWORD, c.POINTER(w.DWORD)]
    security.LookupPrivilegeNameW.argtypes = [w.LPCWSTR, c.POINTER(Luid), w.LPWSTR, c.POINTER(w.DWORD)]
    token = w.HANDLE()
    if not security.OpenProcessToken(handle, 8, c.byref(token)):
        raise c.WinError(c.get_last_error())
    try:
        size = w.DWORD()
        security.GetTokenInformation(token, 3, None, 0, c.byref(size))
        data = c.create_string_buffer(size.value)
        if not security.GetTokenInformation(token, 3, data, size.value, c.byref(size)):
            raise c.WinError(c.get_last_error())
        count = w.DWORD.from_buffer_copy(data.raw[:4]).value
        for index in range(count):
            item = Privilege.from_buffer_copy(data.raw, 4 + index * c.sizeof(Privilege))
            text = c.create_unicode_buffer(256)
            length = w.DWORD(256)
            if not security.LookupPrivilegeNameW(None, c.byref(item.luid), text, c.byref(length)):
                raise c.WinError(c.get_last_error())
            if text.value == 'SeLockMemoryPrivilege':
                return {'assigned': True, 'enabled': bool(item.attributes & 2)}
        return {'assigned': False, 'enabled': False}
    finally:
        kernel.CloseHandle(token)


def inspect(pid):
    kernel = c.WinDLL('kernel32', use_last_error=True)
    kernel.OpenProcess.argtypes = [w.DWORD, w.BOOL, w.DWORD]
    kernel.OpenProcess.restype = w.HANDLE
    kernel.CloseHandle.argtypes = [w.HANDLE]
    kernel.VirtualQueryEx.argtypes = [w.HANDLE, c.c_void_p, c.POINTER(Region), c.c_size_t]
    kernel.VirtualQueryEx.restype = c.c_size_t
    kernel.K32QueryWorkingSetEx.argtypes = [w.HANDLE, c.c_void_p, w.DWORD]
    kernel.K32QueryWorkingSetEx.restype = w.BOOL
    handle = kernel.OpenProcess(0x400, False, pid)  # PROCESS_QUERY_INFORMATION
    if not handle:
        raise c.WinError(c.get_last_error())
    try:
        region = Region()
        address = 0
        samples = []
        committed = 0
        while kernel.VirtualQueryEx(handle, address, c.byref(region), c.sizeof(region)):
            base = region.base or 0
            end = base + region.size
            if end <= address:
                break
            if region.state == 0x1000:  # MEM_COMMIT
                committed += region.size
                samples.extend(range(base, end, 2 * 1024 * 1024))
            address = end
        valid = large = 0
        for offset in range(0, len(samples), 4096):
            chunk = samples[offset:offset + 4096]
            pages = (Page * len(chunk))(*(Page(x, 0) for x in chunk))
            if not kernel.K32QueryWorkingSetEx(handle, pages, c.sizeof(pages)):
                raise c.WinError(c.get_last_error())
            valid += sum(bool(x.flags & 1) for x in pages)
            large += sum(bool((x.flags & 1) and (x.flags & (1 << 23))) for x in pages)
        return {'pid': pid, 'lock_memory_privilege': lock_memory_privilege(handle, kernel),
                'committed_regions_MiB': round(committed / 2**20),
                'sampled_addresses': len(samples), 'resident_samples': valid,
                'large_page_samples': large, 'large_pages_observed': large > 0,
                'method': 'VirtualQueryEx regions; QueryWorkingSetEx at 2 MiB intervals (not an exact large-page byte count)'}
    finally:
        kernel.CloseHandle(handle)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--runtime', type=Path, default=Path(__file__).resolve().parents[2] / 'mybuild' / 'lan-server')
    args = parser.parse_args()
    session = json.loads((args.runtime / 'session.json').read_text(encoding='utf-8-sig'))
    result = [{'role': entry['role'], **inspect(entry['pid'])} for entry in session['processes']]
    print(json.dumps(result, indent=2))
