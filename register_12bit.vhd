library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMAERIC_STD.ALL;

entity register_12bit is
    Port ( clk    : in  STD_LOGIC;
           reset  : in  STD_LOGIC;
           load   : in  STD_LOGIC;
           INR    : in  STD_LOGIC;
           d_in   : in  STD_LOGIC_VECTOR (11 downto 0);
           d_out  : out STD_LOGIC_VECTOR (11 downto 0));
end register_12bit;

architecture Behavioral of register_12bit is
signal temp_reg :unsigned(11 downto 0) : = (others => '0');
begin
    process(clk, reset)
    begin
        if reset = '1' then
            temp_reg <= (others => '0');
        elsif rising_edge(clk) then
            if load = '1' then
                temp_reg <= unsigned (d_in);
            elsif INR = '1' then 
                temp_reg <= temp_reg +1;
            end if;
        end if;
    end process;
     d_out <= STD_LOGIC_VECTOR (temp_reg);
end Behavioral;