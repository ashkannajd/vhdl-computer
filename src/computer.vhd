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
    printer  : out   std_logic_vector(7 downto 0);
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
  -- sequence counter
  signal sc_clear : std_logic;
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

  inpr <= keyboard;

  initialization_process : process is
  begin

    -- sequence counter
    sc_clear <= '0';

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

  sc_process : process (clk) is
  begin

    if rising_edge(clk) then
      if (sc_clear = '1') then
        sc <= (others => '0');
      else
        sc <= std_logic_vector(unsigned(sc) + 1);
      end if;
    end if;

  end process sc_process;

  computer_process : process (clk) is

    variable result : unsigned(ac'length downto 0);
    variable old_ac : std_logic_vector(ac'range);
    variable old_e  : std_logic;

  begin

    if rising_edge(clk) then
      -- ##################################################################
      -- START / RUN CONTROL
      -- ##################################################################

      sc_clear <= '0';
      wrt      <= '0';
      if (start = '1' and s = '0') then
        s <= '1';
      elsif (s = '1') then
        -- ################################################################
        -- FETCH
        -- ################################################################
        if (r = '0' and t(0) = '1') then
          ar <= pc;
        end if;

        if (r = '0' and t(1) = '1') then
          ir <= mem(to_integer(unsigned(ar)));
          pc <= std_logic_vector(unsigned(pc) + 1);
        end if;

        -- ################################################################
        -- DECODE
        -- ################################################################
        if (r = '0' and t(2) = '1') then
          i  <= ir(wordwidth - 1);
          ar <= ir(addresswidth - 1 downto 0);
        end if;

        -- ################################################################
        -- INDIRECT
        -- D7' I T3 : AR <- M[AR]
        -- ################################################################
        if (d(7) = '0' and i = '1' and t(3) = '1') then
          ar <= mem(to_integer(unsigned(ar)))(addresswidth - 1 downto 0);
        end if;

        -- ################################################################
        -- INTERRUPT REQUEST CHECK
        -- ################################################################
        if (t(0) = '0' and t(1) = '0' and t(2) = '0' and
            ien = '1' and (fgi = '1' or fgo = '1')) then
          r <= '1';
        end if;

        -- ################################################################
        -- INTERRUPT CYCLE
        -- ################################################################
        if (r = '1' and t(0) = '1') then
          ar <= (others => '0');
          tr <=
          (
            tr'high downto addresswidth => '0'
          ) &
            pc(addresswidth - 1 downto 0
              );
        end if;

        if (r = '1' and t(1) = '1') then
          mem(to_integer(unsigned(ar))) <= tr;
          pc                            <= (others => '0');
        end if;

        if (r = '1' and t(2) = '1') then
          pc       <= std_logic_vector(unsigned(pc) + 1);
          ien      <= '0';
          r        <= '0';
          sc_clear <= '1';
        end if;

        -- ################################################################
        -- MEMORY REFERENCE INSTRUCTIONS
        -- ################################################################

        -- ################################################################
        -- AND
        -- D0T4: DR <- M[AR]
        -- D0T5: AC <- AC and DR, SC <- 0
        -- ################################################################
        if (d(0) = '1' and t(4) = '1') then
          dr <= mem(to_integer(unsigned(ar)));
        end if;

        if (d(0) = '1' and t(5) = '1') then
          ac       <= ac and dr;
          sc_clear <= '1';
        end if;

        -- ################################################################
        -- ADD
        -- D1T4: DR <- M[AR]
        -- D1T5: AC <- AC + DR, E <- carry, SC <- 0
        -- ################################################################
        if (d(1) = '1' and t(4) = '1') then
          dr <= mem(to_integer(unsigned(ar)));
        end if;

        if (d(1) = '1' and t(5) = '1') then
          result   := ('0' & unsigned(ac)) + ('0' & unsigned(dr));
          e        <= result(result'high);
          ac       <= std_logic_vector(result(ac'range));
          sc_clear <= '1';
        end if;

        -- ################################################################
        -- LDA
        -- D2T4: DR <- M[AR]
        -- D2T5: AC <- DR, SC <- 0
        -- ################################################################
        if (d(2) = '1' and t(4) = '1') then
          dr <= mem(to_integer(unsigned(ar)));
        end if;

        if (d(2) = '1' and t(5) = '1') then
          ac       <= dr;
          sc_clear <= '1';
        end if;

        -- ################################################################
        -- STA
        -- D3T4: M[AR] <- AC, SC <- 0
        -- ################################################################
        if (d(3) = '1' and t(4) = '1') then
          mem(to_integer(unsigned(ar))) <= ac;
          sc_clear                      <= '1';
        end if;

        -- ################################################################
        -- BUN
        -- D4T4: PC <- AR, SC <- 0
        -- ################################################################
        if (d(4) = '1' and t(4) = '1') then
          pc       <= ar;
          sc_clear <= '1';
        end if;

        -- ################################################################
        -- BSA
        -- D5T4: M[AR] <- PC, AR <- AR + 1
        -- D5T5: PC <- AR, SC <- 0
        -- ################################################################
        if (d(5) = '1' and t(4) = '1') then
          mem(to_integer(unsigned(ar))) <=
          (
            wordwidth - 1 downto addresswidth => '0'
          ) &
            pc(addresswidth - 1 downto 0
              );

          ar <= std_logic_vector(unsigned(ar) + 1);
        end if;

        if (d(5) = '1' and t(5) = '1') then
          pc       <= ar;
          sc_clear <= '1';
        end if;

        -- ################################################################
        -- ISZ
        -- D6T4: DR <- M[AR]
        -- D6T5: DR <- DR + 1
        -- D6T6: M[AR] <- DR, if DR = 0 then PC <- PC + 1, SC <- 0
        -- ################################################################
        if (d(6) = '1' and t(4) = '1') then
          dr <= mem(to_integer(unsigned(ar)));
        end if;

        if (d(6) = '1' and t(5) = '1') then
          dr <= std_logic_vector(unsigned(dr) + 1);
        end if;

        if (d(6) = '1' and t(6) = '1') then
          mem(to_integer(unsigned(ar))) <= dr;

          if (dr = (dr'range => '0')) then
            pc <= std_logic_vector(unsigned(pc) + 1);
          end if;

          sc_clear <= '1';
        end if;

        -- ################################################################
        -- REGISTER REFERENCE INSTRUCTIONS
        -- D7 I' T3
        -- ################################################################
        if (d(7) = '1' and i = '0' and t(3) = '1') then
          sc_clear <= '1';

          -- ##############################################################
          -- CLA: AC <- 0
          -- ##############################################################
          if (ir(11) = '1') then
            ac <= (others => '0');
          end if;

          -- ##############################################################
          -- CLE: E <- 0
          -- ##############################################################
          if (ir(10) = '1') then
            e <= '0';
          end if;

          -- ##############################################################
          -- CMA: AC <- not AC
          -- ##############################################################
          if (ir(9) = '1') then
            ac <= not ac;
          end if;

          -- ##############################################################
          -- CME: E <- not E
          -- ##############################################################
          if (ir(8) = '1') then
            e <= not e;
          end if;

          -- ##############################################################
          -- CIR: AC and E rotate right
          -- E <- AC(0)
          -- AC <- E & AC(high downto 1)
          -- ##############################################################
          if (ir(7) = '1') then
            old_ac := ac;
            old_e  := e;

            e  <= old_ac(0);
            ac <= old_e & old_ac(old_ac'high downto 1);
          end if;

          -- ##############################################################
          -- CIL: AC and E rotate left
          -- E <- AC(high)
          -- AC <- AC(high - 1 downto 0) & E
          -- ##############################################################
          if (ir(6) = '1') then
            old_ac := ac;
            old_e  := e;

            e  <= old_ac(old_ac'high);
            ac <= old_ac(old_ac'high - 1 downto 0) & old_e;
          end if;

          -- ##############################################################
          -- INC: AC <- AC + 1
          -- ##############################################################
          if (ir(5) = '1') then
            ac <= std_logic_vector(unsigned(ac) + 1);
          end if;

          -- ##############################################################
          -- SPA: skip if AC is positive
          -- ##############################################################
          if (ir(4) = '1') then
            if (ac(ac'high) = '0') then
              pc <= std_logic_vector(unsigned(pc) + 1);
            end if;
          end if;

          -- ##############################################################
          -- SNA: skip if AC is negative
          -- ##############################################################
          if (ir(3) = '1') then
            if (ac(ac'high) = '1') then
              pc <= std_logic_vector(unsigned(pc) + 1);
            end if;
          end if;

          -- ##############################################################
          -- SZA: skip if AC is zero
          -- ##############################################################
          if (ir(2) = '1') then
            if (ac = (ac'range => '0')) then
              pc <= std_logic_vector(unsigned(pc) + 1);
            end if;
          end if;

          -- ##############################################################
          -- SZE: skip if E is zero
          -- ##############################################################
          if (ir(1) = '1') then
            if (e = '0') then
              pc <= std_logic_vector(unsigned(pc) + 1);
            end if;
          end if;

          -- ##############################################################
          -- HLT: S <- 0
          -- ##############################################################
          if (ir(0) = '1') then
            s <= '0';
          end if;
        end if;

        -- ################################################################
        -- INPUT/OUTPUT INSTRUCTIONS
        -- D7 I T3
        -- ################################################################
        if (d(7) = '1' and i = '1' and t(3) = '1') then
          sc_clear <= '1';

          -- ##############################################################
          -- INP: AC(7 downto 0) <- INPR, FGI <- 0
          -- ##############################################################
          if (ir(11) = '1') then
            ac(7 downto 0) <= inpr;
            fgi            <= '0';
          end if;

          -- ##############################################################
          -- OUT: OUTR <- AC(7 downto 0), FGO <- 0
          -- ##############################################################
          if (ir(10) = '1') then
            outr <= ac(7 downto 0);
            fgo  <= '0';
            wrt  <= '1';
          end if;

          -- ##############################################################
          -- SKI: skip if input flag is 1
          -- ##############################################################
          if (ir(9) = '1') then
            if (fgi = '1') then
              pc <= std_logic_vector(unsigned(pc) + 1);
            end if;
          end if;

          -- ##############################################################
          -- SKO: skip if output flag is 1
          -- ##############################################################
          if (ir(8) = '1') then
            if (fgo = '1') then
              pc <= std_logic_vector(unsigned(pc) + 1);
            end if;
          end if;

          -- ##############################################################
          -- ION: enable interrupts
          -- ##############################################################
          if (ir(7) = '1') then
            ien <= '1';
          end if;

          -- ##############################################################
          -- IOF: disable interrupts
          -- ##############################################################
          if (ir(6) = '1') then
            ien <= '0';
          end if;
        end if;
      end if;
    end if;

  end process computer_process;

end architecture rtl;
