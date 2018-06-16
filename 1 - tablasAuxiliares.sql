SET DATESTYLE TO DMY;

DROP TABLE IF EXISTS route_imported;
DROP TABLE IF EXISTS route1;
DROP TABLE IF EXISTS route2;
DROP TABLE IF EXISTS route_final;

/* creo tablas auxiliares */

CREATE TABLE route_imported(
	periodo INTEGER,
	id_usuario INTEGER,
	fecha_hora_retiro TEXT,
	origen_estacion INTEGER,
	nombre_origen TEXT,
	destino_estacion INTEGER,
	nombre_destino TEXT,
	tiempo_uso TEXT,
	fecha_creacion TEXT
);
CREATE TABLE route1
(
        periodo    TEXT,
        usuario    INTEGER,
        fecha_hora_ret  TIMESTAMP NOT NULL,
        est_origen    INTEGER NOT NULL,
        est_destino   INTEGER NOT NULL,
        fecha_hora_dev  TIMESTAMP NOT NULL CHECK(fecha_hora_dev >= fecha_hora_ret)
);
CREATE TABLE route2
(
        periodo    TEXT,
        usuario    INTEGER,
        fecha_hora_ret  TIMESTAMP NOT NULL,
        est_origen    INTEGER NOT NULL,
        est_destino   INTEGER NOT NULL,
        fecha_hora_dev  TIMESTAMP NOT NULL CHECK(fecha_hora_dev >= fecha_hora_ret),
        PRIMARY KEY(usuario,fecha_hora_ret)
);

CREATE TABLE route_final
(
        periodo    TEXT,
        usuario    INTEGER,
        fecha_hora_ret  TIMESTAMP NOT NULL,
        est_origen    INTEGER NOT NULL,
        est_destino   INTEGER NOT NULL,
        fecha_hora_dev  TIMESTAMP NOT NULL CHECK(fecha_hora_dev >= 
        fecha_hora_ret),
        PRIMARY KEY(usuario,fecha_hora_ret)
);