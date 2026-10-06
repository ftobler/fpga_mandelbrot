# Tang Nano 20K (GW2AR-LV18QN88C8/I7) — build / test / load

top    := "top"
tb     := "tb_top"
cst    := "tangnano20k.cst"
device := "GW2AR-LV18QN88C8/I7"
family := "GW2A-18C"
board  := "tangnano20k"
build  := "build"
venv   := ".venv"
oss    := "oss-cad-suite/bin"

set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

# list available recipes
default:
    @just --list

# create the Python venv (cocotb + apycula/gowin_pack)
venv:
    python3 -m venv {{venv}}
    {{venv}}/bin/pip install --upgrade pip
    {{venv}}/bin/pip install cocotb apycula

# analyze and elaborate the design (fast syntax check)
check:
    ghdl -a --std=08 {{top}}.vhd
    ghdl -e --std=08 {{top}}

# synthesize, place & route, pack a bitstream
build: check venv
    @mkdir -p {{build}}
    ghdl synth --std=08 --out=verilog {{top}}.vhd -e {{top}} > {{build}}/{{top}}.v
    yosys -p "read_verilog {{build}}/{{top}}.v; synth_gowin -top {{top}} -family gw2a -json {{build}}/{{top}}.json"
    {{oss}}/nextpnr-himbaechel --json {{build}}/{{top}}.json --write {{build}}/{{top}}_pnr.json \
        --device {{device}} --vopt family={{family}} --vopt cst={{cst}} --timing-allow-fail
    {{venv}}/bin/gowin_pack -d {{family}} -o {{build}}/{{top}}.fs {{build}}/{{top}}_pnr.json

# run the GHDL testbench
test:
    ghdl -a --std=08 {{top}}.vhd {{tb}}.vhd
    ghdl -e --std=08 {{tb}}
    ghdl -r --std=08 {{tb}} --stop-time=10us

# load bitstream into SRAM (volatile, lost on power-off)
load: build
    openFPGALoader -b {{board}} {{build}}/{{top}}.fs

# write bitstream to the onboard SPI flash (persists across power cycles)
flash: build
    openFPGALoader -b {{board}} -f {{build}}/{{top}}.fs

# remove generated files
clean:
    rm -rf {{build}} work-obj08.cf *.cf
