library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity decoder4x16 is
    Port (
        A : in  STD_LOGIC_VECTOR(3 downto 0);
        Y : out STD_LOGIC_VECTOR(15 downto 0)
    );
end decoder4x16;

architecture Behavioral of decoder4x16 is
begin
    process(A)
    begin
        Y <= (others => '0');
        case A is
            when "0000" => out_vector(0)  <= '1';
            when "0001" => Y(1)  <= '1';
            when "0010" => Y(2)  <= '1';
            when "0011" => Y(3)  <= '1';
            when "0100" => Y(4)  <= '1';
            when "0101" => Y(5)  <= '1';
            when "0110" => Y(6)  <= '1';
            when "0111" => Y(7)  <= '1';
            when "1000" => Y(8)  <= '1';
            when "1001" => Y(9)  <= '1';
            when "1010" => Y(10) <= '1';
            when "1011" => Y(11) <= '1';
            when "1100" => Y(12) <= '1';
            when "1101" => Y(13) <= '1';
            when "1110" => Y(14) <= '1';
            when "1111" => Y(15) <= '1';
            when others => Y <= (others => '0');
        end case;
    end process;
end Behavioral;

