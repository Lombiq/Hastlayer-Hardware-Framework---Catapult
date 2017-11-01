library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Hast_ip_wrapper is
	port (
		DataIn:      In std_logic_vector(31 downto 0); 
		DataOut:     Out std_logic_vector(31 downto 0);
		CellIndex:   Out integer;                      
		ReadEnable:  Out boolean;                      
		WriteEnable: Out boolean;                      
		ReadsDone:   In boolean;                       
		WritesDone:  In boolean;                       
		MemberId:    In integer;                       
		Reset:       In std_logic;                     
		Started:     In boolean;                       
		Finished:    Out boolean;                      
		Clock:       In std_logic                      
	);
end Hast_ip_wrapper;
		
architecture Imp of Hast_ip_wrapper is
		
	component Hast_IP
	port(
		\DataIn\:      In std_logic_vector(31 downto 0);
		\DataOut\:     Out std_logic_vector(31 downto 0);
		\CellIndex\:   Out integer;
		\ReadEnable\:  Out boolean;
		\WriteEnable\: Out boolean;
		\ReadsDone\:   In boolean;
		\WritesDone\:  In boolean;
		\MemberId\:    In integer;
		\Reset\:       In std_logic;
		\Started\:     In boolean;
		\Finished\:    Out boolean;
		\Clock\:       In std_logic
	);
	end component;
		
begin
		
	Hast_IP_inst : Hast_IP
	port map(
		\DataIn\      => DataIn,         
		\DataOut\     => DataOut,       
		\CellIndex\   => CellIndex,      
		\ReadEnable\  => ReadEnable,    
		\WriteEnable\ => WriteEnable,   
		\ReadsDone\   => ReadsDone,  
		\WritesDone\  => WritesDone, 
		\MemberId\    => MemberId,        
		\Reset\       => Reset,      
		\Started\     => Started,                     
		\Finished\    => Finished,   
		\Clock\       => Clock                                              
	);                                                       
		                                                     
	
end Imp;
