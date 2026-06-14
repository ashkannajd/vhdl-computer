library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity register_8bit is
    Port ( clk    : in  STD_LOGIC;
           reset  : in  STD_LOGIC;
           load   : in  STD_LOGIC;
           d_in   : in  STD_LOGIC_VECTOR (7 downto 0);
           d_out  : out STD_LOGIC_VECTOR (7 downto 0));
end register_8bit;

architecture Behavioral of register_8bit is
begin
    process(clk, reset)
    begin
        if reset = '1' then
            d_out <= (others => '0');
        elsif rising_edge(clk) then
            if load = '1' then
                d_out <= d_in;
            end if;
        end if;
    end process;
end Behavioral;