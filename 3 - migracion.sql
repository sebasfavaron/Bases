create or REPLACE FUNCTION migration() RETURNS VOID
AS $$

BEGIN

PERFORM migration_route1();
PERFORM migration_route2();
PERFORM migration_route3();

/*
DROP TABLE IF EXISTS route1;
DROP TABLE IF EXISTS route2;
DROP TABLE IF EXISTS route_imported;*/

END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION migration_route1() RETURNS VOID
AS $$
DECLARE
croute CURSOR FOR
SELECT * FROM route_imported;
rroute RECORD;
hindex int;
minindex int;
segindex int;
hsAdd int;
minsAdd int;
segsAdd int;
diaretiro text;
mesretiro text;
anioretiro text;
hsretiro text;
minsretiro text;
fecha_hora_retiro timestamp;
fecha_hora_devolucion timestamp;
BEGIN

OPEN croute;
LOOP
FETCH croute INTO rroute;
EXIT WHEN NOT FOUND;

IF(rroute.id_usuario is not null and rroute.fecha_hora_retiro is not null and rroute.origen_estacion is not null and
rroute.destino_estacion is not null and rroute.tiempo_uso is not null) THEN
	SELECT REPLACE(rroute.tiempo_uso, ' ', '') into rroute.tiempo_uso;
	
	select POSITION('H' IN rroute.tiempo_uso) into hindex;
	select POSITION('MIN' IN rroute.tiempo_uso) into minindex;
	select POSITION('SEG' IN rroute.tiempo_uso) into segindex;
	
	SELECT CAST (SUBSTRING(rroute.tiempo_uso, 1, hindex-1) AS INT) into hsAdd;
	SELECT CAST(SUBSTRING(rroute.tiempo_uso, hindex+1, minindex-hindex-1) AS INT) into minsAdd;
	SELECT CAST(SUBSTRING(rroute.tiempo_uso, minindex+3, segindex-minindex-3) AS INT) into segsAdd;
        
	SELECT (SUBSTRING(rroute.fecha_hora_retiro, 1, 2)) into diaretiro;
	SELECT (SUBSTRING(rroute.fecha_hora_retiro, 4, 2)) into mesretiro;
	SELECT (SUBSTRING(rroute.fecha_hora_retiro, 7, 4)) into anioretiro;
	SELECT (SUBSTRING(rroute.fecha_hora_retiro, 12, 2)) into hsretiro;
	SELECT (SUBSTRING(rroute.fecha_hora_retiro, 15, 2)) into minsretiro;
	
	IF(hsAdd >= 0 and minsAdd >= 0 and minsAdd <=60 and segsAdd >= 0 and segsAdd <=60) THEN
	
		SELECT CAST((anioretiro || '-' || mesretiro || '-' || diaretiro || ' ' || hsretiro || ':' || minsretiro || ':00') AS TIMESTAMP) into fecha_hora_retiro;
		SELECT (fecha_hora_retiro + CAST((hsAdd || 'h ' || minsAdd || 'm ' || segsAdd || 's')  AS INTERVAL)) into fecha_hora_devolucion;
		insert into route1 values(rroute.periodo, rroute.id_usuario, fecha_hora_retiro, rroute.origen_estacion, rroute.destino_estacion, fecha_hora_devolucion);
		
	END IF;

END IF;

END LOOP;
CLOSE croute;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION migration_route2() RETURNS VOID
AS $$
DECLARE
croute CURSOR FOR
SELECT distinct usuario, fecha_hora_ret FROM route1;
rroute RECORD;
BEGIN

OPEN croute;
LOOP
FETCH croute INTO rroute;
EXIT WHEN NOT FOUND;

PERFORM escoger_valores_route2(rroute.usuario, rroute.fecha_hora_ret);

END LOOP;
CLOSE croute;

END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION escoger_valores_route2(pusuario route1.usuario%type, pfecha_hora_ret route1.fecha_hora_ret%type) RETURNS VOID
AS $$
DECLARE
cantidad int;
ordenTupla int;
croute2 CURSOR FOR
SELECT * 
FROM route1 
where usuario=pusuario and fecha_hora_ret=pfecha_hora_ret
order by fecha_hora_dev;
rroute2 RECORD;

BEGIN
	select count(*) into cantidad 
	from route1
	where usuario=pusuario and fecha_hora_ret=pfecha_hora_ret;
	
	OPEN croute2;
	
	if(cantidad > 1) then
		ordenTupla = 0;
		
		LOOP
		FETCH croute2 INTO rroute2;
		EXIT WHEN NOT FOUND OR ordenTupla > 1;
		
		if(ordenTupla = 1) then

			insert into route2 values(rroute2.periodo, rroute2.usuario, rroute2.fecha_hora_ret, rroute2.est_origen, rroute2.est_destino, rroute2.fecha_hora_dev);
		end if;
		ordenTupla=ordenTupla+1;
		
		END LOOP;
		
	else
		FETCH croute2 INTO rroute2;
		
		insert into route2 values(rroute2.periodo, rroute2.usuario, rroute2.fecha_hora_ret, rroute2.est_origen, rroute2.est_destino, rroute2.fecha_hora_dev);

	end if;
	
	CLOSE croute2;

END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION migration_route3() RETURNS VOID
AS $$
DECLARE
croute CURSOR FOR
SELECT DISTINCT usuario FROM route2;
rroute RECORD;
BEGIN
OPEN croute;
LOOP
FETCH croute INTO rroute;
EXIT WHEN NOT FOUND;
PERFORM escoger_valores_route_final(rroute.usuario);
END LOOP;
CLOSE croute;
END;
$$ LANGUAGE PLPGSQL;

CREATE OR REPLACE FUNCTION escoger_valores_route_final
(pusuario route2.usuario%TYPE) RETURNS VOID AS $$
DECLARE
croute2 CURSOR FOR
SELECT * FROM route2
WHERE usuario = pusuario
ORDER BY fecha_hora_ret;
rroute2 RECORD;
periodo_ant text;
est_origen_ant int;
est_destino_ant int;
fecha_hora_ret_ant TIMESTAMP;
fecha_hora_dev_ant TIMESTAMP;
BEGIN
OPEN croute2;
FETCH croute2 INTO rroute2;
fecha_hora_ret_ant = rroute2.fecha_hora_ret;
fecha_hora_dev_ant = rroute2.fecha_hora_dev;
periodo_ant = rroute2.periodo;
est_origen_ant = rroute2.est_origen;
est_destino_ant = rroute2.est_destino;
LOOP
FETCH croute2 INTO rroute2;
EXIT WHEN NOT FOUND;
IF rroute2.fecha_hora_ret >= fecha_hora_dev_ant THEN
INSERT INTO route_final VALUES(periodo_ant, pusuario, fecha_hora_ret_ant, est_origen_ant, est_destino_ant, fecha_hora_dev_ant);
fecha_hora_ret_ant = rroute2.fecha_hora_ret;
fecha_hora_dev_ant = rroute2.fecha_hora_dev;
periodo_ant = rroute2.periodo;
est_origen_ant = rroute2.est_origen;
est_destino_ant = rroute2.est_destino;
ELSE
est_destino_ant = rroute2.est_destino;
fecha_hora_dev_ant = rroute2.fecha_hora_dev;
END IF;
END LOOP;
INSERT INTO route_final VALUES(periodo_ant, pusuario, fecha_hora_ret_ant, est_origen_ant, est_destino_ant, fecha_hora_dev_ant);
CLOSE croute2;
END;
$$ LANGUAGE PLPGSQL;
