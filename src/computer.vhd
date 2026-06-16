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
  -- step counter
  signal sc : std_logic_vector(3 downto 0);

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

  -- ================================================================
  -- MEMORY
  -- ================================================================

  type mem_type is array (0 to (2 ** addresswidth) - 1)
    of std_logic_vector(wordwidth - 1 downto 0);

  signal mem : mem_type;

  -- ================================================================
  -- CONSTANTS
  -- ================================================================

  -- ++++++++++++++++++++++++++++++++
  -- INSTRUCTIONS
  -- ++++++++++++++++++++++++++++++++

  -- MEMORY REFERENCE INSTRUCTIONS OP-CODE
  constant and_op : std_logic_vector(2 downto 0) := "000";
  constant add_op : std_logic_vector(2 downto 0) := "001";
  constant lda_op : std_logic_vector(2 downto 0) := "010";
  constant sta_op : std_logic_vector(2 downto 0) := "011";
  constant bun_op : std_logic_vector(2 downto 0) := "100";
  constant bsa_op : std_logic_vector(2 downto 0) := "101";
  constant isz_op : std_logic_vector(2 downto 0) := "110";

  -- REGISTER REFERENCE INSTRUCTIONS
  constant cla : std_logic_vector(15 downto 0) := x"7800";
  constant cle : std_logic_vector(15 downto 0) := x"7400";
  constant cma : std_logic_vector(15 downto 0) := x"7200";
  constant cme : std_logic_vector(15 downto 0) := x"7100";
  constant cir : std_logic_vector(15 downto 0) := x"7080";
  constant cil : std_logic_vector(15 downto 0) := x"7040";
  constant inc : std_logic_vector(15 downto 0) := x"7020";
  constant spa : std_logic_vector(15 downto 0) := x"7010";
  constant sna : std_logic_vector(15 downto 0) := x"7008";
  constant sza : std_logic_vector(15 downto 0) := x"7004";
  constant sze : std_logic_vector(15 downto 0) := x"7002";
  constant hlt : std_logic_vector(15 downto 0) := x"7001";

  -- INPUT-OUTPUT INSTRUCTIONS
  constant inp  : std_logic_vector(15 downto 0) := x"F800";
  constant outt : std_logic_vector(15 downto 0) := x"F400";
  constant ski  : std_logic_vector(15 downto 0) := x"F200";
  constant sko  : std_logic_vector(15 downto 0) := x"F100";
  constant ion  : std_logic_vector(15 downto 0) := x"F080";
  constant iof  : std_logic_vector(15 downto 0) := x"F040";

  -- ================================================================
  -- COMPONENT PORTS
  -- ================================================================
  -- 3-to-8 decoder
  signal d : std_logic_vector(7 downto 0);
  -- 4-to-16 decoder
  signal t : std_logic_vector(15 downto 0);
  -- clock
  signal clk : std_logic;

begin

  -- ================================================================
  -- COMPONENT INSTANTIATION
  -- ================================================================
  u_dec3x8 : entity work.dec3x8(behavioral)
    port map (
      in_vector  => ir(14 downto 12),
      out_vector => d(7 downto 0)
    );

  u_dec4x16 : entity work.dec4x16(behavioral)
    port map (
      in_vector  => sc(3 downto 0),
      out_vector => t(15 downto 0)
    );

  -- ================================================================
  -- CLOCK GENERATION
  -- ================================================================
  clk_process : process is
  begin

    while true loop

      clk <= '0';
      wait for clk_period / 2;
      clk <= '1';
      wait for clk_period / 2;

    end loop;

  end process clk_process;

  initialization_process : process is
  begin

    -- memory
    mem <= (others => (others => '0'));

    -- registers
    pc   <= (others => '0');
    ar   <= (others => '0');
    ir   <= (others => '0');
    dr   <= (others => '0');
    ac   <= (others => '0');
    tr   <= (others => '0');
    outr <= (others => '0');
    inpr <= (others => '0');
    sc   <= (others => '0');

    -- flip flops
    fgi <= '0';
    fgo <= '0';
    ien <= '0';
    r   <= '0';
    s   <= '0';
    e   <= '0';
    i   <= '0';

  end process initialization_process;
  end process computer_process;

end architecture rtl;
