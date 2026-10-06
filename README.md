# fpga_mandelbrot

Tang Nano 20K (`GW2AR-LV18QN88C8/I7`) VHDL project. Currently a simple LED blink.

## Install

Simulation, synthesis and loader (Debian/Ubuntu):

```sh
sudo apt install ghdl yosys openfpgaloader
```

Place & route uses `nextpnr-himbaechel`, which has no apt/pip package. Get it from
[OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build) and put it on `PATH`.
The justfile assumes it is in `oss-cad-suite/` in the project folder

```sh
source /path/to/oss-cad-suite/environment
```

Python tooling (`cocotb`, and `apycula`/`gowin_pack`) in a local venv:

```sh
just venv
```

## Use

```sh
just build   # synthesize + place & route + pack -> build/top.fs
just test    # GHDL simulation of tb_top
just load    # program board SRAM (volatile)
just flash   # program onboard SPI flash (persistent)
just clean
```

## Files

| File | Purpose |
|------|---------|
| `top.vhd` | design; `BLINK_MAX` generic sets the blink rate |
| `tb_top.vhd` | GHDL testbench |
| `tangnano20k.cst` | pin constraints |
| `justfile` | build / test / load recipes |
