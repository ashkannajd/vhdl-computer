library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity dec3x8 is
  port (
    in_vector  : in    std_logic_vector(2 downto 0);
    out_vector : out   std_logic_vector(7 downto 0)
  );
end entity dec3x8;

architecture behavioral of dec3x8 is

begin

  decoder_process : process (in_vector) is
  begin

    out_vector    <= (others => '0');
    out_vector(0) <= '1' when "000";
    out_vector(1) <= '1' when "001";
    out_vector(2) <= '1' when "010";
    out_vector(3) <= '1' when "011";
    out_vector(4) <= '1' when "100";
    out_vector(5) <= '1' when "101";
    out_vector(6) <= '1' when "110";
    out_vector(7) <= '1' when "111";

  end process decoder_process;

end architecture behavioral;
