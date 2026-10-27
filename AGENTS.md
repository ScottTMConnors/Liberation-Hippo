# Arma capture environment

Use isolated mission packages and profiles for screenshots and engine checks;
preserve player campaign saves and unrelated game sessions.

Arma 3 is installed at `F:/Medium500/Applications/Steam/steamapps/common/Arma 3`.
Pass this path with `--game-directory` to `tools/hippo_testing/run.py`; the
harness default may point to an older Steam library.

Before stopping for `No monitor found` / DXGI / Direct3D initialization errors,
check the installed virtual display. This workstation has a preconfigured
1920x1080 virtual display using the AMD Radeon RX 6900 XT. Its device is
`ROOT\DISPLAY\0000` (hardware ID `Root\MttVDD`). Problem code 22 means disabled.

The existing machine tasks provide the intended display controls:

```powershell
Start-ScheduledTask -TaskName 'UltimateGore-Display-enable'
Get-Content C:/ProgramData/UltimateGore/DisplayControl/status.json
Get-PnpDevice -Class Display
```

Verify problem code 0 / status OK before launching the rendering client. The
paired `UltimateGore-Display-disable` task restores the original disabled state
after all owned rendering sessions finish. Do not disable it while another task
or user is using it. Do not install another driver or change global power policy.
The task names are machine infrastructure; they do not require running tools or
loading mods from the UltimateGore repository.

Machine control implementation: `C:/ProgramData/UltimateGore/DisplayControl/`.
Settings: `C:/VirtualDisplayDriver/vdd_settings.xml`. This procedure was verified
while following the user's request to reuse the Arma3BuildingDestruction display
setup on 2026-10-26. That checkout records DXGI failures in
`docs/BUILDING_PIPELINE.md`; its original user-profile skill paths may be absent
on this migrated workstation.

After an RDP disconnect, inspect `query session`. If ScottServer is disconnected,
run `Start-ScheduledTask -TaskName 'UltimateGore-Console-recover'` and verify
`C:/ProgramData/UltimateGore/DisplayControl/console-status.json`. This existing
task transfers only that disconnected user session to the console. Refresh game
window bindings afterward. For direct rendering-client launches, set
`SteamAppId=107410` and `SteamGameId=107410` in that launch's environment. Check
the RPT for successful Steam/DLC ownership initialization before entering a
mission; an initialization failure can show a misleading Purchase button.
Wait for prior owned game processes to exit before restarting the same profile.

Capture Workshop images with Steam F12: the native screenshots retain game UI
without the browser automation cursor. The SQF `screenshot` command captures
only the 3D scene and omits menus. Inspect every selected image before upload.
