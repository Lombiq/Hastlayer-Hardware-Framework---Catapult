library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library Hast;
use Hast.SimpleMemory.all;
		
entity Test_Hast_IP_wrapper is
end Test_Hast_IP_wrapper;
		
architecture Imp of Test_Hast_IP_wrapper is 
		
	-- Component Declaration
	component Hast_ip_wrapper is
	port(
		Hast_IP_Clk_in             : in  std_logic;
		Hast_IP_Rst_in             : in  std_logic;
		Hast_IP_MemberID_in        : in  std_logic_vector(31 downto 0);
		Hast_IP_Data_in            : in  std_logic_vector(511 downto 0);
		Hast_IP_Data_out           : out std_logic_vector(511 downto 0);
		Hast_IP_Read_Addr_out      : out std_logic_vector(31 downto 0);
		Hast_IP_Read_Ena_out       : out std_logic;
		Hast_IP_Write_Addr_out     : out std_logic_vector(31 downto 0);
		Hast_IP_Write_Ena_out      : out std_logic;
		Hast_IP_Started_in         : in  std_logic;
		Hast_IP_Finished_out       : out std_logic;
		Hast_IP_Reads_Done_in      : in  std_logic;
		Hast_IP_Writes_Done_in     : in  std_logic;
		Hast_IP_Control_Packet_out : out std_logic_vector(511 downto 0)
			);
	 end component;
		
	signal Clock        : std_logic := '0';
	signal Reset        : std_logic := '1';
	signal DataIn       : std_logic_vector(511 downto 0) := X"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
	signal Started      : std_logic := '0';
	signal ReadsDone    : std_logic := '0';
	signal WritesDone   : std_logic := '0';
		
	signal ReadEnable   : std_logic := '0';
	signal WriteEnable  : std_logic := '0';
	signal DataOut      : std_logic_vector(511 downto 0);
	signal Write_Addr   : std_logic_vector(31 downto 0);
	signal Read_Addr    : std_logic_vector(31 downto 0);
	signal Finished     : std_logic := '0';
	signal ReadCount    : integer := 0;
	signal MemberId     : std_logic_vector(31 downto 0) := X"00000001";
	
	--Performance Counter signals 
	signal Cnt                  : unsigned(63 downto 0);
	signal sig_hast_performance : std_logic_vector(63 downto 0);
	
	--State macine states
	type SM_PERFORMANCE_CNTR is (ST00_Idle,
								 ST01_Start,
								 ST02_Stop
								 ); 
	signal state_PerformanceCnt : SM_PERFORMANCE_CNTR;
		
begin
		
	-- Component Instantiation
	UUT: Hast_ip_wrapper port map (
		Hast_IP_Clk_in             => Clock,
		Hast_IP_Rst_in             => Reset,
		Hast_IP_MemberID_in        => MemberId,
		Hast_IP_Data_in            => DataIn,
		Hast_IP_Data_out           => DataOut,
		Hast_IP_Read_Addr_out      => Read_Addr,
		Hast_IP_Read_Ena_out       => ReadEnable,
		Hast_IP_Write_Addr_out     => Write_Addr,
		Hast_IP_Write_Ena_out      => WriteEnable,
		Hast_IP_Started_in         => Started,
		Hast_IP_Finished_out       => Finished,
		Hast_IP_Reads_Done_in      => ReadsDone, 
		Hast_IP_Writes_Done_in     => WritesDone,
		Hast_IP_Control_Packet_out => open
		);
		
	Clock <= not Clock after 10 ns;
		
	ReadEnable_proc : process
	begin
		ReadsDone <= '0';
		loop
			 wait until ReadEnable = '1';
			 ReadsDone <= '0';
			 wait for 1000 ns;
			 ReadsDone <= '1';
			
			case (ReadCount) is
				when 0 => DataIn <= X"000000100000000F0000000E0000000D0000000C0000000B0000000A000000090000000800000007000000060000000500000004000000030000001400000001";
				when 1 => DataIn <= X"000000200000001F0000001E0000001D0000001C0000001B0000001A000000190000001800000017000000160000001500000014000000130000001200000011";
				when 2 => DataIn <= X"000000300000002F0000002E0000002D0000002C0000002B0000002A000000290000002800000027000000260000002500000024000000230000002200000021";
				when 3 => DataIn <= X"000000400000003F0000003E0000003D0000003C0000003B0000003A000000390000003800000037000000360000003500000034000000330000003200000031";
				--when 3 => DataIn <= X"000000400000003F0000003E0000003D0000003C0000003B0000003A000000390000003800000037000000360000003500000034000000330000003200000031";
				--when 4 => DataIn <= X"000000500000004F0000004E0000004D0000004C0000004B0000004A000000490000004800000047000000460000004500000044000000430000004200000041";
				--when 5 => DataIn <= X"000000600000005F0000005E0000005D0000005C0000005B0000005A000000590000005800000057000000560000005500000054000000530000005200000051";
				when others => DataIn <= X"00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
			end case; 
			
			ReadCount <= ReadCount + 1;
			wait until ReadEnable = '0';
		end loop;
	end process;
		
		
	WriteEnable_proc : process
	begin
		WritesDone <= '0';
		loop
			wait until WriteEnable = '1';
			WritesDone <= '0';
			wait for 1000 ns;
			WritesDone <= '1';
			--wait for 10 ns;
			--WritesDone <= '0';
			--wait until WriteEnable = '0';
		end loop;
	end process;
	
	-- Stimulus process
	Stim_proc: process
	begin
		-- hold Reset state for 100 ns.
		wait for 100 ns;
		Reset <= '1';
		wait for 100 ns;
		Reset <= '0';
		wait;
	end process;
		
	--Test bench statements
	Test : process(Clock)
	begin
		if (rising_edge(Clock)) then
			if Reset = '1' then
				Started <= '0';
			else
				Started <= '1';
			end if;
		end if;
	end process;
		
		
		
end Imp;
