library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decoder4x16 is
    Port (
        A : in  STD_LOGIC_VECTOR(3 downto 0);
        Y : out STD_LOGIC_VECTOR(15 downto 0)
    );
end decoder4x16;

architecture Structural of decoder4x16 is

    component simple_3_to_8_decoder
        Port (
            A  : in  STD_LOGIC_VECTOR(2 downto 0);
            EN : in  STD_LOGIC;
            Y  : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

begin

    DEC_LOW : simple_3_to_8_decoder
        port map(
            A  => A(2 downto 0),
            EN => not A(3),
            Y  => Y(7 downto 0)
        );

    DEC_HIGH : simple_3_to_8_decoder
        port map(
            A  => A(2 downto 0),
            EN => A(3),
            Y  => Y(15 downto 8)
        );

end Structural;