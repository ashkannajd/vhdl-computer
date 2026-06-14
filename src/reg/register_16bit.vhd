library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity register_16bit is
    Port (
        clk   : in  STD_LOGIC;
        rst   : in  STD_LOGIC; 
        load  : in  STD_LOGIC;
        d_in  : in  STD_LOGIC_VECTOR(15 downto 0);
        q_out : out STD_LOGIC_VECTOR(15 downto 0)
    );
end register_16bit;

architecture Behavioral of register_16bit is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                q_out <= (others => '0');
            elsif load = '1' then
                q_out <= d_in;
            end if;
        end if;
    end process;
end Behavioral;