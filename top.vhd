library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    generic (
        BLINK_MAX : natural := 13_500_000
    );
    port (
        clk : in std_logic;
        led : out std_logic_vector(5 downto 0)
    );
end top;

architecture rtl of top is
    signal counter : unsigned(23 downto 0) := (others => '0');
    signal blink   : std_logic             := '0';
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

end rtl;
