	component lab7_soc is
		port (
			clk_clk                        : in    std_logic                     := 'X';             -- clk
			game_rst_sig                   : out   std_logic;                                        -- sig
			key_external_connection_export : in    std_logic_vector(1 downto 0)  := (others => 'X'); -- export
			keycode_export                 : out   std_logic_vector(7 downto 0);                     -- export
			led_wire_export                : out   std_logic_vector(7 downto 0);                     -- export
			leds_export                    : out   std_logic_vector(13 downto 0);                    -- export
			move_ready                     : in    std_logic                     := 'X';             -- ready
			move_hl_export                 : out   std_logic;                                        -- export
			reset_reset_n                  : in    std_logic                     := 'X';             -- reset_n
			reset_game_export              : in    std_logic                     := 'X';             -- export
			reset_sw_export                : out   std_logic;                                        -- export
			sdram_clk_clk                  : out   std_logic;                                        -- clk
			sdram_wire_addr                : out   std_logic_vector(12 downto 0);                    -- addr
			sdram_wire_ba                  : out   std_logic_vector(1 downto 0);                     -- ba
			sdram_wire_cas_n               : out   std_logic;                                        -- cas_n
			sdram_wire_cke                 : out   std_logic;                                        -- cke
			sdram_wire_cs_n                : out   std_logic;                                        -- cs_n
			sdram_wire_dq                  : inout std_logic_vector(15 downto 0) := (others => 'X'); -- dq
			sdram_wire_dqm                 : out   std_logic_vector(1 downto 0);                     -- dqm
			sdram_wire_ras_n               : out   std_logic;                                        -- ras_n
			sdram_wire_we_n                : out   std_logic;                                        -- we_n
			spi0_MISO                      : in    std_logic                     := 'X';             -- MISO
			spi0_MOSI                      : out   std_logic;                                        -- MOSI
			spi0_SCLK                      : out   std_logic;                                        -- SCLK
			spi0_SS_n                      : out   std_logic;                                        -- SS_n
			start_sw_export                : out   std_logic;                                        -- export
			text_ctrl_keycode              : in    std_logic_vector(7 downto 0)  := (others => 'X'); -- keycode
			usb_gpx_export                 : in    std_logic                     := 'X';             -- export
			usb_irq_export                 : in    std_logic                     := 'X';             -- export
			usb_rst_export                 : out   std_logic;                                        -- export
			vga_port_blue                  : out   std_logic_vector(3 downto 0);                     -- blue
			vga_port_green                 : out   std_logic_vector(3 downto 0);                     -- green
			vga_port_red                   : out   std_logic_vector(3 downto 0);                     -- red
			vga_port_hs                    : out   std_logic;                                        -- hs
			vga_port_vs                    : out   std_logic;                                        -- vs
			win_export                     : out   std_logic;                                        -- export
			win_cond_edge                  : in    std_logic                     := 'X';             -- edge
			menu_hex                       : out   std_logic_vector(3 downto 0);                     -- hex
			sw_digits_export               : in    std_logic_vector(15 downto 0) := (others => 'X')  -- export
		);
	end component lab7_soc;

	u0 : component lab7_soc
		port map (
			clk_clk                        => CONNECTED_TO_clk_clk,                        --                     clk.clk
			game_rst_sig                   => CONNECTED_TO_game_rst_sig,                   --                game_rst.sig
			key_external_connection_export => CONNECTED_TO_key_external_connection_export, -- key_external_connection.export
			keycode_export                 => CONNECTED_TO_keycode_export,                 --                 keycode.export
			led_wire_export                => CONNECTED_TO_led_wire_export,                --                led_wire.export
			leds_export                    => CONNECTED_TO_leds_export,                    --                    leds.export
			move_ready                     => CONNECTED_TO_move_ready,                     --                    move.ready
			move_hl_export                 => CONNECTED_TO_move_hl_export,                 --                 move_hl.export
			reset_reset_n                  => CONNECTED_TO_reset_reset_n,                  --                   reset.reset_n
			reset_game_export              => CONNECTED_TO_reset_game_export,              --              reset_game.export
			reset_sw_export                => CONNECTED_TO_reset_sw_export,                --                reset_sw.export
			sdram_clk_clk                  => CONNECTED_TO_sdram_clk_clk,                  --               sdram_clk.clk
			sdram_wire_addr                => CONNECTED_TO_sdram_wire_addr,                --              sdram_wire.addr
			sdram_wire_ba                  => CONNECTED_TO_sdram_wire_ba,                  --                        .ba
			sdram_wire_cas_n               => CONNECTED_TO_sdram_wire_cas_n,               --                        .cas_n
			sdram_wire_cke                 => CONNECTED_TO_sdram_wire_cke,                 --                        .cke
			sdram_wire_cs_n                => CONNECTED_TO_sdram_wire_cs_n,                --                        .cs_n
			sdram_wire_dq                  => CONNECTED_TO_sdram_wire_dq,                  --                        .dq
			sdram_wire_dqm                 => CONNECTED_TO_sdram_wire_dqm,                 --                        .dqm
			sdram_wire_ras_n               => CONNECTED_TO_sdram_wire_ras_n,               --                        .ras_n
			sdram_wire_we_n                => CONNECTED_TO_sdram_wire_we_n,                --                        .we_n
			spi0_MISO                      => CONNECTED_TO_spi0_MISO,                      --                    spi0.MISO
			spi0_MOSI                      => CONNECTED_TO_spi0_MOSI,                      --                        .MOSI
			spi0_SCLK                      => CONNECTED_TO_spi0_SCLK,                      --                        .SCLK
			spi0_SS_n                      => CONNECTED_TO_spi0_SS_n,                      --                        .SS_n
			start_sw_export                => CONNECTED_TO_start_sw_export,                --                start_sw.export
			text_ctrl_keycode              => CONNECTED_TO_text_ctrl_keycode,              --               text_ctrl.keycode
			usb_gpx_export                 => CONNECTED_TO_usb_gpx_export,                 --                 usb_gpx.export
			usb_irq_export                 => CONNECTED_TO_usb_irq_export,                 --                 usb_irq.export
			usb_rst_export                 => CONNECTED_TO_usb_rst_export,                 --                 usb_rst.export
			vga_port_blue                  => CONNECTED_TO_vga_port_blue,                  --                vga_port.blue
			vga_port_green                 => CONNECTED_TO_vga_port_green,                 --                        .green
			vga_port_red                   => CONNECTED_TO_vga_port_red,                   --                        .red
			vga_port_hs                    => CONNECTED_TO_vga_port_hs,                    --                        .hs
			vga_port_vs                    => CONNECTED_TO_vga_port_vs,                    --                        .vs
			win_export                     => CONNECTED_TO_win_export,                     --                     win.export
			win_cond_edge                  => CONNECTED_TO_win_cond_edge,                  --                win_cond.edge
			menu_hex                       => CONNECTED_TO_menu_hex,                       --                    menu.hex
			sw_digits_export               => CONNECTED_TO_sw_digits_export                --               sw_digits.export
		);

