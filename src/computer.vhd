library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity computer is
  generic (
    addresswidth : integer := 12;
    wordwidth    : integer := 16;
    iowidth      : integer := 8;
    clk_period   : time    := 10 ns
  );
  port (
    start    : in    std_logic;
    keyboard : in    std_logic_vector(7 downto 0);
    printer  : in    std_logic_vector(7 downto 0);
    wrt      : out   std_logic
  );
end entity computer;

architecture rtl of computer is

begin

end architecture rtl;
