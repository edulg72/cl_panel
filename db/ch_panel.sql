--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.6
-- Dumped by pg_dump version 9.5.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry, geography, and raster spatial types and functions';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: cities; Type: TABLE; Schema: public; Owner: waze
--

CREATE TABLE cities (
    id integer NOT NULL,
    name character varying(75),
    geom geometry(MultiPolygon,4326),
    state_id integer
);


ALTER TABLE cities OWNER TO waze;

--
-- Name: countries; Type: TABLE; Schema: public; Owner: waze
--

CREATE TABLE countries (
    gid integer NOT NULL,
    gadmid smallint,
    iso character varying(5),
    name_engli character varying(50),
    name_iso character varying(54),
    name_fao character varying(50),
    name_local character varying(54),
    name_obsol character varying(150),
    name_varia character varying(160),
    name_nonla character varying(50),
    name_frenc character varying(50),
    name_spani character varying(50),
    name_russi character varying(50),
    name_arabi character varying(50),
    name_chine character varying(50),
    waspartof character varying(100),
    contains character varying(50),
    sovereign character varying(40),
    iso2 character varying(4),
    www character varying(2),
    fips character varying(6),
    ison numeric,
    validfr character varying(12),
    validto character varying(10),
    andyid numeric,
    pop2000 numeric,
    sqkm numeric,
    popsqkm numeric,
    unregion1 character varying(254),
    unregion2 character varying(254),
    developing numeric,
    cis numeric,
    transition numeric,
    oecd numeric,
    wbregion character varying(254),
    wbincome character varying(254),
    wbdebt character varying(254),
    wbother character varying(254),
    ceeac numeric,
    cemac numeric,
    ceplg numeric,
    comesa numeric,
    eac numeric,
    ecowas numeric,
    igad numeric,
    ioc numeric,
    mru numeric,
    sacu numeric,
    uemoa numeric,
    uma numeric,
    palop numeric,
    parta numeric,
    cacm numeric,
    eurasec numeric,
    agadir numeric,
    saarc numeric,
    asean numeric,
    nafta numeric,
    gcc numeric,
    csn numeric,
    caricom numeric,
    eu numeric,
    can numeric,
    acp numeric,
    landlocked numeric,
    aosis numeric,
    sids numeric,
    islands numeric,
    ldc numeric,
    shape_leng numeric,
    shape_area numeric,
    geom geometry(MultiPolygon,4326)
);


ALTER TABLE countries OWNER TO waze;

--
-- Name: countries_gid_seq; Type: SEQUENCE; Schema: public; Owner: waze
--

CREATE SEQUENCE countries_gid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE countries_gid_seq OWNER TO waze;

--
-- Name: countries_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: waze
--

ALTER SEQUENCE countries_gid_seq OWNED BY countries.gid;


--
-- Name: mp; Type: TABLE; Schema: public; Owner: waze
--

CREATE TABLE mp (
    id character varying(20) NOT NULL,
    resolved_by integer,
    resolved_on timestamp with time zone,
    weight integer,
    "position" geometry(Point,4326),
    resolution integer,
    city_id integer,
    type integer
);


ALTER TABLE mp OWNER TO waze;

--
-- Name: places; Type: TABLE; Schema: public; Owner: waze
--

CREATE TABLE places (
    id character varying(50) NOT NULL,
    name character varying(100),
    street_id integer,
    created_on timestamp with time zone,
    created_by integer,
    updated_on timestamp with time zone,
    updated_by integer,
    "position" geometry(Point,4326),
    lock integer,
    approved boolean,
    residential boolean,
    category character varying(40),
    ad_locked boolean,
    city_id character varying(7)
);


ALTER TABLE places OWNER TO waze;

--
-- Name: pu; Type: TABLE; Schema: public; Owner: waze
--

CREATE TABLE pu (
    id character varying(60) NOT NULL,
    created_by integer,
    created_on timestamp with time zone,
    "position" geometry(Point,4326),
    staff boolean,
    city_id integer,
    place_id character varying(50),
    type character varying(20),
    subtype character varying(20)
);


ALTER TABLE pu OWNER TO waze;

--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: waze
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE schema_migrations OWNER TO waze;

--
-- Name: states; Type: TABLE; Schema: public; Owner: waze
--

CREATE TABLE states (
    id integer NOT NULL,
    name character varying(75),
    abbreviation character varying(15) NOT NULL,
    geom geometry(MultiPolygon,4326)
);


ALTER TABLE states OWNER TO waze;

--
-- Name: updates; Type: TABLE; Schema: public; Owner: waze
--

CREATE TABLE updates (
    updated_at timestamp with time zone,
    object character varying(20) NOT NULL
);


ALTER TABLE updates OWNER TO waze;

--
-- Name: ur; Type: TABLE; Schema: public; Owner: waze
--

CREATE TABLE ur (
    id integer NOT NULL,
    comments integer,
    last_comment text,
    last_comment_on timestamp with time zone,
    last_comment_by integer,
    first_comment_on timestamp with time zone,
    resolved_by integer,
    resolved_on timestamp with time zone,
    created_on timestamp with time zone,
    "position" geometry(Point,4326),
    resolution integer,
    city_id integer,
    type integer
);


ALTER TABLE ur OWNER TO waze;

--
-- Name: users; Type: TABLE; Schema: public; Owner: waze
--

CREATE TABLE users (
    id integer NOT NULL,
    username character varying(50),
    rank integer
);


ALTER TABLE users OWNER TO waze;

--
-- Name: vw_mp; Type: MATERIALIZED VIEW; Schema: public; Owner: waze
--

CREATE MATERIALIZED VIEW vw_mp AS
 SELECT mp.id,
    mp.resolved_by,
    mp.resolved_on,
    mp.weight,
    st_x(mp."position") AS longitude,
    st_y(mp."position") AS latitude,
    mp.resolution,
    mp.type AS type_mp,
    mp.city_id
   FROM mp
  WITH NO DATA;


ALTER TABLE vw_mp OWNER TO waze;

--
-- Name: vw_places; Type: TABLE; Schema: public; Owner: waze
--

CREATE TABLE vw_places (
    id character varying(50),
    name character varying(100),
    street_id integer,
    created_on timestamp without time zone,
    created_by integer,
    updated_on timestamp without time zone,
    updated_by integer,
    longitude double precision,
    latitude double precision,
    lock integer,
    approved boolean,
    residential boolean,
    category character varying(40),
    ad_locked boolean,
    city_id character varying(7)
);


ALTER TABLE vw_places OWNER TO waze;

--
-- Name: vw_pu; Type: MATERIALIZED VIEW; Schema: public; Owner: waze
--

CREATE MATERIALIZED VIEW vw_pu AS
 SELECT p.id,
    pu.created_by,
    pu.created_on,
    st_x(pu."position") AS longitude,
    st_y(pu."position") AS latitude,
    pu.staff,
    COALESCE(p.name, '[No Name]'::character varying) AS name,
    pu.type AS type_pu,
    p.category,
    pu.subtype,
    pu.city_id
   FROM places p,
    pu
  WHERE ((p.id)::text = (pu.place_id)::text)
  WITH NO DATA;


ALTER TABLE vw_pu OWNER TO waze;

--
-- Name: vw_ur; Type: MATERIALIZED VIEW; Schema: public; Owner: waze
--

CREATE MATERIALIZED VIEW vw_ur AS
 SELECT ur.id,
    ur.comments,
    ur.last_comment,
    ur.last_comment_on,
    ur.last_comment_by,
    ur.first_comment_on,
    ur.resolved_by,
    ur.resolved_on,
    ur.created_on,
    st_x(ur."position") AS longitude,
    st_y(ur."position") AS latitude,
    ur.resolution,
    ur.city_id,
    ur.type AS type_ur
   FROM ur
  WITH NO DATA;


ALTER TABLE vw_ur OWNER TO waze;

--
-- Name: gid; Type: DEFAULT; Schema: public; Owner: waze
--

ALTER TABLE ONLY countries ALTER COLUMN gid SET DEFAULT nextval('countries_gid_seq'::regclass);


--
-- Name: cities_pkey; Type: CONSTRAINT; Schema: public; Owner: waze
--

ALTER TABLE ONLY cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);


--
-- Name: states_pkey; Type: CONSTRAINT; Schema: public; Owner: waze
--

ALTER TABLE ONLY states
    ADD CONSTRAINT states_pkey PRIMARY KEY (id);


--
-- Name: updates_pkey; Type: CONSTRAINT; Schema: public; Owner: waze
--

ALTER TABLE ONLY updates
    ADD CONSTRAINT updates_pkey PRIMARY KEY (object);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: waze
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

