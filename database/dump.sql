--
-- PostgreSQL database dump
--

\restrict 2r2afXVeVX11JnUESHcYarlYN82RDvK0ZxOwb7whvcEGy2afxchd4cofR21aa8U

-- Dumped from database version 15.17 (Debian 15.17-1.pgdg13+1)
-- Dumped by pg_dump version 15.17 (Debian 15.17-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP INDEX IF EXISTS public.idx_paro_sexo;
DROP INDEX IF EXISTS public.idx_paro_anio;
DROP INDEX IF EXISTS public.idx_nacimientos_montilla_anio;
DROP INDEX IF EXISTS public.idx_indice_envejecimiento_ieca_anio;
DROP INDEX IF EXISTS public.idx_indice_envejecimiento_forecast_2032_anio;
DROP INDEX IF EXISTS public.idx_defunciones_montilla_anio;
DROP TABLE IF EXISTS public.tasa_saldo_migratorio_comparativa;
DROP TABLE IF EXISTS public.saldo_migratorio_ine_2021_2024;
DROP TABLE IF EXISTS public.saldo_migratorio_comparativa;
DROP TABLE IF EXISTS public.poblacion_joven_ine_stack;
DROP TABLE IF EXISTS public.poblacion_joven_ine_serie;
DROP TABLE IF EXISTS public.poblacion_joven_ine_2021_2025;
DROP TABLE IF EXISTS public.poblacion_joven_ine_2003_2022;
DROP TABLE IF EXISTS public.poblacion_edad_sexo_ine_padron_2003_2022;
DROP TABLE IF EXISTS public.poblacion_edad_sexo_ine_comparativa;
DROP TABLE IF EXISTS public.poblacion_edad_sexo_ine_censo_2021_2025;
DROP TABLE IF EXISTS public.paro_registrado_montilla_sexo;
DROP TABLE IF EXISTS public.nacimientos_montilla;
DROP VIEW IF EXISTS public.montilla_indicadores_migracion_fix;
DROP TABLE IF EXISTS public.montilla_indicadores_final_long;
DROP TABLE IF EXISTS public.migracion_rebuild;
DROP TABLE IF EXISTS public.migracion_ine_2021_2024_total;
DROP TABLE IF EXISTS public.migracion_ieca_2003_2021;
DROP TABLE IF EXISTS public.inmigracion_sexo_ieca_2003_2021;
DROP TABLE IF EXISTS public.indice_envejecimiento_ine;
DROP TABLE IF EXISTS public.indice_envejecimiento_ieca;
DROP TABLE IF EXISTS public.indice_envejecimiento_forecast_2032;
DROP TABLE IF EXISTS public.indice_dependencia_ine;
DROP TABLE IF EXISTS public.indice_dependencia_ieca;
DROP TABLE IF EXISTS public.edad_media_sexo_montilla;
DROP TABLE IF EXISTS public.edad_media_sexo_ine;
DROP TABLE IF EXISTS public.edad_media_sexo_ieca;
DROP TABLE IF EXISTS public.dim_indicador_sima;
DROP TABLE IF EXISTS public.defunciones_montilla;
DROP TABLE IF EXISTS public.crecimiento_natural_rebuild;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: crecimiento_natural_rebuild; Type: TABLE; Schema: public; Owner: montilla_user
--

CREATE TABLE public.crecimiento_natural_rebuild (
    cod_ine integer,
    municipio text,
    anio integer,
    bloque text,
    indicador_id text,
    indicador_nombre text,
    unidad text,
    fuente text,
    valor double precision,
    valor_texto text
);


ALTER TABLE public.crecimiento_natural_rebuild OWNER TO montilla_user;

--
-- Name: defunciones_montilla; Type: TABLE; Schema: public; Owner: montilla_user
--

CREATE TABLE public.defunciones_montilla (
    anio integer,
    defunciones double precision
);


ALTER TABLE public.defunciones_montilla OWNER TO montilla_user;

--
-- Name: dim_indicador_sima; Type: TABLE; Schema: public; Owner: montilla_user
--

CREATE TABLE public.dim_indicador_sima (
    indicador_id text,
    bloque text,
    indicador_nombre text,
    unidad text,
    tipo text
);


ALTER TABLE public.dim_indicador_sima OWNER TO montilla_user;

--
-- Name: edad_media_sexo_ieca; Type: TABLE; Schema: public; Owner: montilla_user
--

CREATE TABLE public.edad_media_sexo_ieca (
    anio integer,
    sexo text,
    edad_media double precision,
    fuente text
);


ALTER TABLE public.edad_media_sexo_ieca OWNER TO montilla_user;

--
-- Name: edad_media_sexo_ine; Type: TABLE; Schema: public; Owner: montilla_user
--

CREATE TABLE public.edad_media_sexo_ine (
    anio integer,
    sexo text,
    edad_media double precision,
    fuente text
);


ALTER TABLE public.edad_media_sexo_ine OWNER TO montilla_user;

--
-- Name: edad_media_sexo_montilla; Type: TABLE; Schema: public; Owner: montilla_user
--

CREATE TABLE public.edad_media_sexo_montilla (
    anio integer,
    sexo text,
    edad_media double precision,
    fuente text
);


ALTER TABLE public.edad_media_sexo_montilla OWNER TO montilla_user;

--
-- Name: indice_dependencia_ieca; Type: TABLE; Schema: public; Owner: montilla_user
--

CREATE TABLE public.indice_dependencia_ieca (
    anio integer,
    tipo text,
    indice_dependencia numeric
);


ALTER TABLE public.indice_dependencia_ieca OWNER TO montilla_user;

--
-- Name: indice_dependencia_ine; Type: TABLE; Schema: public; Owner: montilla_user
--

CREATE TABLE public.indice_dependencia_ine (
    anio integer,
    indice_dependencia numeric
);


ALTER TABLE public.indice_dependencia_ine OWNER TO montilla_user;

--
-- Name: indice_envejecimiento_forecast_2032; Type: TABLE; Schema: public; Owner: montilla_user
--

CREATE TABLE public.indice_envejecimiento_forecast_2032 (
    anio integer,
    fuente_modelo text,
    metodo text,
    tipo text,
    valor double precision,
    lo80 double precision,
    hi80 double precision,
    lo95 double precision,
    hi95 double precision
);


ALTER TABLE public.indice_envejecimiento_forecast_2032 OWNER TO montilla_user;

--
-- Name: indice_envejecimiento_ieca; Type: TABLE; Schema: public; Owner: montilla_user
--

CREATE TABLE public.indice_envejecimiento_ieca (
    municipio text,
    anio integer,
    indicador text,
    medida text,
    indice_envejecimiento double precision,
    fuente text
);


ALTER TABLE public.indice_envejecimiento_ieca OWNER TO montilla_user;

--
-- Name: indice_envejecimiento_ine; Type: TABLE; Schema: public; Owner: montilla_user
--

CREATE TABLE public.indice_envejecimiento_ine (
    anio integer,
    indice_envejecimiento numeric
);


ALTER TABLE public.indice_envejecimiento_ine OWNER TO montilla_user;

--
-- Name: inmigracion_sexo_ieca_2003_2021; Type: TABLE; Schema: public; Owner: montilla_user
--

CREATE TABLE public.inmigracion_sexo_ieca_2003_2021 (
    anio integer,
    sexo text,
    inmigraciones double precision,
    fuente text
);


ALTER TABLE public.inmigracion_sexo_ieca_2003_2021 OWNER TO montilla_user;

--
-- Name: migracion_ieca_2003_2021; Type: TABLE; Schema: public; Owner: montilla_user
--

CREATE TABLE public.migracion_ieca_2003_2021 (
    anio integer,
    inmigraciones double precision,
    emigraciones double precision,
    saldo_migratorio double precision,
    fuente text
);


ALTER TABLE public.migracion_ieca_2003_2021 OWNER TO montilla_user;

--
-- Name: migracion_ine_2021_2024_total; Type: TABLE; Schema: public; Owner: montilla_user
--

CREATE TABLE public.migracion_ine_2021_2024_total (
    anio integer,
    inmigracion_exterior double precision,
    emigracion_exterior double precision,
    inmigracion_intermunicipal double precision,
    emigracion_intermunicipal double precision,
    inmigraciones double precision,
    emigraciones double precision,
    saldo_migratorio_calculado double precision,
    fuente text
);


ALTER TABLE public.migracion_ine_2021_2024_total OWNER TO montilla_user;

--
-- Name: migracion_rebuild; Type: TABLE; Schema: public; Owner: montilla_user
--

CREATE TABLE public.migracion_rebuild (
    cod_ine integer,
    municipio text,
    anio integer,
    bloque text,
    indicador_id text,
    indicador_nombre text,
    unidad text,
    fuente text,
    valor double precision,
    valor_texto text
);


ALTER TABLE public.migracion_rebuild OWNER TO montilla_user;

--
-- Name: montilla_indicadores_final_long; Type: TABLE; Schema: public; Owner: montilla_user
--

CREATE TABLE public.montilla_indicadores_final_long (
    cod_ine integer,
    municipio text,
    anio integer,
    bloque text,
    indicador_id text,
    indicador_nombre text,
    unidad text,
    fuente text,
    valor numeric,
    valor_texto text
);


ALTER TABLE public.montilla_indicadores_final_long OWNER TO montilla_user;

--
-- Name: montilla_indicadores_migracion_fix; Type: VIEW; Schema: public; Owner: montilla_user
--

CREATE VIEW public.montilla_indicadores_migracion_fix AS
 SELECT montilla_indicadores_final_long.cod_ine,
    montilla_indicadores_final_long.municipio,
    montilla_indicadores_final_long.anio,
    montilla_indicadores_final_long.bloque,
    montilla_indicadores_final_long.indicador_id,
    montilla_indicadores_final_long.indicador_nombre,
    montilla_indicadores_final_long.unidad,
    montilla_indicadores_final_long.fuente,
    montilla_indicadores_final_long.valor,
    montilla_indicadores_final_long.valor_texto
   FROM public.montilla_indicadores_final_long
  WHERE (montilla_indicadores_final_long.indicador_id <> ALL (ARRAY['b12'::text, 'b13'::text, 'b14'::text, 'b15'::text, 'saldo_natural'::text]))
UNION ALL
 SELECT migracion_rebuild.cod_ine,
    migracion_rebuild.municipio,
    migracion_rebuild.anio,
    migracion_rebuild.bloque,
    migracion_rebuild.indicador_id,
    migracion_rebuild.indicador_nombre,
    migracion_rebuild.unidad,
    migracion_rebuild.fuente,
    migracion_rebuild.valor,
    migracion_rebuild.valor_texto
   FROM public.migracion_rebuild
UNION ALL
 SELECT crecimiento_natural_rebuild.cod_ine,
    crecimiento_natural_rebuild.municipio,
    crecimiento_natural_rebuild.anio,
    crecimiento_natural_rebuild.bloque,
    crecimiento_natural_rebuild.indicador_id,
    crecimiento_natural_rebuild.indicador_nombre,
    crecimiento_natural_rebuild.unidad,
    crecimiento_natural_rebuild.fuente,
    crecimiento_natural_rebuild.valor,
    crecimiento_natural_rebuild.valor_texto
   FROM public.crecimiento_natural_rebuild;


ALTER TABLE public.montilla_indicadores_migracion_fix OWNER TO montilla_user;

--
-- Name: nacimientos_montilla; Type: TABLE; Schema: public; Owner: montilla_user
--

CREATE TABLE public.nacimientos_montilla (
    anio integer,
    nacimientos double precision
);


ALTER TABLE public.nacimientos_montilla OWNER TO montilla_user;

--
-- Name: paro_registrado_montilla_sexo; Type: TABLE; Schema: public; Owner: montilla_user
--

CREATE TABLE public.paro_registrado_montilla_sexo (
    anio integer,
    sexo text,
    paro_registrado double precision
);


ALTER TABLE public.paro_registrado_montilla_sexo OWNER TO montilla_user;

--
-- Name: poblacion_edad_sexo_ine_censo_2021_2025; Type: TABLE; Schema: public; Owner: montilla_user
--

CREATE TABLE public.poblacion_edad_sexo_ine_censo_2021_2025 (
    anio integer,
    sexo text,
    grupo_edad text,
    edad_min integer,
    poblacion double precision,
    fuente text
);


ALTER TABLE public.poblacion_edad_sexo_ine_censo_2021_2025 OWNER TO montilla_user;

--
-- Name: poblacion_edad_sexo_ine_comparativa; Type: TABLE; Schema: public; Owner: montilla_user
--

CREATE TABLE public.poblacion_edad_sexo_ine_comparativa (
    anio integer,
    sexo text,
    grupo_edad text,
    edad_min integer,
    poblacion double precision,
    fuente text
);


ALTER TABLE public.poblacion_edad_sexo_ine_comparativa OWNER TO montilla_user;

--
-- Name: poblacion_edad_sexo_ine_padron_2003_2022; Type: TABLE; Schema: public; Owner: montilla_user
--

CREATE TABLE public.poblacion_edad_sexo_ine_padron_2003_2022 (
    anio integer,
    sexo text,
    grupo_edad text,
    edad_min integer,
    poblacion double precision,
    fuente text
);


ALTER TABLE public.poblacion_edad_sexo_ine_padron_2003_2022 OWNER TO montilla_user;

--
-- Name: poblacion_joven_ine_2003_2022; Type: TABLE; Schema: public; Owner: montilla_user
--

CREATE TABLE public.poblacion_joven_ine_2003_2022 (
    anio integer,
    poblacion_joven double precision,
    poblacion_total double precision,
    porcentaje_joven double precision,
    fuente text
);


ALTER TABLE public.poblacion_joven_ine_2003_2022 OWNER TO montilla_user;

--
-- Name: poblacion_joven_ine_2021_2025; Type: TABLE; Schema: public; Owner: montilla_user
--

CREATE TABLE public.poblacion_joven_ine_2021_2025 (
    anio integer,
    poblacion_joven double precision,
    poblacion_total double precision,
    porcentaje_joven double precision,
    fuente text
);


ALTER TABLE public.poblacion_joven_ine_2021_2025 OWNER TO montilla_user;

--
-- Name: poblacion_joven_ine_serie; Type: TABLE; Schema: public; Owner: montilla_user
--

CREATE TABLE public.poblacion_joven_ine_serie (
    anio integer,
    poblacion_joven double precision,
    poblacion_total double precision,
    porcentaje_joven double precision,
    fuente text
);


ALTER TABLE public.poblacion_joven_ine_serie OWNER TO montilla_user;

--
-- Name: poblacion_joven_ine_stack; Type: TABLE; Schema: public; Owner: montilla_user
--

CREATE TABLE public.poblacion_joven_ine_stack (
    anio integer,
    poblacion_joven double precision,
    poblacion_total double precision,
    porcentaje_joven double precision,
    fuente text
);


ALTER TABLE public.poblacion_joven_ine_stack OWNER TO montilla_user;

--
-- Name: saldo_migratorio_comparativa; Type: TABLE; Schema: public; Owner: montilla_user
--

CREATE TABLE public.saldo_migratorio_comparativa (
    anio integer,
    saldo_migratorio double precision,
    fuente text
);


ALTER TABLE public.saldo_migratorio_comparativa OWNER TO montilla_user;

--
-- Name: saldo_migratorio_ine_2021_2024; Type: TABLE; Schema: public; Owner: montilla_user
--

CREATE TABLE public.saldo_migratorio_ine_2021_2024 (
    anio integer,
    saldo_migratorio double precision,
    fuente text
);


ALTER TABLE public.saldo_migratorio_ine_2021_2024 OWNER TO montilla_user;

--
-- Name: tasa_saldo_migratorio_comparativa; Type: TABLE; Schema: public; Owner: montilla_user
--

CREATE TABLE public.tasa_saldo_migratorio_comparativa (
    anio integer,
    saldo_migratorio double precision,
    fuente text,
    poblacion_total double precision,
    tasa_saldo_1000 double precision
);


ALTER TABLE public.tasa_saldo_migratorio_comparativa OWNER TO montilla_user;

--
-- Data for Name: crecimiento_natural_rebuild; Type: TABLE DATA; Schema: public; Owner: montilla_user
--

COPY public.crecimiento_natural_rebuild (cod_ine, municipio, anio, bloque, indicador_id, indicador_nombre, unidad, fuente, valor, valor_texto) FROM stdin;
14042	Montilla	2006	Población	b14	Nacimientos	personas	IECA	241	\N
14042	Montilla	2007	Población	b14	Nacimientos	personas	IECA	230	\N
14042	Montilla	2008	Población	b14	Nacimientos	personas	IECA	231	\N
14042	Montilla	2009	Población	b14	Nacimientos	personas	IECA	230	\N
14042	Montilla	2010	Población	b14	Nacimientos	personas	IECA	222	\N
14042	Montilla	2011	Población	b14	Nacimientos	personas	IECA	217	\N
14042	Montilla	2012	Población	b14	Nacimientos	personas	IECA	220	\N
14042	Montilla	2013	Población	b14	Nacimientos	personas	IECA	176	\N
14042	Montilla	2014	Población	b14	Nacimientos	personas	IECA	179	\N
14042	Montilla	2015	Población	b14	Nacimientos	personas	IECA	196	\N
14042	Montilla	2016	Población	b14	Nacimientos	personas	IECA	170	\N
14042	Montilla	2017	Población	b14	Nacimientos	personas	IECA	150	\N
14042	Montilla	2018	Población	b14	Nacimientos	personas	IECA	164	\N
14042	Montilla	2019	Población	b14	Nacimientos	personas	IECA	151	\N
14042	Montilla	2020	Población	b14	Nacimientos	personas	IECA	158	\N
14042	Montilla	2021	Población	b14	Nacimientos	personas	IECA	136	\N
14042	Montilla	2022	Población	b14	Nacimientos	personas	IECA	149	\N
14042	Montilla	2023	Población	b14	Nacimientos	personas	IECA	137	\N
14042	Montilla	2024	Población	b14	Nacimientos	personas	IECA	120	\N
14042	Montilla	1996	Población	b15	Defunciones	personas	IECA	215	\N
14042	Montilla	1997	Población	b15	Defunciones	personas	IECA	218	\N
14042	Montilla	1998	Población	b15	Defunciones	personas	IECA	234	\N
14042	Montilla	1999	Población	b15	Defunciones	personas	IECA	207	\N
14042	Montilla	2000	Población	b15	Defunciones	personas	IECA	191	\N
14042	Montilla	2001	Población	b15	Defunciones	personas	IECA	211	\N
14042	Montilla	2002	Población	b15	Defunciones	personas	IECA	256	\N
14042	Montilla	2003	Población	b15	Defunciones	personas	IECA	235	\N
14042	Montilla	2004	Población	b15	Defunciones	personas	IECA	210	\N
14042	Montilla	2005	Población	b15	Defunciones	personas	IECA	212	\N
14042	Montilla	2006	Población	b15	Defunciones	personas	IECA	216	\N
14042	Montilla	2007	Población	b15	Defunciones	personas	IECA	233	\N
14042	Montilla	2008	Población	b15	Defunciones	personas	IECA	239	\N
14042	Montilla	2009	Población	b15	Defunciones	personas	IECA	239	\N
14042	Montilla	2010	Población	b15	Defunciones	personas	IECA	212	\N
14042	Montilla	2011	Población	b15	Defunciones	personas	IECA	235	\N
14042	Montilla	2012	Población	b15	Defunciones	personas	IECA	263	\N
14042	Montilla	2013	Población	b15	Defunciones	personas	IECA	256	\N
14042	Montilla	2014	Población	b15	Defunciones	personas	IECA	259	\N
14042	Montilla	2015	Población	b15	Defunciones	personas	IECA	280	\N
14042	Montilla	2016	Población	b15	Defunciones	personas	IECA	206	\N
14042	Montilla	2017	Población	b15	Defunciones	personas	IECA	267	\N
14042	Montilla	2018	Población	b15	Defunciones	personas	IECA	271	\N
14042	Montilla	2019	Población	b15	Defunciones	personas	IECA	249	\N
14042	Montilla	2020	Población	b15	Defunciones	personas	IECA	250	\N
14042	Montilla	2021	Población	b15	Defunciones	personas	IECA	255	\N
14042	Montilla	2022	Población	b15	Defunciones	personas	IECA	278	\N
14042	Montilla	2023	Población	b15	Defunciones	personas	IECA	252	\N
14042	Montilla	2024	Población	b15	Defunciones	personas	IECA	244	\N
14042	Montilla	2006	Población	saldo_natural	Saldo vegetativo	personas	IECA	25	\N
14042	Montilla	2007	Población	saldo_natural	Saldo vegetativo	personas	IECA	-3	\N
14042	Montilla	2008	Población	saldo_natural	Saldo vegetativo	personas	IECA	-8	\N
14042	Montilla	2009	Población	saldo_natural	Saldo vegetativo	personas	IECA	-9	\N
14042	Montilla	2010	Población	saldo_natural	Saldo vegetativo	personas	IECA	10	\N
14042	Montilla	2011	Población	saldo_natural	Saldo vegetativo	personas	IECA	-18	\N
14042	Montilla	2012	Población	saldo_natural	Saldo vegetativo	personas	IECA	-43	\N
14042	Montilla	2013	Población	saldo_natural	Saldo vegetativo	personas	IECA	-80	\N
14042	Montilla	2014	Población	saldo_natural	Saldo vegetativo	personas	IECA	-80	\N
14042	Montilla	2015	Población	saldo_natural	Saldo vegetativo	personas	IECA	-84	\N
14042	Montilla	2016	Población	saldo_natural	Saldo vegetativo	personas	IECA	-36	\N
14042	Montilla	2017	Población	saldo_natural	Saldo vegetativo	personas	IECA	-117	\N
14042	Montilla	2018	Población	saldo_natural	Saldo vegetativo	personas	IECA	-107	\N
14042	Montilla	2019	Población	saldo_natural	Saldo vegetativo	personas	IECA	-98	\N
14042	Montilla	2020	Población	saldo_natural	Saldo vegetativo	personas	IECA	-92	\N
14042	Montilla	2021	Población	saldo_natural	Saldo vegetativo	personas	IECA	-119	\N
14042	Montilla	2022	Población	saldo_natural	Saldo vegetativo	personas	IECA	-129	\N
14042	Montilla	2023	Población	saldo_natural	Saldo vegetativo	personas	IECA	-115	\N
14042	Montilla	2024	Población	saldo_natural	Saldo vegetativo	personas	IECA	-124	\N
\.


--
-- Data for Name: defunciones_montilla; Type: TABLE DATA; Schema: public; Owner: montilla_user
--

COPY public.defunciones_montilla (anio, defunciones) FROM stdin;
1996	215
1997	218
1998	234
1999	207
2000	191
2001	211
2002	256
2003	235
2004	210
2005	212
2006	216
2007	233
2008	239
2009	239
2010	212
2011	235
2012	263
2013	256
2014	259
2015	280
2016	206
2017	267
2018	271
2019	249
2020	250
2021	255
2022	278
2023	252
2024	244
\.


--
-- Data for Name: dim_indicador_sima; Type: TABLE DATA; Schema: public; Owner: montilla_user
--

COPY public.dim_indicador_sima (indicador_id, bloque, indicador_nombre, unidad, tipo) FROM stdin;
b01	Poblacion	Poblacion total	habitantes	num
b02	Poblacion	Poblacion. Hombres	habitantes	num
b03	Poblacion	Poblacion. Mujeres	habitantes	num
b06	Poblacion	Porcentaje de poblacion menor de 20 anos	%	num
b07	Poblacion	Porcentaje de poblacion mayor de 65 anos	%	num
b08	Poblacion	Variacion relativa de la poblacion en diez anos	%	num
b14	Poblacion	Nacimientos	nacimientos	num
b15	Poblacion	Defunciones	defunciones	num
\.


--
-- Data for Name: edad_media_sexo_ieca; Type: TABLE DATA; Schema: public; Owner: montilla_user
--

COPY public.edad_media_sexo_ieca (anio, sexo, edad_media, fuente) FROM stdin;
1998	Ambos sexos	38.690000000000005	IECA
1998	Hombres	\N	IECA
1998	Mujeres	\N	IECA
1999	Ambos sexos	38.220000000000006	IECA
1999	Hombres	36.741593566999995	IECA
1999	Mujeres	39.655089714	IECA
2000	Ambos sexos	38.57	IECA
2000	Hombres	\N	IECA
2000	Mujeres	\N	IECA
2001	Ambos sexos	38.78	IECA
2001	Hombres	37.36062778699999	IECA
2001	Mujeres	40.16815259300001	IECA
2002	Ambos sexos	39	IECA
2002	Hombres	37.606612217000006	IECA
2002	Mujeres	40.367900392	IECA
2003	Ambos sexos	39.25	IECA
2003	Hombres	37.873598679	IECA
2003	Mujeres	40.603339581	IECA
2004	Ambos sexos	39.61	IECA
2004	Hombres	38.19601604000001	IECA
2004	Mujeres	40.99897889700001	IECA
2005	Ambos sexos	39.9	IECA
2005	Hombres	38.463575013	IECA
2005	Mujeres	41.30698047799999	IECA
2006	Ambos sexos	40.120000000000005	IECA
2006	Hombres	38.73152034300001	IECA
2006	Mujeres	41.487898142999995	IECA
2007	Ambos sexos	40.36	IECA
2007	Hombres	39.007206823	IECA
2007	Mujeres	41.69572327000001	IECA
2008	Ambos sexos	40.52	IECA
2008	Hombres	39.187616309	IECA
2008	Mujeres	41.842313788000006	IECA
2009	Ambos sexos	40.809999999999995	IECA
2009	Hombres	39.47174758899999	IECA
2009	Mujeres	42.125728075000005	IECA
2010	Ambos sexos	41.01	IECA
2010	Hombres	39.65673531400001	IECA
2010	Mujeres	42.33489509899999	IECA
2011	Ambos sexos	41.290000000000006	IECA
2011	Hombres	39.962508463	IECA
2011	Mujeres	42.58329185299999	IECA
2012	Ambos sexos	41.57	IECA
2012	Hombres	40.2468612148	IECA
2012	Mujeres	42.872841965499994	IECA
2013	Ambos sexos	41.86	IECA
2013	Hombres	40.6086531098	IECA
2013	Mujeres	43.09113259440001	IECA
2014	Ambos sexos	42.190000000000005	IECA
2014	Hombres	40.90748993059999	IECA
2014	Mujeres	43.4411863131	IECA
2015	Ambos sexos	42.49927718	IECA
2015	Hombres	41.16363089610001	IECA
2015	Mujeres	43.807828282799996	IECA
2016	Ambos sexos	42.7818318	IECA
2016	Hombres	41.45014257319999	IECA
2016	Mujeres	44.0887890095	IECA
2017	Ambos sexos	43.271511052	IECA
2017	Hombres	41.94763645859999	IECA
2017	Mujeres	44.568844907	IECA
2018	Ambos sexos	43.707459510999996	IECA
2018	Hombres	42.386106977199994	IECA
2018	Mujeres	45.007753273599995	IECA
2019	Ambos sexos	43.982829519999996	IECA
2019	Hombres	42.676076808000005	IECA
2019	Mujeres	45.27220580600001	IECA
2020	Ambos sexos	44.29466995	IECA
2020	Hombres	42.978792172000006	IECA
2020	Mujeres	45.59295823900001	IECA
2021	Ambos sexos	44.604935272000006	IECA
2021	Hombres	43.25726770099999	IECA
2021	Mujeres	45.928408792000006	IECA
2022	Ambos sexos	44.99475322400001	IECA
2022	Hombres	43.71697013200001	IECA
2022	Mujeres	46.2509038	IECA
\.


--
-- Data for Name: edad_media_sexo_ine; Type: TABLE DATA; Schema: public; Owner: montilla_user
--

COPY public.edad_media_sexo_ine (anio, sexo, edad_media, fuente) FROM stdin;
2021	Hombres	42.76051620969903	INE
2021	Mujeres	45.37666374781086	INE
2021	Total	44.081487376752	INE
2022	Hombres	43.234585655222006	INE
2022	Mujeres	45.749447538230356	INE
2022	Total	44.50249565488658	INE
2023	Hombres	43.57675239992755	INE
2023	Mujeres	46.1430538283887	INE
2023	Total	44.872331838565024	INE
2024	Hombres	43.89829121977822	INE
2024	Mujeres	46.331123486254754	INE
2024	Total	45.13166031817163	INE
2025	Hombres	44.25084513476473	INE
2025	Mujeres	46.715168489374946	INE
2025	Total	45.49977469358328	INE
\.


--
-- Data for Name: edad_media_sexo_montilla; Type: TABLE DATA; Schema: public; Owner: montilla_user
--

COPY public.edad_media_sexo_montilla (anio, sexo, edad_media, fuente) FROM stdin;
1998	Hombres	\N	IECA
1998	Mujeres	\N	IECA
1998	Total	38.690000000000005	IECA
1999	Hombres	36.741593566999995	IECA
1999	Mujeres	39.655089714	IECA
1999	Total	38.220000000000006	IECA
2000	Hombres	\N	IECA
2000	Mujeres	\N	IECA
2000	Total	38.57	IECA
2001	Hombres	37.36062778699999	IECA
2001	Mujeres	40.16815259300001	IECA
2001	Total	38.78	IECA
2002	Hombres	37.606612217000006	IECA
2002	Mujeres	40.367900392	IECA
2002	Total	39	IECA
2003	Hombres	37.873598679	IECA
2003	Mujeres	40.603339581	IECA
2003	Total	39.25	IECA
2004	Hombres	38.19601604000001	IECA
2004	Mujeres	40.99897889700001	IECA
2004	Total	39.61	IECA
2005	Hombres	38.463575013	IECA
2005	Mujeres	41.30698047799999	IECA
2005	Total	39.9	IECA
2006	Hombres	38.73152034300001	IECA
2006	Mujeres	41.487898142999995	IECA
2006	Total	40.120000000000005	IECA
2007	Hombres	39.007206823	IECA
2007	Mujeres	41.69572327000001	IECA
2007	Total	40.36	IECA
2008	Hombres	39.187616309	IECA
2008	Mujeres	41.842313788000006	IECA
2008	Total	40.52	IECA
2009	Hombres	39.47174758899999	IECA
2009	Mujeres	42.125728075000005	IECA
2009	Total	40.809999999999995	IECA
2010	Hombres	39.65673531400001	IECA
2010	Mujeres	42.33489509899999	IECA
2010	Total	41.01	IECA
2011	Hombres	39.962508463	IECA
2011	Mujeres	42.58329185299999	IECA
2011	Total	41.290000000000006	IECA
2012	Hombres	40.2468612148	IECA
2012	Mujeres	42.872841965499994	IECA
2012	Total	41.57	IECA
2013	Hombres	40.6086531098	IECA
2013	Mujeres	43.09113259440001	IECA
2013	Total	41.86	IECA
2014	Hombres	40.90748993059999	IECA
2014	Mujeres	43.4411863131	IECA
2014	Total	42.190000000000005	IECA
2015	Hombres	41.16363089610001	IECA
2015	Mujeres	43.807828282799996	IECA
2015	Total	42.49927718	IECA
2016	Hombres	41.45014257319999	IECA
2016	Mujeres	44.0887890095	IECA
2016	Total	42.7818318	IECA
2017	Hombres	41.94763645859999	IECA
2017	Mujeres	44.568844907	IECA
2017	Total	43.271511052	IECA
2018	Hombres	42.386106977199994	IECA
2018	Mujeres	45.007753273599995	IECA
2018	Total	43.707459510999996	IECA
2019	Hombres	42.676076808000005	IECA
2019	Mujeres	45.27220580600001	IECA
2019	Total	43.982829519999996	IECA
2020	Hombres	42.978792172000006	IECA
2020	Mujeres	45.59295823900001	IECA
2020	Total	44.29466995	IECA
2021	Hombres	43.25726770099999	IECA
2021	Mujeres	45.928408792000006	IECA
2021	Total	44.604935272000006	IECA
2022	Hombres	43.71697013200001	IECA
2022	Mujeres	46.2509038	IECA
2022	Total	44.99475322400001	IECA
2023	Hombres	43.57675239992755	INE
2023	Mujeres	46.1430538283887	INE
2023	Total	44.872331838565024	INE
2024	Hombres	43.89829121977822	INE
2024	Mujeres	46.331123486254754	INE
2024	Total	45.13166031817163	INE
2025	Hombres	44.25084513476473	INE
2025	Mujeres	46.715168489374946	INE
2025	Total	45.49977469358328	INE
\.


--
-- Data for Name: indice_dependencia_ieca; Type: TABLE DATA; Schema: public; Owner: montilla_user
--

COPY public.indice_dependencia_ieca (anio, tipo, indice_dependencia) FROM stdin;
2020	Índice de dependencia global	53.1864726488817
2021	Índice de dependencia global	53.09117965367965
2022	Índice de dependencia global	52.930776553787574
\.


--
-- Data for Name: indice_dependencia_ine; Type: TABLE DATA; Schema: public; Owner: montilla_user
--

COPY public.indice_dependencia_ine (anio, indice_dependencia) FROM stdin;
2021	51.2
2022	51.5
2023	51.8
2024	52.1
2025	52.4
\.


--
-- Data for Name: indice_envejecimiento_forecast_2032; Type: TABLE DATA; Schema: public; Owner: montilla_user
--

COPY public.indice_envejecimiento_forecast_2032 (anio, fuente_modelo, metodo, tipo, valor, lo80, hi80, lo95, hi95) FROM stdin;
1996	IECA	Regresion lineal	observado	75.72320872918937	\N	\N	\N	\N
1998	IECA	Regresion lineal	observado	90.48943535144817	\N	\N	\N	\N
1999	IECA	Regresion lineal	observado	86.23433567036797	\N	\N	\N	\N
2000	IECA	Regresion lineal	observado	89.92894492573438	\N	\N	\N	\N
2001	IECA	Regresion lineal	observado	91.93545456795887	\N	\N	\N	\N
2002	IECA	Regresion lineal	observado	93.39407744874715	\N	\N	\N	\N
2003	IECA	Regresion lineal	observado	94.86884491486424	\N	\N	\N	\N
2004	IECA	Regresion lineal	observado	97.32833372392781	\N	\N	\N	\N
2005	IECA	Regresion lineal	observado	98.44632768361582	\N	\N	\N	\N
2006	IECA	Regresion lineal	observado	100.49680624556423	\N	\N	\N	\N
2007	IECA	Regresion lineal	observado	101.97162779514306	\N	\N	\N	\N
2008	IECA	Regresion lineal	observado	103.69649805447472	\N	\N	\N	\N
2009	IECA	Regresion lineal	observado	106.09547123623011	\N	\N	\N	\N
2010	IECA	Regresion lineal	observado	107.84119106699752	\N	\N	\N	\N
2011	IECA	Regresion lineal	observado	110.45603426555807	\N	\N	\N	\N
2012	IECA	Regresion lineal	observado	112.24177505738334	\N	\N	\N	\N
2013	IECA	Regresion lineal	observado	114.06491499227202	\N	\N	\N	\N
2014	IECA	Regresion lineal	observado	117.63771186440677	\N	\N	\N	\N
2015	IECA	Regresion lineal	observado	120.77569839978301	\N	\N	\N	\N
2016	IECA	Regresion lineal	observado	122.33895493502902	\N	\N	\N	\N
2017	IECA	Regresion lineal	observado	127.80946948088989	\N	\N	\N	\N
2018	IECA	Regresion lineal	observado	134.28148148148148	\N	\N	\N	\N
2019	IECA	Regresion lineal	observado	138.31267009374056	\N	\N	\N	\N
2020	IECA	Regresion lineal	observado	141.7330067360686	\N	\N	\N	\N
2021	IECA	Regresion lineal	observado	146.51381909547737	\N	\N	\N	\N
2022	IECA	Regresion lineal	observado	152.80935368626177	\N	\N	\N	\N
2023	IECA	Regresion lineal	predicho	145.06338998065257	138.74645098473042	151.38032897657473	135.17026066580928	154.95651929549587
2024	IECA	Regresion lineal	predicho	147.60379535563607	141.23577308394584	153.9718176273263	137.6306631385445	157.57692757272764
2025	IECA	Regresion lineal	predicho	150.14420073062047	143.72190712362067	156.56649433762027	140.08607270485422	160.20232875638672
2026	IECA	Regresion lineal	predicho	152.68460610560487	146.20493320926929	159.16427900194046	142.53661482015553	162.8325973910542
2027	IECA	Regresion lineal	predicho	155.22501148058836	148.6849331431578	161.76508981801894	144.98241759719426	165.46760536398247
2028	IECA	Regresion lineal	predicho	157.76541685557277	151.16198997075156	164.36884374039397	147.42361109572275	168.10722261542278
2029	IECA	Regresion lineal	predicho	160.30582223055717	153.63618755286626	166.97545690824808	149.86032665243704	170.7513178086773
2030	IECA	Regresion lineal	predicho	162.84622760554066	156.10761016635013	169.5848450447312	152.29269625559317	173.39975895548815
2031	IECA	Regresion lineal	predicho	165.38663298052506	158.57634213527507	172.19692382577506	154.72085196740383	176.0524139936463
2032	IECA	Regresion lineal	predicho	167.92703835550947	161.04246749384666	174.81160921717228	157.14492539611567	178.70915131490327
\.


--
-- Data for Name: indice_envejecimiento_ieca; Type: TABLE DATA; Schema: public; Owner: montilla_user
--

COPY public.indice_envejecimiento_ieca (municipio, anio, indicador, medida, indice_envejecimiento, fuente) FROM stdin;
Montilla	1996	Índice de envejecimiento	Población municipal	75.72320872918937	IECA
Montilla	1998	Índice de envejecimiento	Población municipal	90.48943535144817	IECA
Montilla	1999	Índice de envejecimiento	Población municipal	86.23433567036797	IECA
Montilla	2000	Índice de envejecimiento	Población municipal	89.92894492573438	IECA
Montilla	2001	Índice de envejecimiento	Población municipal	91.93545456795887	IECA
Montilla	2002	Índice de envejecimiento	Población municipal	93.39407744874715	IECA
Montilla	2003	Índice de envejecimiento	Población municipal	94.86884491486424	IECA
Montilla	2004	Índice de envejecimiento	Población municipal	97.32833372392781	IECA
Montilla	2005	Índice de envejecimiento	Población municipal	98.44632768361582	IECA
Montilla	2006	Índice de envejecimiento	Población municipal	100.49680624556423	IECA
Montilla	2007	Índice de envejecimiento	Población municipal	101.97162779514306	IECA
Montilla	2008	Índice de envejecimiento	Población municipal	103.69649805447472	IECA
Montilla	2009	Índice de envejecimiento	Población municipal	106.09547123623011	IECA
Montilla	2010	Índice de envejecimiento	Población municipal	107.84119106699752	IECA
Montilla	2011	Índice de envejecimiento	Población municipal	110.45603426555807	IECA
Montilla	2012	Índice de envejecimiento	Población municipal	112.24177505738334	IECA
Montilla	2013	Índice de envejecimiento	Población municipal	114.06491499227202	IECA
Montilla	2014	Índice de envejecimiento	Población municipal	117.63771186440677	IECA
Montilla	2015	Índice de envejecimiento	Población municipal	120.77569839978301	IECA
Montilla	2016	Índice de envejecimiento	Población municipal	122.33895493502902	IECA
Montilla	2017	Índice de envejecimiento	Población municipal	127.80946948088989	IECA
Montilla	2018	Índice de envejecimiento	Población municipal	134.28148148148148	IECA
Montilla	2019	Índice de envejecimiento	Población municipal	138.31267009374056	IECA
Montilla	2020	Índice de envejecimiento	Población municipal	141.7330067360686	IECA
Montilla	2021	Índice de envejecimiento	Población municipal	146.51381909547737	IECA
Montilla	2022	Índice de envejecimiento	Población municipal	152.80935368626177	IECA
\.


--
-- Data for Name: indice_envejecimiento_ine; Type: TABLE DATA; Schema: public; Owner: montilla_user
--

COPY public.indice_envejecimiento_ine (anio, indice_envejecimiento) FROM stdin;
2021	140.0
2022	145.0
2023	147.0
2024	149.0
2025	151.0
\.


--
-- Data for Name: inmigracion_sexo_ieca_2003_2021; Type: TABLE DATA; Schema: public; Owner: montilla_user
--

COPY public.inmigracion_sexo_ieca_2003_2021 (anio, sexo, inmigraciones, fuente) FROM stdin;
2003	Hombres	128	IECA
2003	Mujeres	169	IECA
2003	Total	297	IECA
2004	Hombres	202	IECA
2004	Mujeres	205	IECA
2004	Total	407	IECA
2005	Hombres	205	IECA
2005	Mujeres	219	IECA
2005	Total	424	IECA
2006	Hombres	202	IECA
2006	Mujeres	217	IECA
2006	Total	419	IECA
2007	Hombres	252	IECA
2007	Mujeres	261	IECA
2007	Total	513	IECA
2008	Hombres	209	IECA
2008	Mujeres	256	IECA
2008	Total	465	IECA
2009	Hombres	241	IECA
2009	Mujeres	227	IECA
2009	Total	468	IECA
2010	Hombres	172	IECA
2010	Mujeres	208	IECA
2010	Total	380	IECA
2011	Hombres	165	IECA
2011	Mujeres	197	IECA
2011	Total	362	IECA
2012	Hombres	159	IECA
2012	Mujeres	162	IECA
2012	Total	321	IECA
2013	Hombres	144	IECA
2013	Mujeres	177	IECA
2013	Total	321	IECA
2014	Hombres	193	IECA
2014	Mujeres	175	IECA
2014	Total	368	IECA
2015	Hombres	189	IECA
2015	Mujeres	166	IECA
2015	Total	355	IECA
2016	Hombres	144	IECA
2016	Mujeres	177	IECA
2016	Total	321	IECA
2017	Hombres	185	IECA
2017	Mujeres	165	IECA
2017	Total	350	IECA
2018	Hombres	187	IECA
2018	Mujeres	216	IECA
2018	Total	403	IECA
2019	Hombres	245	IECA
2019	Mujeres	294	IECA
2019	Total	539	IECA
2020	Hombres	162	IECA
2020	Mujeres	235	IECA
2020	Total	397	IECA
2021	Hombres	185	IECA
2021	Mujeres	270	IECA
2021	Total	455	IECA
\.


--
-- Data for Name: migracion_ieca_2003_2021; Type: TABLE DATA; Schema: public; Owner: montilla_user
--

COPY public.migracion_ieca_2003_2021 (anio, inmigraciones, emigraciones, saldo_migratorio, fuente) FROM stdin;
2003	297	298	-1	IECA
2004	407	282	125	IECA
2005	424	311	113	IECA
2006	419	346	73	IECA
2007	513	394	119	IECA
2008	465	441	24	IECA
2009	468	395	73	IECA
2010	380	420	-40	IECA
2011	362	400	-38	IECA
2012	321	380	-59	IECA
2013	321	370	-49	IECA
2014	368	404	-36	IECA
2015	355	444	-89	IECA
2016	321	433	-112	IECA
2017	350	420	-70	IECA
2018	403	482	-79	IECA
2019	539	556	-17	IECA
2020	397	410	-13	IECA
2021	455	500	-45	IECA
\.


--
-- Data for Name: migracion_ine_2021_2024_total; Type: TABLE DATA; Schema: public; Owner: montilla_user
--

COPY public.migracion_ine_2021_2024_total (anio, inmigracion_exterior, emigracion_exterior, inmigracion_intermunicipal, emigracion_intermunicipal, inmigraciones, emigraciones, saldo_migratorio_calculado, fuente) FROM stdin;
2021	149	185	265	358	414	543	-129	INE_EMCR
2022	172	117	363	435	535	552	-17	INE_EMCR
2023	252	152	436	416	688	568	120	INE_EMCR
2024	222	132	323	421	545	553	-8	INE_EMCR
\.


--
-- Data for Name: migracion_rebuild; Type: TABLE DATA; Schema: public; Owner: montilla_user
--

COPY public.migracion_rebuild (cod_ine, municipio, anio, bloque, indicador_id, indicador_nombre, unidad, fuente, valor, valor_texto) FROM stdin;
14042	Montilla	2003	Población	b12	Emigraciones	personas	IECA	298	\N
14042	Montilla	2003	Población	b13	Inmigraciones	personas	IECA	297	\N
14042	Montilla	2004	Población	b12	Emigraciones	personas	IECA	282	\N
14042	Montilla	2004	Población	b13	Inmigraciones	personas	IECA	407	\N
14042	Montilla	2005	Población	b12	Emigraciones	personas	IECA	311	\N
14042	Montilla	2005	Población	b13	Inmigraciones	personas	IECA	424	\N
14042	Montilla	2006	Población	b12	Emigraciones	personas	IECA	346	\N
14042	Montilla	2006	Población	b13	Inmigraciones	personas	IECA	419	\N
14042	Montilla	2007	Población	b12	Emigraciones	personas	IECA	394	\N
14042	Montilla	2007	Población	b13	Inmigraciones	personas	IECA	513	\N
14042	Montilla	2008	Población	b12	Emigraciones	personas	IECA	441	\N
14042	Montilla	2008	Población	b13	Inmigraciones	personas	IECA	465	\N
14042	Montilla	2009	Población	b12	Emigraciones	personas	IECA	395	\N
14042	Montilla	2009	Población	b13	Inmigraciones	personas	IECA	468	\N
14042	Montilla	2010	Población	b12	Emigraciones	personas	IECA	420	\N
14042	Montilla	2010	Población	b13	Inmigraciones	personas	IECA	380	\N
14042	Montilla	2011	Población	b12	Emigraciones	personas	IECA	400	\N
14042	Montilla	2011	Población	b13	Inmigraciones	personas	IECA	362	\N
14042	Montilla	2012	Población	b12	Emigraciones	personas	IECA	380	\N
14042	Montilla	2012	Población	b13	Inmigraciones	personas	IECA	321	\N
14042	Montilla	2013	Población	b12	Emigraciones	personas	IECA	370	\N
14042	Montilla	2013	Población	b13	Inmigraciones	personas	IECA	321	\N
14042	Montilla	2014	Población	b12	Emigraciones	personas	IECA	404	\N
14042	Montilla	2014	Población	b13	Inmigraciones	personas	IECA	368	\N
14042	Montilla	2015	Población	b12	Emigraciones	personas	IECA	444	\N
14042	Montilla	2015	Población	b13	Inmigraciones	personas	IECA	355	\N
14042	Montilla	2016	Población	b12	Emigraciones	personas	IECA	433	\N
14042	Montilla	2016	Población	b13	Inmigraciones	personas	IECA	321	\N
14042	Montilla	2017	Población	b12	Emigraciones	personas	IECA	420	\N
14042	Montilla	2017	Población	b13	Inmigraciones	personas	IECA	350	\N
14042	Montilla	2018	Población	b12	Emigraciones	personas	IECA	482	\N
14042	Montilla	2018	Población	b13	Inmigraciones	personas	IECA	403	\N
14042	Montilla	2019	Población	b12	Emigraciones	personas	IECA	556	\N
14042	Montilla	2019	Población	b13	Inmigraciones	personas	IECA	539	\N
14042	Montilla	2020	Población	b12	Emigraciones	personas	IECA	410	\N
14042	Montilla	2020	Población	b13	Inmigraciones	personas	IECA	397	\N
14042	Montilla	2021	Población	b12	Emigraciones	personas	IECA	500	\N
14042	Montilla	2021	Población	b13	Inmigraciones	personas	IECA	455	\N
14042	Montilla	2022	Población	b12	Emigraciones	personas	INE_EMCR	552	\N
14042	Montilla	2022	Población	b13	Inmigraciones	personas	INE_EMCR	535	\N
14042	Montilla	2023	Población	b12	Emigraciones	personas	INE_EMCR	568	\N
14042	Montilla	2023	Población	b13	Inmigraciones	personas	INE_EMCR	688	\N
14042	Montilla	2024	Población	b12	Emigraciones	personas	INE_EMCR	553	\N
14042	Montilla	2024	Población	b13	Inmigraciones	personas	INE_EMCR	545	\N
\.


--
-- Data for Name: montilla_indicadores_final_long; Type: TABLE DATA; Schema: public; Owner: montilla_user
--

COPY public.montilla_indicadores_final_long (cod_ine, municipio, anio, bloque, indicador_id, indicador_nombre, unidad, fuente, valor, valor_texto) FROM stdin;
14042	Montilla	2003	Población	b01	Población total	habitantes	INE_serie	23245	\N
14042	Montilla	2003	Población	b06	Porcentaje de población menor de 20 años	%	INE_serie	23.6007743600774	\N
14042	Montilla	2003	Población	b07	Porcentaje de población mayor de 65 años	%	INE_serie	17.7371477737148	\N
14042	Montilla	2003	Territorio	densidad	Densidad de población	hab/km2	Derivado	137.308760115778	\N
14042	Montilla	2004	Población	b01	Población total	habitantes	INE_serie	23223	\N
14042	Montilla	2004	Población	b06	Porcentaje de población menor de 20 años	%	INE_serie	23.3001765491108	\N
14042	Montilla	2004	Población	b07	Porcentaje de población mayor de 65 años	%	INE_serie	17.8831331008052	\N
14042	Montilla	2004	Territorio	densidad	Densidad de población	hab/km2	Derivado	137.178805599858	\N
14042	Montilla	2005	Población	b01	Población total	habitantes	INE_serie	23391	\N
14042	Montilla	2005	Población	b06	Porcentaje de población menor de 20 años	%	INE_serie	23.038775597452	\N
14042	Montilla	2005	Población	b07	Porcentaje de población mayor de 65 años	%	INE_serie	17.8786712838271	\N
14042	Montilla	2005	Territorio	densidad	Densidad de población	hab/km2	Derivado	138.171185539607	\N
14042	Montilla	2006	Población	b01	Población total	habitantes	INE_serie	23574	\N
14042	Montilla	2006	Población	b06	Porcentaje de población menor de 20 años	%	INE_serie	22.8684143547977	\N
14042	Montilla	2006	Población	b07	Porcentaje de población mayor de 65 años	%	INE_serie	18.0198523797404	\N
14042	Montilla	2006	Territorio	densidad	Densidad de población	hab/km2	Derivado	139.252170831118	\N
14042	Montilla	2007	Población	b01	Población total	habitantes	INE_serie	23650	\N
14042	Montilla	2007	Población	b06	Porcentaje de población menor de 20 años	%	INE_serie	22.676532769556	\N
14042	Montilla	2007	Población	b07	Porcentaje de población mayor de 65 años	%	INE_serie	17.9323467230444	\N
14042	Montilla	2007	Territorio	densidad	Densidad de población	hab/km2	Derivado	139.701104613385	\N
14042	Montilla	2008	Población	b01	Población total	habitantes	INE_serie	23811	\N
14042	Montilla	2008	Población	b06	Porcentaje de población menor de 20 años	%	INE_serie	22.5316030406115	\N
14042	Montilla	2008	Población	b07	Porcentaje de población mayor de 65 años	%	INE_serie	17.9076897232372	\N
14042	Montilla	2008	Territorio	densidad	Densidad de población	hab/km2	Derivado	140.652135388978	\N
14042	Montilla	2009	Población	b01	Población total	habitantes	INE_serie	23840	\N
14042	Montilla	2009	Población	b06	Porcentaje de población menor de 20 años	%	INE_serie	22.2944630872483	\N
14042	Montilla	2009	Población	b07	Porcentaje de población mayor de 65 años	%	INE_serie	18.1795302013423	\N
14042	Montilla	2009	Territorio	densidad	Densidad de población	hab/km2	Derivado	140.823439069053	\N
14042	Montilla	2010	Población	b01	Población total	habitantes	INE_serie	23907	\N
14042	Montilla	2010	Población	b06	Porcentaje de población menor de 20 años	%	INE_serie	22.1106788806626	\N
14042	Montilla	2010	Población	b07	Porcentaje de población mayor de 65 años	%	INE_serie	18.1787760906847	\N
14042	Montilla	2010	Territorio	densidad	Densidad de población	hab/km2	Derivado	141.219209640262	\N
14042	Montilla	2011	Población	b01	Población total	habitantes	INE_serie	23870	\N
14042	Montilla	2011	Población	b06	Porcentaje de población menor de 20 años	%	INE_serie	21.7343946376204	\N
14042	Montilla	2011	Población	b07	Porcentaje de población mayor de 65 años	%	INE_serie	18.3661499790532	\N
14042	Montilla	2011	Territorio	densidad	Densidad de población	hab/km2	Derivado	141.00064977258	\N
14042	Montilla	2012	Población	b01	Población total	habitantes	INE_serie	23836	\N
14042	Montilla	2012	Población	b06	Porcentaje de población menor de 20 años	%	INE_serie	21.3164960563853	\N
14042	Montilla	2012	Población	b07	Porcentaje de población mayor de 65 años	%	INE_serie	18.4636684007384	\N
14042	Montilla	2012	Territorio	densidad	Densidad de población	hab/km2	Derivado	140.79981097525	\N
14042	Montilla	2013	Población	b01	Población total	habitantes	INE_serie	23752	\N
14042	Montilla	2013	Población	b06	Porcentaje de población menor de 20 años	%	INE_serie	21.0971707645672	\N
14042	Montilla	2013	Población	b07	Porcentaje de población mayor de 65 años	%	INE_serie	18.6426406197373	\N
14042	Montilla	2013	Territorio	densidad	Densidad de población	hab/km2	Derivado	140.303621005375	\N
14042	Montilla	2014	Población	b01	Población total	habitantes	INE_serie	23622	\N
14042	Montilla	2014	Población	b06	Porcentaje de población menor de 20 años	%	INE_serie	20.5613411226822	\N
14042	Montilla	2014	Población	b07	Porcentaje de población mayor de 65 años	%	INE_serie	18.8045042756752	\N
14042	Montilla	2014	Territorio	densidad	Densidad de población	hab/km2	Derivado	139.535707956761	\N
14042	Montilla	2015	Población	b01	Población total	habitantes	INE_serie	23519	\N
14042	Montilla	2015	Población	b06	Porcentaje de población menor de 20 años	%	INE_serie	20.0688804796122	\N
14042	Montilla	2015	Población	b07	Porcentaje de población mayor de 65 años	%	INE_serie	18.9336281304477	\N
14042	Montilla	2015	Territorio	densidad	Densidad de población	hab/km2	Derivado	138.92728454132	\N
14042	Montilla	2016	Población	b01	Población total	habitantes	INE_serie	23365	\N
14042	Montilla	2016	Población	b06	Porcentaje de población menor de 20 años	%	INE_serie	19.8972822597903	\N
14042	Montilla	2016	Población	b07	Porcentaje de población mayor de 65 años	%	INE_serie	18.9385833511663	\N
14042	Montilla	2016	Territorio	densidad	Densidad de población	hab/km2	Derivado	138.017602929884	\N
14042	Montilla	2017	Población	b01	Población total	habitantes	INE_serie	23209	\N
14042	Montilla	2017	Población	b06	Porcentaje de población menor de 20 años	%	INE_serie	19.5613770520057	\N
14042	Montilla	2017	Población	b07	Porcentaje de población mayor de 65 años	%	INE_serie	19.3071653237968	\N
14042	Montilla	2017	Territorio	densidad	Densidad de población	hab/km2	Derivado	137.096107271546	\N
14042	Montilla	2018	Población	b01	Población total	habitantes	INE_serie	23031	\N
14042	Montilla	2018	Población	b06	Porcentaje de población menor de 20 años	%	INE_serie	19.0916590682124	\N
14042	Montilla	2018	Población	b07	Porcentaje de población mayor de 65 años	%	INE_serie	19.6778255394903	\N
14042	Montilla	2018	Territorio	densidad	Densidad de población	hab/km2	Derivado	136.044657097289	\N
14042	Montilla	2019	Población	b01	Población total	habitantes	INE_serie	22859	\N
14042	Montilla	2019	Población	b06	Porcentaje de población menor de 20 años	%	INE_serie	18.8984644997594	\N
14042	Montilla	2019	Población	b07	Porcentaje de población mayor de 65 años	%	INE_serie	20.0096242180323	\N
14042	Montilla	2019	Territorio	a01	Extensión superficial	km2	SIMA	169.29	\N
14042	Montilla	2019	Territorio	densidad	Densidad de población	hab/km2	Derivado	135.028649063737	\N
14042	Montilla	2020	Población	b01	Población total	habitantes	INE_serie	22739	\N
14042	Montilla	2020	Población	b06	Porcentaje de población menor de 20 años	%	INE_serie	18.6727648533357	\N
14042	Montilla	2020	Población	b07	Porcentaje de población mayor de 65 años	%	INE_serie	20.3570957385989	\N
14042	Montilla	2020	Territorio	densidad	Densidad de población	hab/km2	Derivado	134.319806249631	\N
14042	Montilla	2021	Población	b01	Población total	habitantes	INE_serie	22633	\N
14042	Montilla	2021	Población	b06	Porcentaje de población menor de 20 años	%	INE_serie	18.3714045862237	\N
14042	Montilla	2021	Población	b07	Porcentaje de población mayor de 65 años	%	INE_serie	20.6114964874299	\N
14042	Montilla	2021	Territorio	densidad	Densidad de población	hab/km2	Derivado	133.693661763837	\N
14042	Montilla	2022	Población	b01	Población total	habitantes	INE_serie	22490	\N
14042	Montilla	2022	Población	b06	Porcentaje de población menor de 20 años	%	INE_serie	17.843485993775	\N
14042	Montilla	2022	Población	b07	Porcentaje de población mayor de 65 años	%	INE_serie	20.9204090706981	\N
14042	Montilla	2022	Territorio	densidad	Densidad de población	hab/km2	Derivado	132.848957410361	\N
14042	Montilla	2023	Población	b01	Población total	habitantes	INE_serie	22300	\N
14042	Montilla	2023	Población	b06	Porcentaje de población menor de 20 años	%	INE_serie	17.5336322869955	\N
14042	Montilla	2023	Población	b07	Porcentaje de población mayor de 65 años	%	INE_serie	21.5470852017937	\N
14042	Montilla	2023	Territorio	densidad	Densidad de población	hab/km2	Derivado	131.726622954693	\N
14042	Montilla	2024	Población	b01	Población total	habitantes	INE_serie	22315	\N
14042	Montilla	2024	Población	b06	Porcentaje de población menor de 20 años	%	INE_serie	17.373963701546	\N
14042	Montilla	2024	Población	b07	Porcentaje de población mayor de 65 años	%	INE_serie	22.1017252968855	\N
14042	Montilla	2024	Población	b12	Emigraciones	emigraciones	SIMA	553	\N
14042	Montilla	2024	Población	b13	Inmigraciones	inmigraciones	SIMA	545	\N
14042	Montilla	2024	Población	b14	Nacimientos	nacimientos	SIMA	120	\N
14042	Montilla	2024	Población	b15	Defunciones	defunciones	SIMA	230	\N
14042	Montilla	2024	Población	b16	Matrimonios	matrimonios	SIMA	69	\N
14042	Montilla	2024	Territorio	densidad	Densidad de población	hab/km2	Derivado	131.815228306456	\N
14042	Montilla	2025	Población	b01	Población total	habitantes	INE_serie	22192	\N
14042	Montilla	2025	Población	b01	Población total	habitantes	SIMA	22192	\N
14042	Montilla	2025	Población	b02	Población. Hombres	habitantes	SIMA	10945	\N
14042	Montilla	2025	Población	b03	Población. Mujeres	habitantes	SIMA	11247	\N
14042	Montilla	2025	Población	b04	Población en núcleos	habitantes	SIMA	20793	\N
14042	Montilla	2025	Población	b05	Población en diseminados	habitantes	SIMA	1399	\N
14042	Montilla	2025	Población	b06	Porcentaje de población menor de 20 años	%	INE_serie	16.9565609228551	\N
14042	Montilla	2025	Población	b06	Porcentaje de población menor de 20 años	%	SIMA	17	\N
14042	Montilla	2025	Población	b07	Porcentaje de población mayor de 65 años	%	INE_serie	22.7784787310743	\N
14042	Montilla	2025	Población	b07	Porcentaje de población mayor de 65 años	%	SIMA	22.8	\N
14042	Montilla	2025	Población	b09	Número de extranjeros	personas	SIMA	953	\N
14042	Montilla	2025	Población	b10	Principal procedencia de los extranjeros residentes	texto	SIMA	\N	Rumanía
14042	Montilla	2025	Población	b11	Porcentaje que representa respecto total de extranjeros	%	SIMA	40	\N
14042	Montilla	2025	Población	b17	Edad media	años	SIMA	46	\N
14042	Montilla	2025	Territorio	densidad	Densidad de población	hab/km2	Derivado	131.088664421998	\N
14042	Montilla	2003	Población	b08	Variación relativa de la población en diez años	%	INE_serie	\N	NA: cálculo requiere t-10 (no disponible)
14042	Montilla	2004	Población	b08	Variación relativa de la población en diez años	%	INE_serie	\N	NA: cálculo requiere t-10 (no disponible)
14042	Montilla	2005	Población	b08	Variación relativa de la población en diez años	%	INE_serie	\N	NA: cálculo requiere t-10 (no disponible)
14042	Montilla	2006	Población	b08	Variación relativa de la población en diez años	%	INE_serie	2.72343021482417	\N
14042	Montilla	2007	Población	b08	Variación relativa de la población en diez años	%	INE_serie	3.40832076255437	\N
14042	Montilla	2008	Población	b08	Variación relativa de la población en diez años	%	INE_serie	4.47086697086696	\N
14042	Montilla	2009	Población	b08	Variación relativa de la población en diez años	%	INE_serie	4.05936272370144	\N
14042	Montilla	2010	Población	b08	Variación relativa de la población en diez años	%	INE_serie	4.06564227571498	\N
14042	Montilla	2011	Población	b08	Variación relativa de la población en diez años	%	INE_serie	3.32438749891784	\N
14042	Montilla	2012	Población	b08	Variación relativa de la población en diez años	%	INE_serie	2.58661502044331	\N
14042	Montilla	2013	Población	b08	Variación relativa de la población en diez años	%	INE_serie	2.18111421811142	\N
14042	Montilla	2014	Población	b08	Variación relativa de la población en diez años	%	INE_serie	1.7181242733497	\N
14042	Montilla	2015	Población	b08	Variación relativa de la población en diez años	%	INE_serie	0.547219015860811	\N
14042	Montilla	2016	Población	b08	Variación relativa de la población en diez años	%	INE_serie	-0.88656994994486	\N
14042	Montilla	2017	Población	b08	Variación relativa de la población en diez años	%	INE_serie	-1.86469344608879	\N
14042	Montilla	2018	Población	b08	Variación relativa de la población en diez años	%	INE_serie	-3.27579690059216	\N
14042	Montilla	2019	Población	b08	Variación relativa de la población en diez años	%	INE_serie	-4.11493288590604	\N
14042	Montilla	2020	Población	b08	Variación relativa de la población en diez años	%	INE_serie	-4.88559836031288	\N
14042	Montilla	2021	Población	b08	Variación relativa de la población en diez años	%	INE_serie	-5.18223711772099	\N
14042	Montilla	2022	Población	b08	Variación relativa de la población en diez años	%	INE_serie	-5.64692062426582	\N
14042	Montilla	2023	Población	b08	Variación relativa de la población en diez años	%	INE_serie	-6.11316941731222	\N
14042	Montilla	2024	Población	b08	Variación relativa de la población en diez años	%	INE_serie	-5.53297773262214	\N
14042	Montilla	2025	Población	b08	Variación relativa de la población en diez años	%	INE_serie	-5.64224669416217	\N
\.


--
-- Data for Name: nacimientos_montilla; Type: TABLE DATA; Schema: public; Owner: montilla_user
--

COPY public.nacimientos_montilla (anio, nacimientos) FROM stdin;
2006	241
2007	230
2008	231
2009	230
2010	222
2011	217
2012	220
2013	176
2014	179
2015	196
2016	170
2017	150
2018	164
2019	151
2020	158
2021	136
2022	149
2023	137
2024	120
\.


--
-- Data for Name: paro_registrado_montilla_sexo; Type: TABLE DATA; Schema: public; Owner: montilla_user
--

COPY public.paro_registrado_montilla_sexo (anio, sexo, paro_registrado) FROM stdin;
2009	Ambos sexos	2032.33333326
2009	Hombres	915.24999995
2009	Mujeres	1117.08333331
2010	Ambos sexos	2136.91666675
2010	Hombres	966.08333339
2010	Mujeres	1170.83333336
2011	Ambos sexos	2295.08333336
2011	Hombres	1006.83333333
2011	Mujeres	1288.25000003
2012	Ambos sexos	2608.41666668
2012	Hombres	1171.00000003
2012	Mujeres	1437.41666665
2013	Ambos sexos	2771.41666671
2013	Hombres	1230.66666669
2013	Mujeres	1540.75000002
2014	Ambos sexos	2695.66666671
2014	Hombres	1140.75000005
2014	Mujeres	1554.91666666
2015	Ambos sexos	2577.33333338
2015	Hombres	1061.33333334
2015	Mujeres	1516.00000004
2016	Ambos sexos	2351.58333334
2016	Hombres	927.33333333
2016	Mujeres	1424.25000001
2017	Ambos sexos	2127.83333332
2017	Hombres	793.5
2017	Mujeres	1334.33333332
2018	Ambos sexos	1949.50000001
2018	Hombres	708.33333334
2018	Mujeres	1241.16666667
2019	Ambos sexos	1861.16666665
2019	Hombres	654.24999998
2019	Mujeres	1206.91666667
2020	Ambos sexos	2118.16666663
2020	Hombres	806.5
2020	Mujeres	1311.66666663
2021	Ambos sexos	1885.41666662
2021	Hombres	656.33333327
2021	Mujeres	1229.08333335
2022	Ambos sexos	1710.08333335
2022	Hombres	568.91666665
2022	Mujeres	1141.1666667
2023	Ambos sexos	1585.41666665
2023	Hombres	504.3333333
2023	Mujeres	1081.08333335
2024	Ambos sexos	1465.58333335
2024	Hombres	462
2024	Mujeres	1003.58333335
2025	Ambos sexos	1340.74999997
2025	Hombres	433.58333334
2025	Mujeres	907.16666663
\.


--
-- Data for Name: poblacion_edad_sexo_ine_censo_2021_2025; Type: TABLE DATA; Schema: public; Owner: montilla_user
--

COPY public.poblacion_edad_sexo_ine_censo_2021_2025 (anio, sexo, grupo_edad, edad_min, poblacion, fuente) FROM stdin;
2021	Hombres	De 0 a 4 a�os	0	433	INE_Censo
2021	Hombres	De 5 a 9 a�os	5	521	INE_Censo
2021	Hombres	De 10 a 14 a�os	10	602	INE_Censo
2021	Hombres	De 15 a 19 a�os	15	627	INE_Censo
2021	Hombres	De 20 a 24 a�os	20	645	INE_Censo
2021	Hombres	De 25 a 29 a�os	25	667	INE_Censo
2021	Hombres	De 30 a 34 a�os	30	712	INE_Censo
2021	Hombres	De 35 a 39 a�os	35	672	INE_Censo
2021	Hombres	De 40 a 44 a�os	40	809	INE_Censo
2021	Hombres	De 45 a 49 a�os	45	863	INE_Censo
2021	Hombres	De 50 a 54 a�os	50	927	INE_Censo
2021	Hombres	De 55 a 59 a�os	55	876	INE_Censo
2021	Hombres	De 60 a 64 a�os	60	768	INE_Censo
2021	Hombres	De 65 a 69 a�os	65	600	INE_Censo
2021	Hombres	De 70 a 74 a�os	70	493	INE_Censo
2021	Hombres	De 75 a 79 a�os	75	403	INE_Censo
2021	Hombres	De 80 a 84 a�os	80	280	INE_Censo
2021	Hombres	De 85 a 89 a�os	85	202	INE_Censo
2021	Hombres	De 90 a 94 a�os	90	84	INE_Censo
2021	Hombres	De 95 a 99 a�os	95	12	INE_Censo
2021	Hombres	100 y m�s a�os	100	1	INE_Censo
2021	Mujeres	De 0 a 4 a�os	0	387	INE_Censo
2021	Mujeres	De 5 a 9 a�os	5	467	INE_Censo
2021	Mujeres	De 10 a 14 a�os	10	567	INE_Censo
2021	Mujeres	De 15 a 19 a�os	15	561	INE_Censo
2021	Mujeres	De 20 a 24 a�os	20	627	INE_Censo
2021	Mujeres	De 25 a 29 a�os	25	665	INE_Censo
2021	Mujeres	De 30 a 34 a�os	30	593	INE_Censo
2021	Mujeres	De 35 a 39 a�os	35	687	INE_Censo
2021	Mujeres	De 40 a 44 a�os	40	802	INE_Censo
2021	Mujeres	De 45 a 49 a�os	45	861	INE_Censo
2021	Mujeres	De 50 a 54 a�os	50	928	INE_Censo
2021	Mujeres	De 55 a 59 a�os	55	902	INE_Censo
2021	Mujeres	De 60 a 64 a�os	60	791	INE_Censo
2021	Mujeres	De 65 a 69 a�os	65	618	INE_Censo
2021	Mujeres	De 70 a 74 a�os	70	520	INE_Censo
2021	Mujeres	De 75 a 79 a�os	75	494	INE_Censo
2021	Mujeres	De 80 a 84 a�os	80	392	INE_Censo
2021	Mujeres	De 85 a 89 a�os	85	359	INE_Censo
2021	Mujeres	De 90 a 94 a�os	90	154	INE_Censo
2021	Mujeres	De 95 a 99 a�os	95	42	INE_Censo
2021	Mujeres	100 y m�s a�os	100	3	INE_Censo
2022	Hombres	De 0 a 4 a�os	0	409	INE_Censo
2022	Hombres	De 5 a 9 a�os	5	483	INE_Censo
2022	Hombres	De 10 a 14 a�os	10	576	INE_Censo
2022	Hombres	De 15 a 19 a�os	15	628	INE_Censo
2022	Hombres	De 20 a 24 a�os	20	649	INE_Censo
2022	Hombres	De 25 a 29 a�os	25	649	INE_Censo
2022	Hombres	De 30 a 34 a�os	30	720	INE_Censo
2022	Hombres	De 35 a 39 a�os	35	657	INE_Censo
2022	Hombres	De 40 a 44 a�os	40	792	INE_Censo
2022	Hombres	De 45 a 49 a�os	45	835	INE_Censo
2022	Hombres	De 50 a 54 a�os	50	895	INE_Censo
2022	Hombres	De 55 a 59 a�os	55	909	INE_Censo
2022	Hombres	De 60 a 64 a�os	60	809	INE_Censo
2022	Hombres	De 65 a 69 a�os	65	637	INE_Censo
2022	Hombres	De 70 a 74 a�os	70	493	INE_Censo
2022	Hombres	De 75 a 79 a�os	75	406	INE_Censo
2022	Hombres	De 80 a 84 a�os	80	276	INE_Censo
2022	Hombres	De 85 a 89 a�os	85	198	INE_Censo
2022	Hombres	De 90 a 94 a�os	90	84	INE_Censo
2022	Hombres	De 95 a 99 a�os	95	19	INE_Censo
2022	Hombres	100 y m�s a�os	100	2	INE_Censo
2022	Mujeres	De 0 a 4 a�os	0	358	INE_Censo
2022	Mujeres	De 5 a 9 a�os	5	441	INE_Censo
2022	Mujeres	De 10 a 14 a�os	10	556	INE_Censo
2022	Mujeres	De 15 a 19 a�os	15	557	INE_Censo
2022	Mujeres	De 20 a 24 a�os	20	628	INE_Censo
2022	Mujeres	De 25 a 29 a�os	25	633	INE_Censo
2022	Mujeres	De 30 a 34 a�os	30	591	INE_Censo
2022	Mujeres	De 35 a 39 a�os	35	671	INE_Censo
2022	Mujeres	De 40 a 44 a�os	40	758	INE_Censo
2022	Mujeres	De 45 a 49 a�os	45	874	INE_Censo
2022	Mujeres	De 50 a 54 a�os	50	905	INE_Censo
2022	Mujeres	De 55 a 59 a�os	55	895	INE_Censo
2022	Mujeres	De 60 a 64 a�os	60	858	INE_Censo
2022	Mujeres	De 65 a 69 a�os	65	637	INE_Censo
2022	Mujeres	De 70 a 74 a�os	70	526	INE_Censo
2022	Mujeres	De 75 a 79 a�os	75	502	INE_Censo
2022	Mujeres	De 80 a 84 a�os	80	388	INE_Censo
2022	Mujeres	De 85 a 89 a�os	85	337	INE_Censo
2022	Mujeres	De 90 a 94 a�os	90	157	INE_Censo
2022	Mujeres	De 95 a 99 a�os	95	36	INE_Censo
2022	Mujeres	100 y m�s a�os	100	5	INE_Censo
2023	Hombres	De 0 a 4 a�os	0	401	INE_Censo
2023	Hombres	De 5 a 9 a�os	5	449	INE_Censo
2023	Hombres	De 10 a 14 a�os	10	583	INE_Censo
2023	Hombres	De 15 a 19 a�os	15	607	INE_Censo
2023	Hombres	De 20 a 24 a�os	20	639	INE_Censo
2023	Hombres	De 25 a 29 a�os	25	648	INE_Censo
2023	Hombres	De 30 a 34 a�os	30	684	INE_Censo
2023	Hombres	De 35 a 39 a�os	35	651	INE_Censo
2023	Hombres	De 40 a 44 a�os	40	767	INE_Censo
2023	Hombres	De 45 a 49 a�os	45	812	INE_Censo
2023	Hombres	De 50 a 54 a�os	50	906	INE_Censo
2023	Hombres	De 55 a 59 a�os	55	911	INE_Censo
2023	Hombres	De 60 a 64 a�os	60	833	INE_Censo
2023	Hombres	De 65 a 69 a�os	65	657	INE_Censo
2023	Hombres	De 70 a 74 a�os	70	528	INE_Censo
2023	Hombres	De 75 a 79 a�os	75	403	INE_Censo
2023	Hombres	De 80 a 84 a�os	80	273	INE_Censo
2023	Hombres	De 85 a 89 a�os	85	182	INE_Censo
2023	Hombres	De 90 a 94 a�os	90	89	INE_Censo
2023	Hombres	De 95 a 99 a�os	95	18	INE_Censo
2023	Hombres	100 y m�s a�os	100	1	INE_Censo
2023	Mujeres	De 0 a 4 a�os	0	369	INE_Censo
2023	Mujeres	De 5 a 9 a�os	5	402	INE_Censo
2023	Mujeres	De 10 a 14 a�os	10	542	INE_Censo
2023	Mujeres	De 15 a 19 a�os	15	557	INE_Censo
2023	Mujeres	De 20 a 24 a�os	20	611	INE_Censo
2023	Mujeres	De 25 a 29 a�os	25	615	INE_Censo
2023	Mujeres	De 30 a 34 a�os	30	595	INE_Censo
2023	Mujeres	De 35 a 39 a�os	35	631	INE_Censo
2023	Mujeres	De 40 a 44 a�os	40	750	INE_Censo
2023	Mujeres	De 45 a 49 a�os	45	864	INE_Censo
2023	Mujeres	De 50 a 54 a�os	50	908	INE_Censo
2023	Mujeres	De 55 a 59 a�os	55	881	INE_Censo
2023	Mujeres	De 60 a 64 a�os	60	879	INE_Censo
2023	Mujeres	De 65 a 69 a�os	65	681	INE_Censo
2023	Mujeres	De 70 a 74 a�os	70	533	INE_Censo
2023	Mujeres	De 75 a 79 a�os	75	499	INE_Censo
2023	Mujeres	De 80 a 84 a�os	80	421	INE_Censo
2023	Mujeres	De 85 a 89 a�os	85	310	INE_Censo
2023	Mujeres	De 90 a 94 a�os	90	167	INE_Censo
2023	Mujeres	De 95 a 99 a�os	95	38	INE_Censo
2023	Mujeres	100 y m�s a�os	100	5	INE_Censo
2024	Hombres	De 0 a 4 a�os	0	381	INE_Censo
2024	Hombres	De 5 a 9 a�os	5	462	INE_Censo
2024	Hombres	De 10 a 14 a�os	10	556	INE_Censo
2024	Hombres	De 15 a 19 a�os	15	607	INE_Censo
2024	Hombres	De 20 a 24 a�os	20	633	INE_Censo
2024	Hombres	De 25 a 29 a�os	25	639	INE_Censo
2024	Hombres	De 30 a 34 a�os	30	667	INE_Censo
2024	Hombres	De 35 a 39 a�os	35	656	INE_Censo
2024	Hombres	De 40 a 44 a�os	40	732	INE_Censo
2024	Hombres	De 45 a 49 a�os	45	810	INE_Censo
2024	Hombres	De 50 a 54 a�os	50	897	INE_Censo
2024	Hombres	De 55 a 59 a�os	55	886	INE_Censo
2024	Hombres	De 60 a 64 a�os	60	856	INE_Censo
2024	Hombres	De 65 a 69 a�os	65	687	INE_Censo
2024	Hombres	De 70 a 74 a�os	70	542	INE_Censo
2024	Hombres	De 75 a 79 a�os	75	423	INE_Censo
2024	Hombres	De 80 a 84 a�os	80	294	INE_Censo
2024	Hombres	De 85 a 89 a�os	85	176	INE_Censo
2024	Hombres	De 90 a 94 a�os	90	79	INE_Censo
2024	Hombres	De 95 a 99 a�os	95	19	INE_Censo
2024	Hombres	100 y m�s a�os	100	0	INE_Censo
2024	Mujeres	De 0 a 4 a�os	0	380	INE_Censo
2024	Mujeres	De 5 a 9 a�os	5	416	INE_Censo
2024	Mujeres	De 10 a 14 a�os	10	512	INE_Censo
2024	Mujeres	De 15 a 19 a�os	15	563	INE_Censo
2024	Mujeres	De 20 a 24 a�os	20	604	INE_Censo
2024	Mujeres	De 25 a 29 a�os	25	603	INE_Censo
2024	Mujeres	De 30 a 34 a�os	30	644	INE_Censo
2024	Mujeres	De 35 a 39 a�os	35	610	INE_Censo
2024	Mujeres	De 40 a 44 a�os	40	690	INE_Censo
2024	Mujeres	De 45 a 49 a�os	45	880	INE_Censo
2024	Mujeres	De 50 a 54 a�os	50	896	INE_Censo
2024	Mujeres	De 55 a 59 a�os	55	888	INE_Censo
2024	Mujeres	De 60 a 64 a�os	60	915	INE_Censo
2024	Mujeres	De 65 a 69 a�os	65	706	INE_Censo
2024	Mujeres	De 70 a 74 a�os	70	552	INE_Censo
2024	Mujeres	De 75 a 79 a�os	75	498	INE_Censo
2024	Mujeres	De 80 a 84 a�os	80	431	INE_Censo
2024	Mujeres	De 85 a 89 a�os	85	312	INE_Censo
2024	Mujeres	De 90 a 94 a�os	90	168	INE_Censo
2024	Mujeres	De 95 a 99 a�os	95	39	INE_Censo
2024	Mujeres	100 y m�s a�os	100	6	INE_Censo
2025	Hombres	De 0 a 4 a�os	0	354	INE_Censo
2025	Hombres	De 5 a 9 a�os	5	467	INE_Censo
2025	Hombres	De 10 a 14 a�os	10	529	INE_Censo
2025	Hombres	De 15 a 19 a�os	15	604	INE_Censo
2025	Hombres	De 20 a 24 a�os	20	629	INE_Censo
2025	Hombres	De 25 a 29 a�os	25	620	INE_Censo
2025	Hombres	De 30 a 34 a�os	30	664	INE_Censo
2025	Hombres	De 35 a 39 a�os	35	663	INE_Censo
2025	Hombres	De 40 a 44 a�os	40	691	INE_Censo
2025	Hombres	De 45 a 49 a�os	45	818	INE_Censo
2025	Hombres	De 50 a 54 a�os	50	868	INE_Censo
2025	Hombres	De 55 a 59 a�os	55	908	INE_Censo
2025	Hombres	De 60 a 64 a�os	60	858	INE_Censo
2025	Hombres	De 65 a 69 a�os	65	718	INE_Censo
2025	Hombres	De 70 a 74 a�os	70	545	INE_Censo
2025	Hombres	De 75 a 79 a�os	75	434	INE_Censo
2025	Hombres	De 80 a 84 a�os	80	309	INE_Censo
2025	Hombres	De 85 a 89 a�os	85	167	INE_Censo
2025	Hombres	De 90 a 94 a�os	90	84	INE_Censo
2025	Hombres	De 95 a 99 a�os	95	14	INE_Censo
2025	Hombres	100 y m�s a�os	100	1	INE_Censo
2025	Mujeres	De 0 a 4 a�os	0	364	INE_Censo
2025	Mujeres	De 5 a 9 a�os	5	391	INE_Censo
2025	Mujeres	De 10 a 14 a�os	10	491	INE_Censo
2025	Mujeres	De 15 a 19 a�os	15	563	INE_Censo
2025	Mujeres	De 20 a 24 a�os	20	587	INE_Censo
2025	Mujeres	De 25 a 29 a�os	25	598	INE_Censo
2025	Mujeres	De 30 a 34 a�os	30	651	INE_Censo
2025	Mujeres	De 35 a 39 a�os	35	586	INE_Censo
2025	Mujeres	De 40 a 44 a�os	40	709	INE_Censo
2025	Mujeres	De 45 a 49 a�os	45	807	INE_Censo
2025	Mujeres	De 50 a 54 a�os	50	925	INE_Censo
2025	Mujeres	De 55 a 59 a�os	55	912	INE_Censo
2025	Mujeres	De 60 a 64 a�os	60	880	INE_Censo
2025	Mujeres	De 65 a 69 a�os	65	754	INE_Censo
2025	Mujeres	De 70 a 74 a�os	70	574	INE_Censo
2025	Mujeres	De 75 a 79 a�os	75	503	INE_Censo
2025	Mujeres	De 80 a 84 a�os	80	441	INE_Censo
2025	Mujeres	De 85 a 89 a�os	85	282	INE_Censo
2025	Mujeres	De 90 a 94 a�os	90	190	INE_Censo
2025	Mujeres	De 95 a 99 a�os	95	36	INE_Censo
2025	Mujeres	100 y m�s a�os	100	3	INE_Censo
\.


--
-- Data for Name: poblacion_edad_sexo_ine_comparativa; Type: TABLE DATA; Schema: public; Owner: montilla_user
--

COPY public.poblacion_edad_sexo_ine_comparativa (anio, sexo, grupo_edad, edad_min, poblacion, fuente) FROM stdin;
2003	Hombres	De 0 a 4 a�os	0	641	INE_Padron
2003	Hombres	De 5 a 9 a�os	5	707	INE_Padron
2003	Hombres	De 10 a 14 a�os	10	765	INE_Padron
2003	Hombres	De 15 a 19 a�os	15	735	INE_Padron
2003	Hombres	De 20 a 24 a�os	20	857	INE_Padron
2003	Hombres	De 25 a 29 a�os	25	888	INE_Padron
2003	Hombres	De 30 a 34 a�os	30	949	INE_Padron
2003	Hombres	De 35 a 39 a�os	35	942	INE_Padron
2003	Hombres	De 40 a 44 a�os	40	885	INE_Padron
2003	Hombres	De 45 a 49 a�os	45	738	INE_Padron
2003	Hombres	De 50 a 54 a�os	50	609	INE_Padron
2003	Hombres	De 55 a 59 a�os	55	558	INE_Padron
2003	Hombres	De 60 a 64 a�os	60	451	INE_Padron
2003	Hombres	De 65 a 69 a�os	65	567	INE_Padron
2003	Hombres	De 70 a 74 a�os	70	545	INE_Padron
2003	Hombres	De 75 a 79 a�os	75	370	INE_Padron
2003	Hombres	De 80 a 84 a�os	80	207	INE_Padron
2003	Hombres	De 85 a 89 a�os	85	65	INE_Padron
2003	Hombres	De 90 a 94 a�os	90	24	INE_Padron
2003	Hombres	De 95 a 99 a�os	95	3	INE_Padron
2003	Hombres	100 y m�s a�os	100	1	INE_Padron
2003	Mujeres	De 0 a 4 a�os	0	598	INE_Padron
2003	Mujeres	De 5 a 9 a�os	5	654	INE_Padron
2003	Mujeres	De 10 a 14 a�os	10	701	INE_Padron
2003	Mujeres	De 15 a 19 a�os	15	685	INE_Padron
2003	Mujeres	De 20 a 24 a�os	20	791	INE_Padron
2003	Mujeres	De 25 a 29 a�os	25	889	INE_Padron
2003	Mujeres	De 30 a 34 a�os	30	921	INE_Padron
2003	Mujeres	De 35 a 39 a�os	35	911	INE_Padron
2003	Mujeres	De 40 a 44 a�os	40	912	INE_Padron
2003	Mujeres	De 45 a 49 a�os	45	670	INE_Padron
2003	Mujeres	De 50 a 54 a�os	50	562	INE_Padron
2003	Mujeres	De 55 a 59 a�os	55	580	INE_Padron
2003	Mujeres	De 60 a 64 a�os	60	523	INE_Padron
2003	Mujeres	De 65 a 69 a�os	65	614	INE_Padron
2003	Mujeres	De 70 a 74 a�os	70	640	INE_Padron
2003	Mujeres	De 75 a 79 a�os	75	480	INE_Padron
2003	Mujeres	De 80 a 84 a�os	80	338	INE_Padron
2003	Mujeres	De 85 a 89 a�os	85	180	INE_Padron
2003	Mujeres	De 90 a 94 a�os	90	76	INE_Padron
2003	Mujeres	De 95 a 99 a�os	95	11	INE_Padron
2003	Mujeres	100 y m�s a�os	100	2	INE_Padron
2004	Hombres	De 0 a 4 a�os	0	616	INE_Padron
2004	Hombres	De 5 a 9 a�os	5	692	INE_Padron
2004	Hombres	De 10 a 14 a�os	10	768	INE_Padron
2004	Hombres	De 15 a 19 a�os	15	729	INE_Padron
2004	Hombres	De 20 a 24 a�os	20	829	INE_Padron
2004	Hombres	De 25 a 29 a�os	25	881	INE_Padron
2004	Hombres	De 30 a 34 a�os	30	921	INE_Padron
2004	Hombres	De 35 a 39 a�os	35	924	INE_Padron
2004	Hombres	De 40 a 44 a�os	40	905	INE_Padron
2004	Hombres	De 45 a 49 a�os	45	756	INE_Padron
2004	Hombres	De 50 a 54 a�os	50	619	INE_Padron
2004	Hombres	De 55 a 59 a�os	55	573	INE_Padron
2004	Hombres	De 60 a 64 a�os	60	485	INE_Padron
2004	Hombres	De 65 a 69 a�os	65	511	INE_Padron
2004	Hombres	De 70 a 74 a�os	70	534	INE_Padron
2004	Hombres	De 75 a 79 a�os	75	414	INE_Padron
2004	Hombres	De 80 a 84 a�os	80	223	INE_Padron
2004	Hombres	De 85 a 89 a�os	85	66	INE_Padron
2004	Hombres	De 90 a 94 a�os	90	22	INE_Padron
2004	Hombres	De 95 a 99 a�os	95	2	INE_Padron
2004	Hombres	100 y m�s a�os	100	1	INE_Padron
2004	Mujeres	De 0 a 4 a�os	0	580	INE_Padron
2004	Mujeres	De 5 a 9 a�os	5	603	INE_Padron
2004	Mujeres	De 10 a 14 a�os	10	731	INE_Padron
2004	Mujeres	De 15 a 19 a�os	15	692	INE_Padron
2004	Mujeres	De 20 a 24 a�os	20	749	INE_Padron
2004	Mujeres	De 25 a 29 a�os	25	901	INE_Padron
2004	Mujeres	De 30 a 34 a�os	30	891	INE_Padron
2004	Mujeres	De 35 a 39 a�os	35	902	INE_Padron
2004	Mujeres	De 40 a 44 a�os	40	944	INE_Padron
2004	Mujeres	De 45 a 49 a�os	45	697	INE_Padron
2004	Mujeres	De 50 a 54 a�os	50	580	INE_Padron
2004	Mujeres	De 55 a 59 a�os	55	563	INE_Padron
2004	Mujeres	De 60 a 64 a�os	60	539	INE_Padron
2004	Mujeres	De 65 a 69 a�os	65	584	INE_Padron
2004	Mujeres	De 70 a 74 a�os	70	637	INE_Padron
2004	Mujeres	De 75 a 79 a�os	75	490	INE_Padron
2004	Mujeres	De 80 a 84 a�os	80	374	INE_Padron
2004	Mujeres	De 85 a 89 a�os	85	192	INE_Padron
2004	Mujeres	De 90 a 94 a�os	90	92	INE_Padron
2004	Mujeres	De 95 a 99 a�os	95	10	INE_Padron
2004	Mujeres	100 y m�s a�os	100	1	INE_Padron
2005	Hombres	De 0 a 4 a�os	0	617	INE_Padron
2005	Hombres	De 5 a 9 a�os	5	666	INE_Padron
2005	Hombres	De 10 a 14 a�os	10	766	INE_Padron
2005	Hombres	De 15 a 19 a�os	15	749	INE_Padron
2005	Hombres	De 20 a 24 a�os	20	795	INE_Padron
2005	Hombres	De 25 a 29 a�os	25	889	INE_Padron
2005	Hombres	De 30 a 34 a�os	30	913	INE_Padron
2005	Hombres	De 35 a 39 a�os	35	949	INE_Padron
2005	Hombres	De 40 a 44 a�os	40	915	INE_Padron
2005	Hombres	De 45 a 49 a�os	45	802	INE_Padron
2005	Hombres	De 50 a 54 a�os	50	629	INE_Padron
2005	Hombres	De 55 a 59 a�os	55	583	INE_Padron
2005	Hombres	De 60 a 64 a�os	60	506	INE_Padron
2005	Hombres	De 65 a 69 a�os	65	473	INE_Padron
2005	Hombres	De 70 a 74 a�os	70	547	INE_Padron
2005	Hombres	De 75 a 79 a�os	75	423	INE_Padron
2005	Hombres	De 80 a 84 a�os	80	231	INE_Padron
2005	Hombres	De 85 a 89 a�os	85	82	INE_Padron
2005	Hombres	De 90 a 94 a�os	90	19	INE_Padron
2005	Hombres	De 95 a 99 a�os	95	4	INE_Padron
2005	Hombres	100 y m�s a�os	100	0	INE_Padron
2005	Mujeres	De 0 a 4 a�os	0	558	INE_Padron
2005	Mujeres	De 5 a 9 a�os	5	601	INE_Padron
2005	Mujeres	De 10 a 14 a�os	10	743	INE_Padron
2005	Mujeres	De 15 a 19 a�os	15	689	INE_Padron
2005	Mujeres	De 20 a 24 a�os	20	773	INE_Padron
2005	Mujeres	De 25 a 29 a�os	25	814	INE_Padron
2005	Mujeres	De 30 a 34 a�os	30	921	INE_Padron
2005	Mujeres	De 35 a 39 a�os	35	938	INE_Padron
2005	Mujeres	De 40 a 44 a�os	40	903	INE_Padron
2005	Mujeres	De 45 a 49 a�os	45	763	INE_Padron
2005	Mujeres	De 50 a 54 a�os	50	592	INE_Padron
2005	Mujeres	De 55 a 59 a�os	55	570	INE_Padron
2005	Mujeres	De 60 a 64 a�os	60	565	INE_Padron
2005	Mujeres	De 65 a 69 a�os	65	546	INE_Padron
2005	Mujeres	De 70 a 74 a�os	70	655	INE_Padron
2005	Mujeres	De 75 a 79 a�os	75	475	INE_Padron
2005	Mujeres	De 80 a 84 a�os	80	421	INE_Padron
2005	Mujeres	De 85 a 89 a�os	85	200	INE_Padron
2005	Mujeres	De 90 a 94 a�os	90	82	INE_Padron
2005	Mujeres	De 95 a 99 a�os	95	24	INE_Padron
2005	Mujeres	100 y m�s a�os	100	0	INE_Padron
2006	Hombres	De 0 a 4 a�os	0	616	INE_Padron
2006	Hombres	De 5 a 9 a�os	5	662	INE_Padron
2006	Hombres	De 10 a 14 a�os	10	742	INE_Padron
2006	Hombres	De 15 a 19 a�os	15	782	INE_Padron
2006	Hombres	De 20 a 24 a�os	20	771	INE_Padron
2006	Hombres	De 25 a 29 a�os	25	896	INE_Padron
2006	Hombres	De 30 a 34 a�os	30	906	INE_Padron
2006	Hombres	De 35 a 39 a�os	35	966	INE_Padron
2006	Hombres	De 40 a 44 a�os	40	931	INE_Padron
2006	Hombres	De 45 a 49 a�os	45	834	INE_Padron
2006	Hombres	De 50 a 54 a�os	50	663	INE_Padron
2006	Hombres	De 55 a 59 a�os	55	562	INE_Padron
2006	Hombres	De 60 a 64 a�os	60	520	INE_Padron
2006	Hombres	De 65 a 69 a�os	65	469	INE_Padron
2006	Hombres	De 70 a 74 a�os	70	545	INE_Padron
2006	Hombres	De 75 a 79 a�os	75	439	INE_Padron
2006	Hombres	De 80 a 84 a�os	80	247	INE_Padron
2006	Hombres	De 85 a 89 a�os	85	93	INE_Padron
2006	Hombres	De 90 a 94 a�os	90	26	INE_Padron
2006	Hombres	De 95 a 99 a�os	95	5	INE_Padron
2006	Hombres	100 y m�s a�os	100	0	INE_Padron
2006	Mujeres	De 0 a 4 a�os	0	563	INE_Padron
2006	Mujeres	De 5 a 9 a�os	5	608	INE_Padron
2006	Mujeres	De 10 a 14 a�os	10	710	INE_Padron
2006	Mujeres	De 15 a 19 a�os	15	708	INE_Padron
2006	Mujeres	De 20 a 24 a�os	20	765	INE_Padron
2006	Mujeres	De 25 a 29 a�os	25	802	INE_Padron
2006	Mujeres	De 30 a 34 a�os	30	899	INE_Padron
2006	Mujeres	De 35 a 39 a�os	35	944	INE_Padron
2006	Mujeres	De 40 a 44 a�os	40	929	INE_Padron
2006	Mujeres	De 45 a 49 a�os	45	807	INE_Padron
2006	Mujeres	De 50 a 54 a�os	50	622	INE_Padron
2006	Mujeres	De 55 a 59 a�os	55	559	INE_Padron
2006	Mujeres	De 60 a 64 a�os	60	559	INE_Padron
2006	Mujeres	De 65 a 69 a�os	65	535	INE_Padron
2006	Mujeres	De 70 a 74 a�os	70	621	INE_Padron
2006	Mujeres	De 75 a 79 a�os	75	534	INE_Padron
2006	Mujeres	De 80 a 84 a�os	80	435	INE_Padron
2006	Mujeres	De 85 a 89 a�os	85	187	INE_Padron
2006	Mujeres	De 90 a 94 a�os	90	90	INE_Padron
2006	Mujeres	De 95 a 99 a�os	95	21	INE_Padron
2006	Mujeres	100 y m�s a�os	100	1	INE_Padron
2007	Hombres	De 0 a 4 a�os	0	604	INE_Padron
2007	Hombres	De 5 a 9 a�os	5	672	INE_Padron
2007	Hombres	De 10 a 14 a�os	10	725	INE_Padron
2007	Hombres	De 15 a 19 a�os	15	797	INE_Padron
2007	Hombres	De 20 a 24 a�os	20	754	INE_Padron
2007	Hombres	De 25 a 29 a�os	25	895	INE_Padron
2007	Hombres	De 30 a 34 a�os	30	879	INE_Padron
2007	Hombres	De 35 a 39 a�os	35	928	INE_Padron
2007	Hombres	De 40 a 44 a�os	40	956	INE_Padron
2007	Hombres	De 45 a 49 a�os	45	883	INE_Padron
2007	Hombres	De 50 a 54 a�os	50	699	INE_Padron
2007	Hombres	De 55 a 59 a�os	55	570	INE_Padron
2007	Hombres	De 60 a 64 a�os	60	531	INE_Padron
2007	Hombres	De 65 a 69 a�os	65	454	INE_Padron
2007	Hombres	De 70 a 74 a�os	70	525	INE_Padron
2007	Hombres	De 75 a 79 a�os	75	451	INE_Padron
2007	Hombres	De 80 a 84 a�os	80	253	INE_Padron
2007	Hombres	De 85 a 89 a�os	85	114	INE_Padron
2007	Hombres	De 90 a 94 a�os	90	27	INE_Padron
2007	Hombres	De 95 a 99 a�os	95	7	INE_Padron
2007	Hombres	100 y m�s a�os	100	1	INE_Padron
2007	Mujeres	De 0 a 4 a�os	0	555	INE_Padron
2007	Mujeres	De 5 a 9 a�os	5	614	INE_Padron
2007	Mujeres	De 10 a 14 a�os	10	676	INE_Padron
2007	Mujeres	De 15 a 19 a�os	15	720	INE_Padron
2007	Mujeres	De 20 a 24 a�os	20	776	INE_Padron
2007	Mujeres	De 25 a 29 a�os	25	773	INE_Padron
2007	Mujeres	De 30 a 34 a�os	30	887	INE_Padron
2007	Mujeres	De 35 a 39 a�os	35	925	INE_Padron
2007	Mujeres	De 40 a 44 a�os	40	929	INE_Padron
2007	Mujeres	De 45 a 49 a�os	45	878	INE_Padron
2007	Mujeres	De 50 a 54 a�os	50	631	INE_Padron
2007	Mujeres	De 55 a 59 a�os	55	572	INE_Padron
2007	Mujeres	De 60 a 64 a�os	60	580	INE_Padron
2007	Mujeres	De 65 a 69 a�os	65	501	INE_Padron
2007	Mujeres	De 70 a 74 a�os	70	618	INE_Padron
2007	Mujeres	De 75 a 79 a�os	75	553	INE_Padron
2007	Mujeres	De 80 a 84 a�os	80	429	INE_Padron
2007	Mujeres	De 85 a 89 a�os	85	204	INE_Padron
2007	Mujeres	De 90 a 94 a�os	90	82	INE_Padron
2007	Mujeres	De 95 a 99 a�os	95	20	INE_Padron
2007	Mujeres	100 y m�s a�os	100	2	INE_Padron
2008	Hombres	De 0 a 4 a�os	0	604	INE_Padron
2008	Hombres	De 5 a 9 a�os	5	664	INE_Padron
2008	Hombres	De 10 a 14 a�os	10	729	INE_Padron
2008	Hombres	De 15 a 19 a�os	15	791	INE_Padron
2008	Hombres	De 20 a 24 a�os	20	778	INE_Padron
2008	Hombres	De 25 a 29 a�os	25	875	INE_Padron
2008	Hombres	De 30 a 34 a�os	30	867	INE_Padron
2008	Hombres	De 35 a 39 a�os	35	940	INE_Padron
2008	Hombres	De 40 a 44 a�os	40	963	INE_Padron
2008	Hombres	De 45 a 49 a�os	45	897	INE_Padron
2008	Hombres	De 50 a 54 a�os	50	739	INE_Padron
2008	Hombres	De 55 a 59 a�os	55	598	INE_Padron
2008	Hombres	De 60 a 64 a�os	60	543	INE_Padron
2008	Hombres	De 65 a 69 a�os	65	440	INE_Padron
2008	Hombres	De 70 a 74 a�os	70	513	INE_Padron
2008	Hombres	De 75 a 79 a�os	75	444	INE_Padron
2008	Hombres	De 80 a 84 a�os	80	283	INE_Padron
2008	Hombres	De 85 a 89 a�os	85	121	INE_Padron
2008	Hombres	De 90 a 94 a�os	90	24	INE_Padron
2008	Hombres	De 95 a 99 a�os	95	7	INE_Padron
2008	Hombres	100 y m�s a�os	100	2	INE_Padron
2008	Mujeres	De 0 a 4 a�os	0	555	INE_Padron
2008	Mujeres	De 5 a 9 a�os	5	613	INE_Padron
2008	Mujeres	De 10 a 14 a�os	10	674	INE_Padron
2008	Mujeres	De 15 a 19 a�os	15	735	INE_Padron
2008	Mujeres	De 20 a 24 a�os	20	726	INE_Padron
2008	Mujeres	De 25 a 29 a�os	25	806	INE_Padron
2008	Mujeres	De 30 a 34 a�os	30	872	INE_Padron
2008	Mujeres	De 35 a 39 a�os	35	932	INE_Padron
2008	Mujeres	De 40 a 44 a�os	40	919	INE_Padron
2008	Mujeres	De 45 a 49 a�os	45	911	INE_Padron
2008	Mujeres	De 50 a 54 a�os	50	673	INE_Padron
2008	Mujeres	De 55 a 59 a�os	55	560	INE_Padron
2008	Mujeres	De 60 a 64 a�os	60	583	INE_Padron
2008	Mujeres	De 65 a 69 a�os	65	518	INE_Padron
2008	Mujeres	De 70 a 74 a�os	70	584	INE_Padron
2008	Mujeres	De 75 a 79 a�os	75	576	INE_Padron
2008	Mujeres	De 80 a 84 a�os	80	412	INE_Padron
2008	Mujeres	De 85 a 89 a�os	85	240	INE_Padron
2008	Mujeres	De 90 a 94 a�os	90	77	INE_Padron
2008	Mujeres	De 95 a 99 a�os	95	21	INE_Padron
2008	Mujeres	100 y m�s a�os	100	2	INE_Padron
2009	Hombres	De 0 a 4 a�os	0	619	INE_Padron
2009	Hombres	De 5 a 9 a�os	5	643	INE_Padron
2009	Hombres	De 10 a 14 a�os	10	709	INE_Padron
2009	Hombres	De 15 a 19 a�os	15	787	INE_Padron
2009	Hombres	De 20 a 24 a�os	20	775	INE_Padron
2009	Hombres	De 25 a 29 a�os	25	842	INE_Padron
2009	Hombres	De 30 a 34 a�os	30	858	INE_Padron
2009	Hombres	De 35 a 39 a�os	35	934	INE_Padron
2009	Hombres	De 40 a 44 a�os	40	947	INE_Padron
2009	Hombres	De 45 a 49 a�os	45	910	INE_Padron
2009	Hombres	De 50 a 54 a�os	50	763	INE_Padron
2009	Hombres	De 55 a 59 a�os	55	613	INE_Padron
2009	Hombres	De 60 a 64 a�os	60	560	INE_Padron
2009	Hombres	De 65 a 69 a�os	65	468	INE_Padron
2009	Hombres	De 70 a 74 a�os	70	467	INE_Padron
2009	Hombres	De 75 a 79 a�os	75	446	INE_Padron
2009	Hombres	De 80 a 84 a�os	80	320	INE_Padron
2009	Hombres	De 85 a 89 a�os	85	126	INE_Padron
2009	Hombres	De 90 a 94 a�os	90	25	INE_Padron
2009	Hombres	De 95 a 99 a�os	95	8	INE_Padron
2009	Hombres	100 y m�s a�os	100	2	INE_Padron
2009	Mujeres	De 0 a 4 a�os	0	552	INE_Padron
2009	Mujeres	De 5 a 9 a�os	5	610	INE_Padron
2009	Mujeres	De 10 a 14 a�os	10	630	INE_Padron
2009	Mujeres	De 15 a 19 a�os	15	765	INE_Padron
2009	Mujeres	De 20 a 24 a�os	20	731	INE_Padron
2009	Mujeres	De 25 a 29 a�os	25	753	INE_Padron
2009	Mujeres	De 30 a 34 a�os	30	873	INE_Padron
2009	Mujeres	De 35 a 39 a�os	35	917	INE_Padron
2009	Mujeres	De 40 a 44 a�os	40	913	INE_Padron
2009	Mujeres	De 45 a 49 a�os	45	949	INE_Padron
2009	Mujeres	De 50 a 54 a�os	50	712	INE_Padron
2009	Mujeres	De 55 a 59 a�os	55	583	INE_Padron
2009	Mujeres	De 60 a 64 a�os	60	558	INE_Padron
2009	Mujeres	De 65 a 69 a�os	65	534	INE_Padron
2009	Mujeres	De 70 a 74 a�os	70	562	INE_Padron
2009	Mujeres	De 75 a 79 a�os	75	583	INE_Padron
2009	Mujeres	De 80 a 84 a�os	80	420	INE_Padron
2009	Mujeres	De 85 a 89 a�os	85	274	INE_Padron
2009	Mujeres	De 90 a 94 a�os	90	80	INE_Padron
2009	Mujeres	De 95 a 99 a�os	95	18	INE_Padron
2009	Mujeres	100 y m�s a�os	100	1	INE_Padron
2010	Hombres	De 0 a 4 a�os	0	617	INE_Padron
2010	Hombres	De 5 a 9 a�os	5	657	INE_Padron
2010	Hombres	De 10 a 14 a�os	10	685	INE_Padron
2010	Hombres	De 15 a 19 a�os	15	783	INE_Padron
2010	Hombres	De 20 a 24 a�os	20	771	INE_Padron
2010	Hombres	De 25 a 29 a�os	25	794	INE_Padron
2010	Hombres	De 30 a 34 a�os	30	886	INE_Padron
2010	Hombres	De 35 a 39 a�os	35	900	INE_Padron
2010	Hombres	De 40 a 44 a�os	40	975	INE_Padron
2010	Hombres	De 45 a 49 a�os	45	924	INE_Padron
2010	Hombres	De 50 a 54 a�os	50	802	INE_Padron
2010	Hombres	De 55 a 59 a�os	55	628	INE_Padron
2010	Hombres	De 60 a 64 a�os	60	570	INE_Padron
2010	Hombres	De 65 a 69 a�os	65	479	INE_Padron
2010	Hombres	De 70 a 74 a�os	70	437	INE_Padron
2010	Hombres	De 75 a 79 a�os	75	450	INE_Padron
2010	Hombres	De 80 a 84 a�os	80	317	INE_Padron
2010	Hombres	De 85 a 89 a�os	85	129	INE_Padron
2010	Hombres	De 90 a 94 a�os	90	36	INE_Padron
2010	Hombres	De 95 a 99 a�os	95	7	INE_Padron
2010	Hombres	100 y m�s a�os	100	1	INE_Padron
2010	Mujeres	De 0 a 4 a�os	0	558	INE_Padron
2010	Mujeres	De 5 a 9 a�os	5	598	INE_Padron
2010	Mujeres	De 10 a 14 a�os	10	616	INE_Padron
2010	Mujeres	De 15 a 19 a�os	15	772	INE_Padron
2010	Mujeres	De 20 a 24 a�os	20	718	INE_Padron
2010	Mujeres	De 25 a 29 a�os	25	759	INE_Padron
2010	Mujeres	De 30 a 34 a�os	30	811	INE_Padron
2010	Mujeres	De 35 a 39 a�os	35	941	INE_Padron
2010	Mujeres	De 40 a 44 a�os	40	949	INE_Padron
2010	Mujeres	De 45 a 49 a�os	45	918	INE_Padron
2010	Mujeres	De 50 a 54 a�os	50	771	INE_Padron
2010	Mujeres	De 55 a 59 a�os	55	593	INE_Padron
2010	Mujeres	De 60 a 64 a�os	60	565	INE_Padron
2010	Mujeres	De 65 a 69 a�os	65	562	INE_Padron
2010	Mujeres	De 70 a 74 a�os	70	515	INE_Padron
2010	Mujeres	De 75 a 79 a�os	75	602	INE_Padron
2010	Mujeres	De 80 a 84 a�os	80	412	INE_Padron
2010	Mujeres	De 85 a 89 a�os	85	296	INE_Padron
2010	Mujeres	De 90 a 94 a�os	90	86	INE_Padron
2010	Mujeres	De 95 a 99 a�os	95	16	INE_Padron
2010	Mujeres	100 y m�s a�os	100	1	INE_Padron
2011	Hombres	De 0 a 4 a�os	0	603	INE_Padron
2011	Hombres	De 5 a 9 a�os	5	653	INE_Padron
2011	Hombres	De 10 a 14 a�os	10	668	INE_Padron
2011	Hombres	De 15 a 19 a�os	15	760	INE_Padron
2011	Hombres	De 20 a 24 a�os	20	798	INE_Padron
2011	Hombres	De 25 a 29 a�os	25	746	INE_Padron
2011	Hombres	De 30 a 34 a�os	30	861	INE_Padron
2011	Hombres	De 35 a 39 a�os	35	909	INE_Padron
2011	Hombres	De 40 a 44 a�os	40	963	INE_Padron
2011	Hombres	De 45 a 49 a�os	45	942	INE_Padron
2011	Hombres	De 50 a 54 a�os	50	822	INE_Padron
2011	Hombres	De 55 a 59 a�os	55	651	INE_Padron
2011	Hombres	De 60 a 64 a�os	60	551	INE_Padron
2011	Hombres	De 65 a 69 a�os	65	491	INE_Padron
2011	Hombres	De 70 a 74 a�os	70	420	INE_Padron
2011	Hombres	De 75 a 79 a�os	75	460	INE_Padron
2011	Hombres	De 80 a 84 a�os	80	333	INE_Padron
2011	Hombres	De 85 a 89 a�os	85	142	INE_Padron
2011	Hombres	De 90 a 94 a�os	90	35	INE_Padron
2011	Hombres	De 95 a 99 a�os	95	8	INE_Padron
2011	Hombres	100 y m�s a�os	100	0	INE_Padron
2011	Mujeres	De 0 a 4 a�os	0	567	INE_Padron
2011	Mujeres	De 5 a 9 a�os	5	581	INE_Padron
2011	Mujeres	De 10 a 14 a�os	10	630	INE_Padron
2011	Mujeres	De 15 a 19 a�os	15	726	INE_Padron
2011	Mujeres	De 20 a 24 a�os	20	731	INE_Padron
2011	Mujeres	De 25 a 29 a�os	25	748	INE_Padron
2011	Mujeres	De 30 a 34 a�os	30	789	INE_Padron
2011	Mujeres	De 35 a 39 a�os	35	907	INE_Padron
2011	Mujeres	De 40 a 44 a�os	40	953	INE_Padron
2011	Mujeres	De 45 a 49 a�os	45	934	INE_Padron
2011	Mujeres	De 50 a 54 a�os	50	812	INE_Padron
2011	Mujeres	De 55 a 59 a�os	55	634	INE_Padron
2011	Mujeres	De 60 a 64 a�os	60	547	INE_Padron
2011	Mujeres	De 65 a 69 a�os	65	552	INE_Padron
2011	Mujeres	De 70 a 74 a�os	70	503	INE_Padron
2011	Mujeres	De 75 a 79 a�os	75	575	INE_Padron
2011	Mujeres	De 80 a 84 a�os	80	442	INE_Padron
2011	Mujeres	De 85 a 89 a�os	85	316	INE_Padron
2011	Mujeres	De 90 a 94 a�os	90	87	INE_Padron
2011	Mujeres	De 95 a 99 a�os	95	19	INE_Padron
2011	Mujeres	100 y m�s a�os	100	1	INE_Padron
2012	Hombres	De 0 a 4 a�os	0	581	INE_Padron
2012	Hombres	De 5 a 9 a�os	5	650	INE_Padron
2012	Hombres	De 10 a 14 a�os	10	669	INE_Padron
2012	Hombres	De 15 a 19 a�os	15	722	INE_Padron
2012	Hombres	De 20 a 24 a�os	20	814	INE_Padron
2012	Hombres	De 25 a 29 a�os	25	735	INE_Padron
2012	Hombres	De 30 a 34 a�os	30	862	INE_Padron
2012	Hombres	De 35 a 39 a�os	35	871	INE_Padron
2012	Hombres	De 40 a 44 a�os	40	933	INE_Padron
2012	Hombres	De 45 a 49 a�os	45	959	INE_Padron
2012	Hombres	De 50 a 54 a�os	50	859	INE_Padron
2012	Hombres	De 55 a 59 a�os	55	684	INE_Padron
2012	Hombres	De 60 a 64 a�os	60	557	INE_Padron
2012	Hombres	De 65 a 69 a�os	65	510	INE_Padron
2012	Hombres	De 70 a 74 a�os	70	404	INE_Padron
2012	Hombres	De 75 a 79 a�os	75	435	INE_Padron
2012	Hombres	De 80 a 84 a�os	80	340	INE_Padron
2012	Hombres	De 85 a 89 a�os	85	145	INE_Padron
2012	Hombres	De 90 a 94 a�os	90	51	INE_Padron
2012	Hombres	De 95 a 99 a�os	95	6	INE_Padron
2012	Hombres	100 y m�s a�os	100	1	INE_Padron
2012	Mujeres	De 0 a 4 a�os	0	564	INE_Padron
2012	Mujeres	De 5 a 9 a�os	5	569	INE_Padron
2012	Mujeres	De 10 a 14 a�os	10	639	INE_Padron
2012	Mujeres	De 15 a 19 a�os	15	687	INE_Padron
2012	Mujeres	De 20 a 24 a�os	20	734	INE_Padron
2012	Mujeres	De 25 a 29 a�os	25	759	INE_Padron
2012	Mujeres	De 30 a 34 a�os	30	754	INE_Padron
2012	Mujeres	De 35 a 39 a�os	35	903	INE_Padron
2012	Mujeres	De 40 a 44 a�os	40	928	INE_Padron
2012	Mujeres	De 45 a 49 a�os	45	927	INE_Padron
2012	Mujeres	De 50 a 54 a�os	50	880	INE_Padron
2012	Mujeres	De 55 a 59 a�os	55	634	INE_Padron
2012	Mujeres	De 60 a 64 a�os	60	561	INE_Padron
2012	Mujeres	De 65 a 69 a�os	65	564	INE_Padron
2012	Mujeres	De 70 a 74 a�os	70	482	INE_Padron
2012	Mujeres	De 75 a 79 a�os	75	568	INE_Padron
2012	Mujeres	De 80 a 84 a�os	80	454	INE_Padron
2012	Mujeres	De 85 a 89 a�os	85	314	INE_Padron
2012	Mujeres	De 90 a 94 a�os	90	108	INE_Padron
2012	Mujeres	De 95 a 99 a�os	95	15	INE_Padron
2012	Mujeres	100 y m�s a�os	100	4	INE_Padron
2013	Hombres	De 0 a 4 a�os	0	573	INE_Padron
2013	Hombres	De 5 a 9 a�os	5	628	INE_Padron
2013	Hombres	De 10 a 14 a�os	10	657	INE_Padron
2013	Hombres	De 15 a 19 a�os	15	724	INE_Padron
2013	Hombres	De 20 a 24 a�os	20	782	INE_Padron
2013	Hombres	De 25 a 29 a�os	25	743	INE_Padron
2013	Hombres	De 30 a 34 a�os	30	825	INE_Padron
2013	Hombres	De 35 a 39 a�os	35	841	INE_Padron
2013	Hombres	De 40 a 44 a�os	40	940	INE_Padron
2013	Hombres	De 45 a 49 a�os	45	955	INE_Padron
2013	Hombres	De 50 a 54 a�os	50	867	INE_Padron
2013	Hombres	De 55 a 59 a�os	55	715	INE_Padron
2013	Hombres	De 60 a 64 a�os	60	591	INE_Padron
2013	Hombres	De 65 a 69 a�os	65	523	INE_Padron
2013	Hombres	De 70 a 74 a�os	70	398	INE_Padron
2013	Hombres	De 75 a 79 a�os	75	435	INE_Padron
2013	Hombres	De 80 a 84 a�os	80	339	INE_Padron
2013	Hombres	De 85 a 89 a�os	85	159	INE_Padron
2013	Hombres	De 90 a 94 a�os	90	49	INE_Padron
2013	Hombres	De 95 a 99 a�os	95	7	INE_Padron
2013	Hombres	100 y m�s a�os	100	2	INE_Padron
2013	Mujeres	De 0 a 4 a�os	0	555	INE_Padron
2013	Mujeres	De 5 a 9 a�os	5	566	INE_Padron
2013	Mujeres	De 10 a 14 a�os	10	635	INE_Padron
2013	Mujeres	De 15 a 19 a�os	15	673	INE_Padron
2013	Mujeres	De 20 a 24 a�os	20	734	INE_Padron
2013	Mujeres	De 25 a 29 a�os	25	701	INE_Padron
2013	Mujeres	De 30 a 34 a�os	30	761	INE_Padron
2013	Mujeres	De 35 a 39 a�os	35	878	INE_Padron
2013	Mujeres	De 40 a 44 a�os	40	935	INE_Padron
2013	Mujeres	De 45 a 49 a�os	45	904	INE_Padron
2013	Mujeres	De 50 a 54 a�os	50	914	INE_Padron
2013	Mujeres	De 55 a 59 a�os	55	675	INE_Padron
2013	Mujeres	De 60 a 64 a�os	60	552	INE_Padron
2013	Mujeres	De 65 a 69 a�os	65	563	INE_Padron
2013	Mujeres	De 70 a 74 a�os	70	506	INE_Padron
2013	Mujeres	De 75 a 79 a�os	75	535	INE_Padron
2013	Mujeres	De 80 a 84 a�os	80	479	INE_Padron
2013	Mujeres	De 85 a 89 a�os	85	285	INE_Padron
2013	Mujeres	De 90 a 94 a�os	90	129	INE_Padron
2013	Mujeres	De 95 a 99 a�os	95	15	INE_Padron
2013	Mujeres	100 y m�s a�os	100	4	INE_Padron
2014	Hombres	De 0 a 4 a�os	0	542	INE_Padron
2014	Hombres	De 5 a 9 a�os	5	622	INE_Padron
2014	Hombres	De 10 a 14 a�os	10	645	INE_Padron
2014	Hombres	De 15 a 19 a�os	15	711	INE_Padron
2014	Hombres	De 20 a 24 a�os	20	776	INE_Padron
2014	Hombres	De 25 a 29 a�os	25	737	INE_Padron
2014	Hombres	De 30 a 34 a�os	30	784	INE_Padron
2014	Hombres	De 35 a 39 a�os	35	841	INE_Padron
2014	Hombres	De 40 a 44 a�os	40	920	INE_Padron
2014	Hombres	De 45 a 49 a�os	45	944	INE_Padron
2014	Hombres	De 50 a 54 a�os	50	885	INE_Padron
2014	Hombres	De 55 a 59 a�os	55	740	INE_Padron
2014	Hombres	De 60 a 64 a�os	60	595	INE_Padron
2014	Hombres	De 65 a 69 a�os	65	530	INE_Padron
2014	Hombres	De 70 a 74 a�os	70	434	INE_Padron
2014	Hombres	De 75 a 79 a�os	75	388	INE_Padron
2014	Hombres	De 80 a 84 a�os	80	335	INE_Padron
2014	Hombres	De 85 a 89 a�os	85	183	INE_Padron
2014	Hombres	De 90 a 94 a�os	90	46	INE_Padron
2014	Hombres	De 95 a 99 a�os	95	9	INE_Padron
2014	Hombres	100 y m�s a�os	100	2	INE_Padron
2014	Mujeres	De 0 a 4 a�os	0	524	INE_Padron
2014	Mujeres	De 5 a 9 a�os	5	571	INE_Padron
2014	Mujeres	De 10 a 14 a�os	10	619	INE_Padron
2014	Mujeres	De 15 a 19 a�os	15	623	INE_Padron
2014	Mujeres	De 20 a 24 a�os	20	762	INE_Padron
2014	Mujeres	De 25 a 29 a�os	25	704	INE_Padron
2014	Mujeres	De 30 a 34 a�os	30	712	INE_Padron
2014	Mujeres	De 35 a 39 a�os	35	879	INE_Padron
2014	Mujeres	De 40 a 44 a�os	40	916	INE_Padron
2014	Mujeres	De 45 a 49 a�os	45	905	INE_Padron
2014	Mujeres	De 50 a 54 a�os	50	944	INE_Padron
2014	Mujeres	De 55 a 59 a�os	55	702	INE_Padron
2014	Mujeres	De 60 a 64 a�os	60	577	INE_Padron
2014	Mujeres	De 65 a 69 a�os	65	542	INE_Padron
2014	Mujeres	De 70 a 74 a�os	70	530	INE_Padron
2014	Mujeres	De 75 a 79 a�os	75	504	INE_Padron
2014	Mujeres	De 80 a 84 a�os	80	497	INE_Padron
2014	Mujeres	De 85 a 89 a�os	85	271	INE_Padron
2014	Mujeres	De 90 a 94 a�os	90	154	INE_Padron
2014	Mujeres	De 95 a 99 a�os	95	15	INE_Padron
2014	Mujeres	100 y m�s a�os	100	2	INE_Padron
2015	Hombres	De 0 a 4 a�os	0	523	INE_Padron
2015	Hombres	De 5 a 9 a�os	5	614	INE_Padron
2015	Hombres	De 10 a 14 a�os	10	652	INE_Padron
2015	Hombres	De 15 a 19 a�os	15	672	INE_Padron
2015	Hombres	De 20 a 24 a�os	20	780	INE_Padron
2015	Hombres	De 25 a 29 a�os	25	742	INE_Padron
2015	Hombres	De 30 a 34 a�os	30	750	INE_Padron
2015	Hombres	De 35 a 39 a�os	35	853	INE_Padron
2015	Hombres	De 40 a 44 a�os	40	898	INE_Padron
2015	Hombres	De 45 a 49 a�os	45	963	INE_Padron
2015	Hombres	De 50 a 54 a�os	50	887	INE_Padron
2015	Hombres	De 55 a 59 a�os	55	775	INE_Padron
2015	Hombres	De 60 a 64 a�os	60	599	INE_Padron
2015	Hombres	De 65 a 69 a�os	65	537	INE_Padron
2015	Hombres	De 70 a 74 a�os	70	435	INE_Padron
2015	Hombres	De 75 a 79 a�os	75	365	INE_Padron
2015	Hombres	De 80 a 84 a�os	80	347	INE_Padron
2015	Hombres	De 85 a 89 a�os	85	186	INE_Padron
2015	Hombres	De 90 a 94 a�os	90	48	INE_Padron
2015	Hombres	De 95 a 99 a�os	95	10	INE_Padron
2015	Hombres	100 y m�s a�os	100	3	INE_Padron
2015	Mujeres	De 0 a 4 a�os	0	487	INE_Padron
2015	Mujeres	De 5 a 9 a�os	5	561	INE_Padron
2015	Mujeres	De 10 a 14 a�os	10	590	INE_Padron
2015	Mujeres	De 15 a 19 a�os	15	621	INE_Padron
2015	Mujeres	De 20 a 24 a�os	20	757	INE_Padron
2015	Mujeres	De 25 a 29 a�os	25	688	INE_Padron
2015	Mujeres	De 30 a 34 a�os	30	727	INE_Padron
2015	Mujeres	De 35 a 39 a�os	35	801	INE_Padron
2015	Mujeres	De 40 a 44 a�os	40	945	INE_Padron
2015	Mujeres	De 45 a 49 a�os	45	932	INE_Padron
2015	Mujeres	De 50 a 54 a�os	50	901	INE_Padron
2015	Mujeres	De 55 a 59 a�os	55	758	INE_Padron
2015	Mujeres	De 60 a 64 a�os	60	590	INE_Padron
2015	Mujeres	De 65 a 69 a�os	65	548	INE_Padron
2015	Mujeres	De 70 a 74 a�os	70	541	INE_Padron
2015	Mujeres	De 75 a 79 a�os	75	458	INE_Padron
2015	Mujeres	De 80 a 84 a�os	80	519	INE_Padron
2015	Mujeres	De 85 a 89 a�os	85	279	INE_Padron
2015	Mujeres	De 90 a 94 a�os	90	153	INE_Padron
2015	Mujeres	De 95 a 99 a�os	95	23	INE_Padron
2015	Mujeres	100 y m�s a�os	100	1	INE_Padron
2016	Hombres	De 0 a 4 a�os	0	510	INE_Padron
2016	Hombres	De 5 a 9 a�os	5	603	INE_Padron
2016	Hombres	De 10 a 14 a�os	10	642	INE_Padron
2016	Hombres	De 15 a 19 a�os	15	655	INE_Padron
2016	Hombres	De 20 a 24 a�os	20	741	INE_Padron
2016	Hombres	De 25 a 29 a�os	25	782	INE_Padron
2016	Hombres	De 30 a 34 a�os	30	702	INE_Padron
2016	Hombres	De 35 a 39 a�os	35	837	INE_Padron
2016	Hombres	De 40 a 44 a�os	40	889	INE_Padron
2016	Hombres	De 45 a 49 a�os	45	958	INE_Padron
2016	Hombres	De 50 a 54 a�os	50	909	INE_Padron
2016	Hombres	De 55 a 59 a�os	55	789	INE_Padron
2016	Hombres	De 60 a 64 a�os	60	628	INE_Padron
2016	Hombres	De 65 a 69 a�os	65	528	INE_Padron
2016	Hombres	De 70 a 74 a�os	70	451	INE_Padron
2016	Hombres	De 75 a 79 a�os	75	354	INE_Padron
2016	Hombres	De 80 a 84 a�os	80	336	INE_Padron
2016	Hombres	De 85 a 89 a�os	85	198	INE_Padron
2016	Hombres	De 90 a 94 a�os	90	48	INE_Padron
2016	Hombres	De 95 a 99 a�os	95	11	INE_Padron
2016	Hombres	100 y m�s a�os	100	2	INE_Padron
2016	Mujeres	De 0 a 4 a�os	0	473	INE_Padron
2016	Mujeres	De 5 a 9 a�os	5	562	INE_Padron
2016	Mujeres	De 10 a 14 a�os	10	574	INE_Padron
2016	Mujeres	De 15 a 19 a�os	15	630	INE_Padron
2016	Mujeres	De 20 a 24 a�os	20	708	INE_Padron
2016	Mujeres	De 25 a 29 a�os	25	687	INE_Padron
2016	Mujeres	De 30 a 34 a�os	30	713	INE_Padron
2016	Mujeres	De 35 a 39 a�os	35	787	INE_Padron
2016	Mujeres	De 40 a 44 a�os	40	888	INE_Padron
2016	Mujeres	De 45 a 49 a�os	45	941	INE_Padron
2016	Mujeres	De 50 a 54 a�os	50	907	INE_Padron
2016	Mujeres	De 55 a 59 a�os	55	805	INE_Padron
2016	Mujeres	De 60 a 64 a�os	60	620	INE_Padron
2016	Mujeres	De 65 a 69 a�os	65	532	INE_Padron
2016	Mujeres	De 70 a 74 a�os	70	532	INE_Padron
2016	Mujeres	De 75 a 79 a�os	75	460	INE_Padron
2016	Mujeres	De 80 a 84 a�os	80	486	INE_Padron
2016	Mujeres	De 85 a 89 a�os	85	307	INE_Padron
2016	Mujeres	De 90 a 94 a�os	90	153	INE_Padron
2016	Mujeres	De 95 a 99 a�os	95	24	INE_Padron
2016	Mujeres	100 y m�s a�os	100	3	INE_Padron
2017	Hombres	De 0 a 4 a�os	0	476	INE_Padron
2017	Hombres	De 5 a 9 a�os	5	571	INE_Padron
2017	Hombres	De 10 a 14 a�os	10	636	INE_Padron
2017	Hombres	De 15 a 19 a�os	15	663	INE_Padron
2017	Hombres	De 20 a 24 a�os	20	706	INE_Padron
2017	Hombres	De 25 a 29 a�os	25	774	INE_Padron
2017	Hombres	De 30 a 34 a�os	30	695	INE_Padron
2017	Hombres	De 35 a 39 a�os	35	819	INE_Padron
2017	Hombres	De 40 a 44 a�os	40	844	INE_Padron
2017	Hombres	De 45 a 49 a�os	45	924	INE_Padron
2017	Hombres	De 50 a 54 a�os	50	939	INE_Padron
2017	Hombres	De 55 a 59 a�os	55	828	INE_Padron
2017	Hombres	De 60 a 64 a�os	60	657	INE_Padron
2017	Hombres	De 65 a 69 a�os	65	531	INE_Padron
2017	Hombres	De 70 a 74 a�os	70	469	INE_Padron
2017	Hombres	De 75 a 79 a�os	75	345	INE_Padron
2017	Hombres	De 80 a 84 a�os	80	327	INE_Padron
2017	Hombres	De 85 a 89 a�os	85	211	INE_Padron
2017	Hombres	De 90 a 94 a�os	90	60	INE_Padron
2017	Hombres	De 95 a 99 a�os	95	9	INE_Padron
2017	Hombres	100 y m�s a�os	100	3	INE_Padron
2017	Mujeres	De 0 a 4 a�os	0	443	INE_Padron
2017	Mujeres	De 5 a 9 a�os	5	554	INE_Padron
2017	Mujeres	De 10 a 14 a�os	10	565	INE_Padron
2017	Mujeres	De 15 a 19 a�os	15	632	INE_Padron
2017	Mujeres	De 20 a 24 a�os	20	665	INE_Padron
2017	Mujeres	De 25 a 29 a�os	25	677	INE_Padron
2017	Mujeres	De 30 a 34 a�os	30	695	INE_Padron
2017	Mujeres	De 35 a 39 a�os	35	758	INE_Padron
2017	Mujeres	De 40 a 44 a�os	40	876	INE_Padron
2017	Mujeres	De 45 a 49 a�os	45	919	INE_Padron
2017	Mujeres	De 50 a 54 a�os	50	914	INE_Padron
2017	Mujeres	De 55 a 59 a�os	55	867	INE_Padron
2017	Mujeres	De 60 a 64 a�os	60	631	INE_Padron
2017	Mujeres	De 65 a 69 a�os	65	546	INE_Padron
2017	Mujeres	De 70 a 74 a�os	70	545	INE_Padron
2017	Mujeres	De 75 a 79 a�os	75	451	INE_Padron
2017	Mujeres	De 80 a 84 a�os	80	474	INE_Padron
2017	Mujeres	De 85 a 89 a�os	85	327	INE_Padron
2017	Mujeres	De 90 a 94 a�os	90	149	INE_Padron
2017	Mujeres	De 95 a 99 a�os	95	30	INE_Padron
2017	Mujeres	100 y m�s a�os	100	4	INE_Padron
2018	Hombres	De 0 a 4 a�os	0	449	INE_Padron
2018	Hombres	De 5 a 9 a�os	5	572	INE_Padron
2018	Hombres	De 10 a 14 a�os	10	603	INE_Padron
2018	Hombres	De 15 a 19 a�os	15	654	INE_Padron
2018	Hombres	De 20 a 24 a�os	20	699	INE_Padron
2018	Hombres	De 25 a 29 a�os	25	746	INE_Padron
2018	Hombres	De 30 a 34 a�os	30	695	INE_Padron
2018	Hombres	De 35 a 39 a�os	35	796	INE_Padron
2018	Hombres	De 40 a 44 a�os	40	818	INE_Padron
2018	Hombres	De 45 a 49 a�os	45	925	INE_Padron
2018	Hombres	De 50 a 54 a�os	50	937	INE_Padron
2018	Hombres	De 55 a 59 a�os	55	840	INE_Padron
2018	Hombres	De 60 a 64 a�os	60	690	INE_Padron
2018	Hombres	De 65 a 69 a�os	65	561	INE_Padron
2018	Hombres	De 70 a 74 a�os	70	474	INE_Padron
2018	Hombres	De 75 a 79 a�os	75	346	INE_Padron
2018	Hombres	De 80 a 84 a�os	80	321	INE_Padron
2018	Hombres	De 85 a 89 a�os	85	220	INE_Padron
2018	Hombres	De 90 a 94 a�os	90	68	INE_Padron
2018	Hombres	De 95 a 99 a�os	95	5	INE_Padron
2018	Hombres	100 y m�s a�os	100	4	INE_Padron
2018	Mujeres	De 0 a 4 a�os	0	403	INE_Padron
2018	Mujeres	De 5 a 9 a�os	5	541	INE_Padron
2018	Mujeres	De 10 a 14 a�os	10	556	INE_Padron
2018	Mujeres	De 15 a 19 a�os	15	619	INE_Padron
2018	Mujeres	De 20 a 24 a�os	20	658	INE_Padron
2018	Mujeres	De 25 a 29 a�os	25	654	INE_Padron
2018	Mujeres	De 30 a 34 a�os	30	642	INE_Padron
2018	Mujeres	De 35 a 39 a�os	35	760	INE_Padron
2018	Mujeres	De 40 a 44 a�os	40	856	INE_Padron
2018	Mujeres	De 45 a 49 a�os	45	923	INE_Padron
2018	Mujeres	De 50 a 54 a�os	50	897	INE_Padron
2018	Mujeres	De 55 a 59 a�os	55	898	INE_Padron
2018	Mujeres	De 60 a 64 a�os	60	668	INE_Padron
2018	Mujeres	De 65 a 69 a�os	65	543	INE_Padron
2018	Mujeres	De 70 a 74 a�os	70	540	INE_Padron
2018	Mujeres	De 75 a 79 a�os	75	476	INE_Padron
2018	Mujeres	De 80 a 84 a�os	80	446	INE_Padron
2018	Mujeres	De 85 a 89 a�os	85	355	INE_Padron
2018	Mujeres	De 90 a 94 a�os	90	127	INE_Padron
2018	Mujeres	De 95 a 99 a�os	95	42	INE_Padron
2018	Mujeres	100 y m�s a�os	100	4	INE_Padron
2019	Hombres	De 0 a 4 a�os	0	450	INE_Padron
2019	Hombres	De 5 a 9 a�os	5	548	INE_Padron
2019	Hombres	De 10 a 14 a�os	10	614	INE_Padron
2019	Hombres	De 15 a 19 a�os	15	642	INE_Padron
2019	Hombres	De 20 a 24 a�os	20	690	INE_Padron
2019	Hombres	De 25 a 29 a�os	25	718	INE_Padron
2019	Hombres	De 30 a 34 a�os	30	690	INE_Padron
2019	Hombres	De 35 a 39 a�os	35	753	INE_Padron
2019	Hombres	De 40 a 44 a�os	40	820	INE_Padron
2019	Hombres	De 45 a 49 a�os	45	897	INE_Padron
2019	Hombres	De 50 a 54 a�os	50	914	INE_Padron
2019	Hombres	De 55 a 59 a�os	55	857	INE_Padron
2019	Hombres	De 60 a 64 a�os	60	715	INE_Padron
2019	Hombres	De 65 a 69 a�os	65	571	INE_Padron
2019	Hombres	De 70 a 74 a�os	70	493	INE_Padron
2019	Hombres	De 75 a 79 a�os	75	380	INE_Padron
2019	Hombres	De 80 a 84 a�os	80	296	INE_Padron
2019	Hombres	De 85 a 89 a�os	85	204	INE_Padron
2019	Hombres	De 90 a 94 a�os	90	90	INE_Padron
2019	Hombres	De 95 a 99 a�os	95	7	INE_Padron
2019	Hombres	100 y m�s a�os	100	4	INE_Padron
2019	Mujeres	De 0 a 4 a�os	0	396	INE_Padron
2019	Mujeres	De 5 a 9 a�os	5	517	INE_Padron
2019	Mujeres	De 10 a 14 a�os	10	555	INE_Padron
2019	Mujeres	De 15 a 19 a�os	15	598	INE_Padron
2019	Mujeres	De 20 a 24 a�os	20	621	INE_Padron
2019	Mujeres	De 25 a 29 a�os	25	666	INE_Padron
2019	Mujeres	De 30 a 34 a�os	30	638	INE_Padron
2019	Mujeres	De 35 a 39 a�os	35	703	INE_Padron
2019	Mujeres	De 40 a 44 a�os	40	872	INE_Padron
2019	Mujeres	De 45 a 49 a�os	45	899	INE_Padron
2019	Mujeres	De 50 a 54 a�os	50	894	INE_Padron
2019	Mujeres	De 55 a 59 a�os	55	920	INE_Padron
2019	Mujeres	De 60 a 64 a�os	60	698	INE_Padron
2019	Mujeres	De 65 a 69 a�os	65	564	INE_Padron
2019	Mujeres	De 70 a 74 a�os	70	522	INE_Padron
2019	Mujeres	De 75 a 79 a�os	75	491	INE_Padron
2019	Mujeres	De 80 a 84 a�os	80	424	INE_Padron
2019	Mujeres	De 85 a 89 a�os	85	356	INE_Padron
2019	Mujeres	De 90 a 94 a�os	90	124	INE_Padron
2019	Mujeres	De 95 a 99 a�os	95	45	INE_Padron
2019	Mujeres	100 y m�s a�os	100	3	INE_Padron
2020	Hombres	De 0 a 4 a�os	0	458	INE_Padron
2020	Hombres	De 5 a 9 a�os	5	530	INE_Padron
2020	Hombres	De 10 a 14 a�os	10	608	INE_Padron
2020	Hombres	De 15 a 19 a�os	15	646	INE_Padron
2020	Hombres	De 20 a 24 a�os	20	655	INE_Padron
2020	Hombres	De 25 a 29 a�os	25	700	INE_Padron
2020	Hombres	De 30 a 34 a�os	30	676	INE_Padron
2020	Hombres	De 35 a 39 a�os	35	712	INE_Padron
2020	Hombres	De 40 a 44 a�os	40	820	INE_Padron
2020	Hombres	De 45 a 49 a�os	45	872	INE_Padron
2020	Hombres	De 50 a 54 a�os	50	942	INE_Padron
2020	Hombres	De 55 a 59 a�os	55	863	INE_Padron
2020	Hombres	De 60 a 64 a�os	60	744	INE_Padron
2020	Hombres	De 65 a 69 a�os	65	578	INE_Padron
2020	Hombres	De 70 a 74 a�os	70	507	INE_Padron
2020	Hombres	De 75 a 79 a�os	75	393	INE_Padron
2020	Hombres	De 80 a 84 a�os	80	283	INE_Padron
2020	Hombres	De 85 a 89 a�os	85	206	INE_Padron
2020	Hombres	De 90 a 94 a�os	90	89	INE_Padron
2020	Hombres	De 95 a 99 a�os	95	9	INE_Padron
2020	Hombres	100 y m�s a�os	100	2	INE_Padron
2020	Mujeres	De 0 a 4 a�os	0	391	INE_Padron
2020	Mujeres	De 5 a 9 a�os	5	485	INE_Padron
2020	Mujeres	De 10 a 14 a�os	10	553	INE_Padron
2020	Mujeres	De 15 a 19 a�os	15	575	INE_Padron
2020	Mujeres	De 20 a 24 a�os	20	636	INE_Padron
2020	Mujeres	De 25 a 29 a�os	25	679	INE_Padron
2020	Mujeres	De 30 a 34 a�os	30	593	INE_Padron
2020	Mujeres	De 35 a 39 a�os	35	710	INE_Padron
2020	Mujeres	De 40 a 44 a�os	40	799	INE_Padron
2020	Mujeres	De 45 a 49 a�os	45	917	INE_Padron
2020	Mujeres	De 50 a 54 a�os	50	917	INE_Padron
2020	Mujeres	De 55 a 59 a�os	55	882	INE_Padron
2020	Mujeres	De 60 a 64 a�os	60	747	INE_Padron
2020	Mujeres	De 65 a 69 a�os	65	587	INE_Padron
2020	Mujeres	De 70 a 74 a�os	70	529	INE_Padron
2020	Mujeres	De 75 a 79 a�os	75	502	INE_Padron
2020	Mujeres	De 80 a 84 a�os	80	389	INE_Padron
2020	Mujeres	De 85 a 89 a�os	85	376	INE_Padron
2020	Mujeres	De 90 a 94 a�os	90	132	INE_Padron
2020	Mujeres	De 95 a 99 a�os	95	43	INE_Padron
2020	Mujeres	100 y m�s a�os	100	4	INE_Padron
2021	Hombres	De 0 a 4 a�os	0	433	INE_Censo
2021	Hombres	De 5 a 9 a�os	5	521	INE_Censo
2021	Hombres	De 10 a 14 a�os	10	602	INE_Censo
2021	Hombres	De 15 a 19 a�os	15	627	INE_Censo
2021	Hombres	De 20 a 24 a�os	20	645	INE_Censo
2021	Hombres	De 25 a 29 a�os	25	667	INE_Censo
2021	Hombres	De 30 a 34 a�os	30	712	INE_Censo
2021	Hombres	De 35 a 39 a�os	35	672	INE_Censo
2021	Hombres	De 40 a 44 a�os	40	809	INE_Censo
2021	Hombres	De 45 a 49 a�os	45	863	INE_Censo
2021	Hombres	De 50 a 54 a�os	50	927	INE_Censo
2021	Hombres	De 55 a 59 a�os	55	876	INE_Censo
2021	Hombres	De 60 a 64 a�os	60	768	INE_Censo
2021	Hombres	De 65 a 69 a�os	65	600	INE_Censo
2021	Hombres	De 70 a 74 a�os	70	493	INE_Censo
2021	Hombres	De 75 a 79 a�os	75	403	INE_Censo
2021	Hombres	De 80 a 84 a�os	80	280	INE_Censo
2021	Hombres	De 85 a 89 a�os	85	202	INE_Censo
2021	Hombres	De 90 a 94 a�os	90	84	INE_Censo
2021	Hombres	De 95 a 99 a�os	95	12	INE_Censo
2021	Hombres	100 y m�s a�os	100	1	INE_Censo
2021	Mujeres	De 0 a 4 a�os	0	387	INE_Censo
2021	Mujeres	De 5 a 9 a�os	5	467	INE_Censo
2021	Mujeres	De 10 a 14 a�os	10	567	INE_Censo
2021	Mujeres	De 15 a 19 a�os	15	561	INE_Censo
2021	Mujeres	De 20 a 24 a�os	20	627	INE_Censo
2021	Mujeres	De 25 a 29 a�os	25	665	INE_Censo
2021	Mujeres	De 30 a 34 a�os	30	593	INE_Censo
2021	Mujeres	De 35 a 39 a�os	35	687	INE_Censo
2021	Mujeres	De 40 a 44 a�os	40	802	INE_Censo
2021	Mujeres	De 45 a 49 a�os	45	861	INE_Censo
2021	Mujeres	De 50 a 54 a�os	50	928	INE_Censo
2021	Mujeres	De 55 a 59 a�os	55	902	INE_Censo
2021	Mujeres	De 60 a 64 a�os	60	791	INE_Censo
2021	Mujeres	De 65 a 69 a�os	65	618	INE_Censo
2021	Mujeres	De 70 a 74 a�os	70	520	INE_Censo
2021	Mujeres	De 75 a 79 a�os	75	494	INE_Censo
2021	Mujeres	De 80 a 84 a�os	80	392	INE_Censo
2021	Mujeres	De 85 a 89 a�os	85	359	INE_Censo
2021	Mujeres	De 90 a 94 a�os	90	154	INE_Censo
2021	Mujeres	De 95 a 99 a�os	95	42	INE_Censo
2021	Mujeres	100 y m�s a�os	100	3	INE_Censo
2021	Hombres	De 0 a 4 a�os	0	436	INE_Padron
2021	Hombres	De 5 a 9 a�os	5	521	INE_Padron
2021	Hombres	De 10 a 14 a�os	10	599	INE_Padron
2021	Hombres	De 15 a 19 a�os	15	630	INE_Padron
2021	Hombres	De 20 a 24 a�os	20	644	INE_Padron
2021	Hombres	De 25 a 29 a�os	25	668	INE_Padron
2021	Hombres	De 30 a 34 a�os	30	717	INE_Padron
2021	Hombres	De 35 a 39 a�os	35	671	INE_Padron
2021	Hombres	De 40 a 44 a�os	40	812	INE_Padron
2021	Hombres	De 45 a 49 a�os	45	866	INE_Padron
2021	Hombres	De 50 a 54 a�os	50	928	INE_Padron
2021	Hombres	De 55 a 59 a�os	55	878	INE_Padron
2021	Hombres	De 60 a 64 a�os	60	766	INE_Padron
2021	Hombres	De 65 a 69 a�os	65	602	INE_Padron
2021	Hombres	De 70 a 74 a�os	70	493	INE_Padron
2021	Hombres	De 75 a 79 a�os	75	403	INE_Padron
2021	Hombres	De 80 a 84 a�os	80	280	INE_Padron
2021	Hombres	De 85 a 89 a�os	85	202	INE_Padron
2021	Hombres	De 90 a 94 a�os	90	84	INE_Padron
2021	Hombres	De 95 a 99 a�os	95	12	INE_Padron
2021	Hombres	100 y m�s a�os	100	2	INE_Padron
2021	Mujeres	De 0 a 4 a�os	0	379	INE_Padron
2021	Mujeres	De 5 a 9 a�os	5	464	INE_Padron
2021	Mujeres	De 10 a 14 a�os	10	564	INE_Padron
2021	Mujeres	De 15 a 19 a�os	15	565	INE_Padron
2021	Mujeres	De 20 a 24 a�os	20	626	INE_Padron
2021	Mujeres	De 25 a 29 a�os	25	660	INE_Padron
2021	Mujeres	De 30 a 34 a�os	30	599	INE_Padron
2021	Mujeres	De 35 a 39 a�os	35	683	INE_Padron
2021	Mujeres	De 40 a 44 a�os	40	802	INE_Padron
2021	Mujeres	De 45 a 49 a�os	45	865	INE_Padron
2021	Mujeres	De 50 a 54 a�os	50	929	INE_Padron
2021	Mujeres	De 55 a 59 a�os	55	903	INE_Padron
2021	Mujeres	De 60 a 64 a�os	60	793	INE_Padron
2021	Mujeres	De 65 a 69 a�os	65	619	INE_Padron
2021	Mujeres	De 70 a 74 a�os	70	521	INE_Padron
2021	Mujeres	De 75 a 79 a�os	75	494	INE_Padron
2021	Mujeres	De 80 a 84 a�os	80	394	INE_Padron
2021	Mujeres	De 85 a 89 a�os	85	359	INE_Padron
2021	Mujeres	De 90 a 94 a�os	90	154	INE_Padron
2021	Mujeres	De 95 a 99 a�os	95	42	INE_Padron
2021	Mujeres	100 y m�s a�os	100	4	INE_Padron
2022	Hombres	De 0 a 4 a�os	0	409	INE_Censo
2022	Hombres	De 5 a 9 a�os	5	483	INE_Censo
2022	Hombres	De 10 a 14 a�os	10	576	INE_Censo
2022	Hombres	De 15 a 19 a�os	15	628	INE_Censo
2022	Hombres	De 20 a 24 a�os	20	649	INE_Censo
2022	Hombres	De 25 a 29 a�os	25	649	INE_Censo
2022	Hombres	De 30 a 34 a�os	30	720	INE_Censo
2022	Hombres	De 35 a 39 a�os	35	657	INE_Censo
2022	Hombres	De 40 a 44 a�os	40	792	INE_Censo
2022	Hombres	De 45 a 49 a�os	45	835	INE_Censo
2022	Hombres	De 50 a 54 a�os	50	895	INE_Censo
2022	Hombres	De 55 a 59 a�os	55	909	INE_Censo
2022	Hombres	De 60 a 64 a�os	60	809	INE_Censo
2022	Hombres	De 65 a 69 a�os	65	637	INE_Censo
2022	Hombres	De 70 a 74 a�os	70	493	INE_Censo
2022	Hombres	De 75 a 79 a�os	75	406	INE_Censo
2022	Hombres	De 80 a 84 a�os	80	276	INE_Censo
2022	Hombres	De 85 a 89 a�os	85	198	INE_Censo
2022	Hombres	De 90 a 94 a�os	90	84	INE_Censo
2022	Hombres	De 95 a 99 a�os	95	19	INE_Censo
2022	Hombres	100 y m�s a�os	100	2	INE_Censo
2022	Mujeres	De 0 a 4 a�os	0	358	INE_Censo
2022	Mujeres	De 5 a 9 a�os	5	441	INE_Censo
2022	Mujeres	De 10 a 14 a�os	10	556	INE_Censo
2022	Mujeres	De 15 a 19 a�os	15	557	INE_Censo
2022	Mujeres	De 20 a 24 a�os	20	628	INE_Censo
2022	Mujeres	De 25 a 29 a�os	25	633	INE_Censo
2022	Mujeres	De 30 a 34 a�os	30	591	INE_Censo
2022	Mujeres	De 35 a 39 a�os	35	671	INE_Censo
2022	Mujeres	De 40 a 44 a�os	40	758	INE_Censo
2022	Mujeres	De 45 a 49 a�os	45	874	INE_Censo
2022	Mujeres	De 50 a 54 a�os	50	905	INE_Censo
2022	Mujeres	De 55 a 59 a�os	55	895	INE_Censo
2022	Mujeres	De 60 a 64 a�os	60	858	INE_Censo
2022	Mujeres	De 65 a 69 a�os	65	637	INE_Censo
2022	Mujeres	De 70 a 74 a�os	70	526	INE_Censo
2022	Mujeres	De 75 a 79 a�os	75	502	INE_Censo
2022	Mujeres	De 80 a 84 a�os	80	388	INE_Censo
2022	Mujeres	De 85 a 89 a�os	85	337	INE_Censo
2022	Mujeres	De 90 a 94 a�os	90	157	INE_Censo
2022	Mujeres	De 95 a 99 a�os	95	36	INE_Censo
2022	Mujeres	100 y m�s a�os	100	5	INE_Censo
2022	Hombres	De 0 a 4 a�os	0	410	INE_Padron
2022	Hombres	De 5 a 9 a�os	5	483	INE_Padron
2022	Hombres	De 10 a 14 a�os	10	576	INE_Padron
2022	Hombres	De 15 a 19 a�os	15	629	INE_Padron
2022	Hombres	De 20 a 24 a�os	20	652	INE_Padron
2022	Hombres	De 25 a 29 a�os	25	652	INE_Padron
2022	Hombres	De 30 a 34 a�os	30	721	INE_Padron
2022	Hombres	De 35 a 39 a�os	35	659	INE_Padron
2022	Hombres	De 40 a 44 a�os	40	796	INE_Padron
2022	Hombres	De 45 a 49 a�os	45	837	INE_Padron
2022	Hombres	De 50 a 54 a�os	50	899	INE_Padron
2022	Hombres	De 55 a 59 a�os	55	911	INE_Padron
2022	Hombres	De 60 a 64 a�os	60	809	INE_Padron
2022	Hombres	De 65 a 69 a�os	65	636	INE_Padron
2022	Hombres	De 70 a 74 a�os	70	493	INE_Padron
2022	Hombres	De 75 a 79 a�os	75	406	INE_Padron
2022	Hombres	De 80 a 84 a�os	80	276	INE_Padron
2022	Hombres	De 85 a 89 a�os	85	198	INE_Padron
2022	Hombres	De 90 a 94 a�os	90	84	INE_Padron
2022	Hombres	De 95 a 99 a�os	95	19	INE_Padron
2022	Hombres	100 y m�s a�os	100	3	INE_Padron
2022	Mujeres	De 0 a 4 a�os	0	355	INE_Padron
2022	Mujeres	De 5 a 9 a�os	5	442	INE_Padron
2022	Mujeres	De 10 a 14 a�os	10	559	INE_Padron
2022	Mujeres	De 15 a 19 a�os	15	559	INE_Padron
2022	Mujeres	De 20 a 24 a�os	20	629	INE_Padron
2022	Mujeres	De 25 a 29 a�os	25	635	INE_Padron
2022	Mujeres	De 30 a 34 a�os	30	595	INE_Padron
2022	Mujeres	De 35 a 39 a�os	35	674	INE_Padron
2022	Mujeres	De 40 a 44 a�os	40	761	INE_Padron
2022	Mujeres	De 45 a 49 a�os	45	876	INE_Padron
2022	Mujeres	De 50 a 54 a�os	50	910	INE_Padron
2022	Mujeres	De 55 a 59 a�os	55	898	INE_Padron
2022	Mujeres	De 60 a 64 a�os	60	858	INE_Padron
2022	Mujeres	De 65 a 69 a�os	65	637	INE_Padron
2022	Mujeres	De 70 a 74 a�os	70	527	INE_Padron
2022	Mujeres	De 75 a 79 a�os	75	502	INE_Padron
2022	Mujeres	De 80 a 84 a�os	80	388	INE_Padron
2022	Mujeres	De 85 a 89 a�os	85	337	INE_Padron
2022	Mujeres	De 90 a 94 a�os	90	157	INE_Padron
2022	Mujeres	De 95 a 99 a�os	95	36	INE_Padron
2022	Mujeres	100 y m�s a�os	100	6	INE_Padron
2023	Hombres	De 0 a 4 a�os	0	401	INE_Censo
2023	Hombres	De 5 a 9 a�os	5	449	INE_Censo
2023	Hombres	De 10 a 14 a�os	10	583	INE_Censo
2023	Hombres	De 15 a 19 a�os	15	607	INE_Censo
2023	Hombres	De 20 a 24 a�os	20	639	INE_Censo
2023	Hombres	De 25 a 29 a�os	25	648	INE_Censo
2023	Hombres	De 30 a 34 a�os	30	684	INE_Censo
2023	Hombres	De 35 a 39 a�os	35	651	INE_Censo
2023	Hombres	De 40 a 44 a�os	40	767	INE_Censo
2023	Hombres	De 45 a 49 a�os	45	812	INE_Censo
2023	Hombres	De 50 a 54 a�os	50	906	INE_Censo
2023	Hombres	De 55 a 59 a�os	55	911	INE_Censo
2023	Hombres	De 60 a 64 a�os	60	833	INE_Censo
2023	Hombres	De 65 a 69 a�os	65	657	INE_Censo
2023	Hombres	De 70 a 74 a�os	70	528	INE_Censo
2023	Hombres	De 75 a 79 a�os	75	403	INE_Censo
2023	Hombres	De 80 a 84 a�os	80	273	INE_Censo
2023	Hombres	De 85 a 89 a�os	85	182	INE_Censo
2023	Hombres	De 90 a 94 a�os	90	89	INE_Censo
2023	Hombres	De 95 a 99 a�os	95	18	INE_Censo
2023	Hombres	100 y m�s a�os	100	1	INE_Censo
2023	Mujeres	De 0 a 4 a�os	0	369	INE_Censo
2023	Mujeres	De 5 a 9 a�os	5	402	INE_Censo
2023	Mujeres	De 10 a 14 a�os	10	542	INE_Censo
2023	Mujeres	De 15 a 19 a�os	15	557	INE_Censo
2023	Mujeres	De 20 a 24 a�os	20	611	INE_Censo
2023	Mujeres	De 25 a 29 a�os	25	615	INE_Censo
2023	Mujeres	De 30 a 34 a�os	30	595	INE_Censo
2023	Mujeres	De 35 a 39 a�os	35	631	INE_Censo
2023	Mujeres	De 40 a 44 a�os	40	750	INE_Censo
2023	Mujeres	De 45 a 49 a�os	45	864	INE_Censo
2023	Mujeres	De 50 a 54 a�os	50	908	INE_Censo
2023	Mujeres	De 55 a 59 a�os	55	881	INE_Censo
2023	Mujeres	De 60 a 64 a�os	60	879	INE_Censo
2023	Mujeres	De 65 a 69 a�os	65	681	INE_Censo
2023	Mujeres	De 70 a 74 a�os	70	533	INE_Censo
2023	Mujeres	De 75 a 79 a�os	75	499	INE_Censo
2023	Mujeres	De 80 a 84 a�os	80	421	INE_Censo
2023	Mujeres	De 85 a 89 a�os	85	310	INE_Censo
2023	Mujeres	De 90 a 94 a�os	90	167	INE_Censo
2023	Mujeres	De 95 a 99 a�os	95	38	INE_Censo
2023	Mujeres	100 y m�s a�os	100	5	INE_Censo
2024	Hombres	De 0 a 4 a�os	0	381	INE_Censo
2024	Hombres	De 5 a 9 a�os	5	462	INE_Censo
2024	Hombres	De 10 a 14 a�os	10	556	INE_Censo
2024	Hombres	De 15 a 19 a�os	15	607	INE_Censo
2024	Hombres	De 20 a 24 a�os	20	633	INE_Censo
2024	Hombres	De 25 a 29 a�os	25	639	INE_Censo
2024	Hombres	De 30 a 34 a�os	30	667	INE_Censo
2024	Hombres	De 35 a 39 a�os	35	656	INE_Censo
2024	Hombres	De 40 a 44 a�os	40	732	INE_Censo
2024	Hombres	De 45 a 49 a�os	45	810	INE_Censo
2024	Hombres	De 50 a 54 a�os	50	897	INE_Censo
2024	Hombres	De 55 a 59 a�os	55	886	INE_Censo
2024	Hombres	De 60 a 64 a�os	60	856	INE_Censo
2024	Hombres	De 65 a 69 a�os	65	687	INE_Censo
2024	Hombres	De 70 a 74 a�os	70	542	INE_Censo
2024	Hombres	De 75 a 79 a�os	75	423	INE_Censo
2024	Hombres	De 80 a 84 a�os	80	294	INE_Censo
2024	Hombres	De 85 a 89 a�os	85	176	INE_Censo
2024	Hombres	De 90 a 94 a�os	90	79	INE_Censo
2024	Hombres	De 95 a 99 a�os	95	19	INE_Censo
2024	Hombres	100 y m�s a�os	100	0	INE_Censo
2024	Mujeres	De 0 a 4 a�os	0	380	INE_Censo
2024	Mujeres	De 5 a 9 a�os	5	416	INE_Censo
2024	Mujeres	De 10 a 14 a�os	10	512	INE_Censo
2024	Mujeres	De 15 a 19 a�os	15	563	INE_Censo
2024	Mujeres	De 20 a 24 a�os	20	604	INE_Censo
2024	Mujeres	De 25 a 29 a�os	25	603	INE_Censo
2024	Mujeres	De 30 a 34 a�os	30	644	INE_Censo
2024	Mujeres	De 35 a 39 a�os	35	610	INE_Censo
2024	Mujeres	De 40 a 44 a�os	40	690	INE_Censo
2024	Mujeres	De 45 a 49 a�os	45	880	INE_Censo
2024	Mujeres	De 50 a 54 a�os	50	896	INE_Censo
2024	Mujeres	De 55 a 59 a�os	55	888	INE_Censo
2024	Mujeres	De 60 a 64 a�os	60	915	INE_Censo
2024	Mujeres	De 65 a 69 a�os	65	706	INE_Censo
2024	Mujeres	De 70 a 74 a�os	70	552	INE_Censo
2024	Mujeres	De 75 a 79 a�os	75	498	INE_Censo
2024	Mujeres	De 80 a 84 a�os	80	431	INE_Censo
2024	Mujeres	De 85 a 89 a�os	85	312	INE_Censo
2024	Mujeres	De 90 a 94 a�os	90	168	INE_Censo
2024	Mujeres	De 95 a 99 a�os	95	39	INE_Censo
2024	Mujeres	100 y m�s a�os	100	6	INE_Censo
2025	Hombres	De 0 a 4 a�os	0	354	INE_Censo
2025	Hombres	De 5 a 9 a�os	5	467	INE_Censo
2025	Hombres	De 10 a 14 a�os	10	529	INE_Censo
2025	Hombres	De 15 a 19 a�os	15	604	INE_Censo
2025	Hombres	De 20 a 24 a�os	20	629	INE_Censo
2025	Hombres	De 25 a 29 a�os	25	620	INE_Censo
2025	Hombres	De 30 a 34 a�os	30	664	INE_Censo
2025	Hombres	De 35 a 39 a�os	35	663	INE_Censo
2025	Hombres	De 40 a 44 a�os	40	691	INE_Censo
2025	Hombres	De 45 a 49 a�os	45	818	INE_Censo
2025	Hombres	De 50 a 54 a�os	50	868	INE_Censo
2025	Hombres	De 55 a 59 a�os	55	908	INE_Censo
2025	Hombres	De 60 a 64 a�os	60	858	INE_Censo
2025	Hombres	De 65 a 69 a�os	65	718	INE_Censo
2025	Hombres	De 70 a 74 a�os	70	545	INE_Censo
2025	Hombres	De 75 a 79 a�os	75	434	INE_Censo
2025	Hombres	De 80 a 84 a�os	80	309	INE_Censo
2025	Hombres	De 85 a 89 a�os	85	167	INE_Censo
2025	Hombres	De 90 a 94 a�os	90	84	INE_Censo
2025	Hombres	De 95 a 99 a�os	95	14	INE_Censo
2025	Hombres	100 y m�s a�os	100	1	INE_Censo
2025	Mujeres	De 0 a 4 a�os	0	364	INE_Censo
2025	Mujeres	De 5 a 9 a�os	5	391	INE_Censo
2025	Mujeres	De 10 a 14 a�os	10	491	INE_Censo
2025	Mujeres	De 15 a 19 a�os	15	563	INE_Censo
2025	Mujeres	De 20 a 24 a�os	20	587	INE_Censo
2025	Mujeres	De 25 a 29 a�os	25	598	INE_Censo
2025	Mujeres	De 30 a 34 a�os	30	651	INE_Censo
2025	Mujeres	De 35 a 39 a�os	35	586	INE_Censo
2025	Mujeres	De 40 a 44 a�os	40	709	INE_Censo
2025	Mujeres	De 45 a 49 a�os	45	807	INE_Censo
2025	Mujeres	De 50 a 54 a�os	50	925	INE_Censo
2025	Mujeres	De 55 a 59 a�os	55	912	INE_Censo
2025	Mujeres	De 60 a 64 a�os	60	880	INE_Censo
2025	Mujeres	De 65 a 69 a�os	65	754	INE_Censo
2025	Mujeres	De 70 a 74 a�os	70	574	INE_Censo
2025	Mujeres	De 75 a 79 a�os	75	503	INE_Censo
2025	Mujeres	De 80 a 84 a�os	80	441	INE_Censo
2025	Mujeres	De 85 a 89 a�os	85	282	INE_Censo
2025	Mujeres	De 90 a 94 a�os	90	190	INE_Censo
2025	Mujeres	De 95 a 99 a�os	95	36	INE_Censo
2025	Mujeres	100 y m�s a�os	100	3	INE_Censo
\.


--
-- Data for Name: poblacion_edad_sexo_ine_padron_2003_2022; Type: TABLE DATA; Schema: public; Owner: montilla_user
--

COPY public.poblacion_edad_sexo_ine_padron_2003_2022 (anio, sexo, grupo_edad, edad_min, poblacion, fuente) FROM stdin;
2003	Hombres	De 0 a 4 a�os	0	641	INE_Padron
2003	Hombres	De 5 a 9 a�os	5	707	INE_Padron
2003	Hombres	De 10 a 14 a�os	10	765	INE_Padron
2003	Hombres	De 15 a 19 a�os	15	735	INE_Padron
2003	Hombres	De 20 a 24 a�os	20	857	INE_Padron
2003	Hombres	De 25 a 29 a�os	25	888	INE_Padron
2003	Hombres	De 30 a 34 a�os	30	949	INE_Padron
2003	Hombres	De 35 a 39 a�os	35	942	INE_Padron
2003	Hombres	De 40 a 44 a�os	40	885	INE_Padron
2003	Hombres	De 45 a 49 a�os	45	738	INE_Padron
2003	Hombres	De 50 a 54 a�os	50	609	INE_Padron
2003	Hombres	De 55 a 59 a�os	55	558	INE_Padron
2003	Hombres	De 60 a 64 a�os	60	451	INE_Padron
2003	Hombres	De 65 a 69 a�os	65	567	INE_Padron
2003	Hombres	De 70 a 74 a�os	70	545	INE_Padron
2003	Hombres	De 75 a 79 a�os	75	370	INE_Padron
2003	Hombres	De 80 a 84 a�os	80	207	INE_Padron
2003	Hombres	De 85 a 89 a�os	85	65	INE_Padron
2003	Hombres	De 90 a 94 a�os	90	24	INE_Padron
2003	Hombres	De 95 a 99 a�os	95	3	INE_Padron
2003	Hombres	100 y m�s a�os	100	1	INE_Padron
2003	Mujeres	De 0 a 4 a�os	0	598	INE_Padron
2003	Mujeres	De 5 a 9 a�os	5	654	INE_Padron
2003	Mujeres	De 10 a 14 a�os	10	701	INE_Padron
2003	Mujeres	De 15 a 19 a�os	15	685	INE_Padron
2003	Mujeres	De 20 a 24 a�os	20	791	INE_Padron
2003	Mujeres	De 25 a 29 a�os	25	889	INE_Padron
2003	Mujeres	De 30 a 34 a�os	30	921	INE_Padron
2003	Mujeres	De 35 a 39 a�os	35	911	INE_Padron
2003	Mujeres	De 40 a 44 a�os	40	912	INE_Padron
2003	Mujeres	De 45 a 49 a�os	45	670	INE_Padron
2003	Mujeres	De 50 a 54 a�os	50	562	INE_Padron
2003	Mujeres	De 55 a 59 a�os	55	580	INE_Padron
2003	Mujeres	De 60 a 64 a�os	60	523	INE_Padron
2003	Mujeres	De 65 a 69 a�os	65	614	INE_Padron
2003	Mujeres	De 70 a 74 a�os	70	640	INE_Padron
2003	Mujeres	De 75 a 79 a�os	75	480	INE_Padron
2003	Mujeres	De 80 a 84 a�os	80	338	INE_Padron
2003	Mujeres	De 85 a 89 a�os	85	180	INE_Padron
2003	Mujeres	De 90 a 94 a�os	90	76	INE_Padron
2003	Mujeres	De 95 a 99 a�os	95	11	INE_Padron
2003	Mujeres	100 y m�s a�os	100	2	INE_Padron
2004	Hombres	De 0 a 4 a�os	0	616	INE_Padron
2004	Hombres	De 5 a 9 a�os	5	692	INE_Padron
2004	Hombres	De 10 a 14 a�os	10	768	INE_Padron
2004	Hombres	De 15 a 19 a�os	15	729	INE_Padron
2004	Hombres	De 20 a 24 a�os	20	829	INE_Padron
2004	Hombres	De 25 a 29 a�os	25	881	INE_Padron
2004	Hombres	De 30 a 34 a�os	30	921	INE_Padron
2004	Hombres	De 35 a 39 a�os	35	924	INE_Padron
2004	Hombres	De 40 a 44 a�os	40	905	INE_Padron
2004	Hombres	De 45 a 49 a�os	45	756	INE_Padron
2004	Hombres	De 50 a 54 a�os	50	619	INE_Padron
2004	Hombres	De 55 a 59 a�os	55	573	INE_Padron
2004	Hombres	De 60 a 64 a�os	60	485	INE_Padron
2004	Hombres	De 65 a 69 a�os	65	511	INE_Padron
2004	Hombres	De 70 a 74 a�os	70	534	INE_Padron
2004	Hombres	De 75 a 79 a�os	75	414	INE_Padron
2004	Hombres	De 80 a 84 a�os	80	223	INE_Padron
2004	Hombres	De 85 a 89 a�os	85	66	INE_Padron
2004	Hombres	De 90 a 94 a�os	90	22	INE_Padron
2004	Hombres	De 95 a 99 a�os	95	2	INE_Padron
2004	Hombres	100 y m�s a�os	100	1	INE_Padron
2004	Mujeres	De 0 a 4 a�os	0	580	INE_Padron
2004	Mujeres	De 5 a 9 a�os	5	603	INE_Padron
2004	Mujeres	De 10 a 14 a�os	10	731	INE_Padron
2004	Mujeres	De 15 a 19 a�os	15	692	INE_Padron
2004	Mujeres	De 20 a 24 a�os	20	749	INE_Padron
2004	Mujeres	De 25 a 29 a�os	25	901	INE_Padron
2004	Mujeres	De 30 a 34 a�os	30	891	INE_Padron
2004	Mujeres	De 35 a 39 a�os	35	902	INE_Padron
2004	Mujeres	De 40 a 44 a�os	40	944	INE_Padron
2004	Mujeres	De 45 a 49 a�os	45	697	INE_Padron
2004	Mujeres	De 50 a 54 a�os	50	580	INE_Padron
2004	Mujeres	De 55 a 59 a�os	55	563	INE_Padron
2004	Mujeres	De 60 a 64 a�os	60	539	INE_Padron
2004	Mujeres	De 65 a 69 a�os	65	584	INE_Padron
2004	Mujeres	De 70 a 74 a�os	70	637	INE_Padron
2004	Mujeres	De 75 a 79 a�os	75	490	INE_Padron
2004	Mujeres	De 80 a 84 a�os	80	374	INE_Padron
2004	Mujeres	De 85 a 89 a�os	85	192	INE_Padron
2004	Mujeres	De 90 a 94 a�os	90	92	INE_Padron
2004	Mujeres	De 95 a 99 a�os	95	10	INE_Padron
2004	Mujeres	100 y m�s a�os	100	1	INE_Padron
2005	Hombres	De 0 a 4 a�os	0	617	INE_Padron
2005	Hombres	De 5 a 9 a�os	5	666	INE_Padron
2005	Hombres	De 10 a 14 a�os	10	766	INE_Padron
2005	Hombres	De 15 a 19 a�os	15	749	INE_Padron
2005	Hombres	De 20 a 24 a�os	20	795	INE_Padron
2005	Hombres	De 25 a 29 a�os	25	889	INE_Padron
2005	Hombres	De 30 a 34 a�os	30	913	INE_Padron
2005	Hombres	De 35 a 39 a�os	35	949	INE_Padron
2005	Hombres	De 40 a 44 a�os	40	915	INE_Padron
2005	Hombres	De 45 a 49 a�os	45	802	INE_Padron
2005	Hombres	De 50 a 54 a�os	50	629	INE_Padron
2005	Hombres	De 55 a 59 a�os	55	583	INE_Padron
2005	Hombres	De 60 a 64 a�os	60	506	INE_Padron
2005	Hombres	De 65 a 69 a�os	65	473	INE_Padron
2005	Hombres	De 70 a 74 a�os	70	547	INE_Padron
2005	Hombres	De 75 a 79 a�os	75	423	INE_Padron
2005	Hombres	De 80 a 84 a�os	80	231	INE_Padron
2005	Hombres	De 85 a 89 a�os	85	82	INE_Padron
2005	Hombres	De 90 a 94 a�os	90	19	INE_Padron
2005	Hombres	De 95 a 99 a�os	95	4	INE_Padron
2005	Hombres	100 y m�s a�os	100	0	INE_Padron
2005	Mujeres	De 0 a 4 a�os	0	558	INE_Padron
2005	Mujeres	De 5 a 9 a�os	5	601	INE_Padron
2005	Mujeres	De 10 a 14 a�os	10	743	INE_Padron
2005	Mujeres	De 15 a 19 a�os	15	689	INE_Padron
2005	Mujeres	De 20 a 24 a�os	20	773	INE_Padron
2005	Mujeres	De 25 a 29 a�os	25	814	INE_Padron
2005	Mujeres	De 30 a 34 a�os	30	921	INE_Padron
2005	Mujeres	De 35 a 39 a�os	35	938	INE_Padron
2005	Mujeres	De 40 a 44 a�os	40	903	INE_Padron
2005	Mujeres	De 45 a 49 a�os	45	763	INE_Padron
2005	Mujeres	De 50 a 54 a�os	50	592	INE_Padron
2005	Mujeres	De 55 a 59 a�os	55	570	INE_Padron
2005	Mujeres	De 60 a 64 a�os	60	565	INE_Padron
2005	Mujeres	De 65 a 69 a�os	65	546	INE_Padron
2005	Mujeres	De 70 a 74 a�os	70	655	INE_Padron
2005	Mujeres	De 75 a 79 a�os	75	475	INE_Padron
2005	Mujeres	De 80 a 84 a�os	80	421	INE_Padron
2005	Mujeres	De 85 a 89 a�os	85	200	INE_Padron
2005	Mujeres	De 90 a 94 a�os	90	82	INE_Padron
2005	Mujeres	De 95 a 99 a�os	95	24	INE_Padron
2005	Mujeres	100 y m�s a�os	100	0	INE_Padron
2006	Hombres	De 0 a 4 a�os	0	616	INE_Padron
2006	Hombres	De 5 a 9 a�os	5	662	INE_Padron
2006	Hombres	De 10 a 14 a�os	10	742	INE_Padron
2006	Hombres	De 15 a 19 a�os	15	782	INE_Padron
2006	Hombres	De 20 a 24 a�os	20	771	INE_Padron
2006	Hombres	De 25 a 29 a�os	25	896	INE_Padron
2006	Hombres	De 30 a 34 a�os	30	906	INE_Padron
2006	Hombres	De 35 a 39 a�os	35	966	INE_Padron
2006	Hombres	De 40 a 44 a�os	40	931	INE_Padron
2006	Hombres	De 45 a 49 a�os	45	834	INE_Padron
2006	Hombres	De 50 a 54 a�os	50	663	INE_Padron
2006	Hombres	De 55 a 59 a�os	55	562	INE_Padron
2006	Hombres	De 60 a 64 a�os	60	520	INE_Padron
2006	Hombres	De 65 a 69 a�os	65	469	INE_Padron
2006	Hombres	De 70 a 74 a�os	70	545	INE_Padron
2006	Hombres	De 75 a 79 a�os	75	439	INE_Padron
2006	Hombres	De 80 a 84 a�os	80	247	INE_Padron
2006	Hombres	De 85 a 89 a�os	85	93	INE_Padron
2006	Hombres	De 90 a 94 a�os	90	26	INE_Padron
2006	Hombres	De 95 a 99 a�os	95	5	INE_Padron
2006	Hombres	100 y m�s a�os	100	0	INE_Padron
2006	Mujeres	De 0 a 4 a�os	0	563	INE_Padron
2006	Mujeres	De 5 a 9 a�os	5	608	INE_Padron
2006	Mujeres	De 10 a 14 a�os	10	710	INE_Padron
2006	Mujeres	De 15 a 19 a�os	15	708	INE_Padron
2006	Mujeres	De 20 a 24 a�os	20	765	INE_Padron
2006	Mujeres	De 25 a 29 a�os	25	802	INE_Padron
2006	Mujeres	De 30 a 34 a�os	30	899	INE_Padron
2006	Mujeres	De 35 a 39 a�os	35	944	INE_Padron
2006	Mujeres	De 40 a 44 a�os	40	929	INE_Padron
2006	Mujeres	De 45 a 49 a�os	45	807	INE_Padron
2006	Mujeres	De 50 a 54 a�os	50	622	INE_Padron
2006	Mujeres	De 55 a 59 a�os	55	559	INE_Padron
2006	Mujeres	De 60 a 64 a�os	60	559	INE_Padron
2006	Mujeres	De 65 a 69 a�os	65	535	INE_Padron
2006	Mujeres	De 70 a 74 a�os	70	621	INE_Padron
2006	Mujeres	De 75 a 79 a�os	75	534	INE_Padron
2006	Mujeres	De 80 a 84 a�os	80	435	INE_Padron
2006	Mujeres	De 85 a 89 a�os	85	187	INE_Padron
2006	Mujeres	De 90 a 94 a�os	90	90	INE_Padron
2006	Mujeres	De 95 a 99 a�os	95	21	INE_Padron
2006	Mujeres	100 y m�s a�os	100	1	INE_Padron
2007	Hombres	De 0 a 4 a�os	0	604	INE_Padron
2007	Hombres	De 5 a 9 a�os	5	672	INE_Padron
2007	Hombres	De 10 a 14 a�os	10	725	INE_Padron
2007	Hombres	De 15 a 19 a�os	15	797	INE_Padron
2007	Hombres	De 20 a 24 a�os	20	754	INE_Padron
2007	Hombres	De 25 a 29 a�os	25	895	INE_Padron
2007	Hombres	De 30 a 34 a�os	30	879	INE_Padron
2007	Hombres	De 35 a 39 a�os	35	928	INE_Padron
2007	Hombres	De 40 a 44 a�os	40	956	INE_Padron
2007	Hombres	De 45 a 49 a�os	45	883	INE_Padron
2007	Hombres	De 50 a 54 a�os	50	699	INE_Padron
2007	Hombres	De 55 a 59 a�os	55	570	INE_Padron
2007	Hombres	De 60 a 64 a�os	60	531	INE_Padron
2007	Hombres	De 65 a 69 a�os	65	454	INE_Padron
2007	Hombres	De 70 a 74 a�os	70	525	INE_Padron
2007	Hombres	De 75 a 79 a�os	75	451	INE_Padron
2007	Hombres	De 80 a 84 a�os	80	253	INE_Padron
2007	Hombres	De 85 a 89 a�os	85	114	INE_Padron
2007	Hombres	De 90 a 94 a�os	90	27	INE_Padron
2007	Hombres	De 95 a 99 a�os	95	7	INE_Padron
2007	Hombres	100 y m�s a�os	100	1	INE_Padron
2007	Mujeres	De 0 a 4 a�os	0	555	INE_Padron
2007	Mujeres	De 5 a 9 a�os	5	614	INE_Padron
2007	Mujeres	De 10 a 14 a�os	10	676	INE_Padron
2007	Mujeres	De 15 a 19 a�os	15	720	INE_Padron
2007	Mujeres	De 20 a 24 a�os	20	776	INE_Padron
2007	Mujeres	De 25 a 29 a�os	25	773	INE_Padron
2007	Mujeres	De 30 a 34 a�os	30	887	INE_Padron
2007	Mujeres	De 35 a 39 a�os	35	925	INE_Padron
2007	Mujeres	De 40 a 44 a�os	40	929	INE_Padron
2007	Mujeres	De 45 a 49 a�os	45	878	INE_Padron
2007	Mujeres	De 50 a 54 a�os	50	631	INE_Padron
2007	Mujeres	De 55 a 59 a�os	55	572	INE_Padron
2007	Mujeres	De 60 a 64 a�os	60	580	INE_Padron
2007	Mujeres	De 65 a 69 a�os	65	501	INE_Padron
2007	Mujeres	De 70 a 74 a�os	70	618	INE_Padron
2007	Mujeres	De 75 a 79 a�os	75	553	INE_Padron
2007	Mujeres	De 80 a 84 a�os	80	429	INE_Padron
2007	Mujeres	De 85 a 89 a�os	85	204	INE_Padron
2007	Mujeres	De 90 a 94 a�os	90	82	INE_Padron
2007	Mujeres	De 95 a 99 a�os	95	20	INE_Padron
2007	Mujeres	100 y m�s a�os	100	2	INE_Padron
2008	Hombres	De 0 a 4 a�os	0	604	INE_Padron
2008	Hombres	De 5 a 9 a�os	5	664	INE_Padron
2008	Hombres	De 10 a 14 a�os	10	729	INE_Padron
2008	Hombres	De 15 a 19 a�os	15	791	INE_Padron
2008	Hombres	De 20 a 24 a�os	20	778	INE_Padron
2008	Hombres	De 25 a 29 a�os	25	875	INE_Padron
2008	Hombres	De 30 a 34 a�os	30	867	INE_Padron
2008	Hombres	De 35 a 39 a�os	35	940	INE_Padron
2008	Hombres	De 40 a 44 a�os	40	963	INE_Padron
2008	Hombres	De 45 a 49 a�os	45	897	INE_Padron
2008	Hombres	De 50 a 54 a�os	50	739	INE_Padron
2008	Hombres	De 55 a 59 a�os	55	598	INE_Padron
2008	Hombres	De 60 a 64 a�os	60	543	INE_Padron
2008	Hombres	De 65 a 69 a�os	65	440	INE_Padron
2008	Hombres	De 70 a 74 a�os	70	513	INE_Padron
2008	Hombres	De 75 a 79 a�os	75	444	INE_Padron
2008	Hombres	De 80 a 84 a�os	80	283	INE_Padron
2008	Hombres	De 85 a 89 a�os	85	121	INE_Padron
2008	Hombres	De 90 a 94 a�os	90	24	INE_Padron
2008	Hombres	De 95 a 99 a�os	95	7	INE_Padron
2008	Hombres	100 y m�s a�os	100	2	INE_Padron
2008	Mujeres	De 0 a 4 a�os	0	555	INE_Padron
2008	Mujeres	De 5 a 9 a�os	5	613	INE_Padron
2008	Mujeres	De 10 a 14 a�os	10	674	INE_Padron
2008	Mujeres	De 15 a 19 a�os	15	735	INE_Padron
2008	Mujeres	De 20 a 24 a�os	20	726	INE_Padron
2008	Mujeres	De 25 a 29 a�os	25	806	INE_Padron
2008	Mujeres	De 30 a 34 a�os	30	872	INE_Padron
2008	Mujeres	De 35 a 39 a�os	35	932	INE_Padron
2008	Mujeres	De 40 a 44 a�os	40	919	INE_Padron
2008	Mujeres	De 45 a 49 a�os	45	911	INE_Padron
2008	Mujeres	De 50 a 54 a�os	50	673	INE_Padron
2008	Mujeres	De 55 a 59 a�os	55	560	INE_Padron
2008	Mujeres	De 60 a 64 a�os	60	583	INE_Padron
2008	Mujeres	De 65 a 69 a�os	65	518	INE_Padron
2008	Mujeres	De 70 a 74 a�os	70	584	INE_Padron
2008	Mujeres	De 75 a 79 a�os	75	576	INE_Padron
2008	Mujeres	De 80 a 84 a�os	80	412	INE_Padron
2008	Mujeres	De 85 a 89 a�os	85	240	INE_Padron
2008	Mujeres	De 90 a 94 a�os	90	77	INE_Padron
2008	Mujeres	De 95 a 99 a�os	95	21	INE_Padron
2008	Mujeres	100 y m�s a�os	100	2	INE_Padron
2009	Hombres	De 0 a 4 a�os	0	619	INE_Padron
2009	Hombres	De 5 a 9 a�os	5	643	INE_Padron
2009	Hombres	De 10 a 14 a�os	10	709	INE_Padron
2009	Hombres	De 15 a 19 a�os	15	787	INE_Padron
2009	Hombres	De 20 a 24 a�os	20	775	INE_Padron
2009	Hombres	De 25 a 29 a�os	25	842	INE_Padron
2009	Hombres	De 30 a 34 a�os	30	858	INE_Padron
2009	Hombres	De 35 a 39 a�os	35	934	INE_Padron
2009	Hombres	De 40 a 44 a�os	40	947	INE_Padron
2009	Hombres	De 45 a 49 a�os	45	910	INE_Padron
2009	Hombres	De 50 a 54 a�os	50	763	INE_Padron
2009	Hombres	De 55 a 59 a�os	55	613	INE_Padron
2009	Hombres	De 60 a 64 a�os	60	560	INE_Padron
2009	Hombres	De 65 a 69 a�os	65	468	INE_Padron
2009	Hombres	De 70 a 74 a�os	70	467	INE_Padron
2009	Hombres	De 75 a 79 a�os	75	446	INE_Padron
2009	Hombres	De 80 a 84 a�os	80	320	INE_Padron
2009	Hombres	De 85 a 89 a�os	85	126	INE_Padron
2009	Hombres	De 90 a 94 a�os	90	25	INE_Padron
2009	Hombres	De 95 a 99 a�os	95	8	INE_Padron
2009	Hombres	100 y m�s a�os	100	2	INE_Padron
2009	Mujeres	De 0 a 4 a�os	0	552	INE_Padron
2009	Mujeres	De 5 a 9 a�os	5	610	INE_Padron
2009	Mujeres	De 10 a 14 a�os	10	630	INE_Padron
2009	Mujeres	De 15 a 19 a�os	15	765	INE_Padron
2009	Mujeres	De 20 a 24 a�os	20	731	INE_Padron
2009	Mujeres	De 25 a 29 a�os	25	753	INE_Padron
2009	Mujeres	De 30 a 34 a�os	30	873	INE_Padron
2009	Mujeres	De 35 a 39 a�os	35	917	INE_Padron
2009	Mujeres	De 40 a 44 a�os	40	913	INE_Padron
2009	Mujeres	De 45 a 49 a�os	45	949	INE_Padron
2009	Mujeres	De 50 a 54 a�os	50	712	INE_Padron
2009	Mujeres	De 55 a 59 a�os	55	583	INE_Padron
2009	Mujeres	De 60 a 64 a�os	60	558	INE_Padron
2009	Mujeres	De 65 a 69 a�os	65	534	INE_Padron
2009	Mujeres	De 70 a 74 a�os	70	562	INE_Padron
2009	Mujeres	De 75 a 79 a�os	75	583	INE_Padron
2009	Mujeres	De 80 a 84 a�os	80	420	INE_Padron
2009	Mujeres	De 85 a 89 a�os	85	274	INE_Padron
2009	Mujeres	De 90 a 94 a�os	90	80	INE_Padron
2009	Mujeres	De 95 a 99 a�os	95	18	INE_Padron
2009	Mujeres	100 y m�s a�os	100	1	INE_Padron
2010	Hombres	De 0 a 4 a�os	0	617	INE_Padron
2010	Hombres	De 5 a 9 a�os	5	657	INE_Padron
2010	Hombres	De 10 a 14 a�os	10	685	INE_Padron
2010	Hombres	De 15 a 19 a�os	15	783	INE_Padron
2010	Hombres	De 20 a 24 a�os	20	771	INE_Padron
2010	Hombres	De 25 a 29 a�os	25	794	INE_Padron
2010	Hombres	De 30 a 34 a�os	30	886	INE_Padron
2010	Hombres	De 35 a 39 a�os	35	900	INE_Padron
2010	Hombres	De 40 a 44 a�os	40	975	INE_Padron
2010	Hombres	De 45 a 49 a�os	45	924	INE_Padron
2010	Hombres	De 50 a 54 a�os	50	802	INE_Padron
2010	Hombres	De 55 a 59 a�os	55	628	INE_Padron
2010	Hombres	De 60 a 64 a�os	60	570	INE_Padron
2010	Hombres	De 65 a 69 a�os	65	479	INE_Padron
2010	Hombres	De 70 a 74 a�os	70	437	INE_Padron
2010	Hombres	De 75 a 79 a�os	75	450	INE_Padron
2010	Hombres	De 80 a 84 a�os	80	317	INE_Padron
2010	Hombres	De 85 a 89 a�os	85	129	INE_Padron
2010	Hombres	De 90 a 94 a�os	90	36	INE_Padron
2010	Hombres	De 95 a 99 a�os	95	7	INE_Padron
2010	Hombres	100 y m�s a�os	100	1	INE_Padron
2010	Mujeres	De 0 a 4 a�os	0	558	INE_Padron
2010	Mujeres	De 5 a 9 a�os	5	598	INE_Padron
2010	Mujeres	De 10 a 14 a�os	10	616	INE_Padron
2010	Mujeres	De 15 a 19 a�os	15	772	INE_Padron
2010	Mujeres	De 20 a 24 a�os	20	718	INE_Padron
2010	Mujeres	De 25 a 29 a�os	25	759	INE_Padron
2010	Mujeres	De 30 a 34 a�os	30	811	INE_Padron
2010	Mujeres	De 35 a 39 a�os	35	941	INE_Padron
2010	Mujeres	De 40 a 44 a�os	40	949	INE_Padron
2010	Mujeres	De 45 a 49 a�os	45	918	INE_Padron
2010	Mujeres	De 50 a 54 a�os	50	771	INE_Padron
2010	Mujeres	De 55 a 59 a�os	55	593	INE_Padron
2010	Mujeres	De 60 a 64 a�os	60	565	INE_Padron
2010	Mujeres	De 65 a 69 a�os	65	562	INE_Padron
2010	Mujeres	De 70 a 74 a�os	70	515	INE_Padron
2010	Mujeres	De 75 a 79 a�os	75	602	INE_Padron
2010	Mujeres	De 80 a 84 a�os	80	412	INE_Padron
2010	Mujeres	De 85 a 89 a�os	85	296	INE_Padron
2010	Mujeres	De 90 a 94 a�os	90	86	INE_Padron
2010	Mujeres	De 95 a 99 a�os	95	16	INE_Padron
2010	Mujeres	100 y m�s a�os	100	1	INE_Padron
2011	Hombres	De 0 a 4 a�os	0	603	INE_Padron
2011	Hombres	De 5 a 9 a�os	5	653	INE_Padron
2011	Hombres	De 10 a 14 a�os	10	668	INE_Padron
2011	Hombres	De 15 a 19 a�os	15	760	INE_Padron
2011	Hombres	De 20 a 24 a�os	20	798	INE_Padron
2011	Hombres	De 25 a 29 a�os	25	746	INE_Padron
2011	Hombres	De 30 a 34 a�os	30	861	INE_Padron
2011	Hombres	De 35 a 39 a�os	35	909	INE_Padron
2011	Hombres	De 40 a 44 a�os	40	963	INE_Padron
2011	Hombres	De 45 a 49 a�os	45	942	INE_Padron
2011	Hombres	De 50 a 54 a�os	50	822	INE_Padron
2011	Hombres	De 55 a 59 a�os	55	651	INE_Padron
2011	Hombres	De 60 a 64 a�os	60	551	INE_Padron
2011	Hombres	De 65 a 69 a�os	65	491	INE_Padron
2011	Hombres	De 70 a 74 a�os	70	420	INE_Padron
2011	Hombres	De 75 a 79 a�os	75	460	INE_Padron
2011	Hombres	De 80 a 84 a�os	80	333	INE_Padron
2011	Hombres	De 85 a 89 a�os	85	142	INE_Padron
2011	Hombres	De 90 a 94 a�os	90	35	INE_Padron
2011	Hombres	De 95 a 99 a�os	95	8	INE_Padron
2011	Hombres	100 y m�s a�os	100	0	INE_Padron
2011	Mujeres	De 0 a 4 a�os	0	567	INE_Padron
2011	Mujeres	De 5 a 9 a�os	5	581	INE_Padron
2011	Mujeres	De 10 a 14 a�os	10	630	INE_Padron
2011	Mujeres	De 15 a 19 a�os	15	726	INE_Padron
2011	Mujeres	De 20 a 24 a�os	20	731	INE_Padron
2011	Mujeres	De 25 a 29 a�os	25	748	INE_Padron
2011	Mujeres	De 30 a 34 a�os	30	789	INE_Padron
2011	Mujeres	De 35 a 39 a�os	35	907	INE_Padron
2011	Mujeres	De 40 a 44 a�os	40	953	INE_Padron
2011	Mujeres	De 45 a 49 a�os	45	934	INE_Padron
2011	Mujeres	De 50 a 54 a�os	50	812	INE_Padron
2011	Mujeres	De 55 a 59 a�os	55	634	INE_Padron
2011	Mujeres	De 60 a 64 a�os	60	547	INE_Padron
2011	Mujeres	De 65 a 69 a�os	65	552	INE_Padron
2011	Mujeres	De 70 a 74 a�os	70	503	INE_Padron
2011	Mujeres	De 75 a 79 a�os	75	575	INE_Padron
2011	Mujeres	De 80 a 84 a�os	80	442	INE_Padron
2011	Mujeres	De 85 a 89 a�os	85	316	INE_Padron
2011	Mujeres	De 90 a 94 a�os	90	87	INE_Padron
2011	Mujeres	De 95 a 99 a�os	95	19	INE_Padron
2011	Mujeres	100 y m�s a�os	100	1	INE_Padron
2012	Hombres	De 0 a 4 a�os	0	581	INE_Padron
2012	Hombres	De 5 a 9 a�os	5	650	INE_Padron
2012	Hombres	De 10 a 14 a�os	10	669	INE_Padron
2012	Hombres	De 15 a 19 a�os	15	722	INE_Padron
2012	Hombres	De 20 a 24 a�os	20	814	INE_Padron
2012	Hombres	De 25 a 29 a�os	25	735	INE_Padron
2012	Hombres	De 30 a 34 a�os	30	862	INE_Padron
2012	Hombres	De 35 a 39 a�os	35	871	INE_Padron
2012	Hombres	De 40 a 44 a�os	40	933	INE_Padron
2012	Hombres	De 45 a 49 a�os	45	959	INE_Padron
2012	Hombres	De 50 a 54 a�os	50	859	INE_Padron
2012	Hombres	De 55 a 59 a�os	55	684	INE_Padron
2012	Hombres	De 60 a 64 a�os	60	557	INE_Padron
2012	Hombres	De 65 a 69 a�os	65	510	INE_Padron
2012	Hombres	De 70 a 74 a�os	70	404	INE_Padron
2012	Hombres	De 75 a 79 a�os	75	435	INE_Padron
2012	Hombres	De 80 a 84 a�os	80	340	INE_Padron
2012	Hombres	De 85 a 89 a�os	85	145	INE_Padron
2012	Hombres	De 90 a 94 a�os	90	51	INE_Padron
2012	Hombres	De 95 a 99 a�os	95	6	INE_Padron
2012	Hombres	100 y m�s a�os	100	1	INE_Padron
2012	Mujeres	De 0 a 4 a�os	0	564	INE_Padron
2012	Mujeres	De 5 a 9 a�os	5	569	INE_Padron
2012	Mujeres	De 10 a 14 a�os	10	639	INE_Padron
2012	Mujeres	De 15 a 19 a�os	15	687	INE_Padron
2012	Mujeres	De 20 a 24 a�os	20	734	INE_Padron
2012	Mujeres	De 25 a 29 a�os	25	759	INE_Padron
2012	Mujeres	De 30 a 34 a�os	30	754	INE_Padron
2012	Mujeres	De 35 a 39 a�os	35	903	INE_Padron
2012	Mujeres	De 40 a 44 a�os	40	928	INE_Padron
2012	Mujeres	De 45 a 49 a�os	45	927	INE_Padron
2012	Mujeres	De 50 a 54 a�os	50	880	INE_Padron
2012	Mujeres	De 55 a 59 a�os	55	634	INE_Padron
2012	Mujeres	De 60 a 64 a�os	60	561	INE_Padron
2012	Mujeres	De 65 a 69 a�os	65	564	INE_Padron
2012	Mujeres	De 70 a 74 a�os	70	482	INE_Padron
2012	Mujeres	De 75 a 79 a�os	75	568	INE_Padron
2012	Mujeres	De 80 a 84 a�os	80	454	INE_Padron
2012	Mujeres	De 85 a 89 a�os	85	314	INE_Padron
2012	Mujeres	De 90 a 94 a�os	90	108	INE_Padron
2012	Mujeres	De 95 a 99 a�os	95	15	INE_Padron
2012	Mujeres	100 y m�s a�os	100	4	INE_Padron
2013	Hombres	De 0 a 4 a�os	0	573	INE_Padron
2013	Hombres	De 5 a 9 a�os	5	628	INE_Padron
2013	Hombres	De 10 a 14 a�os	10	657	INE_Padron
2013	Hombres	De 15 a 19 a�os	15	724	INE_Padron
2013	Hombres	De 20 a 24 a�os	20	782	INE_Padron
2013	Hombres	De 25 a 29 a�os	25	743	INE_Padron
2013	Hombres	De 30 a 34 a�os	30	825	INE_Padron
2013	Hombres	De 35 a 39 a�os	35	841	INE_Padron
2013	Hombres	De 40 a 44 a�os	40	940	INE_Padron
2013	Hombres	De 45 a 49 a�os	45	955	INE_Padron
2013	Hombres	De 50 a 54 a�os	50	867	INE_Padron
2013	Hombres	De 55 a 59 a�os	55	715	INE_Padron
2013	Hombres	De 60 a 64 a�os	60	591	INE_Padron
2013	Hombres	De 65 a 69 a�os	65	523	INE_Padron
2013	Hombres	De 70 a 74 a�os	70	398	INE_Padron
2013	Hombres	De 75 a 79 a�os	75	435	INE_Padron
2013	Hombres	De 80 a 84 a�os	80	339	INE_Padron
2013	Hombres	De 85 a 89 a�os	85	159	INE_Padron
2013	Hombres	De 90 a 94 a�os	90	49	INE_Padron
2013	Hombres	De 95 a 99 a�os	95	7	INE_Padron
2013	Hombres	100 y m�s a�os	100	2	INE_Padron
2013	Mujeres	De 0 a 4 a�os	0	555	INE_Padron
2013	Mujeres	De 5 a 9 a�os	5	566	INE_Padron
2013	Mujeres	De 10 a 14 a�os	10	635	INE_Padron
2013	Mujeres	De 15 a 19 a�os	15	673	INE_Padron
2013	Mujeres	De 20 a 24 a�os	20	734	INE_Padron
2013	Mujeres	De 25 a 29 a�os	25	701	INE_Padron
2013	Mujeres	De 30 a 34 a�os	30	761	INE_Padron
2013	Mujeres	De 35 a 39 a�os	35	878	INE_Padron
2013	Mujeres	De 40 a 44 a�os	40	935	INE_Padron
2013	Mujeres	De 45 a 49 a�os	45	904	INE_Padron
2013	Mujeres	De 50 a 54 a�os	50	914	INE_Padron
2013	Mujeres	De 55 a 59 a�os	55	675	INE_Padron
2013	Mujeres	De 60 a 64 a�os	60	552	INE_Padron
2013	Mujeres	De 65 a 69 a�os	65	563	INE_Padron
2013	Mujeres	De 70 a 74 a�os	70	506	INE_Padron
2013	Mujeres	De 75 a 79 a�os	75	535	INE_Padron
2013	Mujeres	De 80 a 84 a�os	80	479	INE_Padron
2013	Mujeres	De 85 a 89 a�os	85	285	INE_Padron
2013	Mujeres	De 90 a 94 a�os	90	129	INE_Padron
2013	Mujeres	De 95 a 99 a�os	95	15	INE_Padron
2013	Mujeres	100 y m�s a�os	100	4	INE_Padron
2014	Hombres	De 0 a 4 a�os	0	542	INE_Padron
2014	Hombres	De 5 a 9 a�os	5	622	INE_Padron
2014	Hombres	De 10 a 14 a�os	10	645	INE_Padron
2014	Hombres	De 15 a 19 a�os	15	711	INE_Padron
2014	Hombres	De 20 a 24 a�os	20	776	INE_Padron
2014	Hombres	De 25 a 29 a�os	25	737	INE_Padron
2014	Hombres	De 30 a 34 a�os	30	784	INE_Padron
2014	Hombres	De 35 a 39 a�os	35	841	INE_Padron
2014	Hombres	De 40 a 44 a�os	40	920	INE_Padron
2014	Hombres	De 45 a 49 a�os	45	944	INE_Padron
2014	Hombres	De 50 a 54 a�os	50	885	INE_Padron
2014	Hombres	De 55 a 59 a�os	55	740	INE_Padron
2014	Hombres	De 60 a 64 a�os	60	595	INE_Padron
2014	Hombres	De 65 a 69 a�os	65	530	INE_Padron
2014	Hombres	De 70 a 74 a�os	70	434	INE_Padron
2014	Hombres	De 75 a 79 a�os	75	388	INE_Padron
2014	Hombres	De 80 a 84 a�os	80	335	INE_Padron
2014	Hombres	De 85 a 89 a�os	85	183	INE_Padron
2014	Hombres	De 90 a 94 a�os	90	46	INE_Padron
2014	Hombres	De 95 a 99 a�os	95	9	INE_Padron
2014	Hombres	100 y m�s a�os	100	2	INE_Padron
2014	Mujeres	De 0 a 4 a�os	0	524	INE_Padron
2014	Mujeres	De 5 a 9 a�os	5	571	INE_Padron
2014	Mujeres	De 10 a 14 a�os	10	619	INE_Padron
2014	Mujeres	De 15 a 19 a�os	15	623	INE_Padron
2014	Mujeres	De 20 a 24 a�os	20	762	INE_Padron
2014	Mujeres	De 25 a 29 a�os	25	704	INE_Padron
2014	Mujeres	De 30 a 34 a�os	30	712	INE_Padron
2014	Mujeres	De 35 a 39 a�os	35	879	INE_Padron
2014	Mujeres	De 40 a 44 a�os	40	916	INE_Padron
2014	Mujeres	De 45 a 49 a�os	45	905	INE_Padron
2014	Mujeres	De 50 a 54 a�os	50	944	INE_Padron
2014	Mujeres	De 55 a 59 a�os	55	702	INE_Padron
2014	Mujeres	De 60 a 64 a�os	60	577	INE_Padron
2014	Mujeres	De 65 a 69 a�os	65	542	INE_Padron
2014	Mujeres	De 70 a 74 a�os	70	530	INE_Padron
2014	Mujeres	De 75 a 79 a�os	75	504	INE_Padron
2014	Mujeres	De 80 a 84 a�os	80	497	INE_Padron
2014	Mujeres	De 85 a 89 a�os	85	271	INE_Padron
2014	Mujeres	De 90 a 94 a�os	90	154	INE_Padron
2014	Mujeres	De 95 a 99 a�os	95	15	INE_Padron
2014	Mujeres	100 y m�s a�os	100	2	INE_Padron
2015	Hombres	De 0 a 4 a�os	0	523	INE_Padron
2015	Hombres	De 5 a 9 a�os	5	614	INE_Padron
2015	Hombres	De 10 a 14 a�os	10	652	INE_Padron
2015	Hombres	De 15 a 19 a�os	15	672	INE_Padron
2015	Hombres	De 20 a 24 a�os	20	780	INE_Padron
2015	Hombres	De 25 a 29 a�os	25	742	INE_Padron
2015	Hombres	De 30 a 34 a�os	30	750	INE_Padron
2015	Hombres	De 35 a 39 a�os	35	853	INE_Padron
2015	Hombres	De 40 a 44 a�os	40	898	INE_Padron
2015	Hombres	De 45 a 49 a�os	45	963	INE_Padron
2015	Hombres	De 50 a 54 a�os	50	887	INE_Padron
2015	Hombres	De 55 a 59 a�os	55	775	INE_Padron
2015	Hombres	De 60 a 64 a�os	60	599	INE_Padron
2015	Hombres	De 65 a 69 a�os	65	537	INE_Padron
2015	Hombres	De 70 a 74 a�os	70	435	INE_Padron
2015	Hombres	De 75 a 79 a�os	75	365	INE_Padron
2015	Hombres	De 80 a 84 a�os	80	347	INE_Padron
2015	Hombres	De 85 a 89 a�os	85	186	INE_Padron
2015	Hombres	De 90 a 94 a�os	90	48	INE_Padron
2015	Hombres	De 95 a 99 a�os	95	10	INE_Padron
2015	Hombres	100 y m�s a�os	100	3	INE_Padron
2015	Mujeres	De 0 a 4 a�os	0	487	INE_Padron
2015	Mujeres	De 5 a 9 a�os	5	561	INE_Padron
2015	Mujeres	De 10 a 14 a�os	10	590	INE_Padron
2015	Mujeres	De 15 a 19 a�os	15	621	INE_Padron
2015	Mujeres	De 20 a 24 a�os	20	757	INE_Padron
2015	Mujeres	De 25 a 29 a�os	25	688	INE_Padron
2015	Mujeres	De 30 a 34 a�os	30	727	INE_Padron
2015	Mujeres	De 35 a 39 a�os	35	801	INE_Padron
2015	Mujeres	De 40 a 44 a�os	40	945	INE_Padron
2015	Mujeres	De 45 a 49 a�os	45	932	INE_Padron
2015	Mujeres	De 50 a 54 a�os	50	901	INE_Padron
2015	Mujeres	De 55 a 59 a�os	55	758	INE_Padron
2015	Mujeres	De 60 a 64 a�os	60	590	INE_Padron
2015	Mujeres	De 65 a 69 a�os	65	548	INE_Padron
2015	Mujeres	De 70 a 74 a�os	70	541	INE_Padron
2015	Mujeres	De 75 a 79 a�os	75	458	INE_Padron
2015	Mujeres	De 80 a 84 a�os	80	519	INE_Padron
2015	Mujeres	De 85 a 89 a�os	85	279	INE_Padron
2015	Mujeres	De 90 a 94 a�os	90	153	INE_Padron
2015	Mujeres	De 95 a 99 a�os	95	23	INE_Padron
2015	Mujeres	100 y m�s a�os	100	1	INE_Padron
2016	Hombres	De 0 a 4 a�os	0	510	INE_Padron
2016	Hombres	De 5 a 9 a�os	5	603	INE_Padron
2016	Hombres	De 10 a 14 a�os	10	642	INE_Padron
2016	Hombres	De 15 a 19 a�os	15	655	INE_Padron
2016	Hombres	De 20 a 24 a�os	20	741	INE_Padron
2016	Hombres	De 25 a 29 a�os	25	782	INE_Padron
2016	Hombres	De 30 a 34 a�os	30	702	INE_Padron
2016	Hombres	De 35 a 39 a�os	35	837	INE_Padron
2016	Hombres	De 40 a 44 a�os	40	889	INE_Padron
2016	Hombres	De 45 a 49 a�os	45	958	INE_Padron
2016	Hombres	De 50 a 54 a�os	50	909	INE_Padron
2016	Hombres	De 55 a 59 a�os	55	789	INE_Padron
2016	Hombres	De 60 a 64 a�os	60	628	INE_Padron
2016	Hombres	De 65 a 69 a�os	65	528	INE_Padron
2016	Hombres	De 70 a 74 a�os	70	451	INE_Padron
2016	Hombres	De 75 a 79 a�os	75	354	INE_Padron
2016	Hombres	De 80 a 84 a�os	80	336	INE_Padron
2016	Hombres	De 85 a 89 a�os	85	198	INE_Padron
2016	Hombres	De 90 a 94 a�os	90	48	INE_Padron
2016	Hombres	De 95 a 99 a�os	95	11	INE_Padron
2016	Hombres	100 y m�s a�os	100	2	INE_Padron
2016	Mujeres	De 0 a 4 a�os	0	473	INE_Padron
2016	Mujeres	De 5 a 9 a�os	5	562	INE_Padron
2016	Mujeres	De 10 a 14 a�os	10	574	INE_Padron
2016	Mujeres	De 15 a 19 a�os	15	630	INE_Padron
2016	Mujeres	De 20 a 24 a�os	20	708	INE_Padron
2016	Mujeres	De 25 a 29 a�os	25	687	INE_Padron
2016	Mujeres	De 30 a 34 a�os	30	713	INE_Padron
2016	Mujeres	De 35 a 39 a�os	35	787	INE_Padron
2016	Mujeres	De 40 a 44 a�os	40	888	INE_Padron
2016	Mujeres	De 45 a 49 a�os	45	941	INE_Padron
2016	Mujeres	De 50 a 54 a�os	50	907	INE_Padron
2016	Mujeres	De 55 a 59 a�os	55	805	INE_Padron
2016	Mujeres	De 60 a 64 a�os	60	620	INE_Padron
2016	Mujeres	De 65 a 69 a�os	65	532	INE_Padron
2016	Mujeres	De 70 a 74 a�os	70	532	INE_Padron
2016	Mujeres	De 75 a 79 a�os	75	460	INE_Padron
2016	Mujeres	De 80 a 84 a�os	80	486	INE_Padron
2016	Mujeres	De 85 a 89 a�os	85	307	INE_Padron
2016	Mujeres	De 90 a 94 a�os	90	153	INE_Padron
2016	Mujeres	De 95 a 99 a�os	95	24	INE_Padron
2016	Mujeres	100 y m�s a�os	100	3	INE_Padron
2017	Hombres	De 0 a 4 a�os	0	476	INE_Padron
2017	Hombres	De 5 a 9 a�os	5	571	INE_Padron
2017	Hombres	De 10 a 14 a�os	10	636	INE_Padron
2017	Hombres	De 15 a 19 a�os	15	663	INE_Padron
2017	Hombres	De 20 a 24 a�os	20	706	INE_Padron
2017	Hombres	De 25 a 29 a�os	25	774	INE_Padron
2017	Hombres	De 30 a 34 a�os	30	695	INE_Padron
2017	Hombres	De 35 a 39 a�os	35	819	INE_Padron
2017	Hombres	De 40 a 44 a�os	40	844	INE_Padron
2017	Hombres	De 45 a 49 a�os	45	924	INE_Padron
2017	Hombres	De 50 a 54 a�os	50	939	INE_Padron
2017	Hombres	De 55 a 59 a�os	55	828	INE_Padron
2017	Hombres	De 60 a 64 a�os	60	657	INE_Padron
2017	Hombres	De 65 a 69 a�os	65	531	INE_Padron
2017	Hombres	De 70 a 74 a�os	70	469	INE_Padron
2017	Hombres	De 75 a 79 a�os	75	345	INE_Padron
2017	Hombres	De 80 a 84 a�os	80	327	INE_Padron
2017	Hombres	De 85 a 89 a�os	85	211	INE_Padron
2017	Hombres	De 90 a 94 a�os	90	60	INE_Padron
2017	Hombres	De 95 a 99 a�os	95	9	INE_Padron
2017	Hombres	100 y m�s a�os	100	3	INE_Padron
2017	Mujeres	De 0 a 4 a�os	0	443	INE_Padron
2017	Mujeres	De 5 a 9 a�os	5	554	INE_Padron
2017	Mujeres	De 10 a 14 a�os	10	565	INE_Padron
2017	Mujeres	De 15 a 19 a�os	15	632	INE_Padron
2017	Mujeres	De 20 a 24 a�os	20	665	INE_Padron
2017	Mujeres	De 25 a 29 a�os	25	677	INE_Padron
2017	Mujeres	De 30 a 34 a�os	30	695	INE_Padron
2017	Mujeres	De 35 a 39 a�os	35	758	INE_Padron
2017	Mujeres	De 40 a 44 a�os	40	876	INE_Padron
2017	Mujeres	De 45 a 49 a�os	45	919	INE_Padron
2017	Mujeres	De 50 a 54 a�os	50	914	INE_Padron
2017	Mujeres	De 55 a 59 a�os	55	867	INE_Padron
2017	Mujeres	De 60 a 64 a�os	60	631	INE_Padron
2017	Mujeres	De 65 a 69 a�os	65	546	INE_Padron
2017	Mujeres	De 70 a 74 a�os	70	545	INE_Padron
2017	Mujeres	De 75 a 79 a�os	75	451	INE_Padron
2017	Mujeres	De 80 a 84 a�os	80	474	INE_Padron
2017	Mujeres	De 85 a 89 a�os	85	327	INE_Padron
2017	Mujeres	De 90 a 94 a�os	90	149	INE_Padron
2017	Mujeres	De 95 a 99 a�os	95	30	INE_Padron
2017	Mujeres	100 y m�s a�os	100	4	INE_Padron
2018	Hombres	De 0 a 4 a�os	0	449	INE_Padron
2018	Hombres	De 5 a 9 a�os	5	572	INE_Padron
2018	Hombres	De 10 a 14 a�os	10	603	INE_Padron
2018	Hombres	De 15 a 19 a�os	15	654	INE_Padron
2018	Hombres	De 20 a 24 a�os	20	699	INE_Padron
2018	Hombres	De 25 a 29 a�os	25	746	INE_Padron
2018	Hombres	De 30 a 34 a�os	30	695	INE_Padron
2018	Hombres	De 35 a 39 a�os	35	796	INE_Padron
2018	Hombres	De 40 a 44 a�os	40	818	INE_Padron
2018	Hombres	De 45 a 49 a�os	45	925	INE_Padron
2018	Hombres	De 50 a 54 a�os	50	937	INE_Padron
2018	Hombres	De 55 a 59 a�os	55	840	INE_Padron
2018	Hombres	De 60 a 64 a�os	60	690	INE_Padron
2018	Hombres	De 65 a 69 a�os	65	561	INE_Padron
2018	Hombres	De 70 a 74 a�os	70	474	INE_Padron
2018	Hombres	De 75 a 79 a�os	75	346	INE_Padron
2018	Hombres	De 80 a 84 a�os	80	321	INE_Padron
2018	Hombres	De 85 a 89 a�os	85	220	INE_Padron
2018	Hombres	De 90 a 94 a�os	90	68	INE_Padron
2018	Hombres	De 95 a 99 a�os	95	5	INE_Padron
2018	Hombres	100 y m�s a�os	100	4	INE_Padron
2018	Mujeres	De 0 a 4 a�os	0	403	INE_Padron
2018	Mujeres	De 5 a 9 a�os	5	541	INE_Padron
2018	Mujeres	De 10 a 14 a�os	10	556	INE_Padron
2018	Mujeres	De 15 a 19 a�os	15	619	INE_Padron
2018	Mujeres	De 20 a 24 a�os	20	658	INE_Padron
2018	Mujeres	De 25 a 29 a�os	25	654	INE_Padron
2018	Mujeres	De 30 a 34 a�os	30	642	INE_Padron
2018	Mujeres	De 35 a 39 a�os	35	760	INE_Padron
2018	Mujeres	De 40 a 44 a�os	40	856	INE_Padron
2018	Mujeres	De 45 a 49 a�os	45	923	INE_Padron
2018	Mujeres	De 50 a 54 a�os	50	897	INE_Padron
2018	Mujeres	De 55 a 59 a�os	55	898	INE_Padron
2018	Mujeres	De 60 a 64 a�os	60	668	INE_Padron
2018	Mujeres	De 65 a 69 a�os	65	543	INE_Padron
2018	Mujeres	De 70 a 74 a�os	70	540	INE_Padron
2018	Mujeres	De 75 a 79 a�os	75	476	INE_Padron
2018	Mujeres	De 80 a 84 a�os	80	446	INE_Padron
2018	Mujeres	De 85 a 89 a�os	85	355	INE_Padron
2018	Mujeres	De 90 a 94 a�os	90	127	INE_Padron
2018	Mujeres	De 95 a 99 a�os	95	42	INE_Padron
2018	Mujeres	100 y m�s a�os	100	4	INE_Padron
2019	Hombres	De 0 a 4 a�os	0	450	INE_Padron
2019	Hombres	De 5 a 9 a�os	5	548	INE_Padron
2019	Hombres	De 10 a 14 a�os	10	614	INE_Padron
2019	Hombres	De 15 a 19 a�os	15	642	INE_Padron
2019	Hombres	De 20 a 24 a�os	20	690	INE_Padron
2019	Hombres	De 25 a 29 a�os	25	718	INE_Padron
2019	Hombres	De 30 a 34 a�os	30	690	INE_Padron
2019	Hombres	De 35 a 39 a�os	35	753	INE_Padron
2019	Hombres	De 40 a 44 a�os	40	820	INE_Padron
2019	Hombres	De 45 a 49 a�os	45	897	INE_Padron
2019	Hombres	De 50 a 54 a�os	50	914	INE_Padron
2019	Hombres	De 55 a 59 a�os	55	857	INE_Padron
2019	Hombres	De 60 a 64 a�os	60	715	INE_Padron
2019	Hombres	De 65 a 69 a�os	65	571	INE_Padron
2019	Hombres	De 70 a 74 a�os	70	493	INE_Padron
2019	Hombres	De 75 a 79 a�os	75	380	INE_Padron
2019	Hombres	De 80 a 84 a�os	80	296	INE_Padron
2019	Hombres	De 85 a 89 a�os	85	204	INE_Padron
2019	Hombres	De 90 a 94 a�os	90	90	INE_Padron
2019	Hombres	De 95 a 99 a�os	95	7	INE_Padron
2019	Hombres	100 y m�s a�os	100	4	INE_Padron
2019	Mujeres	De 0 a 4 a�os	0	396	INE_Padron
2019	Mujeres	De 5 a 9 a�os	5	517	INE_Padron
2019	Mujeres	De 10 a 14 a�os	10	555	INE_Padron
2019	Mujeres	De 15 a 19 a�os	15	598	INE_Padron
2019	Mujeres	De 20 a 24 a�os	20	621	INE_Padron
2019	Mujeres	De 25 a 29 a�os	25	666	INE_Padron
2019	Mujeres	De 30 a 34 a�os	30	638	INE_Padron
2019	Mujeres	De 35 a 39 a�os	35	703	INE_Padron
2019	Mujeres	De 40 a 44 a�os	40	872	INE_Padron
2019	Mujeres	De 45 a 49 a�os	45	899	INE_Padron
2019	Mujeres	De 50 a 54 a�os	50	894	INE_Padron
2019	Mujeres	De 55 a 59 a�os	55	920	INE_Padron
2019	Mujeres	De 60 a 64 a�os	60	698	INE_Padron
2019	Mujeres	De 65 a 69 a�os	65	564	INE_Padron
2019	Mujeres	De 70 a 74 a�os	70	522	INE_Padron
2019	Mujeres	De 75 a 79 a�os	75	491	INE_Padron
2019	Mujeres	De 80 a 84 a�os	80	424	INE_Padron
2019	Mujeres	De 85 a 89 a�os	85	356	INE_Padron
2019	Mujeres	De 90 a 94 a�os	90	124	INE_Padron
2019	Mujeres	De 95 a 99 a�os	95	45	INE_Padron
2019	Mujeres	100 y m�s a�os	100	3	INE_Padron
2020	Hombres	De 0 a 4 a�os	0	458	INE_Padron
2020	Hombres	De 5 a 9 a�os	5	530	INE_Padron
2020	Hombres	De 10 a 14 a�os	10	608	INE_Padron
2020	Hombres	De 15 a 19 a�os	15	646	INE_Padron
2020	Hombres	De 20 a 24 a�os	20	655	INE_Padron
2020	Hombres	De 25 a 29 a�os	25	700	INE_Padron
2020	Hombres	De 30 a 34 a�os	30	676	INE_Padron
2020	Hombres	De 35 a 39 a�os	35	712	INE_Padron
2020	Hombres	De 40 a 44 a�os	40	820	INE_Padron
2020	Hombres	De 45 a 49 a�os	45	872	INE_Padron
2020	Hombres	De 50 a 54 a�os	50	942	INE_Padron
2020	Hombres	De 55 a 59 a�os	55	863	INE_Padron
2020	Hombres	De 60 a 64 a�os	60	744	INE_Padron
2020	Hombres	De 65 a 69 a�os	65	578	INE_Padron
2020	Hombres	De 70 a 74 a�os	70	507	INE_Padron
2020	Hombres	De 75 a 79 a�os	75	393	INE_Padron
2020	Hombres	De 80 a 84 a�os	80	283	INE_Padron
2020	Hombres	De 85 a 89 a�os	85	206	INE_Padron
2020	Hombres	De 90 a 94 a�os	90	89	INE_Padron
2020	Hombres	De 95 a 99 a�os	95	9	INE_Padron
2020	Hombres	100 y m�s a�os	100	2	INE_Padron
2020	Mujeres	De 0 a 4 a�os	0	391	INE_Padron
2020	Mujeres	De 5 a 9 a�os	5	485	INE_Padron
2020	Mujeres	De 10 a 14 a�os	10	553	INE_Padron
2020	Mujeres	De 15 a 19 a�os	15	575	INE_Padron
2020	Mujeres	De 20 a 24 a�os	20	636	INE_Padron
2020	Mujeres	De 25 a 29 a�os	25	679	INE_Padron
2020	Mujeres	De 30 a 34 a�os	30	593	INE_Padron
2020	Mujeres	De 35 a 39 a�os	35	710	INE_Padron
2020	Mujeres	De 40 a 44 a�os	40	799	INE_Padron
2020	Mujeres	De 45 a 49 a�os	45	917	INE_Padron
2020	Mujeres	De 50 a 54 a�os	50	917	INE_Padron
2020	Mujeres	De 55 a 59 a�os	55	882	INE_Padron
2020	Mujeres	De 60 a 64 a�os	60	747	INE_Padron
2020	Mujeres	De 65 a 69 a�os	65	587	INE_Padron
2020	Mujeres	De 70 a 74 a�os	70	529	INE_Padron
2020	Mujeres	De 75 a 79 a�os	75	502	INE_Padron
2020	Mujeres	De 80 a 84 a�os	80	389	INE_Padron
2020	Mujeres	De 85 a 89 a�os	85	376	INE_Padron
2020	Mujeres	De 90 a 94 a�os	90	132	INE_Padron
2020	Mujeres	De 95 a 99 a�os	95	43	INE_Padron
2020	Mujeres	100 y m�s a�os	100	4	INE_Padron
2021	Hombres	De 0 a 4 a�os	0	436	INE_Padron
2021	Hombres	De 5 a 9 a�os	5	521	INE_Padron
2021	Hombres	De 10 a 14 a�os	10	599	INE_Padron
2021	Hombres	De 15 a 19 a�os	15	630	INE_Padron
2021	Hombres	De 20 a 24 a�os	20	644	INE_Padron
2021	Hombres	De 25 a 29 a�os	25	668	INE_Padron
2021	Hombres	De 30 a 34 a�os	30	717	INE_Padron
2021	Hombres	De 35 a 39 a�os	35	671	INE_Padron
2021	Hombres	De 40 a 44 a�os	40	812	INE_Padron
2021	Hombres	De 45 a 49 a�os	45	866	INE_Padron
2021	Hombres	De 50 a 54 a�os	50	928	INE_Padron
2021	Hombres	De 55 a 59 a�os	55	878	INE_Padron
2021	Hombres	De 60 a 64 a�os	60	766	INE_Padron
2021	Hombres	De 65 a 69 a�os	65	602	INE_Padron
2021	Hombres	De 70 a 74 a�os	70	493	INE_Padron
2021	Hombres	De 75 a 79 a�os	75	403	INE_Padron
2021	Hombres	De 80 a 84 a�os	80	280	INE_Padron
2021	Hombres	De 85 a 89 a�os	85	202	INE_Padron
2021	Hombres	De 90 a 94 a�os	90	84	INE_Padron
2021	Hombres	De 95 a 99 a�os	95	12	INE_Padron
2021	Hombres	100 y m�s a�os	100	2	INE_Padron
2021	Mujeres	De 0 a 4 a�os	0	379	INE_Padron
2021	Mujeres	De 5 a 9 a�os	5	464	INE_Padron
2021	Mujeres	De 10 a 14 a�os	10	564	INE_Padron
2021	Mujeres	De 15 a 19 a�os	15	565	INE_Padron
2021	Mujeres	De 20 a 24 a�os	20	626	INE_Padron
2021	Mujeres	De 25 a 29 a�os	25	660	INE_Padron
2021	Mujeres	De 30 a 34 a�os	30	599	INE_Padron
2021	Mujeres	De 35 a 39 a�os	35	683	INE_Padron
2021	Mujeres	De 40 a 44 a�os	40	802	INE_Padron
2021	Mujeres	De 45 a 49 a�os	45	865	INE_Padron
2021	Mujeres	De 50 a 54 a�os	50	929	INE_Padron
2021	Mujeres	De 55 a 59 a�os	55	903	INE_Padron
2021	Mujeres	De 60 a 64 a�os	60	793	INE_Padron
2021	Mujeres	De 65 a 69 a�os	65	619	INE_Padron
2021	Mujeres	De 70 a 74 a�os	70	521	INE_Padron
2021	Mujeres	De 75 a 79 a�os	75	494	INE_Padron
2021	Mujeres	De 80 a 84 a�os	80	394	INE_Padron
2021	Mujeres	De 85 a 89 a�os	85	359	INE_Padron
2021	Mujeres	De 90 a 94 a�os	90	154	INE_Padron
2021	Mujeres	De 95 a 99 a�os	95	42	INE_Padron
2021	Mujeres	100 y m�s a�os	100	4	INE_Padron
2022	Hombres	De 0 a 4 a�os	0	410	INE_Padron
2022	Hombres	De 5 a 9 a�os	5	483	INE_Padron
2022	Hombres	De 10 a 14 a�os	10	576	INE_Padron
2022	Hombres	De 15 a 19 a�os	15	629	INE_Padron
2022	Hombres	De 20 a 24 a�os	20	652	INE_Padron
2022	Hombres	De 25 a 29 a�os	25	652	INE_Padron
2022	Hombres	De 30 a 34 a�os	30	721	INE_Padron
2022	Hombres	De 35 a 39 a�os	35	659	INE_Padron
2022	Hombres	De 40 a 44 a�os	40	796	INE_Padron
2022	Hombres	De 45 a 49 a�os	45	837	INE_Padron
2022	Hombres	De 50 a 54 a�os	50	899	INE_Padron
2022	Hombres	De 55 a 59 a�os	55	911	INE_Padron
2022	Hombres	De 60 a 64 a�os	60	809	INE_Padron
2022	Hombres	De 65 a 69 a�os	65	636	INE_Padron
2022	Hombres	De 70 a 74 a�os	70	493	INE_Padron
2022	Hombres	De 75 a 79 a�os	75	406	INE_Padron
2022	Hombres	De 80 a 84 a�os	80	276	INE_Padron
2022	Hombres	De 85 a 89 a�os	85	198	INE_Padron
2022	Hombres	De 90 a 94 a�os	90	84	INE_Padron
2022	Hombres	De 95 a 99 a�os	95	19	INE_Padron
2022	Hombres	100 y m�s a�os	100	3	INE_Padron
2022	Mujeres	De 0 a 4 a�os	0	355	INE_Padron
2022	Mujeres	De 5 a 9 a�os	5	442	INE_Padron
2022	Mujeres	De 10 a 14 a�os	10	559	INE_Padron
2022	Mujeres	De 15 a 19 a�os	15	559	INE_Padron
2022	Mujeres	De 20 a 24 a�os	20	629	INE_Padron
2022	Mujeres	De 25 a 29 a�os	25	635	INE_Padron
2022	Mujeres	De 30 a 34 a�os	30	595	INE_Padron
2022	Mujeres	De 35 a 39 a�os	35	674	INE_Padron
2022	Mujeres	De 40 a 44 a�os	40	761	INE_Padron
2022	Mujeres	De 45 a 49 a�os	45	876	INE_Padron
2022	Mujeres	De 50 a 54 a�os	50	910	INE_Padron
2022	Mujeres	De 55 a 59 a�os	55	898	INE_Padron
2022	Mujeres	De 60 a 64 a�os	60	858	INE_Padron
2022	Mujeres	De 65 a 69 a�os	65	637	INE_Padron
2022	Mujeres	De 70 a 74 a�os	70	527	INE_Padron
2022	Mujeres	De 75 a 79 a�os	75	502	INE_Padron
2022	Mujeres	De 80 a 84 a�os	80	388	INE_Padron
2022	Mujeres	De 85 a 89 a�os	85	337	INE_Padron
2022	Mujeres	De 90 a 94 a�os	90	157	INE_Padron
2022	Mujeres	De 95 a 99 a�os	95	36	INE_Padron
2022	Mujeres	100 y m�s a�os	100	6	INE_Padron
\.


--
-- Data for Name: poblacion_joven_ine_2003_2022; Type: TABLE DATA; Schema: public; Owner: montilla_user
--

COPY public.poblacion_joven_ine_2003_2022 (anio, poblacion_joven, poblacion_total, porcentaje_joven, fuente) FROM stdin;
2003	4845	23245	20.84319208431921	INE
2004	4781	23223	20.587348749084956	INE
2005	4709	23391	20.131674575691505	INE
2006	4724	23574	20.039026045643503	INE
2007	4715	23650	19.93657505285412	INE
2008	4711	23811	19.78497333165344	INE
2009	4653	23840	19.517617449664428	INE
2010	4597	23907	19.228677793114986	INE
2011	4509	23870	18.889819857561793	INE
2012	4451	23836	18.67343514012418	INE
2013	4357	23752	18.34371842371169	INE
2014	4313	23622	18.258403183473035	INE
2015	4260	23519	18.113015009141545	INE
2016	4203	23365	17.98844425422641	INE
2017	4117	23209	17.73880822094877	INE
2018	4030	23031	17.498154661108938	INE
2019	3935	22859	17.21422634410954	INE
2020	3891	22739	17.111570429658297	INE
2021	3793	22633	16.758715150444043	INE
2022	3756	22490	16.700755891507338	INE
\.


--
-- Data for Name: poblacion_joven_ine_2021_2025; Type: TABLE DATA; Schema: public; Owner: montilla_user
--

COPY public.poblacion_joven_ine_2021_2025 (anio, poblacion_joven, poblacion_total, porcentaje_joven, fuente) FROM stdin;
2021	3792	22617	16.766149356678607	INE_Censo
2022	3744	22439	16.68523552742992	INE_Censo
2023	3677	22300	16.48878923766816	INE_Censo
2024	3649	22315	16.35222944207932	INE_Censo
2025	3601	22192	16.226568132660418	INE_Censo
\.


--
-- Data for Name: poblacion_joven_ine_serie; Type: TABLE DATA; Schema: public; Owner: montilla_user
--

COPY public.poblacion_joven_ine_serie (anio, poblacion_joven, poblacion_total, porcentaje_joven, fuente) FROM stdin;
2003	4845	23245	20.84319208431921	INE
2004	4781	23223	20.587348749084956	INE
2005	4709	23391	20.131674575691505	INE
2006	4724	23574	20.039026045643503	INE
2007	4715	23650	19.93657505285412	INE
2008	4711	23811	19.78497333165344	INE
2009	4653	23840	19.517617449664428	INE
2010	4597	23907	19.228677793114986	INE
2011	4509	23870	18.889819857561793	INE
2012	4451	23836	18.67343514012418	INE
2013	4357	23752	18.34371842371169	INE
2014	4313	23622	18.258403183473035	INE
2015	4260	23519	18.113015009141545	INE
2016	4203	23365	17.98844425422641	INE
2017	4117	23209	17.73880822094877	INE
2018	4030	23031	17.498154661108938	INE
2019	3935	22859	17.21422634410954	INE
2020	3891	22739	17.111570429658297	INE
2021	3793	22633	16.758715150444043	INE
2022	3756	22490	16.700755891507338	INE
2023	3677	22300	16.48878923766816	INE_Censo
2024	3649	22315	16.35222944207932	INE_Censo
2025	3601	22192	16.226568132660418	INE_Censo
\.


--
-- Data for Name: poblacion_joven_ine_stack; Type: TABLE DATA; Schema: public; Owner: montilla_user
--

COPY public.poblacion_joven_ine_stack (anio, poblacion_joven, poblacion_total, porcentaje_joven, fuente) FROM stdin;
2003	4845	23245	20.84319208431921	INE
2004	4781	23223	20.587348749084956	INE
2005	4709	23391	20.131674575691505	INE
2006	4724	23574	20.039026045643503	INE
2007	4715	23650	19.93657505285412	INE
2008	4711	23811	19.78497333165344	INE
2009	4653	23840	19.517617449664428	INE
2010	4597	23907	19.228677793114986	INE
2011	4509	23870	18.889819857561793	INE
2012	4451	23836	18.67343514012418	INE
2013	4357	23752	18.34371842371169	INE
2014	4313	23622	18.258403183473035	INE
2015	4260	23519	18.113015009141545	INE
2016	4203	23365	17.98844425422641	INE
2017	4117	23209	17.73880822094877	INE
2018	4030	23031	17.498154661108938	INE
2019	3935	22859	17.21422634410954	INE
2020	3891	22739	17.111570429658297	INE
2021	3793	22633	16.758715150444043	INE
2021	3792	22617	16.766149356678607	INE_Censo
2022	3756	22490	16.700755891507338	INE
2022	3744	22439	16.68523552742992	INE_Censo
2023	3677	22300	16.48878923766816	INE_Censo
2024	3649	22315	16.35222944207932	INE_Censo
2025	3601	22192	16.226568132660418	INE_Censo
\.


--
-- Data for Name: saldo_migratorio_comparativa; Type: TABLE DATA; Schema: public; Owner: montilla_user
--

COPY public.saldo_migratorio_comparativa (anio, saldo_migratorio, fuente) FROM stdin;
2003	-1	IECA
2004	125	IECA
2005	113	IECA
2006	73	IECA
2007	119	IECA
2008	24	IECA
2009	73	IECA
2010	-40	IECA
2011	-38	IECA
2012	-59	IECA
2013	-49	IECA
2014	-36	IECA
2015	-89	IECA
2016	-112	IECA
2017	-70	IECA
2018	-79	IECA
2019	-17	IECA
2020	-13	IECA
2021	-45	IECA
2021	-129	INE
2022	-17	INE
2023	120	INE
2024	-8	INE
\.


--
-- Data for Name: saldo_migratorio_ine_2021_2024; Type: TABLE DATA; Schema: public; Owner: montilla_user
--

COPY public.saldo_migratorio_ine_2021_2024 (anio, saldo_migratorio, fuente) FROM stdin;
2021	-129	INE
2022	-17	INE
2023	120	INE
2024	-8	INE
\.


--
-- Data for Name: tasa_saldo_migratorio_comparativa; Type: TABLE DATA; Schema: public; Owner: montilla_user
--

COPY public.tasa_saldo_migratorio_comparativa (anio, saldo_migratorio, fuente, poblacion_total, tasa_saldo_1000) FROM stdin;
2003	-1	IECA	23245	-0.04302000430200043
2004	125	IECA	23223	5.382594841321104
2005	113	IECA	23391	4.830917874396135
2006	73	IECA	23574	3.096631882582506
2007	119	IECA	23650	5.031712473572939
2008	24	IECA	23811	1.0079375078745116
2009	73	IECA	23840	3.0620805369127515
2010	-40	IECA	23907	-1.6731501233948216
2011	-38	IECA	23870	-1.591956430666108
2012	-59	IECA	23836	-2.4752475247524752
2013	-49	IECA	23752	-2.062984169754126
2014	-36	IECA	23622	-1.524003048006096
2015	-89	IECA	23519	-3.7841744972150178
2016	-112	IECA	23365	-4.793494543120051
2017	-70	IECA	23209	-3.016071351630833
2018	-79	IECA	23031	-3.4301593504407104
2019	-17	IECA	22859	-0.7436895752220132
2020	-13	IECA	22739	-0.5717050002198866
2021	-45	IECA	22633	-1.9882472495913048
2021	-129	INE	22633	-5.699642115495074
2022	-17	INE	22490	-0.755891507336594
2023	120	INE	22300	5.381165919282512
2024	-8	INE	22315	-0.35850324893569346
\.


--
-- Name: idx_defunciones_montilla_anio; Type: INDEX; Schema: public; Owner: montilla_user
--

CREATE INDEX idx_defunciones_montilla_anio ON public.defunciones_montilla USING btree (anio);


--
-- Name: idx_indice_envejecimiento_forecast_2032_anio; Type: INDEX; Schema: public; Owner: montilla_user
--

CREATE INDEX idx_indice_envejecimiento_forecast_2032_anio ON public.indice_envejecimiento_forecast_2032 USING btree (anio);


--
-- Name: idx_indice_envejecimiento_ieca_anio; Type: INDEX; Schema: public; Owner: montilla_user
--

CREATE INDEX idx_indice_envejecimiento_ieca_anio ON public.indice_envejecimiento_ieca USING btree (anio);


--
-- Name: idx_nacimientos_montilla_anio; Type: INDEX; Schema: public; Owner: montilla_user
--

CREATE INDEX idx_nacimientos_montilla_anio ON public.nacimientos_montilla USING btree (anio);


--
-- Name: idx_paro_anio; Type: INDEX; Schema: public; Owner: montilla_user
--

CREATE INDEX idx_paro_anio ON public.paro_registrado_montilla_sexo USING btree (anio);


--
-- Name: idx_paro_sexo; Type: INDEX; Schema: public; Owner: montilla_user
--

CREATE INDEX idx_paro_sexo ON public.paro_registrado_montilla_sexo USING btree (sexo);


--
-- PostgreSQL database dump complete
--

\unrestrict 2r2afXVeVX11JnUESHcYarlYN82RDvK0ZxOwb7whvcEGy2afxchd4cofR21aa8U

