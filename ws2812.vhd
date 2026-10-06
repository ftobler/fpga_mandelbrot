library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ws2812_entity is
    generic (
        CLK_FREQ     : natural := 27_000_000; -- 27 MHz
        LED_COUNT    : natural := 1; -- Number of WS2812 LEDs
        DELAY_1_HIGH : natural := CLK_FREQ / 1_000_000 * 850 / 1_000; -- ≈850ns±150ns
        DELAY_1_LOW  : natural := CLK_FREQ / 1_000_000 * 350 / 1_000; -- ≈400ns±150ns
        DELAY_0_HIGH : natural := CLK_FREQ / 1_000_000 * 350 / 1_000; -- ≈400ns±150ns
        DELAY_0_LOW  : natural := CLK_FREQ / 1_000_000 * 850 / 1_000; -- ≈850ns±150ns
        DELAY_RESET  : natural := CLK_FREQ / 1_000_000 * 400          -- ≈100us (min 50µs)
    );
    port (
        clk : in std_logic;
        ws2812_out : out std_logic;
        data : in std_logic_vector(LED_COUNT * 24 - 1 downto 0)
    );
end entity ws2812_entity;

architecture rtl of ws2812_entity is
    type StateType is (RESET, DATA_SEND, BIT_SEND_HIGH, BIT_SEND_LOW);
    signal state : StateType := RESET;
    signal delay_counter : unsigned(14 downto 0) := (others => '0');
    signal bit_counter : unsigned(4 downto 0) := (others => '0');
    signal led_counter : unsigned(4 downto 0) := (others => '0');
    signal data_latched : std_logic_vector(LED_COUNT * 24 - 1 downto 0) := (others => '0');
begin

    process (clk)
    begin
        if rising_edge(clk) then
            case state is

                when RESET =>
                    -- led output is low during reset
                    ws2812_out <= '0';

                    -- count up for the reset delay
                    if delay_counter < DELAY_RESET then
                        delay_counter <= delay_counter + 1;
                    else
                        state <= DATA_SEND;
                        bit_counter <= to_unsigned(24, bit_counter'length);
                        led_counter <= (others => '0');
                        data_latched <= data;
                    end if;

                when DATA_SEND =>
                    ws2812_out <= '0';
                    if led_counter < LED_COUNT then
                        if bit_counter > 0 then
                            state <= BIT_SEND_HIGH;
                            delay_counter <= (others => '0');
                            bit_counter <= bit_counter - 1;
                        else
                            led_counter <= led_counter + 1;
                            bit_counter <= to_unsigned(24, bit_counter'length);
                        end if;
                    else
                        state <= RESET;
                        delay_counter <= (others => '0');
                    end if;

                when BIT_SEND_HIGH =>
                    ws2812_out <= '1';
                    if data_latched(to_integer(bit_counter)) = '1' then
                        if delay_counter < DELAY_1_HIGH then
                            delay_counter <= delay_counter + 1;
                        else
                            state <= BIT_SEND_LOW;
                            delay_counter <= (others => '0');
                        end if;
                    else
                        if delay_counter < DELAY_0_HIGH then
                            delay_counter <= delay_counter + 1;
                        else
                            state <= BIT_SEND_LOW;
                            delay_counter <= (others => '0');
                        end if;
                    end if;

                when BIT_SEND_LOW =>
                    ws2812_out <= '0';
                    if data_latched(to_integer(bit_counter)) = '1' then
                        if delay_counter < DELAY_1_LOW - 1 then
                            delay_counter <= delay_counter + 1;
                        else
                            state <= DATA_SEND;
                            delay_counter <= (others => '0');
                        end if;
                    else
                        if delay_counter < DELAY_0_LOW - 1 then
                            delay_counter <= delay_counter + 1;
                        else
                            state <= DATA_SEND;
                            delay_counter <= (others => '0');
                        end if;
                    end if;

            end case;
        end if;
    end process;



end rtl;