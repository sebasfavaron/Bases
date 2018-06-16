CREATE OR REPLACE FUNCTION comprobar_solapamiento() RETURNS trigger AS $$
DECLARE
rowCount int; 
BEGIN
  SELECT count(*) INTO rowCount FROM recorrido_final rec
  WHERE (rec.usuario = NEW.usuario AND 
      ((rec.fecha_hora_dev > NEW.fecha_hora_ret AND rec.fecha_hora_ret < NEW.fecha_hora_ret) OR
        (NEW.fecha_hora_dev > rec.fecha_hora_ret AND NEW.fecha_hora_ret < rec.fecha_hora_ret)));

  IF (rowCount > 0) THEN
    RAISE EXCEPTION 'INSERCION IMPOSIBLE POR SOLAPAMIENTO';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql; 

CREATE TRIGGER triggerSolapamiento
BEFORE INSERT ON recorrido_final
FOR EACH ROW EXECUTE PROCEDURE comprobar_solapamiento();