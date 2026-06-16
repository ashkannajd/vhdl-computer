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

  computer_process : process (clk) is
  begin

    if (rising_edge(clk) and start and not s) then
      -- set the start flipflop s to 1
      s <= '1';
    elsif rising_edge(clk) then
      -- T0
      -- ################################################################
      if (not r and t(0)) then
        ar <= pc;
      end if;
      if (r and t(0)) then
        ar <= (others => '0');
        tr <= (tr'high downto addresswidth => '0') & pc(addresswidth - 1 downto 0);
      end if;

      -- T1
      -- ################################################################
      if (not r and t(1)) then
        ir <= mem(ar(addresswidth - 1 downto 0));
        pc <= std_logic_vector(unsigned(pc) + 1);
      end if;
      if (r and t(1)) then
        mem(ar) <= tr;
        pc      <= (others => '0');
      end if;

      -- T2
      -- ################################################################
      if (not r and t(2)) then
        i  <= ir(wordwidth - 1);
        ar <= ir(addresswidth - 1 downto 0);
      end if;
      if (r and t(2)) then
        pc  <= std_logic_vector(unsigned(pc) + 1);
        ien <= '0';
        r   <= '0';
        sc  <= '0';
      end if;

      -- T3
      -- ################################################################
      -- D7IT3
      ----------------------------------
      if (d(7) and i and t(3)) then
        sc <= '0';
      end if;
      if (d(7) and i and t(3) and ir(11)) then
        fgi            <= '0';
        ac(7 downto 0) <= inpr;
      end if;
      if (d(7) and i and t(3) and ir(10)) then
        fgo  <= '0';
        inpr <= ac(7 downto 0);
      end if;
      if (d(7) and i and t(3) and ir(9)) then
        pc <= std_logic_vector(unsigned(pc) + 1) when fgi;
      end if;
      if (d(7) and i and t(3) and ir(8)) then
        pc <= std_logic_vector(unsigned(pc) + 1) when fgo;
      end if;
      if (d(7) and i and t(3) and ir(7)) then
        ien <= '1';
      end if;
      if (d(7) and i and t(3) and ir(6)) then
        ien <= '0';
      end if;
      -- D7I'T3
      ----------------------------------
      if (d(7) and i and t(3)) then
        sc <= (others => '0');
      end if;
      if (d(7) and i and t(3) and ir(11)) then
        ac <= (others => '0');
      end if;
      if (d(7) and i and t(3) and ir(10)) then
        e <= '0';
      end if;
      if (d(7) and i and t(3) and ir(9)) then
        ac <= not ac;
      end if;
      if (d(7) and i and t(3) and ir(8)) then
        e <= not e;
      end if;
      if (d(7) and i and t(3) and ir(7)) then
        e  <= ac(0);
        ac <= e & ac(ac'high downto 1);
      end if;
      if (d(7) and i and t(3) and ir(6)) then
        e  <= ac(ac'high);
        ac <= ac(ac'high - 1 downto 0) & e;
      end if;
      if (d(7) and i and t(3) and ir(5)) then
        ac <= std_logic_vector(unsigned(ac) + 1);
      end if;
      if (d(7) and i and t(3) and ir(4)) then
        pc <= std_logic_vector(unsigned(pc) + 1) when not ac(ac'high);
      end if;
      if (d(7) and i and t(3) and ir(3)) then
        pc <= std_logic_vector(unsigned(pc) + 1) when ac(ac'high);
      end if;
      if (d(7) and i and t(3) and ir(2)) then
        pc <= std_logic_vector(unsigned(pc) + 1) when ac = (others => '0');
      end if;
      if (d(7) and i and t(3) and ir(1)) then
        pc <= std_logic_vector(unsigned(pc) + 1) when not e;
      end if;
      if (d(7) and i and t(3) and ir(0)) then
        s <= '0';
      end if;
      -- D7'IT3
      ----------------------------------
      if (not d(7) and i and t(3)) then
        ar <= mem(ar);
      end if;
      -- D7'I'T3
      ----------------------------------
      if (not d(7) and not i and t(3)) then
      -- do nothing
      end if;

      -- T4
      -- ################################################################
      if (d(0) and t(4)) then
        dr <= mem(ar);
      end if;
      if (d(1) and t(4)) then
        dr <= mem(ar);
      end if;
      if (d(2) and t(4)) then
        dr <= mem(ar);
      end if;
      if (d(3) and t(4)) then
        sc      <= (others => '0');
        mem(ar) <= ac;
      end if;
      if (d(4) and t(4)) then
        sc <= (others => '0');
        pc <= ar;
      end if;
      if (d(5) and t(4)) then
        mem(ar) <= pc;
        ar      <= std_logic_vector(unsigned(ar) + 1);
      end if;
      if (d(6) and t(4)) then
        dr <= mem (ar);
      end if;

      -- T5
      -- ################################################################
      if (d(0) and t(5)) then
        ac <= ac and dr;
        sc <= (others => '0');
      end if;
      if (d(1) and t(5)) then
        result := ('0' & unsigned(ac) + '0' & unsigned(dr));
        e      <= result(result'high);
        ac     <= restult(result'high - 1 downto 0);
        sc     <= (others => '0');
      end if;
      if (d(2) and t(5)) then
        ac <= dr;
        sc <= (others => '0');
      end if;
      if (d(5) and t(5)) then
        pc <= ar;
        sc <= (others => '0');
      end if;
      if (d(6) and t(5)) then
        dr <= std_logic_vector(unsigned(dr) + 1);
      end if;

      -- T6
      -- ################################################################
      if (d(6) and t(7)) then
        mem(ar) <= dr;
        pc      <= std_logic_vector(unsigned(pc) + 1) when dr = (others => '0');
        sc      <= (others => '0');
      end if;
    end if;

  end process computer_process;

end architecture rtl;
