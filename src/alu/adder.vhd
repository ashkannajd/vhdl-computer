library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity adder is
  port (
    a    : in    std_logic_vector(15 downto 0);
    b    : in    std_logic_vector(15 downto 0);
    sum  : out   std_logic_vector(15 downto 0);
    cin  : in    std_logic;
    cout : out   std_logic
  );
end entity adder;

architecture rtl of adder is

  signal cin_u : unsigned(16 downto 0);
  signal res   : unsigned(16 downto 0);

begin

  cin_u <= to_unsigned(1, 17) when cin = '1' else
           to_unsigned(0, 17);

  res <= unsigned('0' & a) +
         unsigned('0' & b) +
         cin_u;

  sum  <= std_logic_vector(res(15 downto 0));
  cout <= res(16);

end architecture rtl;

