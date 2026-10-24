"""Documented Arma command pipe, used only for run-owned rendering clients."""
import ctypes
from ctypes import wintypes
import msvcrt
import time

class ArmaPipe:
    def __init__(self,name): self.pipe=open('\\\\.\\pipe\\'+name,'r+b',buffering=0)
    def close(self): self.pipe.close()
    def send(self,command,reply=False):
        self.pipe.write(command.encode('utf-8'))
        if not reply: time.sleep(.15); return ''
        peek=ctypes.windll.kernel32.PeekNamedPipe
        peek.argtypes=[wintypes.HANDLE,ctypes.c_void_p,wintypes.DWORD,ctypes.c_void_p,ctypes.POINTER(wintypes.DWORD),ctypes.c_void_p]
        peek.restype=wintypes.BOOL
        available=wintypes.DWORD(); handle=msvcrt.get_osfhandle(self.pipe.fileno()); deadline=time.monotonic()+2
        while time.monotonic()<deadline:
            if not peek(handle,None,0,None,ctypes.byref(available),None): raise ctypes.WinError()
            if available.value: return self.pipe.read(available.value).decode('utf-8',errors='replace')
            time.sleep(.05)
        raise TimeoutError('No command pipe reply')
