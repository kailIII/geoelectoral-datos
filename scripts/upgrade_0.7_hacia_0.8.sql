-------------------------------------------
-- Adición de un campo "observacion" en la tabla de resultados
-------------------------------------------

-------------------------------------------
-- Paso 1 - adición de una columna de tipo text "observacion"
-------------------------------------------

ALTER TABLE public.resultados
  ADD COLUMN observacion text;

-------------------------------------------
-- Paso 2 - actualización de la función de inserción de un resultado
-------------------------------------------

-- Function: public.f_insert_resultado_2014_plurinacional_votos(integer, integer, integer, string)
-- entradas:
--  * id_partido
--  * id_dpa
--  * resultado
--  * observacion
CREATE OR REPLACE FUNCTION public.f_insert_resultado_2014_plurinacional_votos(
    _id_partido integer
  , _id_dpa integer
  , _resultado integer
  , _observacion text) RETURNS int
AS $$
  DECLARE
    id_val int;
  BEGIN

  DELETE FROM public.resultados
    WHERE id_resultado IN (
      SELECT id_resultado
      FROM public.resultados AS r
      JOIN (
        SELECT id_eleccion FROM public.elecciones WHERE ano = 2014 AND id_tipo_eleccion=1
      ) AS e ON (r.id_eleccion = e.id_eleccion)
      JOIN (
        SELECT id_eleccion, id_candidato, id_partido, id_tipo_partido FROM public.candidatos WHERE id_partido=_id_partido
      ) AS c ON (c.id_eleccion=e.id_eleccion AND r.id_candidato=c.id_candidato)
      JOIN (
        SELECT id_dpa, id_tipo_dpa FROM public.dpa WHERE id_dpa=_id_dpa
      ) AS d ON r.id_dpa=d.id_dpa);
  
  INSERT INTO public.resultados (id_eleccion, id_candidato, id_partido, id_tipo_partido, id_dpa, id_tipo_dpa, id_tipo_resultado, resultado, observacion)
    SELECT e.id_eleccion, c.id_candidato, c.id_partido, c.id_tipo_partido, d.id_dpa, d.id_tipo_dpa, 1, _resultado, _observacion
    FROM (
      SELECT id_eleccion FROM public.elecciones WHERE ano = 2014 AND id_tipo_eleccion=1
    ) AS e
    JOIN (
      SELECT id_eleccion, id_candidato, id_partido, id_tipo_partido FROM public.candidatos WHERE id_partido=_id_partido
    ) AS c ON (c.id_eleccion=e.id_eleccion)
    JOIN (
      SELECT id_dpa, id_tipo_dpa FROM public.dpa WHERE id_dpa=_id_dpa
    ) AS d ON true
  RETURNING id_resultado INTO id_val;

  RETURN id_val;

  END;
$$
LANGUAGE plpgsql;
