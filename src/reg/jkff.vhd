library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity jkff is
  port (
    j   : in    std_logic;
    k   : in    std_logic;
    clk : in    std_logic;
    rst : in    std_logic;
    q   : out   std_logic
  );
end entity jkff;

architecture rtl of jkff is

  signal val : std_logic;

begin

  q <= val;

  jkff_process : process (clk) is
  begin

    if (rst = '1') then
      val <= '0';
    elsif rising_edge(clk) then
      with j & k select val <=
        val when "00",
        '0' when "01",
        '1' when "10",
        not val when "11";
    end if;

  end process jkff_process;

end architecture rtl;
