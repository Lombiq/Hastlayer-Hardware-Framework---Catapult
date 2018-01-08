library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Hast_ip_wrapper is
	port (
		Hast_IP_Clk_in          : in  std_logic;
		Hast_IP_Rst_in          : in  std_logic;
		Hast_IP_MemberID_in     : in  std_logic_vector(31 downto 0);
		Hast_IP_Data_in         : in  std_logic_vector(511 downto 0);
		Hast_IP_Data_out        : out std_logic_vector(511 downto 0);
		Hast_IP_Read_Addr_out   : out std_logic_vector(31 downto 0);
		Hast_IP_Read_Ena_out    : out std_logic;
		Hast_IP_Write_Addr_out  : out std_logic_vector(31 downto 0);
		Hast_IP_Write_Ena_out   : out std_logic;
		Hast_IP_Started_in      : in  std_logic;
		Hast_IP_Finished_out    : out std_logic;
		Hast_IP_Reads_Done_in   : in  std_logic;
		Hast_IP_Writes_Done_in  : in  std_logic;
		Hast_IP_Performance_out : out std_logic_vector(31 downto 0)
	);
end Hast_ip_wrapper;
		
architecture Imp of Hast_ip_wrapper is
		
		
	--Procedure convert boolean to std_logic
	procedure Bool_to_std_logic(signal DataIn: in boolean; signal DataOut : out std_logic) is 
	begin
		if (DataIn = false) then
			DataOut <= '0';
		elsif (DataIn = true) then
			DataOut <= '1';
		end if;
	end Bool_to_std_logic;
		
	--Procedure to convert std_logic to boolean
	procedure Std_logic_to_bool(signal DataIn: in std_logic; signal DataOut : out boolean) is 
	begin
		if (DataIn = '0') then
			DataOut <= false;
		elsif (DataIn = '1') then
			DataOut <= true;
		end if;
	end Std_logic_to_bool;
		
	signal Hast_IP_MemberID_in_sig        : std_logic_vector(31 downto 0);
	signal Hast_IP_MemberID_in_int        : integer;
	signal Hast_IP_StartCellIndex_out_sig : std_logic_vector(31 downto 0);
		
	signal Hast_IP_Read_Addr_out_sig      : std_logic_vector(31 downto 0);
	signal Hast_IP_Write_Addr_out_sig     : std_logic_vector(31 downto 0);
	signal Hast_IP_Read_Ena_out_sig       : std_logic;
	signal Hast_IP_Write_Ena_out_sig      : std_logic;
	signal Hast_IP_Finished_out_sig       : std_logic;
	                                      
	signal Hast_IP_Data_in_sig            : std_logic_vector(511 downto 0);
	signal Hast_IP_Data_out_sig           : std_logic_vector(511 downto 0);
		
	--Performance Counter signals 
	--signal Performance_Counter_Ena    : std_logic;
		
	--Signals for typecast
	signal Hast_IP_StartCellIndex_out_int : integer;
	signal Hast_IP_reads_done_in_bool     : boolean;
	signal Hast_IP_writes_done_in_bool    : boolean;
	signal Hast_IP_Read_Ena_out_bool      : boolean;
	signal Hast_IP_Write_Ena_out_bool     : boolean;
	signal Hast_IP_Started_in_bool        : boolean;
	signal Hast_IP_Finished_out_bool      : boolean;
	
	--Performance Counter signals 
	signal Cnt                  : unsigned(31 downto 0);
	signal sig_hast_performance : std_logic_vector(31 downto 0);
		
	--State macine states
	type SM_PERFORMANCE_CNTR is (ST00_Idle,
								 ST01_Start,
								 ST02_Stop
								 ); 
	signal state_PerformanceCnt : SM_PERFORMANCE_CNTR;
		
	component Hast_IP
	port(
		\DataIn\:         in  std_logic_vector(511 downto 0);
		\DataOut\:        out std_logic_vector(511 downto 0);
		\StartCellIndex\: out integer;
		\ReadEnable\:     out boolean;
		\WriteEnable\:    out boolean;
		\ReadsDone\:      in  boolean;
		\WritesDone\:     in  boolean;
		\MemberId\:       in  integer;
		\Reset\:          in  std_logic;
		\Started\:        in  boolean;
		\Finished\:       out boolean;
		\Clock\:          in  std_logic
	);
	end component;
		
begin
		
	--Typecast   
	Hast_IP_MemberID_in_sig <= Hast_IP_MemberID_in;                                                                    
	Hast_IP_MemberID_in_int <= to_integer(unsigned(Hast_IP_MemberID_in_sig(31 downto 0)));
	
	--Hast_IP_MemberID_in_sig <= Hast_IP_Data_in(31 downto 0);
   --Hast_IP_Data_in_sig     <= Hast_IP_Data_in(63 downto 32);
	Hast_IP_Data_in_sig     <= Hast_IP_Data_in;
    Hast_IP_Data_out        <= Hast_IP_Data_out_sig ;--Hast_IP_Data_in_sig(511 downto 96) & Hast_IP_Data_out_sig & Hast_IP_Data_in_sig(63 downto 0) when Hast_IP_MemberID_in_sig = x"00000001"; 
	
	Hast_IP_inst : Hast_IP
	port map(
		\DataIn\         => Hast_IP_Data_in_sig,                      
		\DataOut\        => Hast_IP_Data_out_sig,                     
		\StartCellIndex\ => Hast_IP_StartCellIndex_out_int,             
		\ReadEnable\     => Hast_IP_Read_Ena_out_bool,                 
		\WriteEnable\    => Hast_IP_Write_Ena_out_bool,           
		\ReadsDone\      => Hast_IP_reads_done_in_bool,         
		\WritesDone\     => Hast_IP_writes_done_in_bool,       
		\MemberId\       => Hast_IP_MemberID_in_int,         
		\Reset\          => Hast_IP_Rst_in,               
		\Started\        => Hast_IP_Started_in_bool,                          
		\Finished\       => Hast_IP_Finished_out_bool,                          
		\Clock\          => Hast_IP_Clk_in                                                     
	);   
		
	Std_logic_to_bool(Hast_IP_reads_done_in, Hast_IP_reads_done_in_bool);
	Std_logic_to_bool(Hast_IP_writes_done_in, Hast_IP_writes_done_in_bool);  
	Std_logic_to_bool(Hast_IP_Started_in, Hast_IP_Started_in_bool);
		
	Bool_to_std_logic(Hast_IP_Read_Ena_out_bool, Hast_IP_Read_Ena_out_sig);
	Bool_to_std_logic(Hast_IP_Write_Ena_out_bool, Hast_IP_Write_Ena_out_sig);
	Bool_to_std_logic(Hast_IP_Finished_out_bool, Hast_IP_Finished_out_sig); 
		
	Hast_IP_Read_Ena_out  <= Hast_IP_Read_Ena_out_sig;
	Hast_IP_Write_Ena_out <= Hast_IP_Write_Ena_out_sig;
	Hast_IP_Finished_out  <= Hast_IP_Finished_out_sig;
		                                                                         
	--Hast_IP_StartCellIndex_out_sig <= std_logic_vector(to_unsigned(Hast_IP_StartCellIndex_out_int,32)); 
	Hast_IP_StartCellIndex_out_sig <= std_logic_vector(to_unsigned(Hast_IP_StartCellIndex_out_int,32));
		
	Read_Write_Address_Choice : process(Hast_IP_Rst_in, Hast_IP_Read_Ena_out_sig, Hast_IP_Write_Ena_out_sig, Hast_IP_StartCellIndex_out_sig)
	begin
		if Hast_IP_Rst_in = '1' then
			Hast_IP_Read_Addr_out_sig  <= (others => '0');
			Hast_IP_Write_Addr_out_sig <= (others => '0');
		else
			if Hast_IP_Read_Ena_out_sig = '1' then
				Hast_IP_Read_Addr_out_sig <= Hast_IP_StartCellIndex_out_sig;
			elsif Hast_IP_Write_Ena_out_sig = '1' then
				Hast_IP_Write_Addr_out_sig <= Hast_IP_StartCellIndex_out_sig;
			end if;
		 end if;
	end process;
		
	Hast_IP_Read_Addr_out  <= Hast_IP_Read_Addr_out_sig; 
	Hast_IP_Write_Addr_out <= Hast_IP_Write_Addr_out_sig;
		
	--SM_PERFORMANCE_CNTR
	SM_Performance_Counter: process (Hast_IP_Clk_in)
	begin
		if (rising_edge(Hast_IP_Clk_in)) then
			if Hast_IP_Rst_in = '1' then
				Cnt <= (others => '0');
				state_PerformanceCnt <= ST00_Idle;
			else
				case (state_PerformanceCnt) is
					when ST00_Idle =>
						if Hast_IP_Started_in = '1' then
							Cnt <= (others => '0');
							state_PerformanceCnt <= ST01_Start;
						end if;
					when ST01_Start =>
						if Hast_IP_Finished_out_sig = '1' then
							state_PerformanceCnt <= ST02_Stop;
						else
							Cnt <= Cnt + 1;
							state_PerformanceCnt <= ST01_Start;
						end if;
					when ST02_Stop =>
						if Hast_IP_Started_in = '0' then
							state_PerformanceCnt <= ST00_Idle;
						end if;               
					when others => null;        
				end case;  
			end if;
		end if;    
	end process; 
		
	sig_hast_performance <= std_logic_vector(Cnt);
		
end Imp;
