library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity dec4x16 is
  port (
    in_vector  : in    std_logic_vector(3 downto 0);
    out_vector : out   std_logic_vector(15 downto 0)
  );
end entity dec4x16;

architecture behavioral of dec4x16 is

begin

  decoder_process : process (in_vector) is
  begin

    out_vector     <= (others => '0');
    out_vector(0)  <= '1' when "0000";
    out_vector(1)  <= '1' when "0001";
    out_vector(2)  <= '1' when "0010";
    out_vector(3)  <= '1' when "0011";
    out_vector(4)  <= '1' when "0100";
    out_vector(5)  <= '1' when "0101";
    out_vector(6)  <= '1' when "0110";
    out_vector(7)  <= '1' when "0111";
    out_vector(8)  <= '1' when "1000";
    out_vector(9)  <= '1' when "1001";
    out_vector(10) <= '1' when "1010";
    out_vector(11) <= '1' when "1011";
    out_vector(12) <= '1' when "1100";
    out_vector(13) <= '1' when "1101";
    out_vector(14) <= '1' when "1110";
    out_vector(15) <= '1' when "1111";

  end process decoder_process;

end architecture behavioral;
