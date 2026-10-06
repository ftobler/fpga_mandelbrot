library ieee;
use ieee.std_logic_1164.all;

entity tb_top is
end tb_top;

architecture sim of tb_top is
    constant CLK_PERIOD : time    := 1 sec / 27_000_000;
    constant BLINK_MAX  : natural := 10;

    signal clk : std_logic := '0';
    signal led : std_logic_vector(5 downto 0);
begin

    dut : entity work.top
        generic map (
            BLINK_MAX => BLINK_MAX
        )
        port map (
            clk => clk,
            led => led
        );

    clk <= not clk after CLK_PERIOD / 2;

    process
        variable edges : natural := 0;
    begin
        wait until rising_edge(clk);
        assert led = "111111"
            report "LEDs should be off (active-low) at start"
            severity failure;

        loop
            wait until rising_edge(clk);
            wait for 1 ns;
            edges := edges + 1;
            exit when led = "000000";
        end loop;

        assert edges = BLINK_MAX - 1
            report "first toggle should happen after BLINK_MAX - 1 edges, got " &
                         integer'image(edges)
            severity failure;

        loop
            wait until rising_edge(clk);
            wait for 1 ns;
            edges := edges + 1;
            exit when led = "111111";
        end loop;

        assert edges = 2 * BLINK_MAX - 1
            report "second toggle should happen after 2*BLINK_MAX - 1 edges, got " &
                         integer'image(edges)
            severity failure;

        report "tb_top PASSED" severity note;
        std.env.stop;
    end process;

end sim;
