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

  -- ================================================================
  -- REGISTERS
  -- ================================================================

  -- program counter
  signal pc : std_logic_vector(addresswidth - 1 downto 0);
  -- address register
  signal ar : std_logic_vector(addresswidth - 1 downto 0);
  -- instruction register
  signal ir : std_logic_vector(wordwidth - 1 downto 0);
  -- data register
  signal dr : std_logic_vector(wordwidth - 1 downto 0);
  -- accumulator
  signal ac : std_logic_vector(wordwidth - 1 downto 0);
  -- temporary register
  signal tr : std_logic_vector(wordwidth - 1 downto 0);
  -- output register
  signal outr : std_logic_vector(iowidth - 1 downto 0);
  -- input register
  signal inpr : std_logic_vector(iowidth - 1 downto 0);
  -- sequence counter
  signal sc : std_logic_vector(2 downto 0);

  -- ================================================================
  -- FLIP FLOPS
  -- ================================================================

  -- INPUT OUTPUT
  signal fgi : std_logic;
  signal fgo : std_logic;
  signal ien : std_logic;
  signal r   : std_logic;

  -- START
  signal s : std_logic;
  -- ALU
  signal e : std_logic;
  -- INSTRUCTION
  signal i : std_logic;

begin

end architecture rtl;
