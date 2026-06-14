library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity simple_3_to_8_decoder is
    Port ( 
        in_vector  : in  STD_LOGIC_VECTOR (2 downto 0);
        out_vector : out STD_LOGIC_VECTOR (7 downto 0)
    );
end simple_3_to_8_decoder;

architecture Behavioral of simple_3_to_8_decoder is
begin
    process(in_vector)
    begin
        out_vector <= (others => '0');
        
        case in_vector is
            when "000" => out_vector(0) <= '1';
            when "001" => out_vector(1) <= '1';
            when "010" => out_vector(2) <= '1';
            when "011" => out_vector(3) <= '1';
            when "100" => out_vector(4) <= '1';
            when "101" => out_vector(5) <= '1';
            when "110" => out_vector(6) <= '1';
            when "111" => out_vector(7) <= '1';
            when others => out_vector <= (others => '0');
        end case;
    end process;
end Behavioral;