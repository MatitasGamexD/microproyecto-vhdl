library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_boton_unico is
    generic(
        DEB_TICKS  : natural := 3;    -- 3 muestras a 100 Hz = 30 ms aprox.
        LONG_TICKS : natural := 201   -- 201 muestras a 100 Hz = 2.01 s
    );
    port(
        clk         : in  std_logic;
        tick_sample : in  std_logic;
        button_n    : in  std_logic;  -- botón físico, activo en bajo
        running     : out std_logic;
        reset_pulse : out std_logic
    );
end entity;

architecture rtl of control_boton_unico is
    signal btn_meta      : std_logic := '0';
    signal btn_sync      : std_logic := '0';
    signal btn_db        : std_logic := '0'; -- 1 = presionado (ya filtrado)
    signal btn_db_prev   : std_logic := '0';

    signal run_reg       : std_logic := '0';
    signal reset_reg     : std_logic := '0';
    signal long_done     : std_logic := '0';

    signal stable_count  : natural range 0 to DEB_TICKS := 0;
    signal hold_count    : natural range 0 to LONG_TICKS := 0;
begin
    -- Sincronización al reloj
    process(clk)
    begin
        if rising_edge(clk) then
            btn_meta <= not button_n; -- invertimos: 1 = presionado
            btn_sync <= btn_meta;
        end if;
    end process;

    -- Control del botón
    process(clk)
    begin
        if rising_edge(clk) then
            reset_reg <= '0';

            if tick_sample = '1' then
                -- Debounce simple
                if btn_sync = btn_db then
                    stable_count <= 0;
                else
                    if stable_count = DEB_TICKS - 1 then
                        btn_db <= btn_sync;
                        stable_count <= 0;
                    else
                        stable_count <= stable_count + 1;
                    end if;
                end if;

                -- Detección de pulsación corta si el boton esta presionado
                if btn_db = '1' then
                    if hold_count < LONG_TICKS then
                        hold_count <= hold_count + 1;
                    end if;

						  -- en caso de superar los 2 s, hace reset
                    if (hold_count = LONG_TICKS - 1) and (long_done = '0') then
                        reset_reg <= '1';
                        run_reg   <= '0';
                        long_done <= '1';
                    end if;
                else
                    -- Al soltar el botón
                    if btn_db_prev = '1' then
                        if long_done = '0' then
                            run_reg <= not run_reg;  -- pulsación corta
                        end if;
                    end if;

                    hold_count <= 0;
                    long_done  <= '0';
                end if;

                btn_db_prev <= btn_db;
            end if;
        end if;
    end process;

    running     <= run_reg;
    reset_pulse <= reset_reg;
end architecture;