library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    generic (
        CLK_FREQ  : natural := 27_000_000; -- 27 MHz
        BLINK_MAX : natural := 13_500_000
    );
    port (
        clk : in std_logic;
        led : out std_logic_vector(5 downto 0);
        ws2812 : out std_logic
    );
end top;

architecture rtl of top is
    signal counter : unsigned(23 downto 0) := (others => '0');
    signal blink   : std_logic             := '0';

    signal ws2812_data : std_logic_vector(23 downto 0) := x"000000";

    component ws2812_entity
        generic (
            CLK_FREQ     : natural := 27_000_000; -- 27 MHz
            LED_COUNT    : natural := 1 -- Number of WS2812 LEDs
        );
        port (
            clk         : in std_logic;
            ws2812_out  : out std_logic;
            data        : in std_logic_vector(LED_COUNT * 24 - 1 downto 0)
        );
    end component;

begin

    process (clk)
    begin
        if rising_edge(clk) then
            if counter = BLINK_MAX - 1 then
                counter <= to_unsigned(0, counter'length);
                blink   <= not blink;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    led(0) <= blink;
    led(1) <= not blink;
    led(2) <= blink;
    led(3) <= not blink;
    led(4) <= blink;
    led(5) <= not blink;
    ws2812_data <= x"0F0000" when blink = '1' else x"000F00";

    ws2812_module_inst : ws2812_entity
        generic map (
            CLK_FREQ     => CLK_FREQ,
            LED_COUNT    => 1
        )
        port map (
            clk         => clk,
            ws2812_out  => ws2812,
            data        => ws2812_data
        );

end rtl;
