--
-- PostgreSQL database dump
--

-- Dumped from database version 10.1
-- Dumped by pg_dump version 10.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
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


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: cache; Type: TABLE; Schema: public; Owner: gidrovik-admin
--

CREATE TABLE cache (
    key character varying(255) NOT NULL,
    value text NOT NULL,
    expiration bigint NOT NULL
);


ALTER TABLE cache OWNER TO "gidrovik-admin";

--
-- Name: cache_locks; Type: TABLE; Schema: public; Owner: gidrovik-admin
--

CREATE TABLE cache_locks (
    key character varying(255) NOT NULL,
    owner character varying(255) NOT NULL,
    expiration bigint NOT NULL
);


ALTER TABLE cache_locks OWNER TO "gidrovik-admin";

--
-- Name: categories; Type: TABLE; Schema: public; Owner: gidrovik-admin
--

CREATE TABLE categories (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    slug character varying(255) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE categories OWNER TO "gidrovik-admin";

--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: gidrovik-admin
--

CREATE SEQUENCE categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE categories_id_seq OWNER TO "gidrovik-admin";

--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gidrovik-admin
--

ALTER SEQUENCE categories_id_seq OWNED BY categories.id;


--
-- Name: category_characteristic; Type: TABLE; Schema: public; Owner: gidrovik-admin
--

CREATE TABLE category_characteristic (
    id bigint NOT NULL,
    category_id bigint NOT NULL,
    characteristic_id bigint NOT NULL,
    is_required boolean DEFAULT false NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE category_characteristic OWNER TO "gidrovik-admin";

--
-- Name: category_characteristic_id_seq; Type: SEQUENCE; Schema: public; Owner: gidrovik-admin
--

CREATE SEQUENCE category_characteristic_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE category_characteristic_id_seq OWNER TO "gidrovik-admin";

--
-- Name: category_characteristic_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gidrovik-admin
--

ALTER SEQUENCE category_characteristic_id_seq OWNED BY category_characteristic.id;


--
-- Name: characteristics; Type: TABLE; Schema: public; Owner: gidrovik-admin
--

CREATE TABLE characteristics (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    slug character varying(255) NOT NULL,
    type character varying(30) NOT NULL,
    unit character varying(255),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE characteristics OWNER TO "gidrovik-admin";

--
-- Name: characteristics_id_seq; Type: SEQUENCE; Schema: public; Owner: gidrovik-admin
--

CREATE SEQUENCE characteristics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE characteristics_id_seq OWNER TO "gidrovik-admin";

--
-- Name: characteristics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gidrovik-admin
--

ALTER SEQUENCE characteristics_id_seq OWNED BY characteristics.id;


--
-- Name: countries; Type: TABLE; Schema: public; Owner: gidrovik-admin
--

CREATE TABLE countries (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    code character varying(3),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE countries OWNER TO "gidrovik-admin";

--
-- Name: countries_id_seq; Type: SEQUENCE; Schema: public; Owner: gidrovik-admin
--

CREATE SEQUENCE countries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE countries_id_seq OWNER TO "gidrovik-admin";

--
-- Name: countries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gidrovik-admin
--

ALTER SEQUENCE countries_id_seq OWNED BY countries.id;


--
-- Name: diameters; Type: TABLE; Schema: public; Owner: gidrovik-admin
--

CREATE TABLE diameters (
    id bigint NOT NULL,
    value integer NOT NULL,
    unit character varying(255) DEFAULT 'mm'::character varying NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE diameters OWNER TO "gidrovik-admin";

--
-- Name: diameters_id_seq; Type: SEQUENCE; Schema: public; Owner: gidrovik-admin
--

CREATE SEQUENCE diameters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE diameters_id_seq OWNER TO "gidrovik-admin";

--
-- Name: diameters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gidrovik-admin
--

ALTER SEQUENCE diameters_id_seq OWNED BY diameters.id;


--
-- Name: failed_jobs; Type: TABLE; Schema: public; Owner: gidrovik-admin
--

CREATE TABLE failed_jobs (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    connection character varying(255) NOT NULL,
    queue character varying(255) NOT NULL,
    payload text NOT NULL,
    exception text NOT NULL,
    failed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE failed_jobs OWNER TO "gidrovik-admin";

--
-- Name: failed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: gidrovik-admin
--

CREATE SEQUENCE failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE failed_jobs_id_seq OWNER TO "gidrovik-admin";

--
-- Name: failed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gidrovik-admin
--

ALTER SEQUENCE failed_jobs_id_seq OWNED BY failed_jobs.id;


--
-- Name: job_batches; Type: TABLE; Schema: public; Owner: gidrovik-admin
--

CREATE TABLE job_batches (
    id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    total_jobs integer NOT NULL,
    pending_jobs integer NOT NULL,
    failed_jobs integer NOT NULL,
    failed_job_ids text NOT NULL,
    options text,
    cancelled_at integer,
    created_at integer NOT NULL,
    finished_at integer
);


ALTER TABLE job_batches OWNER TO "gidrovik-admin";

--
-- Name: jobs; Type: TABLE; Schema: public; Owner: gidrovik-admin
--

CREATE TABLE jobs (
    id bigint NOT NULL,
    queue character varying(255) NOT NULL,
    payload text NOT NULL,
    attempts smallint NOT NULL,
    reserved_at integer,
    available_at integer NOT NULL,
    created_at integer NOT NULL
);


ALTER TABLE jobs OWNER TO "gidrovik-admin";

--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: gidrovik-admin
--

CREATE SEQUENCE jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE jobs_id_seq OWNER TO "gidrovik-admin";

--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gidrovik-admin
--

ALTER SEQUENCE jobs_id_seq OWNED BY jobs.id;


--
-- Name: locations; Type: TABLE; Schema: public; Owner: gidrovik-admin
--

CREATE TABLE locations (
    id bigint NOT NULL,
    rack_id bigint NOT NULL,
    number integer NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE locations OWNER TO "gidrovik-admin";

--
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: gidrovik-admin
--

CREATE SEQUENCE locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE locations_id_seq OWNER TO "gidrovik-admin";

--
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gidrovik-admin
--

ALTER SEQUENCE locations_id_seq OWNED BY locations.id;


--
-- Name: manufacturers; Type: TABLE; Schema: public; Owner: gidrovik-admin
--

CREATE TABLE manufacturers (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE manufacturers OWNER TO "gidrovik-admin";

--
-- Name: manufacturers_id_seq; Type: SEQUENCE; Schema: public; Owner: gidrovik-admin
--

CREATE SEQUENCE manufacturers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE manufacturers_id_seq OWNER TO "gidrovik-admin";

--
-- Name: manufacturers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gidrovik-admin
--

ALTER SEQUENCE manufacturers_id_seq OWNED BY manufacturers.id;


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: gidrovik-admin
--

CREATE TABLE migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);


ALTER TABLE migrations OWNER TO "gidrovik-admin";

--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: gidrovik-admin
--

CREATE SEQUENCE migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE migrations_id_seq OWNER TO "gidrovik-admin";

--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gidrovik-admin
--

ALTER SEQUENCE migrations_id_seq OWNED BY migrations.id;


--
-- Name: passkeys; Type: TABLE; Schema: public; Owner: gidrovik-admin
--

CREATE TABLE passkeys (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    credential_id character varying(255) NOT NULL,
    credential json NOT NULL,
    last_used_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE passkeys OWNER TO "gidrovik-admin";

--
-- Name: passkeys_id_seq; Type: SEQUENCE; Schema: public; Owner: gidrovik-admin
--

CREATE SEQUENCE passkeys_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE passkeys_id_seq OWNER TO "gidrovik-admin";

--
-- Name: passkeys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gidrovik-admin
--

ALTER SEQUENCE passkeys_id_seq OWNED BY passkeys.id;


--
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: gidrovik-admin
--

CREATE TABLE password_reset_tokens (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone
);


ALTER TABLE password_reset_tokens OWNER TO "gidrovik-admin";

--
-- Name: product_characteristic_values; Type: TABLE; Schema: public; Owner: gidrovik-admin
--

CREATE TABLE product_characteristic_values (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    characteristic_id bigint NOT NULL,
    value text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE product_characteristic_values OWNER TO "gidrovik-admin";

--
-- Name: product_characteristic_values_id_seq; Type: SEQUENCE; Schema: public; Owner: gidrovik-admin
--

CREATE SEQUENCE product_characteristic_values_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE product_characteristic_values_id_seq OWNER TO "gidrovik-admin";

--
-- Name: product_characteristic_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gidrovik-admin
--

ALTER SEQUENCE product_characteristic_values_id_seq OWNED BY product_characteristic_values.id;


--
-- Name: product_connections; Type: TABLE; Schema: public; Owner: gidrovik-admin
--

CREATE TABLE product_connections (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    "position" smallint NOT NULL,
    standard_id bigint,
    diameter_id bigint,
    thread_id bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    end_type character varying(50)
);


ALTER TABLE product_connections OWNER TO "gidrovik-admin";

--
-- Name: product_connections_id_seq; Type: SEQUENCE; Schema: public; Owner: gidrovik-admin
--

CREATE SEQUENCE product_connections_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE product_connections_id_seq OWNER TO "gidrovik-admin";

--
-- Name: product_connections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gidrovik-admin
--

ALTER SEQUENCE product_connections_id_seq OWNED BY product_connections.id;


--
-- Name: product_location; Type: TABLE; Schema: public; Owner: gidrovik-admin
--

CREATE TABLE product_location (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    location_id bigint NOT NULL,
    quantity numeric(12,3) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE product_location OWNER TO "gidrovik-admin";

--
-- Name: product_location_id_seq; Type: SEQUENCE; Schema: public; Owner: gidrovik-admin
--

CREATE SEQUENCE product_location_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE product_location_id_seq OWNER TO "gidrovik-admin";

--
-- Name: product_location_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gidrovik-admin
--

ALTER SEQUENCE product_location_id_seq OWNED BY product_location.id;


--
-- Name: product_types; Type: TABLE; Schema: public; Owner: gidrovik-admin
--

CREATE TABLE product_types (
    id bigint NOT NULL,
    category_id bigint NOT NULL,
    name character varying(255) NOT NULL,
    slug character varying(255) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE product_types OWNER TO "gidrovik-admin";

--
-- Name: product_types_id_seq; Type: SEQUENCE; Schema: public; Owner: gidrovik-admin
--

CREATE SEQUENCE product_types_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE product_types_id_seq OWNER TO "gidrovik-admin";

--
-- Name: product_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gidrovik-admin
--

ALTER SEQUENCE product_types_id_seq OWNED BY product_types.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: gidrovik-admin
--

CREATE TABLE products (
    id bigint NOT NULL,
    category_id bigint NOT NULL,
    product_type_id bigint,
    name character varying(255) NOT NULL,
    sku character varying(255) NOT NULL,
    angle smallint,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    manufacturer_id bigint,
    country_id bigint,
    unit character varying(20) DEFAULT 'шт.'::character varying NOT NULL,
    minimum_stock numeric(12,3)
);


ALTER TABLE products OWNER TO "gidrovik-admin";

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: gidrovik-admin
--

CREATE SEQUENCE products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE products_id_seq OWNER TO "gidrovik-admin";

--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gidrovik-admin
--

ALTER SEQUENCE products_id_seq OWNED BY products.id;


--
-- Name: racks; Type: TABLE; Schema: public; Owner: gidrovik-admin
--

CREATE TABLE racks (
    id bigint NOT NULL,
    code character varying(10) NOT NULL,
    name character varying(255),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE racks OWNER TO "gidrovik-admin";

--
-- Name: racks_id_seq; Type: SEQUENCE; Schema: public; Owner: gidrovik-admin
--

CREATE SEQUENCE racks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE racks_id_seq OWNER TO "gidrovik-admin";

--
-- Name: racks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gidrovik-admin
--

ALTER SEQUENCE racks_id_seq OWNED BY racks.id;


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: gidrovik-admin
--

CREATE TABLE sessions (
    id character varying(255) NOT NULL,
    user_id bigint,
    ip_address character varying(45),
    user_agent text,
    payload text NOT NULL,
    last_activity integer NOT NULL
);


ALTER TABLE sessions OWNER TO "gidrovik-admin";

--
-- Name: standards; Type: TABLE; Schema: public; Owner: gidrovik-admin
--

CREATE TABLE standards (
    id bigint NOT NULL,
    code character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE standards OWNER TO "gidrovik-admin";

--
-- Name: standards_id_seq; Type: SEQUENCE; Schema: public; Owner: gidrovik-admin
--

CREATE SEQUENCE standards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE standards_id_seq OWNER TO "gidrovik-admin";

--
-- Name: standards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gidrovik-admin
--

ALTER SEQUENCE standards_id_seq OWNED BY standards.id;


--
-- Name: stock_movements; Type: TABLE; Schema: public; Owner: gidrovik-admin
--

CREATE TABLE stock_movements (
    id bigint NOT NULL,
    product_id bigint NOT NULL,
    from_location_id bigint,
    to_location_id bigint,
    quantity numeric(12,3) NOT NULL,
    type character varying(30) NOT NULL,
    comment text,
    user_id bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE stock_movements OWNER TO "gidrovik-admin";

--
-- Name: stock_movements_id_seq; Type: SEQUENCE; Schema: public; Owner: gidrovik-admin
--

CREATE SEQUENCE stock_movements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE stock_movements_id_seq OWNER TO "gidrovik-admin";

--
-- Name: stock_movements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gidrovik-admin
--

ALTER SEQUENCE stock_movements_id_seq OWNED BY stock_movements.id;


--
-- Name: threads; Type: TABLE; Schema: public; Owner: gidrovik-admin
--

CREATE TABLE threads (
    id bigint NOT NULL,
    system character varying(20) NOT NULL,
    designation character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE threads OWNER TO "gidrovik-admin";

--
-- Name: threads_id_seq; Type: SEQUENCE; Schema: public; Owner: gidrovik-admin
--

CREATE SEQUENCE threads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE threads_id_seq OWNER TO "gidrovik-admin";

--
-- Name: threads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gidrovik-admin
--

ALTER SEQUENCE threads_id_seq OWNED BY threads.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: gidrovik-admin
--

CREATE TABLE users (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    email_verified_at timestamp(0) without time zone,
    password character varying(255) NOT NULL,
    remember_token character varying(100),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    two_factor_secret text,
    two_factor_recovery_codes text,
    two_factor_confirmed_at timestamp(0) without time zone,
    role character varying(255) DEFAULT 'viewer'::character varying NOT NULL
);


ALTER TABLE users OWNER TO "gidrovik-admin";

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: gidrovik-admin
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE users_id_seq OWNER TO "gidrovik-admin";

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gidrovik-admin
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: categories id; Type: DEFAULT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


--
-- Name: category_characteristic id; Type: DEFAULT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY category_characteristic ALTER COLUMN id SET DEFAULT nextval('category_characteristic_id_seq'::regclass);


--
-- Name: characteristics id; Type: DEFAULT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY characteristics ALTER COLUMN id SET DEFAULT nextval('characteristics_id_seq'::regclass);


--
-- Name: countries id; Type: DEFAULT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY countries ALTER COLUMN id SET DEFAULT nextval('countries_id_seq'::regclass);


--
-- Name: diameters id; Type: DEFAULT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY diameters ALTER COLUMN id SET DEFAULT nextval('diameters_id_seq'::regclass);


--
-- Name: failed_jobs id; Type: DEFAULT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY failed_jobs ALTER COLUMN id SET DEFAULT nextval('failed_jobs_id_seq'::regclass);


--
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY jobs ALTER COLUMN id SET DEFAULT nextval('jobs_id_seq'::regclass);


--
-- Name: locations id; Type: DEFAULT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY locations ALTER COLUMN id SET DEFAULT nextval('locations_id_seq'::regclass);


--
-- Name: manufacturers id; Type: DEFAULT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY manufacturers ALTER COLUMN id SET DEFAULT nextval('manufacturers_id_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY migrations ALTER COLUMN id SET DEFAULT nextval('migrations_id_seq'::regclass);


--
-- Name: passkeys id; Type: DEFAULT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY passkeys ALTER COLUMN id SET DEFAULT nextval('passkeys_id_seq'::regclass);


--
-- Name: product_characteristic_values id; Type: DEFAULT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY product_characteristic_values ALTER COLUMN id SET DEFAULT nextval('product_characteristic_values_id_seq'::regclass);


--
-- Name: product_connections id; Type: DEFAULT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY product_connections ALTER COLUMN id SET DEFAULT nextval('product_connections_id_seq'::regclass);


--
-- Name: product_location id; Type: DEFAULT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY product_location ALTER COLUMN id SET DEFAULT nextval('product_location_id_seq'::regclass);


--
-- Name: product_types id; Type: DEFAULT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY product_types ALTER COLUMN id SET DEFAULT nextval('product_types_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY products ALTER COLUMN id SET DEFAULT nextval('products_id_seq'::regclass);


--
-- Name: racks id; Type: DEFAULT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY racks ALTER COLUMN id SET DEFAULT nextval('racks_id_seq'::regclass);


--
-- Name: standards id; Type: DEFAULT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY standards ALTER COLUMN id SET DEFAULT nextval('standards_id_seq'::regclass);


--
-- Name: stock_movements id; Type: DEFAULT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY stock_movements ALTER COLUMN id SET DEFAULT nextval('stock_movements_id_seq'::regclass);


--
-- Name: threads id; Type: DEFAULT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY threads ALTER COLUMN id SET DEFAULT nextval('threads_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Data for Name: cache; Type: TABLE DATA; Schema: public; Owner: gidrovik-admin
--

COPY cache (key, value, expiration) FROM stdin;
gidrovik-cache-05aec360595897d1dff33c3b5c75fa60:timer	i:1792575436;	1792575436
gidrovik-cache-05aec360595897d1dff33c3b5c75fa60	i:1;	1792575436
\.


--
-- Data for Name: cache_locks; Type: TABLE DATA; Schema: public; Owner: gidrovik-admin
--

COPY cache_locks (key, owner, expiration) FROM stdin;
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: gidrovik-admin
--

COPY categories (id, name, slug, is_active, created_at, updated_at) FROM stdin;
1	Фитинги	fittings	t	2026-10-12 07:39:40	2026-10-12 07:39:40
3	Адаптеры	adapters	t	2026-10-15 09:33:37	2026-10-15 09:33:37
4	Хомуты	clamp	t	2026-10-16 06:45:10	2026-10-16 06:45:10
6	Трубки пневматические	pneumatic_tube	t	2026-10-19 02:49:24	2026-10-19 02:49:39
2	Муфты	ferrules	t	2026-10-12 08:09:33	2026-10-19 03:01:49
7	Рукава	hoses	t	2026-10-19 03:01:56	2026-10-19 03:01:56
\.


--
-- Data for Name: category_characteristic; Type: TABLE DATA; Schema: public; Owner: gidrovik-admin
--

COPY category_characteristic (id, category_id, characteristic_id, is_required, sort_order, created_at, updated_at) FROM stdin;
2	1	3	f	0	2026-10-14 04:19:31	2026-10-14 04:19:31
1	1	2	f	0	2026-10-14 03:48:01	2026-10-14 04:19:31
5	2	3	f	0	2026-10-14 06:35:17	2026-10-14 06:35:17
\.


--
-- Data for Name: characteristics; Type: TABLE DATA; Schema: public; Owner: gidrovik-admin
--

COPY characteristics (id, name, slug, type, unit, is_active, created_at, updated_at) FROM stdin;
2	O-Ring	o-ring	boolean	\N	t	2026-10-14 03:47:03	2026-10-14 03:47:41
3	Interlock	interlock	boolean	\N	t	2026-10-14 04:19:25	2026-10-14 04:19:25
\.


--
-- Data for Name: countries; Type: TABLE DATA; Schema: public; Owner: gidrovik-admin
--

COPY countries (id, name, code, is_active, created_at, updated_at) FROM stdin;
1	Италия	\N	t	2026-10-13 08:49:57	2026-10-13 08:49:57
2	Германия	\N	t	2026-10-13 08:50:06	2026-10-13 08:50:06
\.


--
-- Data for Name: diameters; Type: TABLE DATA; Schema: public; Owner: gidrovik-admin
--

COPY diameters (id, value, unit, is_active, created_at, updated_at) FROM stdin;
1	6	mm	t	2026-10-12 08:48:02	2026-10-12 08:48:02
2	8	mm	t	2026-10-14 02:24:38	2026-10-14 02:24:38
3	10	mm	t	2026-10-14 02:24:45	2026-10-14 02:24:45
4	12	mm	t	2026-10-14 02:24:49	2026-10-14 02:24:49
5	16	mm	t	2026-10-14 02:24:53	2026-10-14 02:24:53
6	20	mm	t	2026-10-14 02:24:57	2026-10-14 02:24:57
7	25	mm	t	2026-10-14 02:25:01	2026-10-14 02:25:01
8	32	mm	t	2026-10-14 02:25:04	2026-10-14 02:25:04
9	38	mm	t	2026-10-14 02:25:10	2026-10-14 02:25:10
10	50	mm	t	2026-10-14 02:25:15	2026-10-14 02:25:15
11	4	mm	t	2026-10-14 02:25:48	2026-10-14 02:25:48
12	5	mm	t	2026-10-14 02:25:52	2026-10-14 02:25:52
13	60	mm	t	2026-10-19 03:23:49	2026-10-19 03:23:49
\.


--
-- Data for Name: failed_jobs; Type: TABLE DATA; Schema: public; Owner: gidrovik-admin
--

COPY failed_jobs (id, uuid, connection, queue, payload, exception, failed_at) FROM stdin;
\.


--
-- Data for Name: job_batches; Type: TABLE DATA; Schema: public; Owner: gidrovik-admin
--

COPY job_batches (id, name, total_jobs, pending_jobs, failed_jobs, failed_job_ids, options, cancelled_at, created_at, finished_at) FROM stdin;
\.


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: gidrovik-admin
--

COPY jobs (id, queue, payload, attempts, reserved_at, available_at, created_at) FROM stdin;
\.


--
-- Data for Name: locations; Type: TABLE DATA; Schema: public; Owner: gidrovik-admin
--

COPY locations (id, rack_id, number, created_at, updated_at) FROM stdin;
1	1	1	2026-10-09 05:00:58	2026-10-09 05:00:58
2	1	2	2026-10-09 05:01:01	2026-10-09 05:01:01
3	1	3	2026-10-09 05:01:03	2026-10-09 05:01:03
4	1	4	2026-10-09 05:01:04	2026-10-09 05:01:04
5	1	5	2026-10-09 05:01:06	2026-10-09 05:01:06
6	1	6	2026-10-09 05:01:07	2026-10-09 05:01:07
7	1	7	2026-10-09 05:01:08	2026-10-09 05:01:08
8	1	8	2026-10-09 05:01:11	2026-10-09 05:01:11
9	1	9	2026-10-09 05:01:12	2026-10-09 05:01:12
10	1	10	2026-10-09 05:01:13	2026-10-09 05:01:13
11	1	11	2026-10-09 05:01:23	2026-10-09 05:01:23
12	1	12	2026-10-09 05:01:25	2026-10-09 05:01:25
13	1	13	2026-10-09 05:01:26	2026-10-09 05:01:26
14	1	14	2026-10-09 05:01:28	2026-10-09 05:01:28
15	1	15	2026-10-09 05:01:29	2026-10-09 05:01:29
16	1	16	2026-10-09 05:01:30	2026-10-09 05:01:30
17	1	17	2026-10-09 05:01:32	2026-10-09 05:01:32
18	1	18	2026-10-09 05:01:33	2026-10-09 05:01:33
19	1	19	2026-10-09 05:01:34	2026-10-09 05:01:34
20	1	20	2026-10-09 05:01:36	2026-10-09 05:01:36
21	1	21	2026-10-09 05:01:37	2026-10-09 05:01:37
22	1	22	2026-10-09 05:01:38	2026-10-09 05:01:38
23	1	23	2026-10-09 05:01:40	2026-10-09 05:01:40
24	1	24	2026-10-09 05:01:41	2026-10-09 05:01:41
25	1	25	2026-10-09 05:01:48	2026-10-09 05:01:48
26	2	1	2026-10-12 07:15:01	2026-10-12 07:15:01
27	2	2	2026-10-12 07:15:04	2026-10-12 07:15:04
28	2	3	2026-10-12 07:15:55	2026-10-12 07:15:55
29	2	4	2026-10-12 07:15:58	2026-10-12 07:15:58
30	2	5	2026-10-12 07:16:03	2026-10-12 07:16:03
31	2	6	2026-10-12 07:16:05	2026-10-12 07:16:05
32	2	7	2026-10-12 07:16:08	2026-10-12 07:16:08
33	2	8	2026-10-12 07:16:10	2026-10-12 07:16:10
34	2	9	2026-10-12 07:16:12	2026-10-12 07:16:12
35	2	10	2026-10-12 07:16:15	2026-10-12 07:16:15
36	2	11	2026-10-12 07:16:17	2026-10-12 07:16:17
37	2	12	2026-10-12 07:16:19	2026-10-12 07:16:19
38	2	13	2026-10-12 07:16:20	2026-10-12 07:16:20
39	2	14	2026-10-12 07:16:23	2026-10-12 07:16:23
40	2	15	2026-10-12 07:16:24	2026-10-12 07:16:24
41	2	16	2026-10-12 07:16:25	2026-10-12 07:16:25
42	2	17	2026-10-12 07:16:28	2026-10-12 07:16:28
43	2	18	2026-10-12 07:16:35	2026-10-12 07:16:35
44	2	19	2026-10-12 07:16:38	2026-10-12 07:16:38
45	2	20	2026-10-12 07:16:40	2026-10-12 07:16:40
46	2	21	2026-10-12 07:16:42	2026-10-12 07:16:42
47	2	22	2026-10-12 07:16:43	2026-10-12 07:16:43
48	2	23	2026-10-12 07:16:44	2026-10-12 07:16:44
49	2	24	2026-10-12 07:16:46	2026-10-12 07:16:46
50	2	25	2026-10-12 07:16:47	2026-10-12 07:16:47
51	2	26	2026-10-12 07:16:50	2026-10-12 07:16:50
53	3	1	2026-10-12 07:37:04	2026-10-12 07:37:04
54	3	2	2026-10-12 07:37:19	2026-10-12 07:37:19
55	3	3	2026-10-12 07:37:22	2026-10-12 07:37:22
56	3	4	2026-10-12 07:37:23	2026-10-12 07:37:23
57	3	5	2026-10-12 07:37:25	2026-10-12 07:37:25
58	3	6	2026-10-12 07:37:26	2026-10-12 07:37:26
59	4	1	2026-10-12 07:37:57	2026-10-12 07:37:57
60	4	2	2026-10-12 07:37:59	2026-10-12 07:37:59
61	4	3	2026-10-12 07:38:01	2026-10-12 07:38:01
62	4	4	2026-10-12 07:38:02	2026-10-12 07:38:02
63	4	5	2026-10-12 07:38:03	2026-10-12 07:38:03
64	4	6	2026-10-12 07:38:05	2026-10-12 07:38:05
65	4	7	2026-10-12 07:38:06	2026-10-12 07:38:06
66	4	8	2026-10-12 07:38:09	2026-10-12 07:38:09
67	4	9	2026-10-12 07:38:10	2026-10-12 07:38:10
68	4	10	2026-10-12 07:38:12	2026-10-12 07:38:12
69	4	11	2026-10-12 07:38:14	2026-10-12 07:38:14
70	4	12	2026-10-12 07:38:16	2026-10-12 07:38:16
73	6	1	2026-10-16 08:04:08	2026-10-16 08:04:08
74	6	2	2026-10-16 08:04:18	2026-10-16 08:04:18
75	6	3	2026-10-16 08:04:20	2026-10-16 08:04:20
76	6	4	2026-10-16 08:04:24	2026-10-16 08:04:24
77	6	5	2026-10-16 08:04:26	2026-10-16 08:04:26
78	6	6	2026-10-16 08:04:30	2026-10-16 08:04:30
79	6	7	2026-10-16 08:04:32	2026-10-16 08:04:32
80	6	8	2026-10-16 08:04:35	2026-10-16 08:04:35
81	6	9	2026-10-16 08:04:37	2026-10-16 08:04:37
82	6	10	2026-10-16 08:04:41	2026-10-16 08:04:41
\.


--
-- Data for Name: manufacturers; Type: TABLE DATA; Schema: public; Owner: gidrovik-admin
--

COPY manufacturers (id, name, is_active, created_at, updated_at) FROM stdin;
1	Vitillo	t	2026-10-13 08:49:21	2026-10-13 08:49:21
2	Alfagomma	t	2026-10-13 08:49:33	2026-10-13 08:49:33
3	Parker	t	2026-10-14 03:24:18	2026-10-14 03:24:18
4	Gates	t	2026-10-14 03:24:24	2026-10-14 03:24:24
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: gidrovik-admin
--

COPY migrations (id, migration, batch) FROM stdin;
1	0001_01_01_000000_create_users_table	1
2	0001_01_01_000001_create_cache_table	1
3	0001_01_01_000002_create_jobs_table	1
4	2024_01_01_000000_create_passkeys_table	1
5	2025_08_14_170933_add_two_factor_columns_to_users_table	1
6	2026_10_07_014558_create_categories_table	1
7	2026_10_07_014651_create_product_types_table	1
8	2026_10_07_014700_create_characteristics_table	1
9	2026_10_07_014701_create_category_characteristics_table	1
10	2026_10_07_014723_create_standards_table	1
11	2026_10_07_014740_create_diameters_table	1
12	2026_10_07_014807_create_threads_table	1
13	2026_10_07_014824_create_products_table	1
14	2026_10_07_014825_create_product_characteristic_values_table	1
15	2026_10_07_014917_create_product_connections_table	1
16	2026_10_07_014935_create_racks_table	1
17	2026_10_07_014946_create_locations_table	1
18	2026_10_07_015012_create_product_location_table	1
19	2026_10_07_015828_create_stock_movements_table	1
20	2026_10_13_025957_create_manufacturers_table	2
21	2026_10_13_025958_create_countries_table	2
22	2026_10_13_025959_add_manufacturer_country_unit_and_minimum_stock_to_products_table	2
23	2026_10_13_030000_add_end_type_to_product_connections_table	2
24	2026_10_13_030001_change_quantity_columns_to_decimal_in_product_location_table	2
25	2026_10_13_030002_change_quantity_column_to_decimal_in_stock_movements_table	2
26	2026_12_15_000001_add_indexes_to_products_table	3
27	2026_12_15_000002_add_indexes_to_product_location_table	3
28	2026_12_15_000003_add_indexes_to_stock_movements_table	3
29	2026_10_21_000001_add_role_to_users_table	4
\.


--
-- Data for Name: passkeys; Type: TABLE DATA; Schema: public; Owner: gidrovik-admin
--

COPY passkeys (id, user_id, name, credential_id, credential, last_used_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: gidrovik-admin
--

COPY password_reset_tokens (email, token, created_at) FROM stdin;
\.


--
-- Data for Name: product_characteristic_values; Type: TABLE DATA; Schema: public; Owner: gidrovik-admin
--

COPY product_characteristic_values (id, product_id, characteristic_id, value, created_at, updated_at) FROM stdin;
2	29	3	1	2026-10-14 04:24:28	2026-10-14 04:24:28
3	30	3	1	2026-10-14 04:26:51	2026-10-14 04:26:51
4	33	3	1	2026-10-14 06:42:37	2026-10-14 06:42:37
5	43	2	1	2026-10-14 08:30:56	2026-10-14 08:30:56
6	43	3	1	2026-10-14 08:30:56	2026-10-14 08:30:56
7	44	3	1	2026-10-14 08:30:56	2026-10-14 08:30:56
8	45	3	1	2026-10-14 08:30:56	2026-10-14 08:30:56
9	46	3	1	2026-10-14 08:30:56	2026-10-14 08:30:56
10	47	2	1	2026-10-14 08:30:56	2026-10-14 08:30:56
11	47	3	1	2026-10-14 08:30:56	2026-10-14 08:30:56
12	48	2	1	2026-10-14 08:30:56	2026-10-14 08:30:56
13	48	3	1	2026-10-14 08:30:56	2026-10-14 08:30:56
14	49	3	1	2026-10-14 08:30:56	2026-10-14 08:30:56
15	50	3	1	2026-10-14 08:30:56	2026-10-14 08:30:56
16	51	2	1	2026-10-14 08:30:56	2026-10-14 08:30:56
17	51	3	1	2026-10-14 08:30:56	2026-10-14 08:30:56
18	52	3	1	2026-10-14 08:30:56	2026-10-14 08:30:56
19	53	3	1	2026-10-14 08:30:56	2026-10-14 08:30:56
20	54	3	1	2026-10-14 08:30:56	2026-10-14 08:30:56
21	55	2	1	2026-10-14 08:30:56	2026-10-14 08:30:56
22	55	3	1	2026-10-14 08:30:56	2026-10-14 08:30:56
23	56	3	1	2026-10-14 08:30:56	2026-10-14 08:30:56
24	57	3	1	2026-10-14 08:30:56	2026-10-14 08:30:56
25	58	2	1	2026-10-14 08:30:56	2026-10-14 08:30:56
26	58	3	1	2026-10-14 08:30:56	2026-10-14 08:30:56
27	59	3	1	2026-10-14 08:30:56	2026-10-14 08:30:56
28	60	2	1	2026-10-14 08:30:56	2026-10-14 08:30:56
29	60	3	1	2026-10-14 08:30:56	2026-10-14 08:30:56
30	61	3	1	2026-10-14 08:30:56	2026-10-14 08:30:56
31	62	3	1	2026-10-14 08:30:56	2026-10-14 08:30:56
32	63	3	1	2026-10-14 08:30:56	2026-10-14 08:30:56
33	67	2	1	2026-10-14 08:30:56	2026-10-14 08:30:56
34	75	2	1	2026-10-14 08:30:56	2026-10-14 08:30:56
35	76	2	1	2026-10-14 08:30:56	2026-10-14 08:30:56
36	108	2	1	2026-10-14 08:30:56	2026-10-14 08:30:56
37	224	2	1	2026-10-14 08:30:56	2026-10-14 08:30:56
38	718	3	1	2026-10-14 08:30:57	2026-10-14 08:30:57
39	900	3	1	2026-10-14 08:30:58	2026-10-14 08:30:58
40	901	3	1	2026-10-14 08:30:58	2026-10-14 08:30:58
41	902	3	1	2026-10-14 08:30:58	2026-10-14 08:30:58
42	903	3	1	2026-10-14 08:30:58	2026-10-14 08:30:58
43	904	3	1	2026-10-14 08:30:58	2026-10-14 08:30:58
44	905	3	1	2026-10-14 08:30:58	2026-10-14 08:30:58
45	906	3	1	2026-10-14 08:30:58	2026-10-14 08:30:58
46	907	3	1	2026-10-14 08:30:58	2026-10-14 08:30:58
47	908	3	1	2026-10-14 08:30:58	2026-10-14 08:30:58
48	909	3	1	2026-10-14 08:30:58	2026-10-14 08:30:58
49	910	3	1	2026-10-14 08:30:58	2026-10-14 08:30:58
50	911	3	1	2026-10-14 08:30:58	2026-10-14 08:30:58
51	912	3	1	2026-10-14 08:30:58	2026-10-14 08:30:58
52	913	3	1	2026-10-14 08:30:58	2026-10-14 08:30:58
53	914	3	1	2026-10-14 08:30:58	2026-10-14 08:30:58
54	915	3	1	2026-10-14 08:30:58	2026-10-14 08:30:58
55	916	3	1	2026-10-14 08:30:58	2026-10-14 08:30:58
56	917	3	1	2026-10-14 08:30:58	2026-10-14 08:30:58
57	918	3	1	2026-10-14 08:30:58	2026-10-14 08:30:58
58	919	3	1	2026-10-14 08:30:58	2026-10-14 08:30:58
59	1365	3	1	2026-10-14 08:30:59	2026-10-14 08:30:59
60	1366	3	1	2026-10-14 08:30:59	2026-10-14 08:30:59
61	1367	3	1	2026-10-14 08:30:59	2026-10-14 08:30:59
62	1368	3	1	2026-10-14 08:30:59	2026-10-14 08:30:59
63	1369	3	1	2026-10-14 08:30:59	2026-10-14 08:30:59
64	1370	3	1	2026-10-14 08:30:59	2026-10-14 08:30:59
65	1371	3	1	2026-10-14 08:30:59	2026-10-14 08:30:59
66	1372	3	1	2026-10-14 08:30:59	2026-10-14 08:30:59
67	1373	3	1	2026-10-14 08:30:59	2026-10-14 08:30:59
68	1490	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
69	1491	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
70	1492	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
71	1493	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
72	1494	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
73	1495	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
74	1496	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
75	1497	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
76	1498	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
77	1499	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
78	1500	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
79	1501	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
80	1502	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
81	1503	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
82	1504	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
83	1505	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
84	1506	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
85	1507	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
86	1508	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
87	1509	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
88	1510	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
89	1511	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
90	1512	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
91	1513	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
92	1514	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
93	1515	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
94	1516	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
95	1517	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
96	1518	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
97	1519	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
98	1520	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
99	1521	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
100	1522	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
101	1523	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
102	1524	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
103	1525	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
104	1526	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
105	1527	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
106	1528	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
107	1529	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
108	1530	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
109	1531	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
110	1532	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
111	1533	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
112	1534	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
113	1535	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
114	1536	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
115	1537	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
116	1538	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
117	1539	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
118	1540	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
119	1541	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
120	1542	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
121	1543	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
122	1544	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
123	1545	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
124	1546	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
125	1547	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
126	1548	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
127	1549	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
128	1550	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
129	1551	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
130	1552	3	1	2026-10-15 01:16:08	2026-10-15 01:16:08
131	1729	3	1	2026-10-15 01:55:22	2026-10-15 01:55:22
\.


--
-- Data for Name: product_connections; Type: TABLE DATA; Schema: public; Owner: gidrovik-admin
--

COPY product_connections (id, product_id, "position", standard_id, diameter_id, thread_id, created_at, updated_at, end_type) FROM stdin;
1	11	1	5	2	40	2026-10-14 03:27:07	2026-10-14 03:27:07	\N
4	14	1	5	4	42	2026-10-14 03:33:37	2026-10-14 03:33:37	\N
5	13	1	4	7	55	2026-10-14 03:34:07	2026-10-14 03:34:07	\N
6	12	1	5	6	53	2026-10-14 03:34:34	2026-10-14 03:34:34	\N
7	15	1	5	7	53	2026-10-14 03:36:50	2026-10-14 03:36:50	\N
8	16	1	5	6	53	2026-10-14 03:39:32	2026-10-14 03:39:32	\N
9	17	1	4	9	58	2026-10-14 03:41:36	2026-10-14 03:41:36	\N
10	18	1	4	9	58	2026-10-14 03:42:46	2026-10-14 03:42:46	\N
11	19	1	13	4	4	2026-10-14 03:45:46	2026-10-14 03:45:46	\N
13	21	1	13	4	4	2026-10-14 03:52:53	2026-10-14 03:52:53	\N
14	20	1	7	4	11	2026-10-14 03:53:03	2026-10-14 03:53:03	\N
15	22	1	4	2	38	2026-10-14 03:54:40	2026-10-14 03:54:40	\N
16	23	1	4	2	38	2026-10-14 03:56:34	2026-10-14 03:56:34	\N
17	24	1	4	2	38	2026-10-14 03:57:33	2026-10-14 03:57:33	\N
18	25	1	4	7	53	2026-10-14 04:04:07	2026-10-14 04:04:07	\N
19	26	1	5	4	43	2026-10-14 04:11:26	2026-10-14 04:11:26	\N
20	27	1	5	7	55	2026-10-14 04:13:05	2026-10-14 04:13:05	\N
21	28	1	5	4	41	2026-10-14 04:14:23	2026-10-14 04:14:23	\N
25	29	1	5	7	55	2026-10-14 04:24:28	2026-10-14 04:24:28	\N
26	30	1	5	8	58	2026-10-14 04:26:51	2026-10-14 04:26:51	\N
27	33	1	\N	6	\N	2026-10-14 06:42:37	2026-10-14 06:42:37	\N
28	32	1	\N	5	\N	2026-10-14 06:42:59	2026-10-14 06:42:59	\N
29	31	1	\N	12	\N	2026-10-14 06:43:18	2026-10-14 06:43:18	\N
31	35	1	\N	1	\N	2026-10-14 07:26:39	2026-10-14 07:26:39	\N
32	34	1	\N	6	\N	2026-10-14 07:27:01	2026-10-14 07:27:01	\N
33	36	1	\N	3	\N	2026-10-14 07:29:01	2026-10-14 07:29:01	\N
34	37	1	\N	3	\N	2026-10-14 07:31:11	2026-10-14 07:31:11	\N
35	38	1	\N	3	\N	2026-10-14 07:32:12	2026-10-14 07:32:12	\N
36	39	1	1	3	1	2026-10-14 07:42:21	2026-10-14 07:42:21	\N
37	40	1	1	3	1	2026-10-14 07:42:21	2026-10-14 07:42:21	\N
38	41	1	1	3	1	2026-10-14 07:42:21	2026-10-14 07:42:21	\N
39	42	1	1	3	1	2026-10-14 07:42:21	2026-10-14 07:42:21	\N
40	43	1	1	6	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
41	44	1	1	6	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
42	45	1	1	6	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
43	46	1	1	6	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
44	47	1	1	6	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
45	48	1	1	7	4	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
46	49	1	1	7	4	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
47	50	1	1	7	4	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
48	51	1	1	7	4	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
49	52	1	1	7	4	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
50	53	1	1	7	5	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
51	54	1	1	7	4	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
52	55	1	1	8	5	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
53	56	1	1	8	5	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
54	57	1	1	8	5	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
55	58	1	1	8	5	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
56	59	1	1	8	5	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
57	60	1	1	8	5	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
58	61	1	1	9	6	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
59	62	1	1	10	7	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
60	63	1	1	10	7	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
61	64	1	1	3	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
62	65	1	1	3	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
63	66	1	1	3	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
64	67	1	1	3	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
65	68	1	1	3	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
66	69	1	1	3	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
67	70	1	1	3	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
68	71	1	1	3	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
69	72	1	1	3	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
70	73	1	1	3	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
71	74	1	1	3	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
72	75	1	1	3	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
73	76	1	1	3	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
74	77	1	1	3	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
75	78	1	1	3	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
76	79	1	1	3	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
77	80	1	1	3	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
78	81	1	1	3	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
79	82	1	1	3	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
80	83	1	1	3	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
81	84	1	1	3	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
82	85	1	1	3	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
83	86	1	1	3	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
84	87	1	1	3	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
85	88	1	1	3	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
86	89	1	1	3	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
87	90	1	1	3	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
88	91	1	9	3	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
89	92	1	1	4	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
90	93	1	1	4	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
91	94	1	1	4	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
92	95	1	1	4	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
93	96	1	1	4	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
94	97	1	1	4	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
95	98	1	1	4	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
96	99	1	1	4	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
97	100	1	1	4	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
98	101	1	1	4	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
99	102	1	1	4	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
100	103	1	1	4	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
101	104	1	1	4	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
102	105	1	1	4	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
103	106	1	1	4	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
104	107	1	1	4	9	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
105	108	1	1	4	9	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
106	109	1	1	4	9	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
107	110	1	1	4	9	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
108	111	1	1	4	9	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
109	112	1	1	4	9	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
110	113	1	1	4	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
111	114	1	1	4	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
112	115	1	1	4	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
113	116	1	1	4	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
114	117	1	1	4	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
115	118	1	1	4	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
116	119	1	1	4	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
117	120	1	1	4	9	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
118	121	1	1	4	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
119	122	1	1	4	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
120	123	1	1	4	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
121	124	1	1	4	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
122	125	1	1	4	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
123	126	1	1	5	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
124	127	1	1	5	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
125	128	1	1	5	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
126	129	1	1	5	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
127	130	1	1	5	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
128	131	1	1	5	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
129	132	1	1	5	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
130	133	1	1	5	9	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
131	134	1	1	5	9	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
132	135	1	1	5	9	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
133	136	1	1	5	9	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
134	137	1	1	5	9	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
135	138	1	1	5	9	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
136	139	1	1	5	9	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
137	140	1	1	5	9	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
138	141	1	1	5	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
139	142	1	1	5	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
140	143	1	1	5	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
141	144	1	1	5	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
142	145	1	1	5	9	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
143	146	1	1	5	9	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
144	147	1	1	6	4	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
145	148	1	1	6	4	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
146	149	1	1	6	4	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
147	150	1	1	6	4	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
148	151	1	1	6	4	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
149	152	1	1	6	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
150	153	1	1	6	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
151	154	1	1	6	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
152	155	1	1	6	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
153	156	1	1	6	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
154	157	1	1	6	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
155	158	1	1	6	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
156	159	1	1	6	4	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
157	160	1	1	6	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
158	161	1	1	6	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
159	162	1	1	6	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
160	163	1	1	6	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
161	164	1	1	6	4	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
162	165	1	1	6	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
163	166	1	1	7	4	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
164	167	1	1	7	4	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
165	168	1	1	7	4	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
166	169	1	1	7	4	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
167	170	1	1	7	4	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
168	171	1	1	7	4	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
169	172	1	1	7	4	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
170	173	1	1	7	4	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
171	174	1	1	7	4	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
172	175	1	1	7	5	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
173	176	1	1	7	5	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
174	177	1	1	7	5	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
175	178	1	1	7	5	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
176	179	1	1	7	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
177	180	1	1	7	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
178	181	1	1	7	4	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
179	182	1	1	7	4	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
180	183	1	1	7	5	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
181	184	1	1	7	5	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
182	185	1	1	7	3	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
183	186	1	1	7	4	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
184	187	1	1	7	4	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
185	188	1	1	\N	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
186	189	1	1	8	6	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
187	190	1	1	8	6	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
188	191	1	1	8	5	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
189	192	1	1	8	5	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
190	193	1	1	8	5	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
191	194	1	1	8	5	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
192	195	1	1	8	5	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
193	196	1	1	8	5	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
194	197	1	1	8	5	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
195	198	1	1	8	5	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
196	199	1	1	9	6	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
197	200	1	1	9	6	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
198	201	1	1	9	6	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
199	202	1	1	9	6	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
200	203	1	1	10	5	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
201	204	1	1	10	7	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
202	205	1	1	10	7	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
203	206	1	1	10	7	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
204	207	1	1	10	5	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
205	208	1	1	10	7	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
206	209	1	1	12	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
207	210	1	1	12	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
208	211	1	1	12	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
209	212	1	1	12	10	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
210	213	1	1	12	10	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
211	214	1	1	12	10	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
212	215	1	1	12	10	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
213	216	1	9	12	10	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
214	217	1	1	1	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
215	218	1	1	1	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
216	219	1	1	1	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
217	220	1	1	1	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
218	221	1	1	1	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
219	222	1	1	1	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
220	223	1	1	1	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
221	224	1	1	1	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
222	225	1	1	1	10	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
223	226	1	1	1	10	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
224	227	1	1	1	10	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
225	228	1	1	1	10	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
226	229	1	1	1	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
227	230	1	1	1	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
228	231	1	1	1	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
229	232	1	1	1	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
230	233	1	1	1	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
231	234	1	1	1	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
232	235	1	1	1	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
233	236	1	1	1	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
234	237	1	1	1	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
235	238	1	1	1	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
236	239	1	1	1	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
237	240	1	1	1	10	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
238	241	1	1	1	10	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
239	242	1	1	1	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
240	243	1	1	1	10	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
241	244	1	1	1	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
242	245	1	1	1	10	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
243	246	1	1	1	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
244	247	1	9	1	10	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
245	248	1	1	2	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
246	249	1	1	2	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
247	250	1	1	2	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
248	251	1	1	2	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
249	252	1	1	2	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
250	253	1	1	2	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
251	254	1	1	2	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
252	255	1	1	2	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
253	256	1	1	2	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
254	257	1	1	2	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
255	258	1	1	2	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
256	259	1	1	2	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
257	260	1	1	2	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
258	261	1	1	2	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
259	262	1	1	2	1	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
260	263	1	1	2	2	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
261	264	1	1	2	10	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
262	265	1	1	2	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
263	266	1	1	2	8	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
264	267	1	2	3	36	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
265	268	1	2	3	37	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
266	269	1	2	3	37	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
267	270	1	2	3	37	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
268	271	1	2	3	38	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
269	272	1	2	3	38	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
270	273	1	2	3	38	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
271	274	1	2	3	38	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
272	275	1	2	3	38	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
273	276	1	2	3	39	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
274	277	1	2	3	39	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
275	278	1	2	3	39	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
276	279	1	2	3	39	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
277	280	1	2	3	40	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
278	281	1	2	3	40	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
279	282	1	2	3	40	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
280	283	1	2	3	40	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
281	284	1	2	3	41	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
282	285	1	2	3	41	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
283	286	1	2	3	41	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
284	287	1	2	3	41	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
285	288	1	2	3	42	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
286	289	1	2	3	37	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
287	290	1	2	3	38	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
288	291	1	2	3	38	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
289	292	1	2	3	39	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
290	293	1	2	3	39	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
291	294	1	2	3	40	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
292	295	1	2	3	41	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
293	296	1	2	4	39	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
294	297	1	2	4	39	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
295	298	1	2	4	39	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
296	299	1	2	4	40	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
297	300	1	2	4	40	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
298	301	1	2	4	40	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
299	302	1	2	4	41	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
300	303	1	2	4	41	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
301	304	1	2	4	41	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
302	305	1	2	4	41	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
303	306	1	2	4	41	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
304	307	1	2	4	42	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
305	308	1	2	4	42	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
306	309	1	2	4	42	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
307	310	1	2	4	43	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
308	311	1	2	4	43	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
309	312	1	2	4	44	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
310	313	1	2	4	44	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
311	314	1	2	4	38	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
312	315	1	2	4	40	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
313	316	1	2	4	41	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
314	317	1	2	4	42	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
315	318	1	2	4	43	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
316	319	1	2	4	44	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
317	320	1	\N	4	41	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
318	321	1	\N	4	41	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
319	322	1	\N	4	42	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
320	323	1	2	5	42	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
321	324	1	2	5	42	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
322	325	1	2	5	42	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
323	326	1	2	5	43	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
324	327	1	2	5	43	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
325	328	1	2	5	43	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
326	329	1	2	5	44	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
327	330	1	2	5	44	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
328	331	1	2	5	44	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
329	332	1	2	5	50	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
330	333	1	2	5	50	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
331	334	1	2	5	45	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
332	335	1	2	5	51	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
333	336	1	2	5	51	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
334	337	1	2	5	42	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
335	338	1	2	5	43	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
336	339	1	2	5	44	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
337	340	1	2	5	50	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
338	341	1	\N	5	43	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
339	342	1	\N	5	43	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
340	343	1	\N	5	44	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
341	344	1	2	6	44	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
342	345	1	2	6	44	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
343	346	1	2	6	50	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
344	347	1	2	6	45	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
345	348	1	2	6	45	2026-10-14 08:30:56	2026-10-14 08:30:56	\N
346	349	1	2	6	45	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
347	350	1	2	6	45	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
348	351	1	2	6	45	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
349	352	1	2	6	51	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
350	353	1	2	6	51	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
351	354	1	2	6	51	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
352	355	1	2	6	46	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
353	356	1	2	6	46	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
354	357	1	2	6	46	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
355	358	1	2	6	46	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
356	359	1	2	6	46	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
357	360	1	2	6	52	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
358	361	1	2	6	52	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
359	362	1	2	6	52	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
360	363	1	2	6	47	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
361	364	1	2	6	47	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
362	365	1	2	6	47	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
363	366	1	2	6	47	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
364	367	1	2	6	53	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
365	368	1	2	6	53	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
366	369	1	2	6	53	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
367	370	1	2	6	53	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
368	371	1	2	6	54	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
369	372	1	2	6	45	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
370	373	1	2	6	52	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
371	374	1	\N	6	45	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
372	375	1	\N	6	46	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
373	376	1	\N	6	47	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
374	377	1	\N	6	53	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
375	378	1	2	7	46	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
376	379	1	2	7	46	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
377	380	1	2	7	52	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
378	381	1	2	7	52	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
379	382	1	2	7	52	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
380	383	1	2	7	47	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
381	384	1	2	7	47	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
382	385	1	2	7	53	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
383	386	1	2	7	53	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
384	387	1	2	7	53	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
385	388	1	2	7	48	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
386	389	1	2	7	54	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
387	390	1	2	7	54	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
388	391	1	2	7	54	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
389	392	1	2	7	55	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
390	393	1	2	7	55	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
391	394	1	2	7	55	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
392	395	1	2	7	55	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
393	396	1	2	7	52	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
394	397	1	2	7	53	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
395	398	1	2	7	54	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
396	399	1	2	7	55	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
397	400	1	2	8	56	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
398	401	1	2	8	49	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
399	402	1	2	8	49	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
400	403	1	2	8	49	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
401	404	1	2	8	57	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
402	405	1	2	8	58	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
403	406	1	2	8	58	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
404	407	1	2	8	58	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
405	408	1	2	9	55	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
406	409	1	2	9	55	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
407	410	1	2	9	55	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
408	411	1	2	9	49	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
409	412	1	2	9	58	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
410	413	1	2	9	58	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
411	414	1	2	9	58	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
412	415	1	2	1	36	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
413	416	1	2	1	36	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
414	417	1	2	1	36	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
415	418	1	2	1	\N	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
416	419	1	2	1	\N	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
417	420	1	2	1	\N	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
418	421	1	2	1	60	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
419	422	1	2	1	59	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
420	423	1	2	1	59	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
421	424	1	2	1	59	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
422	425	1	2	1	59	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
423	426	1	2	1	61	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
424	427	1	2	1	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
425	428	1	2	1	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
426	429	1	2	1	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
427	430	1	2	1	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
428	431	1	2	1	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
429	432	1	2	1	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
430	433	1	2	1	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
431	434	1	2	1	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
432	435	1	2	1	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
433	436	1	2	1	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
434	437	1	2	1	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
435	438	1	2	1	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
436	439	1	2	1	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
437	440	1	2	1	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
438	441	1	2	1	36	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
439	442	1	2	1	\N	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
440	443	1	2	1	59	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
441	444	1	2	1	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
442	445	1	2	1	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
443	446	1	2	1	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
444	447	1	2	2	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
445	448	1	2	2	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
446	449	1	2	2	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
447	450	1	2	2	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
448	451	1	2	2	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
449	452	1	2	2	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
450	453	1	2	2	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
451	454	1	2	2	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
452	455	1	2	2	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
453	456	1	2	2	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
454	457	1	2	2	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
455	458	1	2	2	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
456	459	1	2	2	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
457	460	1	2	2	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
458	461	1	2	2	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
459	462	1	2	2	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
460	463	1	2	2	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
461	464	1	2	2	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
462	465	1	2	2	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
463	466	1	2	2	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
464	467	1	2	2	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
465	468	1	2	2	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
466	469	1	2	2	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
467	470	1	2	2	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
468	471	1	3	3	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
469	472	1	3	3	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
470	473	1	3	3	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
471	474	1	3	3	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
472	475	1	3	3	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
473	476	1	3	3	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
474	477	1	3	3	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
475	478	1	3	3	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
476	479	1	3	3	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
477	480	1	3	3	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
478	481	1	3	4	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
479	482	1	3	4	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
480	483	1	3	4	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
481	484	1	3	4	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
482	485	1	3	4	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
483	486	1	3	4	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
484	487	1	3	4	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
485	488	1	3	4	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
486	489	1	3	4	42	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
487	490	1	3	4	42	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
488	491	1	3	5	44	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
489	492	1	3	5	44	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
490	493	1	3	6	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
491	494	1	3	6	45	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
492	495	1	3	6	45	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
493	496	1	3	6	45	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
494	497	1	3	6	51	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
495	498	1	3	6	51	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
496	499	1	3	6	46	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
497	500	1	3	6	52	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
498	501	1	3	6	52	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
499	502	1	3	6	47	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
500	503	1	3	6	53	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
501	504	1	3	7	47	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
502	505	1	3	7	53	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
503	506	1	3	7	53	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
504	507	1	3	7	54	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
505	508	1	3	7	55	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
506	509	1	3	8	58	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
507	510	1	3	9	58	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
508	511	1	3	9	62	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
509	512	1	3	1	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
510	513	1	3	1	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
511	514	1	3	1	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
512	515	1	3	1	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
513	516	1	3	1	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
514	517	1	3	1	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
515	518	1	3	1	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
516	519	1	3	2	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
517	520	1	3	2	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
518	521	1	3	2	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
519	522	1	3	2	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
520	523	1	3	2	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
521	524	1	3	2	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
522	525	1	3	2	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
523	526	1	4	3	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
524	527	1	4	3	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
525	528	1	4	3	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
526	529	1	4	3	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
527	530	1	4	3	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
528	531	1	4	3	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
529	532	1	4	3	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
530	533	1	4	3	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
531	534	1	4	3	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
532	535	1	4	3	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
533	536	1	4	3	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
534	537	1	4	3	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
535	538	1	4	3	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
536	539	1	4	3	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
537	540	1	4	3	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
538	541	1	4	3	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
539	542	1	4	3	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
540	543	1	4	3	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
541	544	1	4	3	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
542	545	1	4	3	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
543	546	1	4	3	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
544	547	1	4	3	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
545	548	1	4	3	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
546	549	1	4	3	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
547	550	1	4	3	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
548	551	1	4	3	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
549	552	1	4	3	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
550	553	1	4	3	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
551	554	1	4	3	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
552	555	1	4	3	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
553	556	1	4	3	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
554	557	1	4	4	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
555	558	1	4	4	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
556	559	1	4	4	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
557	560	1	4	4	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
558	561	1	4	4	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
559	562	1	4	4	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
560	563	1	4	4	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
561	564	1	4	4	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
562	565	1	4	4	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
563	566	1	4	4	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
564	567	1	4	4	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
565	568	1	4	4	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
566	569	1	4	4	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
567	570	1	4	4	42	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
568	571	1	4	4	42	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
569	572	1	4	4	42	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
570	573	1	4	4	43	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
571	574	1	4	4	43	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
572	575	1	4	4	43	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
573	576	1	4	4	43	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
574	577	1	4	4	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
575	578	1	4	4	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
576	579	1	4	4	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
577	580	1	4	4	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
578	581	1	4	4	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
579	582	1	4	4	42	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
580	583	1	4	4	43	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
581	584	1	4	5	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
582	585	1	4	5	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
583	586	1	4	5	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
584	587	1	4	5	42	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
585	588	1	4	5	42	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
586	589	1	4	5	42	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
587	590	1	4	5	43	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
588	591	1	4	5	43	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
589	592	1	4	5	43	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
590	593	1	4	5	43	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
591	594	1	4	5	43	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
592	595	1	4	5	43	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
593	596	1	4	5	44	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
594	597	1	4	5	44	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
595	598	1	4	5	44	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
596	599	1	4	5	51	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
597	600	1	4	5	51	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
598	601	1	4	5	51	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
599	602	1	4	5	53	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
600	603	1	4	5	53	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
601	604	1	4	5	43	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
602	605	1	4	5	44	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
603	606	1	4	\N	51	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
604	607	1	4	6	43	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
605	608	1	4	6	43	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
606	609	1	4	6	43	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
607	610	1	4	6	44	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
608	611	1	4	6	44	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
609	612	1	4	6	45	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
610	613	1	4	6	45	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
611	614	1	4	6	45	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
612	615	1	4	6	51	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
613	616	1	4	6	51	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
614	617	1	4	6	51	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
615	618	1	4	6	51	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
616	619	1	4	6	51	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
617	620	1	4	6	51	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
618	621	1	4	6	51	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
619	622	1	4	6	51	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
620	623	1	4	6	51	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
621	624	1	4	6	46	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
622	625	1	4	6	46	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
623	626	1	4	6	46	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
624	627	1	4	6	52	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
625	628	1	4	6	52	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
626	629	1	4	6	52	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
627	630	1	4	6	53	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
628	631	1	4	6	53	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
629	632	1	4	6	43	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
630	633	1	4	6	45	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
631	634	1	4	6	51	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
632	635	1	4	6	51	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
633	636	1	4	6	47	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
634	637	1	4	7	46	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
635	638	1	4	7	46	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
636	639	1	4	7	46	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
637	640	1	4	7	52	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
638	641	1	4	7	52	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
639	642	1	4	7	52	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
640	643	1	4	7	53	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
641	644	1	4	7	53	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
642	645	1	4	7	53	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
643	646	1	4	7	53	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
644	647	1	4	7	54	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
645	648	1	4	7	54	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
646	649	1	4	7	55	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
647	650	1	4	7	55	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
648	651	1	4	7	56	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
649	652	1	4	7	56	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
650	653	1	4	7	56	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
651	654	1	4	7	46	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
652	655	1	4	7	52	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
653	656	1	4	7	55	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
654	657	1	4	8	56	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
655	658	1	4	8	56	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
656	659	1	4	8	56	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
657	660	1	4	8	58	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
658	661	1	4	8	58	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
659	662	1	4	8	58	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
660	663	1	4	8	56	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
661	664	1	4	9	58	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
662	665	1	4	11	59	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
663	666	1	4	11	59	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
664	667	1	4	12	59	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
665	668	1	4	12	59	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
666	669	1	4	12	59	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
667	670	1	4	12	59	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
668	671	1	4	12	59	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
669	672	1	4	12	59	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
670	673	1	4	1	59	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
671	674	1	4	1	59	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
672	675	1	4	1	59	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
673	676	1	4	1	59	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
674	677	1	4	1	59	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
675	678	1	4	1	59	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
676	679	1	4	1	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
677	680	1	4	1	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
678	681	1	4	1	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
679	682	1	4	1	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
680	683	1	4	1	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
681	684	1	4	1	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
682	685	1	4	1	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
683	686	1	4	1	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
684	687	1	4	1	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
685	688	1	4	1	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
686	689	1	4	1	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
687	690	1	4	1	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
688	691	1	4	1	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
689	692	1	4	1	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
690	693	1	4	1	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
691	694	1	4	1	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
692	695	1	4	1	59	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
693	696	1	4	1	59	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
694	697	1	4	1	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
695	698	1	4	1	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
696	699	1	4	1	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
697	700	1	4	1	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
698	701	1	4	1	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
699	702	1	4	1	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
700	703	1	4	2	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
701	704	1	4	2	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
702	705	1	4	2	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
703	706	1	4	2	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
704	707	1	4	2	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
705	708	1	4	2	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
706	709	1	4	2	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
707	710	1	4	2	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
708	711	1	4	2	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
709	712	1	4	2	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
710	713	1	4	2	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
711	714	1	4	2	37	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
712	715	1	4	2	38	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
713	716	1	4	2	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
714	717	1	4	2	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
715	718	1	5	6	53	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
716	719	1	5	3	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
717	720	1	5	3	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
718	721	1	5	3	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
719	722	1	5	3	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
720	723	1	5	3	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
721	724	1	5	3	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
722	725	1	5	3	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
723	726	1	5	3	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
724	727	1	5	3	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
725	728	1	5	3	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
726	729	1	5	3	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
727	730	1	5	3	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
728	731	1	5	3	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
729	732	1	5	3	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
730	733	1	5	3	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
731	734	1	5	3	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
732	735	1	5	3	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
733	736	1	5	3	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
734	737	1	5	3	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
735	738	1	5	3	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
736	739	1	5	3	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
737	740	1	5	3	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
738	741	1	5	3	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
739	742	1	5	4	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
740	743	1	5	4	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
741	744	1	5	4	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
742	745	1	5	4	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
743	746	1	5	4	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
744	747	1	5	4	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
745	748	1	5	4	42	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
746	749	1	5	4	42	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
747	750	1	5	4	42	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
748	751	1	5	4	39	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
749	752	1	5	4	40	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
750	753	1	5	4	41	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
751	754	1	5	4	42	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
752	755	1	5	5	42	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
753	756	1	5	5	42	2026-10-14 08:30:57	2026-10-14 08:30:57	\N
754	757	1	5	5	42	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
755	758	1	5	5	43	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
756	759	1	5	5	44	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
757	760	1	5	5	51	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
758	761	1	5	5	51	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
759	762	1	5	5	51	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
760	763	1	5	5	51	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
761	764	1	5	5	42	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
762	765	1	5	5	51	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
763	766	1	5	6	45	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
764	767	1	5	6	45	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
765	768	1	5	6	51	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
766	769	1	5	6	51	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
767	770	1	5	6	51	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
768	771	1	5	6	46	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
769	772	1	5	6	46	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
770	773	1	5	6	46	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
771	774	1	5	6	52	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
772	775	1	5	6	52	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
773	776	1	5	6	52	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
774	777	1	5	6	53	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
775	778	1	5	6	53	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
776	779	1	5	6	53	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
777	780	1	5	6	55	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
778	781	1	5	6	55	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
779	782	1	5	6	45	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
780	783	1	5	6	51	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
781	784	1	5	6	52	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
782	785	1	5	6	53	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
783	786	1	5	7	53	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
784	787	1	5	7	53	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
785	788	1	5	7	55	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
786	789	1	5	7	55	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
787	790	1	5	7	55	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
788	791	1	5	7	53	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
789	792	1	5	8	55	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
790	793	1	5	8	58	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
791	794	1	5	8	58	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
792	795	1	5	8	58	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
793	796	1	5	8	58	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
794	797	1	5	9	58	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
795	798	1	5	9	58	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
796	799	1	5	9	58	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
797	800	1	5	9	58	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
798	801	1	5	1	60	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
799	802	1	5	1	59	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
800	803	1	5	1	59	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
801	804	1	5	1	59	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
802	805	1	5	1	37	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
803	806	1	5	1	37	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
804	807	1	5	1	37	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
805	808	1	5	1	37	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
806	809	1	5	1	37	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
807	810	1	5	1	38	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
808	811	1	5	1	38	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
809	812	1	5	1	38	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
810	813	1	5	1	38	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
811	814	1	5	1	38	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
812	815	1	5	1	38	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
813	816	1	5	1	39	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
814	817	1	5	1	39	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
815	818	1	5	1	39	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
816	819	1	5	1	39	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
817	820	1	5	1	39	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
818	821	1	5	1	39	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
819	822	1	5	1	37	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
820	823	1	5	1	38	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
821	824	1	5	1	38	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
822	825	1	5	1	39	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
823	826	1	5	1	39	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
824	827	1	5	1	40	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
825	828	1	5	2	38	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
826	829	1	5	2	38	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
827	830	1	5	2	38	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
828	831	1	5	2	39	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
829	832	1	5	2	39	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
830	833	1	5	2	39	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
831	834	1	5	2	39	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
832	835	1	5	2	39	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
833	836	1	5	2	40	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
834	837	1	5	2	40	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
835	838	1	5	2	40	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
836	839	1	5	2	40	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
837	840	1	5	2	38	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
838	841	1	5	2	39	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
839	842	1	5	2	40	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
840	843	1	5	2	41	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
841	844	1	6	3	1	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
842	845	1	6	3	2	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
843	846	1	6	3	\N	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
844	847	1	6	3	59	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
845	848	1	6	3	37	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
846	849	1	6	3	38	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
847	850	1	6	3	39	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
848	851	1	6	3	40	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
849	852	1	6	3	41	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
850	853	1	6	3	\N	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
851	854	1	6	3	8	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
852	855	1	6	4	1	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
853	856	1	6	4	37	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
854	857	1	6	4	38	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
855	858	1	6	4	39	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
856	859	1	6	4	40	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
857	860	1	6	4	41	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
858	861	1	6	4	\N	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
859	862	1	6	4	42	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
860	863	1	6	4	8	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
861	864	1	6	5	1	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
862	865	1	6	5	40	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
863	866	1	6	5	41	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
864	867	1	6	5	42	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
865	868	1	6	5	43	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
866	869	1	6	5	\N	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
867	870	1	6	5	44	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
868	871	1	6	5	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
869	872	1	6	6	41	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
870	873	1	6	6	43	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
871	874	1	6	6	43	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
872	875	1	6	6	44	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
873	876	1	6	6	\N	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
874	877	1	6	6	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
875	878	1	6	6	45	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
876	879	1	6	\N	36	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
877	880	1	6	\N	\N	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
878	881	1	6	11	36	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
879	882	1	6	11	37	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
880	883	1	6	11	\N	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
881	884	1	6	12	\N	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
882	885	1	6	1	2	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
883	886	1	6	1	\N	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
884	887	1	6	1	59	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
885	888	1	6	1	37	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
886	889	1	6	1	8	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
887	890	1	6	1	\N	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
888	891	1	6	1	38	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
889	892	1	6	2	2	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
890	893	1	6	2	\N	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
891	894	1	6	2	59	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
892	895	1	6	2	37	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
893	896	1	6	2	38	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
894	897	1	6	2	39	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
895	898	1	6	2	40	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
896	899	1	6	2	8	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
897	900	1	7	6	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
898	901	1	7	6	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
899	902	1	7	6	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
900	903	1	7	6	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
901	904	1	7	6	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
902	905	1	7	6	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
903	906	1	7	6	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
904	907	1	7	6	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
905	908	1	7	7	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
906	909	1	7	7	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
907	910	1	7	7	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
908	911	1	7	7	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
909	912	1	7	7	13	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
910	913	1	7	7	13	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
911	914	1	7	7	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
912	915	1	7	8	13	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
913	916	1	7	8	13	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
914	917	1	7	8	14	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
915	918	1	7	8	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
916	919	1	7	8	13	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
917	921	1	7	3	1	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
918	922	1	7	3	1	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
919	923	1	7	3	1	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
920	924	1	7	3	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
921	925	1	7	3	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
922	926	1	7	3	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
923	927	1	7	3	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
924	928	1	7	3	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
925	929	1	7	3	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
926	930	1	7	3	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
927	931	1	7	3	9	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
928	932	1	7	3	9	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
929	933	1	7	3	9	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
930	934	1	7	3	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
931	935	1	7	3	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
932	936	1	7	3	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
933	937	1	7	3	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
934	938	1	7	3	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
935	939	1	7	3	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
936	940	1	7	3	18	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
937	941	1	7	3	18	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
938	942	1	7	3	18	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
939	943	1	7	3	18	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
940	944	1	7	3	18	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
941	945	1	7	3	18	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
942	946	1	7	3	18	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
943	947	1	7	3	18	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
944	948	1	7	3	18	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
945	949	1	7	3	18	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
946	950	1	7	3	18	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
947	951	1	7	3	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
948	952	1	7	3	9	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
949	953	1	7	3	18	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
950	954	1	7	3	18	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
951	955	1	8	3	18	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
952	956	1	7	4	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
953	957	1	7	4	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
954	958	1	7	4	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
955	959	1	7	4	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
956	960	1	7	4	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
957	961	1	7	4	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
958	962	1	7	4	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
959	963	1	7	4	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
960	964	1	7	4	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
961	965	1	7	4	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
962	966	1	7	4	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
963	967	1	7	4	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
964	968	1	7	4	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
965	969	1	7	4	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
966	970	1	7	4	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
967	971	1	7	4	9	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
968	972	1	7	4	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
969	973	1	7	4	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
970	974	1	7	4	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
971	975	1	7	4	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
972	976	1	7	4	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
973	977	1	7	4	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
974	978	1	7	4	18	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
975	979	1	7	4	18	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
976	980	1	7	4	18	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
977	981	1	7	4	18	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
978	982	1	7	4	18	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
979	983	1	7	4	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
980	984	1	7	4	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
981	985	1	7	4	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
982	986	1	7	4	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
983	987	1	7	4	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
984	988	1	7	4	9	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
985	989	1	7	4	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
986	990	1	7	4	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
987	991	1	7	4	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
988	992	1	7	4	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
989	993	1	7	4	18	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
990	994	1	7	4	18	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
991	995	1	8	4	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
992	996	1	8	4	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
993	997	1	8	4	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
994	998	1	8	4	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
995	999	1	8	4	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
996	1000	1	8	4	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
997	1001	1	8	4	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
998	1002	1	7	5	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
999	1003	1	7	5	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1000	1004	1	7	5	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1001	1005	1	7	5	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1002	1006	1	7	5	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1003	1007	1	7	5	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1004	1008	1	7	5	3	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1005	1009	1	7	5	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1006	1010	1	7	5	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1007	1011	1	7	5	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1008	1012	1	7	5	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1009	1013	1	7	5	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1010	1014	1	7	5	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1011	1015	1	7	5	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1012	1016	1	7	5	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1013	1017	1	7	5	19	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1014	1018	1	7	5	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1015	1019	1	7	5	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1016	1020	1	8	5	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1017	1021	1	7	6	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1018	1022	1	7	6	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1019	1023	1	7	6	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1020	1024	1	7	6	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1021	1025	1	7	6	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1022	1026	1	7	6	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1023	1027	1	7	6	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1024	1028	1	7	6	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1025	1029	1	7	6	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1026	1030	1	7	6	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1027	1031	1	7	6	19	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1028	1032	1	7	6	19	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1029	1033	1	7	6	19	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1030	1034	1	7	6	19	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1031	1035	1	7	6	19	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1032	1036	1	7	6	19	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1033	1037	1	7	6	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1034	1038	1	7	6	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1035	1039	1	7	6	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1036	1040	1	7	6	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1037	1041	1	7	6	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1038	1042	1	7	6	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1039	1043	1	7	6	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1040	1044	1	7	6	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1041	1045	1	7	6	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1042	1046	1	7	6	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1043	1047	1	7	6	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1044	1048	1	7	6	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1045	1049	1	7	6	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1046	1050	1	7	6	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1047	1051	1	7	6	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1048	1052	1	7	6	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1049	1053	1	7	6	19	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1050	1054	1	7	6	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1051	1055	1	7	6	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1052	1056	1	7	6	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1053	1057	1	7	6	17	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1054	1058	1	8	6	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1055	1059	1	8	6	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1056	1060	1	8	6	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1057	1061	1	8	6	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1058	1062	1	8	6	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1059	1063	1	7	7	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1060	1064	1	7	7	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1061	1065	1	7	7	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1062	1066	1	7	7	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1063	1067	1	7	7	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1064	1068	1	7	7	19	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1065	1069	1	7	7	19	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1066	1070	1	7	7	19	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1067	1071	1	7	7	19	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1068	1072	1	7	7	19	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1069	1073	1	7	7	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1070	1074	1	7	7	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1071	1075	1	7	7	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1072	1076	1	7	7	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1073	1077	1	7	7	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1074	1078	1	7	7	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1075	1079	1	7	7	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1076	1080	1	7	7	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1077	1081	1	7	7	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1078	1082	1	7	7	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1079	1083	1	7	7	13	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1080	1084	1	7	7	13	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1081	1085	1	7	7	13	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1082	1086	1	7	7	4	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1083	1087	1	7	7	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1084	1088	1	7	7	11	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1085	1089	1	7	7	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1086	1090	1	7	7	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1087	1091	1	7	7	13	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1088	1092	1	8	7	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1089	1093	1	8	7	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1090	1094	1	8	7	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1091	1095	1	8	7	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1092	1096	1	7	8	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1093	1097	1	7	8	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1094	1098	1	7	8	13	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1095	1099	1	7	8	13	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1096	1100	1	7	8	13	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1097	1101	1	7	8	13	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1098	1102	1	7	8	13	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1099	1103	1	7	8	13	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1100	1104	1	7	8	14	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1101	1105	1	7	8	14	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1102	1106	1	7	8	14	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1103	1107	1	7	8	12	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1104	1108	1	7	8	13	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1105	1109	1	7	8	13	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1106	1110	1	7	8	14	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1107	1111	1	7	8	14	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1108	1112	1	8	8	13	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1109	1113	1	8	8	13	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1110	1114	1	8	8	13	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1111	1115	1	7	9	14	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1112	1116	1	7	9	14	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1113	1117	1	7	9	14	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1114	1118	1	7	9	14	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1115	1119	1	7	9	14	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1116	1120	1	7	9	14	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1117	1121	1	7	9	14	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1118	1122	1	7	9	14	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1119	1123	1	7	11	61	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1120	1124	1	7	10	7	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1121	1125	1	7	10	20	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1122	1126	1	7	10	20	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1123	1127	1	7	10	20	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1124	1128	1	7	10	20	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1125	1129	1	7	12	16	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1126	1130	1	7	12	16	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1127	1131	1	7	12	16	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1128	1132	1	7	12	16	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1129	1133	1	7	1	1	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1130	1134	1	7	1	1	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1131	1135	1	7	1	1	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1132	1136	1	7	1	1	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1133	1137	1	7	1	1	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1134	1138	1	7	1	1	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1135	1139	1	7	1	60	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1136	1140	1	7	1	16	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1137	1141	1	7	1	16	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1138	1142	1	7	1	16	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1139	1143	1	7	1	16	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1140	1144	1	7	1	16	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1141	1145	1	7	1	16	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1142	1146	1	7	1	16	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1143	1147	1	7	1	16	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1144	1148	1	7	1	16	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1145	1149	1	7	1	18	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1146	1150	1	7	1	18	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1147	1151	1	7	1	18	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1148	1152	1	7	1	18	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1149	1153	1	7	1	18	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1150	1154	1	7	1	18	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1151	1155	1	7	1	1	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1152	1156	1	7	1	16	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1153	1157	1	7	1	16	2026-10-14 08:30:58	2026-10-14 08:30:58	\N
1154	1158	1	7	1	18	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1155	1159	1	8	1	16	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1156	1160	1	7	2	1	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1157	1161	1	7	2	1	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1158	1162	1	7	2	1	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1159	1163	1	7	2	1	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1160	1164	1	7	2	1	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1161	1165	1	7	2	3	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1162	1166	1	7	2	3	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1163	1167	1	7	2	9	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1164	1168	1	7	2	9	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1165	1169	1	7	2	18	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1166	1170	1	7	2	18	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1167	1171	1	7	2	18	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1168	1172	1	7	2	18	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1169	1173	1	7	2	18	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1170	1174	1	7	2	18	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1171	1175	1	7	2	1	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1172	1176	1	7	2	3	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1173	1177	1	7	2	18	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1174	1178	1	7	2	18	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1175	1179	1	9	3	2	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1176	1180	1	9	3	8	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1177	1181	1	9	3	8	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1178	1182	1	9	3	8	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1179	1183	1	9	3	18	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1180	1184	1	9	4	1	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1181	1185	1	9	4	1	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1182	1186	1	9	4	1	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1183	1187	1	9	6	3	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1184	1188	1	9	6	3	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1185	1189	1	9	6	3	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1186	1190	1	9	7	4	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1187	1191	1	9	7	4	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1188	1192	1	9	7	4	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1189	1193	1	9	1	2	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1190	1194	1	9	1	2	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1191	1195	1	9	1	2	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1192	1196	1	9	1	10	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1193	1197	1	10	3	37	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1194	1198	1	10	3	37	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1195	1199	1	10	3	37	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1196	1200	1	10	3	63	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1197	1201	1	10	3	38	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1198	1202	1	10	3	38	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1199	1203	1	10	3	38	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1200	1204	1	10	3	38	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1201	1205	1	10	3	39	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1202	1206	1	10	3	39	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1203	1207	1	10	3	39	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1204	1208	1	10	3	39	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1205	1209	1	10	3	40	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1206	1210	1	10	3	40	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1207	1211	1	10	3	40	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1208	1212	1	10	3	38	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1209	1213	1	10	3	40	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1210	1214	1	10	8	47	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1211	1215	1	10	9	64	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1212	1216	1	10	9	64	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1213	1217	1	10	9	64	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1214	1218	1	10	9	58	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1215	1219	1	10	1	36	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1216	1220	1	10	1	36	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1217	1221	1	10	1	36	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1218	1222	1	10	1	\N	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1219	1223	1	10	1	60	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1220	1224	1	10	1	59	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1221	1225	1	10	1	59	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1222	1226	1	10	1	59	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1223	1227	1	10	1	61	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1224	1228	1	10	1	61	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1225	1229	1	10	1	37	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1226	1230	1	10	1	37	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1227	1231	1	10	1	37	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1228	1232	1	10	1	\N	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1229	1233	1	10	1	63	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1230	1234	1	10	1	38	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1231	1235	1	10	1	38	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1232	1236	1	10	1	38	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1233	1237	1	10	1	36	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1234	1238	1	10	1	36	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1235	1239	1	10	1	36	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1236	1240	1	10	1	60	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1237	1241	1	10	1	60	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1238	1242	1	10	1	\N	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1239	1243	1	10	1	59	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1240	1244	1	10	1	37	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1241	1245	1	10	2	37	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1242	1246	1	10	2	37	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1243	1247	1	10	2	37	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1244	1248	1	10	2	63	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1245	1249	1	10	2	63	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1246	1250	1	10	2	38	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1247	1251	1	10	2	38	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1248	1252	1	10	2	38	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1249	1253	1	10	2	39	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1250	1254	1	10	2	39	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1251	1255	1	10	2	37	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1252	1256	1	\N	3	37	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1253	1257	1	\N	3	37	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1254	1258	1	\N	3	37	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1255	1259	1	\N	3	63	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1256	1260	1	\N	3	63	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1257	1261	1	\N	3	38	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1258	1262	1	\N	3	39	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1259	1263	1	\N	3	39	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1260	1264	1	\N	3	39	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1261	1265	1	\N	3	40	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1262	1266	1	\N	3	40	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1263	1267	1	\N	3	37	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1264	1268	1	\N	3	37	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1265	1269	1	\N	3	37	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1266	1270	1	\N	3	38	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1267	1271	1	\N	3	38	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1268	1272	1	\N	3	38	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1269	1273	1	\N	3	39	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1270	1274	1	\N	3	39	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1271	1275	1	\N	3	40	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1272	1276	1	\N	3	40	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1273	1277	1	\N	3	40	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1274	1278	1	\N	4	39	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1275	1279	1	\N	4	39	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1276	1280	1	\N	4	39	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1277	1281	1	\N	4	40	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1278	1282	1	\N	4	40	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1279	1283	1	\N	4	41	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1280	1284	1	\N	4	41	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1281	1285	1	\N	4	41	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1282	1286	1	\N	4	42	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1283	1287	1	\N	4	42	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1284	1288	1	\N	4	40	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1285	1289	1	\N	4	41	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1286	1290	1	\N	4	41	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1287	1291	1	\N	4	42	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1288	1292	1	\N	4	42	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1289	1293	1	\N	5	42	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1290	1294	1	\N	5	42	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1291	1295	1	\N	5	42	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1292	1296	1	\N	5	42	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1293	1297	1	\N	5	44	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1294	1298	1	\N	5	44	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1295	1299	1	\N	5	46	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1296	1300	1	\N	5	46	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1297	1301	1	\N	5	46	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1298	1302	1	\N	6	42	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1299	1303	1	\N	6	45	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1300	1304	1	\N	6	45	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1301	1305	1	\N	6	45	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1302	1306	1	\N	6	46	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1303	1307	1	\N	6	46	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1304	1308	1	\N	6	46	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1305	1309	1	\N	7	46	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1306	1310	1	\N	7	46	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1307	1311	1	\N	7	46	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1308	1312	1	\N	7	46	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1309	1313	1	\N	7	52	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1310	1314	1	\N	7	47	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1311	1315	1	\N	7	47	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1312	1316	1	\N	7	47	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1313	1317	1	\N	7	47	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1314	1318	1	\N	7	53	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1315	1319	1	\N	7	53	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1316	1320	1	\N	7	53	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1317	1321	1	\N	8	64	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1318	1322	1	\N	8	64	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1319	1323	1	\N	8	64	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1320	1324	1	\N	8	64	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1321	1325	1	\N	8	64	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1322	1326	1	\N	1	10	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1323	1327	1	\N	1	36	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1324	1328	1	\N	1	\N	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1325	1329	1	\N	1	60	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1326	1330	1	\N	1	59	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1327	1331	1	\N	1	59	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1328	1332	1	\N	1	59	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1329	1333	1	\N	1	59	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1330	1334	1	\N	1	61	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1331	1335	1	\N	1	61	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1332	1336	1	\N	1	37	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1333	1337	1	\N	1	37	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1334	1338	1	\N	1	37	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1335	1339	1	\N	1	38	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1336	1340	1	\N	1	\N	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1337	1341	1	\N	1	\N	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1338	1342	1	\N	1	60	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1339	1343	1	\N	1	60	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1340	1344	1	\N	1	\N	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1341	1345	1	\N	1	59	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1342	1346	1	\N	2	37	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1343	1347	1	\N	2	38	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1344	1348	1	\N	2	38	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1345	1349	1	\N	2	38	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1346	1350	1	12	3	41	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1347	1351	1	\N	1	41	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1348	1352	1	12	1	41	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1349	1353	1	12	1	41	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1350	1354	1	12	1	41	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1351	1355	1	12	1	41	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1352	1356	1	12	1	\N	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1353	1357	1	12	1	\N	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1354	1358	1	12	1	\N	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1355	1359	1	\N	2	41	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1356	1360	1	12	2	41	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1357	1361	1	12	2	41	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1358	1362	1	12	2	41	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1359	1363	1	12	2	\N	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1360	1364	1	12	2	\N	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1361	1365	1	13	6	19	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1362	1366	1	13	7	21	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1363	1367	1	13	7	21	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1364	1368	1	13	7	21	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1365	1369	1	13	8	22	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1366	1370	1	13	8	22	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1367	1371	1	13	8	22	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1368	1372	1	13	8	22	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1369	1373	1	13	8	22	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1370	1374	1	13	3	23	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1371	1375	1	13	3	23	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1372	1376	1	13	3	23	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1373	1377	1	13	3	23	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1374	1378	1	13	3	24	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1375	1379	1	13	3	24	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1376	1380	1	13	3	24	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1377	1381	1	13	3	24	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1378	1382	1	13	3	18	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1379	1383	1	13	3	18	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1380	1384	1	13	3	18	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1381	1385	1	13	3	23	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1382	1386	1	13	3	24	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1383	1387	1	13	3	18	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1384	1388	1	13	4	4	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1385	1389	1	13	4	19	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1386	1390	1	13	4	19	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1387	1391	1	13	4	19	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1388	1392	1	13	4	19	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1389	1393	1	13	4	23	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1390	1394	1	13	4	23	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1391	1395	1	13	4	23	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1392	1396	1	13	4	24	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1393	1397	1	13	4	24	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1394	1398	1	13	4	24	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1395	1399	1	13	4	24	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1396	1400	1	13	4	24	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1397	1401	1	13	4	24	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1398	1402	1	13	4	24	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1399	1403	1	13	4	4	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1400	1404	1	13	4	4	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1401	1405	1	13	4	4	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1402	1406	1	13	4	19	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1403	1407	1	13	4	23	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1404	1408	1	13	4	24	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1405	1409	1	13	4	24	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1406	1410	1	13	5	4	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1407	1411	1	13	5	4	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1408	1412	1	13	5	4	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1409	1413	1	13	5	19	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1410	1414	1	13	5	19	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1411	1415	1	13	5	19	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1412	1416	1	13	5	4	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1413	1417	1	13	5	19	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1414	1418	1	13	6	4	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1415	1419	1	13	6	4	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1416	1420	1	13	6	19	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1417	1421	1	13	6	19	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1418	1422	1	13	6	19	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1419	1423	1	13	6	19	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1420	1424	1	13	6	21	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1421	1425	1	13	6	21	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1422	1426	1	13	6	45	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1423	1427	1	13	6	4	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1424	1428	1	13	6	19	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1425	1429	1	13	7	22	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1426	1430	1	13	7	22	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1427	1431	1	13	7	22	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1428	1432	1	13	7	19	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1429	1433	1	13	7	19	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1430	1434	1	13	7	19	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1431	1435	1	13	7	21	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1432	1436	1	13	7	21	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1433	1437	1	13	7	21	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1434	1438	1	13	7	21	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1435	1439	1	13	8	22	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1436	1440	1	13	8	22	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1437	1441	1	13	8	22	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1438	1442	1	13	8	22	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1439	1443	1	13	9	22	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1440	1444	1	13	9	22	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1441	1445	1	13	9	22	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1442	1446	1	13	9	7	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1443	1447	1	13	1	23	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1444	1448	1	13	1	23	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1445	1449	1	13	1	23	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1446	1450	1	13	1	23	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1447	1451	1	13	1	18	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1448	1452	1	13	1	18	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1449	1453	1	13	1	18	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1450	1454	1	13	1	18	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1451	1455	1	13	1	18	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1452	1456	1	13	1	18	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1453	1457	1	13	1	18	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1454	1458	1	13	1	18	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1455	1459	1	13	1	23	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1456	1460	1	13	1	18	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1457	1461	1	13	2	23	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1458	1462	1	13	2	23	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1459	1463	1	13	2	23	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1460	1464	1	13	2	18	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1461	1465	1	13	2	18	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1462	1466	1	13	2	18	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1463	1467	1	13	2	23	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1464	1468	1	13	2	18	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1465	1469	1	14	3	2	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1466	1470	1	14	3	8	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1467	1471	1	14	4	1	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1468	1472	1	14	4	8	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1469	1473	1	14	5	3	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1470	1474	1	14	6	4	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1471	1475	1	14	6	3	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1472	1476	1	14	7	4	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1473	1477	1	14	7	5	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1474	1478	1	14	8	5	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1475	1479	1	14	9	6	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1476	1480	1	14	10	7	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1477	1481	1	14	1	2	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1478	1482	1	14	1	10	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1479	1483	1	14	1	8	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1480	1484	1	14	2	2	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1481	1485	1	14	2	10	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1482	1486	1	14	2	8	2026-10-14 08:30:59	2026-10-14 08:30:59	\N
1483	1487	1	\N	7	\N	2026-10-14 09:38:21	2026-10-14 09:38:21	\N
1485	1489	1	\N	5	\N	2026-10-14 09:55:10	2026-10-14 09:55:10	\N
1486	1488	1	\N	6	\N	2026-10-14 09:55:21	2026-10-14 09:55:21	\N
1487	1729	1	\N	9	\N	2026-10-15 01:55:22	2026-10-15 01:55:22	\N
1488	1730	1	\N	1	\N	2026-10-15 02:04:58	2026-10-15 02:04:58	\N
1489	1731	1	\N	9	\N	2026-10-15 02:48:58	2026-10-15 02:48:58	\N
1490	1732	1	\N	7	\N	2026-10-15 02:51:03	2026-10-15 02:51:03	\N
1491	1733	1	\N	6	\N	2026-10-15 03:10:57	2026-10-15 03:10:57	\N
1492	1734	1	\N	8	\N	2026-10-15 03:33:47	2026-10-15 03:33:47	\N
1493	1735	1	\N	5	\N	2026-10-15 03:34:52	2026-10-15 03:34:52	\N
1494	1736	1	\N	7	\N	2026-10-15 03:36:05	2026-10-15 03:36:05	\N
1495	1737	1	\N	10	\N	2026-10-15 03:49:09	2026-10-15 03:49:09	\N
1496	1738	1	\N	10	\N	2026-10-15 03:50:23	2026-10-15 03:50:23	\N
1497	1739	1	\N	8	\N	2026-10-15 04:05:23	2026-10-15 04:05:23	\N
1498	1740	1	\N	9	\N	2026-10-15 04:20:59	2026-10-15 04:20:59	\N
1499	1741	1	\N	8	\N	2026-10-15 04:23:04	2026-10-15 04:23:04	\N
1500	1742	1	\N	8	\N	2026-10-15 04:25:52	2026-10-15 04:25:52	\N
1501	1743	1	\N	4	\N	2026-10-15 04:27:12	2026-10-15 04:27:12	\N
1502	1744	1	\N	5	\N	2026-10-15 04:30:40	2026-10-15 04:30:40	\N
1503	1745	1	\N	3	\N	2026-10-15 04:33:34	2026-10-15 04:33:34	\N
1504	1746	1	\N	4	\N	2026-10-15 04:34:26	2026-10-15 04:34:26	\N
1505	1747	1	\N	7	\N	2026-10-15 08:52:13	2026-10-15 08:52:13	\N
1512	1749	1	2	\N	40	2026-10-16 06:27:52	2026-10-16 06:27:52	\N
1513	1749	2	2	\N	44	2026-10-16 06:27:52	2026-10-16 06:27:52	\N
1514	1750	1	2	\N	44	2026-10-16 06:29:58	2026-10-16 06:29:58	\N
1515	1750	2	2	\N	44	2026-10-16 06:29:58	2026-10-16 06:29:58	\N
1516	1751	1	2	\N	44	2026-10-16 06:32:32	2026-10-16 06:32:32	\N
1517	1751	2	2	\N	44	2026-10-16 06:32:32	2026-10-16 06:32:32	\N
1518	1751	3	2	\N	44	2026-10-16 06:32:32	2026-10-16 06:32:32	\N
1519	1752	1	2	\N	44	2026-10-16 06:34:07	2026-10-16 06:34:07	\N
1520	1752	2	2	\N	44	2026-10-16 06:34:07	2026-10-16 06:34:07	\N
1521	1753	1	\N	2	\N	2026-10-16 06:38:28	2026-10-16 06:38:28	\N
1522	1754	1	\N	1	\N	2026-10-16 06:39:52	2026-10-16 06:39:52	\N
1523	1755	1	\N	7	\N	2026-10-16 06:40:30	2026-10-16 06:40:30	\N
1524	1748	1	2	\N	41	2026-10-16 08:59:01	2026-10-16 08:59:01	\N
1525	1748	2	2	\N	40	2026-10-16 08:59:01	2026-10-16 08:59:01	\N
1526	1789	1	\N	10	\N	2026-10-19 03:18:27	2026-10-19 03:18:27	\N
1528	1790	1	\N	13	\N	2026-10-19 03:24:14	2026-10-19 03:24:14	\N
1529	1792	1	\N	10	\N	2026-10-19 03:25:25	2026-10-19 03:25:25	\N
\.


--
-- Data for Name: product_location; Type: TABLE DATA; Schema: public; Owner: gidrovik-admin
--

COPY product_location (id, product_id, location_id, quantity, created_at, updated_at) FROM stdin;
79	1029	56	34.000	2026-10-15 02:36:42	2026-10-15 02:36:42
4	11	5	8.000	2026-10-14 03:27:41	2026-10-14 03:27:41
5	13	10	11.000	2026-10-14 03:32:09	2026-10-14 03:32:09
6	14	5	5.000	2026-10-14 03:35:20	2026-10-14 03:35:20
7	15	10	10.000	2026-10-14 03:37:53	2026-10-14 03:37:53
8	17	11	1.000	2026-10-14 03:41:50	2026-10-14 03:41:50
9	18	11	1.000	2026-10-14 03:42:58	2026-10-14 03:42:58
10	19	11	6.000	2026-10-14 03:46:05	2026-10-14 03:46:05
11	20	11	4.000	2026-10-14 03:50:10	2026-10-14 03:50:10
12	21	11	3.000	2026-10-14 03:55:18	2026-10-14 03:55:18
13	22	11	2.000	2026-10-14 03:55:32	2026-10-14 03:55:32
14	23	11	8.000	2026-10-14 03:56:48	2026-10-14 03:56:48
15	24	11	15.000	2026-10-14 03:57:52	2026-10-14 03:57:52
16	25	11	6.000	2026-10-14 04:05:50	2026-10-14 04:05:50
17	26	11	6.000	2026-10-14 04:11:44	2026-10-14 04:11:44
18	27	11	3.000	2026-10-14 04:13:22	2026-10-14 04:13:22
19	28	11	6.000	2026-10-14 04:15:17	2026-10-14 04:15:17
20	29	66	1.000	2026-10-14 04:27:09	2026-10-14 04:27:09
21	30	66	1.000	2026-10-14 04:27:24	2026-10-14 04:27:24
22	31	15	28.000	2026-10-14 05:55:59	2026-10-14 05:55:59
23	32	12	17.000	2026-10-14 06:36:33	2026-10-14 06:36:33
24	33	54	6.000	2026-10-14 06:44:05	2026-10-14 06:44:05
25	34	54	6.000	2026-10-14 07:25:13	2026-10-14 07:25:13
26	35	15	72.000	2026-10-14 07:27:41	2026-10-14 07:27:41
27	36	15	73.000	2026-10-14 07:30:00	2026-10-14 07:30:00
28	37	15	46.000	2026-10-14 07:31:36	2026-10-14 07:31:36
29	38	15	19.000	2026-10-14 07:32:34	2026-10-14 07:32:34
30	646	31	7.000	2026-10-14 09:20:00	2026-10-14 09:20:00
31	565	3	46.000	2026-10-14 09:28:10	2026-10-14 09:28:10
32	658	31	2.000	2026-10-14 09:31:07	2026-10-14 09:31:07
33	659	31	4.000	2026-10-14 09:35:28	2026-10-14 09:35:28
34	657	31	8.000	2026-10-14 09:36:27	2026-10-14 09:36:27
35	1487	54	39.000	2026-10-14 09:38:45	2026-10-14 09:38:45
37	582	5	10.000	2026-10-14 09:45:13	2026-10-14 09:45:13
38	604	5	7.000	2026-10-14 09:45:59	2026-10-14 09:45:59
39	583	5	2.000	2026-10-14 09:48:57	2026-10-14 09:48:57
40	643	5	6.000	2026-10-14 09:50:10	2026-10-14 09:50:10
41	1488	54	26.000	2026-10-14 09:59:37	2026-10-14 09:59:37
42	795	9	6.000	2026-10-15 00:53:39	2026-10-15 00:53:39
36	646	9	6.000	2026-10-14 09:41:08	2026-10-15 00:54:13
43	1530	47	17.000	2026-10-15 01:18:57	2026-10-15 01:18:57
44	643	3	12.000	2026-10-15 01:37:04	2026-10-15 01:37:04
45	1526	9	21.000	2026-10-15 01:40:02	2026-10-15 01:40:02
46	1420	40	25.000	2026-10-15 01:48:37	2026-10-15 01:48:37
47	1262	40	11.000	2026-10-15 01:51:39	2026-10-15 01:51:39
48	1208	40	15.000	2026-10-15 01:52:15	2026-10-15 01:52:15
49	61	40	20.000	2026-10-15 01:53:13	2026-10-15 01:53:13
50	1369	40	20.000	2026-10-15 01:54:07	2026-10-15 01:54:07
51	1729	36	117.000	2026-10-15 01:57:00	2026-10-15 01:57:00
52	1303	2	15.000	2026-10-15 02:01:10	2026-10-15 02:01:10
53	1294	2	3.000	2026-10-15 02:01:44	2026-10-15 02:01:44
54	1373	2	0.000	2026-10-15 02:02:24	2026-10-15 02:02:55
55	1373	29	5.000	2026-10-15 02:02:55	2026-10-15 02:02:55
56	451	41	14.000	2026-10-15 02:04:08	2026-10-15 02:04:08
57	1730	16	123.000	2026-10-15 02:05:25	2026-10-15 02:05:25
58	1396	66	3.000	2026-10-15 02:06:34	2026-10-15 02:06:34
59	1078	66	0.000	2026-10-15 02:08:01	2026-10-15 02:08:23
60	1078	8	26.000	2026-10-15 02:08:23	2026-10-15 02:08:23
61	1078	55	2.000	2026-10-15 02:10:12	2026-10-15 02:10:12
62	928	55	2.000	2026-10-15 02:10:57	2026-10-15 02:10:57
63	157	8	19.000	2026-10-15 02:11:36	2026-10-15 02:11:36
64	967	55	3.000	2026-10-15 02:12:30	2026-10-15 02:12:30
65	953	55	6.000	2026-10-15 02:16:27	2026-10-15 02:16:27
66	746	7	13.000	2026-10-15 02:17:13	2026-10-15 02:17:13
67	115	7	6.000	2026-10-15 02:21:56	2026-10-15 02:21:56
68	1283	7	19.000	2026-10-15 02:22:49	2026-10-15 02:22:49
69	153	7	2.000	2026-10-15 02:23:34	2026-10-15 02:23:34
70	747	29	5.000	2026-10-15 02:25:41	2026-10-15 02:25:41
71	791	29	0.000	2026-10-15 02:26:24	2026-10-15 02:27:05
72	306	29	7.000	2026-10-15 02:27:45	2026-10-15 02:27:45
73	761	29	0.000	2026-10-15 02:28:27	2026-10-15 02:30:36
74	778	29	9.000	2026-10-15 02:29:32	2026-10-15 02:30:45
75	760	29	18.000	2026-10-15 02:31:16	2026-10-15 02:31:16
76	790	29	0.000	2026-10-15 02:31:54	2026-10-15 02:32:11
77	790	30	11.000	2026-10-15 02:32:11	2026-10-15 02:32:11
78	1023	57	260.000	2026-10-15 02:33:38	2026-10-15 02:35:37
80	1077	56	80.000	2026-10-15 02:37:34	2026-10-15 02:37:34
82	1731	18	21.000	2026-10-15 02:49:38	2026-10-15 02:49:38
83	1732	13	55.000	2026-10-15 03:08:21	2026-10-15 03:08:21
84	34	21	311.000	2026-10-15 03:10:17	2026-10-15 03:10:17
85	1733	22	182.000	2026-10-15 03:11:37	2026-10-15 03:11:37
86	1081	58	60.000	2026-10-15 03:31:42	2026-10-15 03:31:42
87	1734	19	27.000	2026-10-15 03:34:07	2026-10-15 03:34:07
88	1735	23	88.000	2026-10-15 03:35:20	2026-10-15 03:35:20
89	1736	20	74.000	2026-10-15 03:36:27	2026-10-15 03:36:27
90	1026	56	20.000	2026-10-15 03:43:06	2026-10-15 03:43:06
91	1737	32	27.000	2026-10-15 03:49:39	2026-10-15 03:49:39
92	1738	33	46.000	2026-10-15 03:51:00	2026-10-15 03:51:00
93	1739	14	41.000	2026-10-15 04:05:48	2026-10-15 04:05:48
94	1740	35	30.000	2026-10-15 04:22:06	2026-10-15 04:22:06
95	1741	19	55.000	2026-10-15 04:24:07	2026-10-15 04:24:07
96	1742	35	15.000	2026-10-15 04:26:20	2026-10-15 04:26:20
97	1735	54	9.000	2026-10-15 04:28:09	2026-10-15 04:28:09
98	1743	54	30.000	2026-10-15 04:28:32	2026-10-15 04:28:32
99	1744	12	10.000	2026-10-15 04:31:04	2026-10-15 04:31:04
100	1730	15	77.000	2026-10-15 04:32:51	2026-10-15 04:32:51
101	1745	15	15.000	2026-10-15 04:33:55	2026-10-15 04:33:55
102	1746	15	9.000	2026-10-15 04:34:39	2026-10-15 04:34:39
103	1489	54	22.000	2026-10-15 04:35:09	2026-10-15 04:35:09
105	1411	51	32.000	2026-10-15 04:47:07	2026-10-15 04:47:07
104	1410	51	46.000	2026-10-15 04:46:09	2026-10-15 04:47:26
106	1413	51	35.000	2026-10-15 04:47:55	2026-10-15 04:47:55
107	168	2	18.000	2026-10-15 04:48:45	2026-10-15 04:48:45
109	154	2	0.000	2026-10-15 04:49:45	2026-10-15 04:51:44
81	35	17	1796.000	2026-10-15 02:39:14	2026-10-16 06:42:25
108	99	2	0.000	2026-10-15 04:49:21	2026-10-15 04:51:34
110	276	2	18.000	2026-10-15 04:52:26	2026-10-15 04:52:26
111	1423	2	11.000	2026-10-15 04:53:05	2026-10-15 04:53:05
112	1422	2	3.000	2026-10-15 04:53:29	2026-10-15 04:53:29
113	1429	39	32.000	2026-10-15 04:54:21	2026-10-15 04:54:21
114	1424	41	46.000	2026-10-15 04:55:44	2026-10-15 04:57:30
115	1436	38	25.000	2026-10-15 04:58:07	2026-10-15 04:58:07
118	1392	32	0.000	2026-10-15 05:00:40	2026-10-15 05:00:58
117	1422	32	22.000	2026-10-15 05:00:08	2026-10-15 05:01:58
116	1423	32	17.000	2026-10-15 04:59:35	2026-10-15 05:02:22
119	1437	38	39.000	2026-10-15 05:48:03	2026-10-15 05:48:03
120	1431	38	30.000	2026-10-15 05:48:41	2026-10-15 05:48:41
121	1081	42	39.000	2026-10-15 05:49:34	2026-10-15 05:49:34
122	1078	42	2.000	2026-10-15 05:50:05	2026-10-15 05:50:05
123	157	4	18.000	2026-10-15 05:51:07	2026-10-15 05:51:07
124	92	4	18.000	2026-10-15 05:51:37	2026-10-15 05:51:37
125	95	4	12.000	2026-10-15 05:52:16	2026-10-15 05:52:16
126	74	4	47.000	2026-10-15 05:52:44	2026-10-15 05:52:44
127	104	4	2.000	2026-10-15 05:54:33	2026-10-15 05:54:33
128	580	6	30.000	2026-10-15 05:55:32	2026-10-15 05:55:32
129	565	6	22.000	2026-10-15 05:56:13	2026-10-15 05:56:13
130	364	44	7.000	2026-10-15 05:58:42	2026-10-15 05:58:42
131	368	44	38.000	2026-10-15 05:59:17	2026-10-15 05:59:17
132	385	44	8.000	2026-10-15 05:59:58	2026-10-15 05:59:58
133	854	4	28.000	2026-10-15 06:00:54	2026-10-15 06:00:54
134	885	4	1.000	2026-10-15 06:01:16	2026-10-15 06:01:16
135	888	4	1.000	2026-10-15 06:01:39	2026-10-15 06:01:39
136	1553	4	14.000	2026-10-15 06:02:10	2026-10-15 06:02:10
137	899	4	1.000	2026-10-15 06:02:27	2026-10-15 06:02:27
138	849	4	17.000	2026-10-15 06:02:51	2026-10-15 06:02:51
139	1022	43	27.000	2026-10-15 06:07:44	2026-10-15 06:07:44
140	1023	43	8.000	2026-10-15 06:08:17	2026-10-15 06:08:17
141	1051	43	20.000	2026-10-15 06:09:19	2026-10-15 06:09:19
142	1055	43	20.000	2026-10-15 06:10:06	2026-10-15 06:10:06
143	1009	5	26.000	2026-10-15 06:10:51	2026-10-15 06:10:51
144	954	5	6.000	2026-10-15 06:11:36	2026-10-15 06:11:36
145	986	5	19.000	2026-10-15 06:12:25	2026-10-15 06:12:25
146	962	5	46.000	2026-10-15 06:17:56	2026-10-15 06:17:56
147	1019	6	16.000	2026-10-15 06:18:44	2026-10-15 06:18:44
148	1654	50	29.000	2026-10-15 06:19:26	2026-10-15 06:19:26
149	1656	50	29.000	2026-10-15 06:22:50	2026-10-15 06:22:50
150	1637	37	16.000	2026-10-15 06:28:26	2026-10-15 06:28:26
151	1638	37	20.000	2026-10-15 06:29:00	2026-10-15 06:29:00
152	1640	37	20.000	2026-10-15 06:29:39	2026-10-15 06:29:39
153	1645	47	22.000	2026-10-15 06:30:42	2026-10-15 06:30:42
154	1648	47	20.000	2026-10-15 06:31:30	2026-10-15 06:31:30
155	1649	47	18.000	2026-10-15 06:31:53	2026-10-15 06:31:53
156	1598	48	19.000	2026-10-15 06:32:36	2026-10-15 06:33:02
157	1603	48	25.000	2026-10-15 06:33:41	2026-10-15 06:33:41
158	1599	48	2.000	2026-10-15 06:34:19	2026-10-15 06:34:19
159	1565	48	1.000	2026-10-15 06:34:47	2026-10-15 06:34:47
160	1527	46	20.000	2026-10-15 06:36:08	2026-10-15 06:36:08
161	1525	45	20.000	2026-10-15 06:37:02	2026-10-15 06:37:02
162	973	68	7.000	2026-10-15 06:41:39	2026-10-15 06:41:39
163	1396	68	14.000	2026-10-15 06:42:01	2026-10-15 06:42:01
164	748	68	11.000	2026-10-15 06:42:41	2026-10-15 06:42:41
165	573	68	14.000	2026-10-15 06:43:20	2026-10-15 06:43:20
166	307	68	16.000	2026-10-15 06:43:55	2026-10-15 06:43:55
167	568	68	16.000	2026-10-15 06:44:19	2026-10-15 06:44:19
168	309	68	4.000	2026-10-15 06:44:51	2026-10-15 06:44:51
169	925	61	5.000	2026-10-15 06:46:29	2026-10-15 06:46:29
170	1074	61	8.000	2026-10-15 06:47:38	2026-10-15 06:47:38
171	941	61	19.000	2026-10-15 06:48:46	2026-10-15 06:48:46
172	940	61	9.000	2026-10-15 07:23:43	2026-10-15 07:23:43
173	950	61	3.000	2026-10-15 07:24:36	2026-10-15 07:24:36
174	945	61	2.000	2026-10-15 07:25:29	2026-10-15 07:25:29
175	969	61	28.000	2026-10-15 07:28:40	2026-10-15 07:28:40
176	966	61	53.000	2026-10-15 07:29:08	2026-10-15 07:29:08
177	1080	62	10.000	2026-10-15 07:29:59	2026-10-15 07:29:59
179	1079	62	3.000	2026-10-15 07:31:48	2026-10-15 07:31:48
180	949	65	40.000	2026-10-15 08:12:35	2026-10-15 08:12:35
181	943	65	66.000	2026-10-15 08:13:03	2026-10-15 08:13:03
182	1077	62	43.000	2026-10-15 08:13:47	2026-10-15 08:13:47
183	1029	63	17.000	2026-10-15 08:16:36	2026-10-15 08:16:36
178	1026	63	38.000	2026-10-15 07:30:50	2026-10-15 08:19:07
184	958	63	3.000	2026-10-15 08:19:42	2026-10-15 08:19:42
185	1052	63	3.000	2026-10-15 08:20:23	2026-10-15 08:20:23
186	1030	63	7.000	2026-10-15 08:22:12	2026-10-15 08:22:12
187	1023	61	62.000	2026-10-15 08:23:00	2026-10-15 08:23:00
188	1003	61	2.000	2026-10-15 08:24:32	2026-10-15 08:24:32
189	963	61	20.000	2026-10-15 08:25:16	2026-10-15 08:25:16
190	963	62	299.000	2026-10-15 08:25:51	2026-10-15 08:25:51
191	968	61	5.000	2026-10-15 08:28:05	2026-10-15 08:28:05
192	961	61	13.000	2026-10-15 08:28:37	2026-10-15 08:28:37
193	930	61	4.000	2026-10-15 08:29:31	2026-10-15 08:29:31
194	964	61	1.000	2026-10-15 08:30:14	2026-10-15 08:30:14
195	970	61	1.000	2026-10-15 08:32:01	2026-10-15 08:32:01
196	1046	64	6.000	2026-10-15 08:33:34	2026-10-15 08:33:34
197	1048	64	11.000	2026-10-15 08:34:14	2026-10-15 08:34:14
198	1043	64	10.000	2026-10-15 08:34:49	2026-10-15 08:34:49
199	1056	64	3.000	2026-10-15 08:35:21	2026-10-15 08:35:21
201	1148	64	20.000	2026-10-15 08:37:26	2026-10-15 08:37:26
200	1029	64	0.000	2026-10-15 08:36:04	2026-10-15 08:37:58
202	1029	67	45.000	2026-10-15 08:37:58	2026-10-15 08:37:58
203	1074	62	6.000	2026-10-15 08:38:47	2026-10-15 08:38:47
204	1747	64	30.000	2026-10-15 08:52:59	2026-10-15 08:52:59
205	970	66	36.000	2026-10-15 08:55:39	2026-10-15 08:55:39
206	964	66	23.000	2026-10-15 08:56:29	2026-10-15 08:56:29
207	987	66	1.000	2026-10-15 08:56:52	2026-10-15 08:56:52
208	1021	63	1.000	2026-10-15 08:57:39	2026-10-15 08:57:39
209	1025	63	3.000	2026-10-15 08:58:09	2026-10-15 08:58:09
210	1028	63	12.000	2026-10-15 08:58:41	2026-10-15 08:58:41
212	1036	63	0.000	2026-10-15 09:06:04	2026-10-15 09:06:33
213	1036	65	6.000	2026-10-15 09:06:33	2026-10-15 09:06:33
211	975	63	0.000	2026-10-15 09:05:24	2026-10-15 09:06:44
214	975	65	25.000	2026-10-15 09:06:44	2026-10-15 09:06:44
215	1054	65	3.000	2026-10-15 09:07:22	2026-10-15 09:07:22
216	1042	65	5.000	2026-10-15 09:16:05	2026-10-15 09:16:05
217	1040	65	1.000	2026-10-15 09:16:49	2026-10-15 09:16:49
218	1038	65	5.000	2026-10-15 09:17:21	2026-10-15 09:17:21
219	1083	65	3.000	2026-10-15 09:21:14	2026-10-15 09:21:14
220	1085	65	2.000	2026-10-15 09:21:41	2026-10-15 09:21:41
221	1018	65	5.000	2026-10-15 09:22:23	2026-10-15 09:22:23
222	1012	65	6.000	2026-10-15 09:29:34	2026-10-15 09:29:34
223	1031	65	5.000	2026-10-15 09:30:06	2026-10-15 09:30:06
224	1064	65	5.000	2026-10-15 09:30:44	2026-10-15 09:30:44
225	1748	53	2.000	2026-10-16 02:12:11	2026-10-16 02:12:11
226	1749	53	2.000	2026-10-16 06:28:29	2026-10-16 06:28:29
227	1750	53	2.000	2026-10-16 06:30:27	2026-10-16 06:30:27
228	1751	53	22.000	2026-10-16 06:33:00	2026-10-16 06:33:00
229	1753	16	150.000	2026-10-16 06:41:17	2026-10-16 06:41:17
230	1754	16	38.000	2026-10-16 06:41:52	2026-10-16 06:41:52
231	1755	66	1.000	2026-10-16 06:43:00	2026-10-16 06:43:00
232	1076	66	10.000	2026-10-16 06:43:38	2026-10-16 06:43:38
233	1752	53	3.000	2026-10-16 07:17:02	2026-10-16 07:17:02
234	1764	75	34.000	2026-10-16 08:20:07	2026-10-16 08:20:07
236	1764	82	14.000	2026-10-16 08:20:47	2026-10-16 08:20:47
237	1759	75	100.000	2026-10-16 08:21:07	2026-10-16 08:21:07
241	1761	75	0.000	2026-10-16 08:22:45	2026-10-16 08:23:21
242	1761	77	30.000	2026-10-16 08:23:21	2026-10-16 08:23:21
239	1767	75	0.000	2026-10-16 08:21:44	2026-10-16 08:24:34
240	1767	79	50.000	2026-10-16 08:22:17	2026-10-16 08:25:15
243	1767	77	100.000	2026-10-16 08:24:58	2026-10-16 08:25:15
238	1756	75	0.000	2026-10-16 08:21:32	2026-10-16 08:26:17
244	1756	77	250.000	2026-10-16 08:25:50	2026-10-16 08:26:17
235	1758	75	180.000	2026-10-16 08:20:30	2026-10-16 08:27:07
245	1763	79	20.000	2026-10-16 08:27:57	2026-10-16 08:27:57
246	1765	79	29.000	2026-10-16 08:28:13	2026-10-16 08:28:13
247	1766	76	100.000	2026-10-16 08:28:31	2026-10-16 08:28:31
248	1762	78	40.000	2026-10-16 08:28:52	2026-10-16 08:28:52
249	1757	80	181.000	2026-10-16 08:29:29	2026-10-16 08:29:29
250	1760	80	20.000	2026-10-16 08:29:45	2026-10-16 08:29:45
251	1765	81	18.000	2026-10-16 08:30:11	2026-10-16 08:30:11
252	1772	82	30.000	2026-10-19 02:39:38	2026-10-19 02:39:38
253	1771	82	425.000	2026-10-19 02:40:01	2026-10-19 02:40:01
254	1774	77	100.000	2026-10-19 02:40:24	2026-10-19 02:40:24
255	1773	77	175.000	2026-10-19 02:40:39	2026-10-19 02:40:39
256	1776	77	450.000	2026-10-19 02:40:59	2026-10-19 02:40:59
257	1775	77	300.000	2026-10-19 02:42:14	2026-10-19 02:42:14
258	1769	76	100.000	2026-10-19 02:42:44	2026-10-19 02:42:44
259	1778	76	250.000	2026-10-19 02:43:11	2026-10-19 02:43:11
260	1777	76	25.000	2026-10-19 02:43:32	2026-10-19 02:43:32
261	1782	78	50.000	2026-10-19 02:44:01	2026-10-19 02:44:01
262	1781	78	30.000	2026-10-19 02:44:19	2026-10-19 02:44:19
263	1780	78	175.000	2026-10-19 02:44:40	2026-10-19 02:44:40
264	1779	78	50.000	2026-10-19 02:45:03	2026-10-19 02:45:03
265	1783	80	75.000	2026-10-19 02:45:24	2026-10-19 02:45:24
266	1770	77	100.000	2026-10-19 02:45:46	2026-10-19 02:45:46
267	1785	73	450.000	2026-10-19 02:53:58	2026-10-19 02:53:58
268	1784	73	275.000	2026-10-19 02:55:13	2026-10-19 02:55:13
269	1784	74	300.000	2026-10-19 02:55:50	2026-10-19 02:55:50
270	1788	74	325.000	2026-10-19 02:56:16	2026-10-19 02:56:16
271	1787	74	400.000	2026-10-19 02:56:38	2026-10-19 02:56:38
272	1786	74	425.000	2026-10-19 02:56:57	2026-10-19 02:56:57
273	1792	1	1.000	2026-10-19 03:26:00	2026-10-19 03:26:00
274	1791	1	1.000	2026-10-19 03:26:19	2026-10-19 03:26:19
275	1789	1	10.000	2026-10-19 03:26:31	2026-10-19 03:26:31
276	1790	1	10.000	2026-10-19 03:26:43	2026-10-19 03:26:43
\.


--
-- Data for Name: product_types; Type: TABLE DATA; Schema: public; Owner: gidrovik-admin
--

COPY product_types (id, category_id, name, slug, is_active, created_at, updated_at) FROM stdin;
2	1	Гайка	female	t	2026-10-12 08:55:14	2026-10-12 08:57:27
3	1	Штуцер	male	t	2026-10-12 08:57:52	2026-10-12 08:57:52
4	1	Фланец	flange	t	2026-10-14 03:44:20	2026-10-14 03:44:20
5	2	2 SN	2sn	t	2026-10-14 04:41:13	2026-10-14 04:41:13
6	2	Желтые 2 SN	yellow2sn	t	2026-10-14 04:41:40	2026-10-14 04:41:40
8	2	4 SH	4sh	t	2026-10-14 05:54:27	2026-10-14 05:54:27
9	2	4 SP	4sp	t	2026-10-14 05:54:43	2026-10-14 05:54:43
10	2	1 SN	1sn	t	2026-10-14 07:30:39	2026-10-14 07:30:39
11	2	3 SN	3sn	t	2026-10-16 06:39:31	2026-10-16 06:39:31
12	4	Силовые	power	t	2026-10-16 06:54:59	2026-10-16 06:54:59
13	4	Червячные	worm	t	2026-10-16 07:11:35	2026-10-16 07:11:35
14	7	ТЭП	tep	t	2026-10-19 03:08:11	2026-10-19 03:08:11
15	7	Газ/дым	gas-smoke	t	2026-10-19 03:09:12	2026-10-19 03:09:12
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: gidrovik-admin
--

COPY products (id, category_id, product_type_id, name, sku, angle, description, is_active, created_at, updated_at, manufacturer_id, country_id, unit, minimum_stock) FROM stdin;
49	1	2	Фитинг Интерлок, d-25mm, BSP, Г, 1, 0°	00-00003647	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
50	1	2	Фитинг Интерлок, d-25mm, BSP, Г, 1, 0°, Italy	00-00006971	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
51	1	2	Фитинг Интерлок, d-25mm, BSP, Г, 1, 45°, o-ring Italy	00-00011843	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
52	1	2	Фитинг Интерлок, d-25mm, BSP, Г, 1, 90°, Italy	00-00006973	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
11	1	2	Фитинг, d-8mm, DKOS, Г, 20*1,5, 90°	00-00011825	90	\N	t	2026-10-14 03:27:07	2026-10-14 03:27:07	\N	\N	шт.	\N
12	1	2	Фитинг, d-20mm, DKOS, Г, 36*2, 0°	00-00000419	\N	\N	t	2026-10-14 03:30:33	2026-10-14 03:30:33	\N	\N	шт.	\N
14	1	2	Фитинг, d-12mm, DKOS, Г, 24*1,5, 90°	00-00020805	90	\N	t	2026-10-14 03:33:37	2026-10-14 03:33:37	\N	\N	шт.	\N
13	1	2	Фитинг, d-25mm, DKOL, Г, 42*2, 45	00-00000450	45	\N	t	2026-10-14 03:31:53	2026-10-14 03:34:07	\N	\N	шт.	\N
15	1	2	Фитинг, d-25mm, DKOS, Г, 36*2, 0°	00-00008857	\N	\N	t	2026-10-14 03:36:50	2026-10-14 03:36:50	\N	\N	шт.	\N
16	1	2	Фитинг, d-20mm, DKOS, Г, 36*2, 90°	00-00000421	90	\N	t	2026-10-14 03:39:32	2026-10-14 03:39:32	\N	\N	шт.	\N
17	1	2	Фитинг, d-38mm, DKOL, Г, 52*2, 45	00-00000441	45	\N	t	2026-10-14 03:41:36	2026-10-14 03:41:36	\N	\N	шт.	\N
18	1	2	Фитинг, d-38mm, DKOL, Г, 52*2, 90°	00-00000442	90	\N	t	2026-10-14 03:42:46	2026-10-14 03:42:46	\N	\N	шт.	\N
19	1	2	Фитинг, d-12mm, ORFS, Г, 1, 0°	00-00003157	\N	\N	t	2026-10-14 03:45:46	2026-10-14 03:45:46	\N	\N	шт.	\N
21	1	2	Фитинг, d-12mm, ORFS, Г, 1, 45°	00-00003158	45	\N	t	2026-10-14 03:52:53	2026-10-14 03:52:53	\N	\N	шт.	\N
20	1	2	Фитинг, d-12mm, JIC, Г, 1,1/16, 90°	00-00000622	90	\N	t	2026-10-14 03:49:55	2026-10-14 03:53:03	\N	\N	шт.	\N
22	1	2	Фитинг, d-8mm, DKOL, Г, 16*1,5, 90°	00-00000350	90	\N	t	2026-10-14 03:54:40	2026-10-14 03:54:40	\N	\N	шт.	\N
23	1	2	Фитинг, d-8mm, DKOL, Г, 16*1,5, 45	00-00000349	45	\N	t	2026-10-14 03:56:34	2026-10-14 03:56:34	\N	\N	шт.	\N
24	1	2	Фитинг, d-8mm, DKOL, Г, 16*1,5, 0°	00-00000348	\N	\N	t	2026-10-14 03:57:33	2026-10-14 03:57:33	\N	\N	шт.	\N
25	1	3	Фитинг, d-25mm, DKOL, Ш, 36*2, 0°	00-00000337	\N	\N	t	2026-10-14 04:04:07	2026-10-14 04:04:07	\N	\N	шт.	\N
26	1	2	Фитинг, d-16mm, DKOS, Г, 26*1,5, 90°	00-00032401	90	\N	t	2026-10-14 04:11:26	2026-10-14 04:11:26	\N	\N	шт.	\N
27	1	3	Фитинг, d-25mm, DKOS, Ш, 42*2, 0°	00-00008856	\N	\N	t	2026-10-14 04:13:05	2026-10-14 04:13:05	\N	\N	шт.	\N
28	1	2	Фитинг, d-12mm, DKOS, Г, 22*1,5, 45°	00-00013167	45	\N	t	2026-10-14 04:14:23	2026-10-14 04:14:23	\N	\N	шт.	\N
29	1	3	Фитинг, d-25mm, DKOS, Ш, 42*2, 0° Interlock	00-00032402	\N	\N	t	2026-10-14 04:22:22	2026-10-14 04:22:22	\N	\N	шт.	\N
30	1	2	Фитинг, d-32mm, DKOS, Г, 52*2, 0° Interlock	00-00032403	\N	\N	t	2026-10-14 04:23:25	2026-10-14 04:26:51	\N	\N	шт.	\N
31	2	5	Муфта, Italy, 2SN, d-5mm	00-00003424	\N	\N	t	2026-10-14 05:55:45	2026-10-14 05:55:45	\N	1	шт.	\N
32	2	5	Муфта, Italy, 2SN, d-16mm	00-00002174	\N	\N	t	2026-10-14 05:59:06	2026-10-14 05:59:06	\N	1	шт.	\N
33	2	8	Муфта, Interlock Italy, 4SH, d-20mm	00-00012412	\N	\N	t	2026-10-14 06:42:37	2026-10-14 06:42:37	\N	\N	шт.	\N
35	2	5	Муфта, Italy, 2SN, d-6mm	00-00002805	\N	\N	t	2026-10-14 07:26:39	2026-10-14 07:26:39	\N	1	шт.	\N
34	2	9	Муфта, Italy, 4SP, d-20mm	00-00006721	\N	\N	t	2026-10-14 07:24:46	2026-10-14 07:27:01	\N	1	шт.	\N
36	2	5	Муфта, Italy, 2SN, d-10mm	00-00004317	\N	\N	t	2026-10-14 07:29:01	2026-10-14 07:29:01	\N	1	шт.	\N
37	2	10	Муфта, Italy, 1SN, d-10mm	00-00008794	\N	\N	t	2026-10-14 07:31:11	2026-10-14 07:31:11	\N	1	шт.	\N
38	2	10	Муфта, Стандарт, 1SN, d-10mm	00-00000043	\N	\N	t	2026-10-14 07:32:12	2026-10-14 07:32:12	\N	\N	шт.	\N
39	1	2	Фитинг, d-10mm, BSP, Г, 1/2, 0, Italy	00-00011734	\N	\N	t	2026-10-14 07:42:21	2026-10-14 07:42:21	\N	1	шт.	\N
40	1	2	Фитинг, d-10mm, BSP, Г, 1/2, 0°	00-00000075	\N	\N	t	2026-10-14 07:42:21	2026-10-14 07:42:21	\N	\N	шт.	\N
41	1	2	Фитинг, d-10mm, BSP, Г, 1/2, 45°	00-00003098	45	\N	t	2026-10-14 07:42:21	2026-10-14 07:42:21	\N	\N	шт.	\N
42	1	2	Фитинг, d-10mm, BSP, Г, 1/2, 45°, Italy	00-00003100	45	\N	t	2026-10-14 07:42:21	2026-10-14 07:42:21	\N	1	шт.	\N
43	1	2	Фитинг Интерлок, d-20mm, BSP, Г, 3/4, 0, o-ring Italy	00-00012021	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
44	1	2	Фитинг Интерлок, d-20mm, BSP, Г, 3/4, 0°	00-00003642	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
45	1	2	Фитинг Интерлок, d-20mm, BSP, Г, 3/4, 45°, Italy	00-00011828	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
46	1	2	Фитинг Интерлок, d-20mm, BSP, Г, 3/4, 90°	00-00031805	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
47	1	2	Фитинг Интерлок, d-20mm, BSP, Г, 3/4, 90°, o-ring Italy	00-00012022	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
48	1	2	Фитинг Интерлок, d-25mm, BSP, Г, 1, 0, o-ring Italy	00-00011842	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
53	1	2	Фитинг Интерлок, d-25mm, BSP, Г, 1,1/4, 90°	00-00003648	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
54	1	3	Фитинг Интерлок, d-25mm, BSP, Ш, 1, 0, Italy	00-00011732	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
55	1	2	Фитинг Интерлок, d-32mm, BSP, Г, 1,1/4, 0, o-ring Italy	00-00011844	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
56	1	2	Фитинг Интерлок, d-32mm, BSP, Г, 1,1/4, 0°	00-00003649	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
57	1	2	Фитинг Интерлок, d-32mm, BSP, Г, 1,1/4, 45°	00-00018803	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
58	1	2	Фитинг Интерлок, d-32mm, BSP, Г, 1,1/4, 45°, o-ring Italy	00-00011845	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
59	1	2	Фитинг Интерлок, d-32mm, BSP, Г, 1,1/4, 90°	00-00003650	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
60	1	2	Фитинг Интерлок, d-32mm, BSP, Г, 1,1/4, 90°, o-ring Italy	00-00011846	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
61	1	2	Фитинг Интерлок, d-38mm, BSP, Г, 1,1/2, 0	00-00018402	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
62	1	2	Фитинг Интерлок, d-50mm, BSP, Г, 2, 0, Italy	00-00026567	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
63	1	2	Фитинг Интерлок, d-50mm, BSP, Г, 2, 0°	00-00006974	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
64	1	2	Фитинг, d-10mm, BSP, Г, 1/2, 90°	00-00003099	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
65	1	2	Фитинг, d-10mm, BSP, Г, 1/2, 90°, Italy	00-00011847	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
66	1	2	Фитинг, d-10mm, BSP, Г, 1/4, 0, Italy	00-00012034	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
67	1	2	Фитинг, d-10mm, BSP, Г, 1/4, 0, o-ring	00-00011735	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
68	1	2	Фитинг, d-10mm, BSP, Г, 1/4, 0°	00-00000470	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
69	1	2	Фитинг, d-10mm, BSP, Г, 1/4, 45°	00-00000471	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
70	1	2	Фитинг, d-10mm, BSP, Г, 1/4, 45°, Italy	00-00011829	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
71	1	2	Фитинг, d-10mm, BSP, Г, 1/4, 90°	00-00000472	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
72	1	2	Фитинг, d-10mm, BSP, Г, 1/4, 90°, Italy	00-00011830	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
73	1	2	Фитинг, d-10mm, BSP, Г, 3/8, 0, Italy	00-00011831	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
74	1	2	Фитинг, d-10mm, BSP, Г, 3/8, 0°	00-00000050	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
75	1	2	Фитинг, d10mm, BSP, Г, 3/8, 0°, oring	00-00020039	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
76	1	2	Фитинг, d-10mm, BSP, Г, 3/8, 0°, o-ring	00-00003640	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
77	1	2	Фитинг, d-10mm, BSP, Г, 3/8, 45	00-00000054	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
78	1	2	Фитинг, d-10mm, BSP, Г, 3/8, 45°, Italy	00-00003084	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
79	1	2	Фитинг, d-10mm, BSP, Г, 3/8, 90°	00-00000055	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
80	1	2	Фитинг, d-10mm, BSP, Г, 3/8, 90°, kompact	00-00003085	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
81	1	3	Фитинг, d-10mm, BSP, Ш, 1/2, 0	00-00011736	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
82	1	3	Фитинг, d-10mm, BSP, Ш, 1/2, 0, Italy	00-00012035	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
83	1	3	Фитинг, d-10mm, BSP, Ш, 1/4, 0°	00-00003082	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
84	1	3	Фитинг, d-10mm, BSP, Ш, 1/4, 0°, Italy	00-00003083	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
85	1	3	Фитинг, d-10mm, BSP, Ш, 3/8, 0, Italy	00-00012036	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
86	1	3	Фитинг, d-10mm, BSP, Ш, 3/8, 0°	00-00000067	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
87	1	2	Фитинг, d-10mm, BSPF, Г, 3/4, 0	00-00019779	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
88	1	3	Фитинг, d-10mm, BSP-L, Ш, 1/4, 0	00-00010214	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
89	1	3	Фитинг, d-10mm, BSPT, Ш, 1/4, 0	00-00023717	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
90	1	3	Фитинг, d-10mm, BSPT, Ш, 3/8, 0° S=17	00-00000068	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
91	1	2	Фитинг, d-10mm, JIS BSP, Г, 3/8, 0	00-00015786	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
92	1	2	Фитинг, d-12mm, BSP, Г, 1/2, 0°	00-00000051	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
93	1	2	Фитинг, d-12mm, BSP, Г, 1/2, 45	00-00000052	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
94	1	2	Фитинг, d-12mm, BSP, Г, 1/2, 45°, Italy	00-00011760	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
95	1	2	Фитинг, d-12mm, BSP, Г, 1/2, 90°	00-00000053	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
96	1	2	Фитинг, d-12mm, BSP, Г, 1/2, 90°, Italy	00-00011849	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
97	1	2	Фитинг, d-12mm, BSP, Г, 1/2, 90°, kompact	00-00003101	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
98	1	2	Фитинг, d-12mm, BSP, Г, 3/4, 0, Italy	00-00011850	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
99	1	2	Фитинг, d-12mm, BSP, Г, 3/4, 0°	00-00000486	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
100	1	2	Фитинг, d-12mm, BSP, Г, 3/4, 45°	00-00000487	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
101	1	2	Фитинг, d-12mm, BSP, Г, 3/4, 90°	00-00000488	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
102	1	2	Фитинг, d-12mm, BSP, Г, 3/8, 0, Italy	00-00011851	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
103	1	2	Фитинг, d-12mm, BSP, Г, 3/8, 0°	00-00000473	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
104	1	2	Фитинг, d-12mm, BSP, Г, 3/8, 45°	00-00000474	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
105	1	2	Фитинг, d-12mm, BSP, Г, 3/8, 45°, Italy	00-00011852	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
106	1	2	Фитинг, d-12mm, BSP, Г, 3/8, 90°	00-00000475	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
107	1	2	Фитинг, d-12mm, BSP, Г, 5/8, 0	00-00011665	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
108	1	2	Фитинг, d-12mm, BSP, Г, 5/8, 0, o-ring Italy	00-00011853	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
109	1	2	Фитинг, d-12mm, BSP, Г, 5/8, 45°	00-00020520	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
110	1	2	Фитинг, d-12mm, BSP, Г, 5/8, 45°, Italy	00-00011854	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
111	1	2	Фитинг, d-12mm, BSP, Г, 5/8, 90°	00-00012038	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
112	1	2	Фитинг, d-12mm, BSP, Г, 5/8, 90°, Italy	00-00011667	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
113	1	3	Фитинг, d-12mm, BSP, Ш, 1/2, 0, Italy	00-00011855	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
114	1	3	Фитинг, d-12mm, BSP, Ш, 1/2, 0, L35	00-00017998	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
115	1	3	Фитинг, d-12mm, BSP, Ш, 1/2, 0°	00-00000070	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
116	1	3	Фитинг, d-12mm, BSP, Ш, 1/2, 0°, L28	00-00001265	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
892	1	\N	Фитинг, d-8mm, Banjo, 1/4, 0°	00-00004333	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
117	1	3	Фитинг, d-12mm, BSP, Ш, 3/4, 0, Italy	00-00011668	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
118	1	3	Фитинг, d-12mm, BSP, Ш, 3/4, 0°	00-00001215	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
119	1	3	Фитинг, d-12mm, BSP, Ш, 3/8, 0°	00-00003089	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
120	1	3	Фитинг, d-12mm, BSP, Ш, 5/8, 90°, Italy	00-00011669	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
121	1	2	Фитинг, d-12mm, BSPF, Г, 1/2, 0°	00-00008106	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
122	1	2	Фитинг, d-12mm, BSPF, Г, 3/4, 0	00-00016479	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
123	1	3	Фитинг, d-12mm, BSPT, Ш, 1/2, 0°	00-00000069	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
124	1	3	Фитинг, d-12mm, BSPT, Ш, 3/4, 0°	00-00001246	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
125	1	3	Фитинг, d-12mm, BSPT, Ш, 3/8, 0°	00-00003090	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
126	1	2	Фитинг, d-16mm, BSP, Г, 1/2, 0°	00-00000492	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
127	1	2	Фитинг, d-16mm, BSP, Г, 1/2, 45°	00-00000493	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
128	1	2	Фитинг, d-16mm, BSP, Г, 1/2, 90°	00-00000494	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
129	1	2	Фитинг, d-16mm, BSP, Г, 3/4, 0, Italy	00-00012042	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
130	1	2	Фитинг, d-16mm, BSP, Г, 3/4, 0°	00-00000491	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
131	1	2	Фитинг, d-16mm, BSP, Г, 3/4, 45°	00-00000490	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
132	1	2	Фитинг, d-16mm, BSP, Г, 3/4, 90°	00-00000489	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
133	1	2	Фитинг, d-16mm, BSP, Г, 5/8, 0, Italy	00-00011672	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
134	1	2	Фитинг, d-16mm, BSP, Г, 5/8, 0°	00-00000483	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
135	1	2	Фитинг, d-16mm, BSP, Г, 5/8, 0°, HD	00-00003093	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
136	1	2	Фитинг, d-16mm, BSP, Г, 5/8, 0°, L29	00-00001266	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
137	1	2	Фитинг, d-16mm, BSP, Г, 5/8, 45°	00-00000484	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
138	1	2	Фитинг, d-16mm, BSP, Г, 5/8, 45°, Italy	00-00011673	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
139	1	2	Фитинг, d-16mm, BSP, Г, 5/8, 90°	00-00000485	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
140	1	2	Фитинг, d-16mm, BSP, Г, 5/8, 90°, Italy	00-00003094	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
141	1	3	Фитинг, d-16mm, BSP, Ш, 1/2, 0	00-00011674	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
142	1	3	Фитинг, d-16mm, BSP, Ш, 1/2, 0, Italy	00-00011832	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
143	1	3	Фитинг, d-16mm, BSP, Ш, 3/4, 0, Italy	00-00012043	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
144	1	3	Фитинг, d-16mm, BSP, Ш, 3/4, 0°	00-00003102	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
145	1	3	Фитинг, d-16mm, BSP, Ш, 5/8, 0, Italy	00-00011864	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
146	1	3	Фитинг, d-16mm, BSP, Ш, 5/8, 0°	00-00003095	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
147	1	2	Фитинг, d-20mm, BSP, Г, 1, 0, Italy	00-00011867	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
148	1	2	Фитинг, d-20mm, BSP, Г, 1, 0°	00-00003105	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
149	1	2	Фитинг, d-20mm, BSP, Г, 1, 45°	00-00003106	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
150	1	2	Фитинг, d-20mm, BSP, Г, 1, 90°	00-00010268	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
151	1	2	Фитинг, d-20mm, BSP, Г, 1, 90°, Italy	00-00012055	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
152	1	2	Фитинг, d-20mm, BSP, Г, 3/4, 0, контр.г	00-00010150	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
153	1	2	Фитинг, d-20mm, BSP, Г, 3/4, 0°	00-00000059	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
154	1	2	Фитинг, d-20mm, BSP, Г, 3/4, 0°, Italy	00-00003103	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
155	1	2	Фитинг, d-20mm, BSP, Г, 3/4, 45	00-00000060	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
156	1	2	Фитинг, d-20mm, BSP, Г, 3/4, 45°, Italy	00-00012056	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
157	1	2	Фитинг, d-20mm, BSP, Г, 3/4, 90°	00-00000061	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
158	1	2	Фитинг, d-20mm, BSP, Г, 3/4, 90°, Italy	00-00012057	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
159	1	3	Фитинг, d-20mm, BSP, Ш, 1, 0	00-00013174	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
160	1	3	Фитинг, d-20mm, BSP, Ш, 1/2, 0°	00-00003641	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
161	1	3	Фитинг, d-20mm, BSP, Ш, 3/4, 0, Italy	00-00011833	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
162	1	3	Фитинг, d-20mm, BSP, Ш, 3/4, 0° S=32	00-00000071	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
163	1	3	Фитинг, d-20mm, BSP, Ш, 3/4, 0°, L35	00-00003646	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
164	1	3	Фитинг, d-20mm, BSPT, Ш, 1, 0°	00-00028027	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
165	1	3	Фитинг, d-20mm, BSPT, Ш, 3/4, 0°	00-00000072	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
166	1	2	Фитинг, d-25mm, BSP, Г, 1, 0, Gates	00-00011873	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
167	1	2	Фитинг, d-25mm, BSP, Г, 1, 0, Italy	00-00011521	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
168	1	2	Фитинг, d-25mm, BSP, Г, 1, 0°	00-00000063	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
169	1	2	Фитинг, d-25mm, BSP, Г, 1, 45	00-00000064	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
170	1	2	Фитинг, d-25mm, BSP, Г, 1, 45°, Gates	00-00011874	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
171	1	2	Фитинг, d-25mm, BSP, Г, 1, 45°, Italy	00-00012069	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
172	1	2	Фитинг, d-25mm, BSP, Г, 1, 90°	00-00000062	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
173	1	2	Фитинг, d-25mm, BSP, Г, 1, 90°, Gates	00-00011875	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
174	1	2	Фитинг, d-25mm, BSP, Г, 1, 90°, Italy	00-00003107	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
175	1	2	Фитинг, d-25mm, BSP, Г, 1,1/4, 0°	00-00003108	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
176	1	2	Фитинг, d-25mm, BSP, Г, 1,1/4, 0°, Italy	00-00003109	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
177	1	2	Фитинг, d-25mm, BSP, Г, 1,1/4, 45°	00-00003111	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
178	1	2	Фитинг, d-25mm, BSP, Г, 1,1/4, 90°	00-00003112	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
179	1	2	Фитинг, d-25mm, BSP, Г, 3/4, 0	00-00013151	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
180	1	2	Фитинг, d-25mm, BSP, Г, 3/4, 90°	00-00003104	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
181	1	3	Фитинг, d-25mm, BSP, Ш, 1, 0, Italy	00-00011876	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
182	1	3	Фитинг, d-25mm, BSP, Ш, 1, 0°	00-00000074	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
183	1	3	Фитинг, d-25mm, BSP, Ш, 1,1/4, 0, Italy	00-00011877	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
184	1	3	Фитинг, d-25mm, BSP, Ш, 1,1/4, 0°	00-00003110	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
185	1	3	Фитинг, d-25mm, BSP, Ш, 3/4, 0	00-00013152	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
186	1	2	Фитинг, d-25mm, BSPF, Г, 1, 0°	00-00005226	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
187	1	3	Фитинг, d-25mm, BSPT, Ш, 1, 0°	00-00000073	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
188	1	\N	Фитинг, d-2mm, BSP, 1/4, L-26 мм 0° (для манометров)	00-00002830	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
189	1	2	Фитинг, d-32mm, BSP, Г, 1,1/2, 0°	00-00003821	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
190	1	2	Фитинг, d-32mm, BSP, Г, 1,1/2, 90°	00-00030809	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
191	1	2	Фитинг, d-32mm, BSP, Г, 1,1/4, 0, Italy	00-00011880	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
192	1	2	Фитинг, d-32mm, BSP, Г, 1,1/4, 0°	00-00000502	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
193	1	2	Фитинг, d-32mm, BSP, Г, 1,1/4, 45°	00-00000503	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
194	1	2	Фитинг, d-32mm, BSP, Г, 1,1/4, 90°	00-00000504	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
195	1	2	Фитинг, d-32mm, BSP, Г, 1,1/4, 90°, Italy	00-00003113	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
196	1	3	Фитинг, d-32mm, BSP, Ш, 1,1/4, 0, Italy	00-00011881	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
197	1	3	Фитинг, d-32mm, BSP, Ш, 1,1/4, 0°	00-00000501	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
198	1	3	Фитинг, d-32mm, BSPT, Ш, 1,1/4, 0	00-00026484	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
199	1	2	Фитинг, d-38mm, BSP, Г, 1,1/2, 0°	00-00000497	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
200	1	2	Фитинг, d-38mm, BSP, Г, 1,1/2, 45°	00-00000498	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
201	1	2	Фитинг, d-38mm, BSP, Г, 1,1/2, 90°	00-00000499	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
202	1	3	Фитинг, d-38mm, BSP, Ш, 1,1/2, 0°	00-00000500	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
203	1	2	Фитинг, d-50mm, BSP, Г, 1,1/4, 0°	00-00005907	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
204	1	2	Фитинг, d-50mm, BSP, Г, 2, 0°	00-00000518	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
205	1	2	Фитинг, d-50mm, BSP, Г, 2, 45°	00-00000541	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
206	1	2	Фитинг, d-50mm, BSP, Г, 2, 90°	00-00000558	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
207	1	3	Фитинг, d-50mm, BSP, Ш, 1,1/4, 0°	00-00005908	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
208	1	3	Фитинг, d-50mm, BSP, Ш, 2, 0°	00-00000559	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
209	1	2	Фитинг, d-5mm, BSP, Г, 1/4, 0°	00-00030295	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
210	1	2	Фитинг, d-5mm, BSP, Г, 1/4, 45°, Italy	00-00030433	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
211	1	2	Фитинг, d-5mm, BSP, Г, 1/4, 90°	00-00030296	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
212	1	2	Фитинг, d-5mm, BSP, Г, 1/8, 0, Italy	00-00010492	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
213	1	2	Фитинг, d-5mm, BSP, Г, 1/8, 0°	00-00003091	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
214	1	3	Фитинг, d-5mm, BSP, Ш, 1/8, 0, Italy	00-00010494	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
215	1	3	Фитинг, d-5mm, BSP, Ш, 1/8, 0°	00-00003092	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
216	1	2	Фитинг, d-5mm, JIS BSP, Г, 1/8, 0	00-00024433	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
217	1	2	Фитинг, d-6mm, BSP, Г, 1/2, 0°	00-00003633	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
218	1	2	Фитинг, d-6mm, BSP, Г, 1/2, 45°	00-00003634	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
219	1	2	Фитинг, d-6mm, BSP, Г, 1/2, 90°	00-00024190	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
220	1	2	Фитинг, d-6mm, BSP, Г, 1/4, 0°	00-00000056	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
221	1	2	Фитинг, d-6mm, BSP, Г, 1/4, 45	00-00000057	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
222	1	2	Фитинг, d-6mm, BSP, Г, 1/4, 90°	00-00000058	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
223	1	2	Фитинг, d-6mm, BSP, Г, 1/4, 90°, kompact	00-00003076	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
224	1	2	Фитинг, d-6mm, BSP, Г, 1/4, 90°, o-ring Italy	00-00012089	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
225	1	2	Фитинг, d-6mm, BSP, Г, 1/8, 0°	00-00001287	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
226	1	2	Фитинг, d-6mm, BSP, Г, 1/8, 45°	00-00000468	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
227	1	2	Фитинг, d-6mm, BSP, Г, 1/8, 90°	00-00000469	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
228	1	2	Фитинг, d-6mm, BSP, Г, 1/8, 90°, Italy	00-00011839	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
229	1	2	Фитинг, d-6mm, BSP, Г, 3/8, 0°	00-00000478	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
230	1	2	Фитинг, d-6mm, BSP, Г, 3/8, 0°, HD	00-00003097	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
231	1	2	Фитинг, d-6mm, BSP, Г, 3/8, 0°, Italy	00-00003096	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
232	1	2	Фитинг, d-6mm, BSP, Г, 3/8, 45°	00-00000477	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
233	1	2	Фитинг, d-6mm, BSP, Г, 3/8, 45°, Italy	00-00011840	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
234	1	2	Фитинг, d-6mm, BSP, Г, 3/8, 90°	00-00000476	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
235	1	2	Фитинг, d-6mm, BSP, Г, 3/8, 90°, Italy	00-00011841	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
236	1	3	Фитинг, d-6mm, BSP, Ш, 1/2, 0°	00-00003635	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
237	1	3	Фитинг, d-6mm, BSP, Ш, 1/4, 0 S=19	00-00010213	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
238	1	3	Фитинг, d-6mm, BSP, Ш, 1/4, 0°	00-00000066	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
239	1	3	Фитинг, d-6mm, BSP, Ш, 1/4, 0°, Italy	00-00003077	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
240	1	3	Фитинг, d-6mm, BSP, Ш, 1/8, 0	00-00020037	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
241	1	3	Фитинг, d-6mm, BSP, Ш, 1/8, 0°	00-00000467	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
242	1	3	Фитинг, d-6mm, BSP, Ш, 3/8, 0°	00-00003636	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
243	1	3	Фитинг, d-6mm, BSP-L, Ш, 1/8, 0	00-00010215	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
244	1	3	Фитинг, d-6mm, BSPT, Ш, 1/4, 0°	00-00000065	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
245	1	3	Фитинг, d-6mm, BSPT, Ш, 1/8, 0°	00-00001288	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
246	1	3	Фитинг, d-6mm, BSPT, Ш, 3/8, 0°	00-00003637	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
247	1	2	Фитинг, d-6mm, JIS BSP, Г, 1/8, 0°	00-00006878	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
248	1	2	Фитинг, d-8mm, BSP, Г, 1/2, 0, Italy	00-00011808	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
249	1	2	Фитинг, d-8mm, BSP, Г, 1/4, 0, Italy	00-00012091	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
250	1	2	Фитинг, d-8mm, BSP, Г, 1/4, 0°	00-00003078	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
251	1	2	Фитинг, d-8mm, BSP, Г, 1/4, 45°	00-00003080	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
252	1	2	Фитинг, d-8mm, BSP, Г, 1/4, 90°	00-00003081	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
253	1	2	Фитинг, d-8mm, BSP, Г, 1/4, 90°, Italy	00-00012092	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
254	1	2	Фитинг, d8mm, BSP, Г, 3/8, 0°	00-00020038	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
255	1	2	Фитинг, d-8mm, BSP, Г, 3/8, 0°	00-00000479	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
256	1	2	Фитинг, d-8mm, BSP, Г, 3/8, 0°, Italy	00-00003087	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
257	1	2	Фитинг, d-8mm, BSP, Г, 3/8, 45°	00-00000480	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
258	1	2	Фитинг, d-8mm, BSP, Г, 3/8, 45°, Italy	00-00011809	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
259	1	2	Фитинг, d-8mm, BSP, Г, 3/8, 90°	00-00000481	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
260	1	2	Фитинг, d-8mm, BSP, Г, 3/8, 90°, Italy	00-00011810	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
261	1	3	Фитинг, d-8mm, BSP, Ш, 1/2, 0, Italy	00-00011811	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
262	1	3	Фитинг, d-8mm, BSP, Ш, 1/2, 0°	00-00005972	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
263	1	3	Фитинг, d-8mm, BSP, Ш, 1/4, 0°	00-00005974	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
264	1	3	Фитинг, d-8mm, BSP, Ш, 1/8, 0°	00-00005973	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
265	1	3	Фитинг, d-8mm, BSP, Ш, 3/8, 0, Italy	00-00011814	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
266	1	3	Фитинг, d-8mm, BSP, Ш, 3/8, 0°	00-00003088	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
267	1	2	Фитинг, d-10mm, DK, Г, 10*1, 0°	00-00000542	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
268	1	2	Фитинг, d-10mm, DK, Г, 14*1,5, 0	00-00013127	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
269	1	2	Фитинг, d-10mm, DK, Г, 14*1,5, 45°	00-00013128	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
270	1	2	Фитинг, d-10mm, DK, Г, 14*1,5, 90°	00-00018332	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
271	1	2	Фитинг, d-10mm, DK, Г, 16*1,5, 0, Italy	00-00011660	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
272	1	2	Фитинг, d-10mm, DK, Г, 16*1,5, 0°	00-00000295	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
273	1	2	Фитинг, d-10mm, DK, Г, 16*1,5, 45	00-00000296	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
274	1	2	Фитинг, d-10mm, DK, Г, 16*1,5, 90°	00-00000297	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
275	1	2	Фитинг, d-10mm, DK, Г, 16*1,5, 90°, Italy	00-00009223	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
276	1	2	Фитинг, d-10mm, DK, Г, 18*1,5, 0	00-00000552	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
277	1	2	Фитинг, d-10mm, DK, Г, 18*1,5, 45	00-00000293	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
278	1	2	Фитинг, d-10mm, DK, Г, 18*1,5, 90°	00-00000294	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
279	1	2	Фитинг, d-10mm, DK, Г, 18*1,5, 90°, Italy	00-00003350	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
280	1	2	Фитинг, d-10mm, DK, Г, 20*1,5, 0°	00-00000277	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
281	1	2	Фитинг, d-10mm, DK, Г, 20*1,5, 45	00-00000278	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
282	1	2	Фитинг, d-10mm, DK, Г, 20*1,5, 90°	00-00000279	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
893	1	\N	Фитинг, d-8mm, Banjo, 10*1,5, 0°	00-00003790	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
283	1	2	Фитинг, d-10mm, DK, Г, 20*1,5, 90°, Italy	00-00011661	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
284	1	2	Фитинг, d-10mm, DK, Г, 22*1,5, 0°	00-00008671	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
285	1	2	Фитинг, d-10mm, DK, Г, 22*1,5, 45°	00-00000556	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
286	1	2	Фитинг, d-10mm, DK, Г, 22*1,5, 90°	00-00000560	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
287	1	2	Фитинг, d-10mm, DK, Г, 22*1,5, 90°, Italy	00-00011662	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
288	1	2	Фитинг, d-10mm, DK, Г, 24*1,5, 0°	00-00006402	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
289	1	3	Фитинг, d-10mm, DK, Ш, 14*1,5, 0°	00-00003654	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
290	1	3	Фитинг, d-10mm, DK, Ш, 16*1,5, 0°	00-00003655	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
291	1	3	Фитинг, d-10mm, DK, Ш, 16*1,5, 0°, токар.	00-00003569	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
292	1	3	Фитинг, d-10mm, DK, Ш, 18*1,5, 0°	00-00004520	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
293	1	3	Фитинг, d-10mm, DK, Ш, 18*1,5, 90°, Italy	00-00011727	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
294	1	3	Фитинг, d-10mm, DK, Ш, 20*1,5, 0°	00-00000276	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
295	1	3	Фитинг, d-10mm, DK, Ш, 22*1,5, 0	00-00011663	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
296	1	2	Фитинг, d-12mm, DK, Г, 18*1,5, 0	00-00011671	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
297	1	2	Фитинг, d-12mm, DK, Г, 18*1,5, 45°	00-00013165	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
298	1	2	Фитинг, d-12mm, DK, Г, 18*1,5, 90°	00-00013133	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
299	1	2	Фитинг, d-12mm, DK, Г, 20*1,5, 0	00-00000272	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
300	1	2	Фитинг, d-12mm, DK, Г, 20*1,5, 45	00-00000273	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
301	1	2	Фитинг, d-12mm, DK, Г, 20*1,5, 90°	00-00000274	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
302	1	2	Фитинг, d-12mm, DK, Г, 22*1,5, 0, (HS)	00-00009566	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
303	1	2	Фитинг, d-12mm, DK, Г, 22*1,5, 0°	00-00000077	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
304	1	2	Фитинг, d-12mm, DK, Г, 22*1,5, 45°	00-00009672	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
305	1	2	Фитинг, d-12mm, DK, Г, 22*1,5, 45°, Italy	00-00011670	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
306	1	2	Фитинг, d-12mm, DK, Г, 22*1,5, 90°	00-00000268	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
307	1	2	Фитинг, d-12mm, DK, Г, 24*1,5, 0°	00-00000271	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
308	1	2	Фитинг, d-12mm, DK, Г, 24*1,5, 45°	00-00003811	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
309	1	2	Фитинг, d-12mm, DK, Г, 24*1,5, 90°	00-00002719	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
310	1	2	Фитинг, d-12mm, DK, Г, 26*1,5, 0°	00-00003451	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
311	1	2	Фитинг, d-12mm, DK, Г, 26*1,5, 90°	00-00009860	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
312	1	2	Фитинг, d-12mm, DK, Г, 27*1,5, 0	00-00006430	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
313	1	2	Фитинг, d-12mm, DK, Г, 27*1,5, 90°	00-00029310	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
314	1	3	Фитинг, d-12mm, DK, Ш, 16*1,5, 0°	00-00003351	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
315	1	3	Фитинг, d-12mm, DK, Ш, 20*1,5, 0°	00-00000275	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
316	1	3	Фитинг, d-12mm, DK, Ш, 22*1,5, 0°	00-00000270	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
317	1	3	Фитинг, d-12mm, DK, Ш, 24*1,5, 0°	00-00003656	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
318	1	3	Фитинг, d-12mm, DK, Ш, 26*1,5, 0°	00-00001301	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
319	1	3	Фитинг, d-12mm, DK, Ш, 27*1,5, 0	00-00003660	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
320	1	2	Фитинг, d-12mm, DKL, Г, 22*1,5, 45°	00-00000269	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
321	1	2	Фитинг, d-12mm, DKL, Г, 22*1,5, 90°	00-00010049	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
322	1	2	Фитинг, d-12mm, DKL, Г, 24*1,5, 90°	00-00010050	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
323	1	2	Фитинг, d-16mm, DK, Г, 24*1,5, 0°	00-00001227	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
324	1	2	Фитинг, d-16mm, DK, Г, 24*1,5, 45°	00-00001262	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
325	1	2	Фитинг, d-16mm, DK, Г, 24*1,5, 90°	00-00001263	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
326	1	2	Фитинг, d-16mm, DK, Г, 26*1,5, 0°	00-00000285	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
327	1	2	Фитинг, d-16mm, DK, Г, 26*1,5, 45	00-00000286	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
328	1	2	Фитинг, d-16mm, DK, Г, 26*1,5, 90°	00-00000287	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
329	1	2	Фитинг, d-16mm, DK, Г, 27*1,5, 0°	00-00000280	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
330	1	2	Фитинг, d-16mm, DK, Г, 27*1,5, 45°	00-00000281	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
331	1	2	Фитинг, d-16mm, DK, Г, 27*1,5, 90°	00-00000282	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
332	1	2	Фитинг, d-16mm, DK, Г, 27*2, 0°	00-00003662	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
333	1	2	Фитинг, d-16mm, DK, Г, 27*2, 90°	00-00019814	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
334	1	2	Фитинг, d-16mm, DK, Г, 30*1,5, 0°	00-00003663	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
335	1	2	Фитинг, d-16mm, DK, Г, 30*2, 0°	00-00003664	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
336	1	2	Фитинг, d-16mm, DK, Г, 30*2, 90°	00-00003665	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
337	1	3	Фитинг, d-16mm, DK, Ш, 24*1,5, 0°	00-00003661	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
338	1	3	Фитинг, d-16mm, DK, Ш, 26*1,5, 0°	00-00000284	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
339	1	3	Фитинг, d-16mm, DK, Ш, 27*1,5, 0	00-00000283	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
340	1	3	Фитинг, d-16mm, DK, Ш, 27*2, 0°	00-00005979	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
341	1	2	Фитинг, d-16mm, DKL, Г, 26*1,5, 0	00-00010044	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
342	1	2	Фитинг, d-16mm, DKL, Г, 26*1,5, 90°	00-00010051	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
343	1	2	Фитинг, d-16mm, DKL, Г, 27*1,5, 0	00-00010042	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
344	1	2	Фитинг, d-20mm, DK, Г, 27*1,5, 0	00-00003666	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
345	1	2	Фитинг, d-20mm, DK, Г, 27*1,5, 90°	00-00004508	90	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
346	1	2	Фитинг, d-20mm, DK, Г, 27*2, 0°	00-00001300	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
347	1	2	Фитинг, d-20mm, DK, Г, 30*1,5, 0, Italy	00-00011675	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	1	шт.	\N
348	1	2	Фитинг, d-20mm, DK, Г, 30*1,5, 0°	00-00000288	\N	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
349	1	2	Фитинг, d-20mm, DK, Г, 30*1,5, 45	00-00000289	45	\N	t	2026-10-14 08:30:56	2026-10-14 08:30:56	\N	\N	шт.	\N
350	1	2	Фитинг, d-20mm, DK, Г, 30*1,5, 90°	00-00000290	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
351	1	2	Фитинг, d-20mm, DK, Г, 30*1,5, 90°, Italy	00-00011676	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
352	1	2	Фитинг, d-20mm, DK, Г, 30*2, 0°	00-00003522	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
353	1	2	Фитинг, d-20mm, DK, Г, 30*2, 45°	00-00003993	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
354	1	2	Фитинг, d-20mm, DK, Г, 30*2, 90°	00-00003994	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
355	1	2	Фитинг, d-20mm, DK, Г, 33*1,5, 0, (HS)	00-00009569	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
356	1	2	Фитинг, d-20mm, DK, Г, 33*1,5, 0°	00-00000338	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
357	1	2	Фитинг, d-20mm, DK, Г, 33*1,5, 0°, Italy	00-00005980	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
358	1	2	Фитинг, d-20mm, DK, Г, 33*1,5, 45°	00-00000561	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
359	1	2	Фитинг, d-20mm, DK, Г, 33*1,5, 90°	00-00000562	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
360	1	2	Фитинг, d-20mm, DK, Г, 33*2, 0°	00-00000565	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
361	1	2	Фитинг, d-20mm, DK, Г, 33*2, 45°	00-00000564	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
362	1	2	Фитинг, d-20mm, DK, Г, 33*2, 90°	00-00000563	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
363	1	2	Фитинг, d-20mm, DK, Г, 36*1,5, 0, (HS)	00-00009570	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
364	1	2	Фитинг, d-20mm, DK, Г, 36*1,5, 0°	00-00000571	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
365	1	2	Фитинг, d-20mm, DK, Г, 36*1,5, 45°	00-00000570	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
366	1	2	Фитинг, d-20mm, DK, Г, 36*1,5, 90°	00-00000569	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
367	1	2	Фитинг, d-20mm, DK, Г, 36*2, 0, (HS)	00-00009571	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
368	1	2	Фитинг, d-20mm, DK, Г, 36*2, 0°	00-00003995	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
369	1	2	Фитинг, d-20mm, DK, Г, 36*2, 45°	00-00000567	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
370	1	2	Фитинг, d-20mm, DK, Г, 36*2, 90°	00-00000568	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
371	1	2	Фитинг, d-20mm, DK, Г, 39*2, 0°	00-00003668	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
372	1	3	Фитинг, d-20mm, DK, Ш, 30*1,5, 0°	00-00000291	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
373	1	3	Фитинг, d-20mm, DK, Ш, 33*2, 0°	00-00003667	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
374	1	2	Фитинг, d-20mm, DKL, Г, 30*1,5, 0	00-00010045	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
375	1	2	Фитинг, d-20mm, DKL, Г, 33*1,5, 0	00-00010046	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
376	1	2	Фитинг, d-20mm, DKL, Г, 36*1,5, 0	00-00010047	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
377	1	2	Фитинг, d-20mm, DKL, Г, 36*2, 90°	00-00010053	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
378	1	2	Фитинг, d-25mm, DK, Г, 33*1,5, 0°	00-00003669	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
379	1	2	Фитинг, d-25mm, DK, Г, 33*1,5, 90°	00-00025686	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
380	1	2	Фитинг, d-25mm, DK, Г, 33*2, 0°	00-00001267	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
381	1	2	Фитинг, d-25mm, DK, Г, 33*2, 45°	00-00001268	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
382	1	2	Фитинг, d-25mm, DK, Г, 33*2, 90°	00-00001269	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
383	1	2	Фитинг, d-25mm, DK, Г, 36*1,5, 0°	00-00003670	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
384	1	2	Фитинг, d-25mm, DK, Г, 36*1,5, 90°	00-00008672	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
385	1	2	Фитинг, d-25mm, DK, Г, 36*2, 0°	00-00000566	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
386	1	2	Фитинг, d-25mm, DK, Г, 36*2, 45°	00-00001247	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
387	1	2	Фитинг, d-25mm, DK, Г, 36*2, 90°	00-00001248	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
388	1	2	Фитинг, d-25mm, DK, Г, 39*1,5, 0°	00-00004033	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
389	1	2	Фитинг, d-25mm, DK, Г, 39*2, 0°	00-00000339	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
390	1	2	Фитинг, d-25mm, DK, Г, 39х2, 45°	00-00000572	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
391	1	2	Фитинг, d-25mm, DK, Г, 39х2, 90°	00-00000573	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
392	1	2	Фитинг, d-25mm, DK, Г, 42*2, 0	00-00010827	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
393	1	2	Фитинг, d-25mm, DK, Г, 42*2, 0°	00-00002322	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
394	1	2	Фитинг, d-25mm, DK, Г, 42*2, 45°	00-00004768	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
395	1	2	Фитинг, d-25mm, DK, Г, 42*2, 90°	00-00004769	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
396	1	3	Фитинг, d-25mm, DK, Ш, 33*2, 0°	00-00006975	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
397	1	3	Фитинг, d-25mm, DK, Ш, 36*2, 0°	00-00006976	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
398	1	3	Фитинг, d-25mm, DK, Ш, 39*2, 0°	00-00003671	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
399	1	3	Фитинг, d-25mm, DK, Ш, 42*2, 0°	00-00003672	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
400	1	2	Фитинг, d-32mm, DK, Г, 45*2, 0°	00-00031951	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
401	1	2	Фитинг, d-32mm, DK, Г, 48*1,5, 0°	00-00000574	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
402	1	2	Фитинг, d-32mm, DK, Г, 48*1,5, 45°	00-00000575	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
403	1	2	Фитинг, d-32mm, DK, Г, 48*1,5, 90°	00-00000576	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
404	1	2	Фитинг, d-32mm, DK, Г, 48*2, 0°	00-00005935	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
405	1	2	Фитинг, d-32mm, DK, Г, 52*2, 0°	00-00002898	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
406	1	2	Фитинг, d-32mm, DK, Г, 52*2, 45°	00-00002899	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
407	1	2	Фитинг, d-32mm, DK, Г, 52*2, 90°	00-00002900	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
408	1	2	Фитинг, d-38mm, DK, Г, 42*2, 0°	00-00000579	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
409	1	2	Фитинг, d-38mm, DK, Г, 42*2, 45°	00-00000578	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
410	1	2	Фитинг, d-38mm, DK, Г, 42*2, 90°	00-00000577	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
411	1	2	Фитинг, d-38mm, DK, Г, 48*1,5, 0	00-00009428	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
412	1	2	Фитинг, d-38mm, DK, Г, 52*2, 0	00-00013617	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
413	1	2	Фитинг, d-38mm, DK, Г, 52*2, 45°	00-00013618	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
414	1	2	Фитинг, d-38mm, DK, Г, 52*2, 90°	00-00013619	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
415	1	2	Фитинг, d-6mm, DK, Г, 10*1, 0°	00-00002930	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
416	1	2	Фитинг, d-6mm, DK, Г, 10*1, 45°	00-00003651	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
417	1	2	Фитинг, d-6mm, DK, Г, 10*1, 90°	00-00002931	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
418	1	2	Фитинг, d-6mm, DK, Г, 10*1,5, 0°	00-00003343	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
419	1	2	Фитинг, d-6mm, DK, Г, 10*1,5, 45°	00-00013115	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
420	1	2	Фитинг, d-6mm, DK, Г, 10*1,5, 90°	00-00013116	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
421	1	2	Фитинг, d-6mm, DK, Г, 12*1, 0°	00-00000543	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
422	1	2	Фитинг, d-6mm, DK, Г, 12*1,5, 0°	00-00000301	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
423	1	2	Фитинг, d-6mm, DK, Г, 12*1,5, 45	00-00000302	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
424	1	2	Фитинг, d-6mm, DK, Г, 12*1,5, 45°, Italy	00-00003344	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
425	1	2	Фитинг, d-6mm, DK, Г, 12*1,5, 90°	00-00000303	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
426	1	2	Фитинг, d-6mm, DK, Г, 14*1, 0°	00-00000544	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
427	1	2	Фитинг, d-6mm, DK, Г, 14*1,5, 0, Italy	00-00011677	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
428	1	2	Фитинг, d-6mm, DK, Г, 14*1,5, 0°	00-00000306	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
429	1	2	Фитинг, d-6mm, DK, Г, 14*1,5, 45	00-00000307	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
430	1	2	Фитинг, d-6mm, DK, Г, 14*1,5, 45°, Italy	00-00003346	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
431	1	2	Фитинг, d-6mm, DK, Г, 14*1,5, 90°	00-00000308	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
432	1	2	Фитинг, d-6mm, DK, Г, 14*1,5, 90°, Italy	00-00003345	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
433	1	2	Фитинг, d-6mm, DK, Г, 16*1,5, 0, Italy	00-00011700	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
434	1	2	Фитинг, d-6mm, DK, Г, 16*1,5, 0°	00-00000548	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
435	1	2	Фитинг, d-6mm, DK, Г, 16*1,5, 45°	00-00000549	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
436	1	2	Фитинг, d-6mm, DK, Г, 16*1,5, 90°	00-00000550	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
437	1	2	Фитинг, d-6mm, DK, Г, 16*1,5, 90°, Italy	00-00011701	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
438	1	2	Фитинг, d-6mm, DK, Г, 18*1,5, 0°	00-00028055	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
439	1	2	Фитинг, d-6mm, DK, Г, 18*1,5, 45°	00-00028121	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
440	1	2	Фитинг, d-6mm, DK, Г, 18*1,5, 90°	00-00028119	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
441	1	3	Фитинг, d-6mm, DK, Ш, 10*1, 0°	00-00003341	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
442	1	3	Фитинг, d-6mm, DK, Ш, 10*1,5, 0°	00-00003342	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
443	1	3	Фитинг, d-6mm, DK, Ш, 12*1,5, 0°	00-00000304	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
444	1	3	Фитинг, d-6mm, DK, Ш, 14*1,5, 0°	00-00000305	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
445	1	3	Фитинг, d-6mm, DK, Ш, 16*1,5, 0, Italy	00-00011702	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
446	1	3	Фитинг, d-6mm, DK, Ш, 16*1,5, 0°	00-00003347	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
447	1	2	Фитинг, d-8mm, DK, Г, 14*1,5, 0°	00-00000545	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
448	1	2	Фитинг, d-8mm, DK, Г, 14*1,5, 45°	00-00000546	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
449	1	2	Фитинг, d-8mm, DK, Г, 14*1,5, 90°	00-00000547	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
450	1	2	Фитинг, d-8mm, DK, Г, 16*1,5, 0, Italy	00-00011703	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
451	1	2	Фитинг, d-8mm, DK, Г, 16*1,5, 0°	00-00000298	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
452	1	2	Фитинг, d-8mm, DK, Г, 16*1,5, 45	00-00000299	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
453	1	2	Фитинг, d-8mm, DK, Г, 16*1,5, 45°, Italy	00-00011704	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
454	1	2	Фитинг, d-8mm, DK, Г, 16*1,5, 90°	00-00000300	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
455	1	2	Фитинг, d-8mm, DK, Г, 16*1,5, 90°, Italy	00-00011705	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
456	1	2	Фитинг, d-8mm, DK, Г, 18*1,5, 0	00-00009654	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
457	1	2	Фитинг, d-8mm, DK, Г, 18*1,5, 45°	00-00000553	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
458	1	2	Фитинг, d-8mm, DK, Г, 18*1,5, 90°	00-00000554	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
459	1	2	Фитинг, d-8mm, DK, Г, 20*1,5, 0°	00-00000551	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
460	1	2	Фитинг, d-8mm, DK, Г, 20*1,5, 45°	00-00013117	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
461	1	2	Фитинг, d-8mm, DK, Г, 20*1,5, 90°	00-00015840	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
462	1	2	Фитинг, d-8mm, DK, Г, 22*1,5, 0°	00-00003348	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
463	1	2	Фитинг, d-8mm, DK, Г, 22*1,5, 90°	00-00028120	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
464	1	3	Фитинг, d-8mm, DK, Ш, 14*1,5, 0	00-00011709	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
465	1	3	Фитинг, d-8mm, DK, Ш, 16*1,5, 0	00-00016489	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
466	1	3	Фитинг, d-8mm, DK, Ш, 16*1,5, 0, Italy	00-00011710	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
467	1	3	Фитинг, d-8mm, DK, Ш, 18*1,5, 0	00-00011711	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
468	1	3	Фитинг, d-8mm, DK, Ш, 18*1,5, 90°	00-00011712	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
469	1	3	Фитинг, d-8mm, DK, Ш, 20*1,5, 0°	00-00003652	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
470	1	3	Фитинг, d-8mm, DK, Ш, 22*1,5, 0°	00-00003653	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
471	1	2	Фитинг, d-10mm, DKF, Г, 16*1,5, 0°	00-00000424	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
472	1	2	Фитинг, d-10mm, DKF, Г, 16*1,5, 45	00-00000425	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
473	1	2	Фитинг, d-10mm, DKF, Г, 16*1,5, 90°	00-00000426	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
474	1	2	Фитинг, d-10mm, DKF, Г, 18*1,5, 0°	00-00003297	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
475	1	2	Фитинг, d-10mm, DKF, Г, 18*1,5, 45°	00-00005918	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
476	1	2	Фитинг, d-10mm, DKF, Г, 18*1,5, 90°	00-00008139	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
477	1	2	Фитинг, d-10mm, DKF, Г, 20*1,5, 0°	00-00003298	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
478	1	2	Фитинг, d-10mm, DKF, Г, 20*1,5, 90°	00-00018356	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
479	1	2	Фитинг, d-10mm, DKF, Г, 22*1,5, 0°	00-00003299	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
480	1	2	Фитинг, d-10mm, DKF, Г, 22*1,5, 90°	00-00026339	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
481	1	2	Фитинг, d-12mm, DKF, Г, 20*1,5, 0°	00-00000429	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
482	1	2	Фитинг, d-12mm, DKF, Г, 20*1,5, 45	00-00000428	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
483	1	2	Фитинг, d-12mm, DKF, Г, 20*1,5, 90°	00-00000427	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
484	1	2	Фитинг, d-12mm, DKF, Г, 22*1,5, 0, (HS)	00-00009572	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
485	1	2	Фитинг, d-12mm, DKF, Г, 22*1,5, 0°	00-00000430	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
486	1	2	Фитинг, d-12mm, DKF, Г, 22*1,5, 0°, Italy	00-00003300	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
487	1	2	Фитинг, d-12mm, DKF, Г, 22*1,5, 45	00-00000431	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
488	1	2	Фитинг, d-12mm, DKF, Г, 22*1,5, 90°	00-00000432	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
489	1	2	Фитинг, d-12mm, DKF, Г, 24*1,5, 0°	00-00003301	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
490	1	2	Фитинг, d-12mm, DKF, Г, 24*1,5, 0°, Italy	00-00003302	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
491	1	2	Фитинг, d-16mm, DKF, Г, 27*1,5, 0	00-00003303	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
492	1	2	Фитинг, d-16mm, DKF, Г, 27*1,5, 90°	00-00003310	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
493	1	2	Фитинг, d-20mm, DKF, Г, 22*1,5, 0°	00-00006903	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
494	1	2	Фитинг, d-20mm, DKF, Г, 30*1,5, 0°	00-00000433	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
495	1	2	Фитинг, d-20mm, DKF, Г, 30*1,5, 0°, Italy	00-00003304	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
496	1	2	Фитинг, d-20mm, DKF, Г, 30*1,5, 90°	00-00010603	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
497	1	2	Фитинг, d-20mm, DKF, Г, 30*2, 0°	00-00005917	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
498	1	2	Фитинг, d-20mm, DKF, Г, 30*2, 90°	00-00017344	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
499	1	2	Фитинг, d-20mm, DKF, Г, 33*1,5, 90°	00-00008143	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
500	1	2	Фитинг, d-20mm, DKF, Г, 33*2, 0°	00-00003311	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
501	1	2	Фитинг, d-20mm, DKF, Г, 33*2, 90°	00-00008144	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
502	1	2	Фитинг, d-20mm, DKF, Г, 36*1,5, 0°	00-00003713	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
503	1	2	Фитинг, d-20mm, DKF, Г, 36*2, 0°	00-00003308	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
504	1	2	Фитинг, d-25mm, DKF, Г, 36*1,5, 0°	00-00005919	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
505	1	2	Фитинг, d-25mm, DKF, Г, 36*2, 0°	00-00003714	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
506	1	2	Фитинг, d-25mm, DKF, Г, 36*2, 90°	00-00003715	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
507	1	2	Фитинг, d-25mm, DKF, Г, 39*2, 0°	00-00003306	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
508	1	2	Фитинг, d-25mm, DKF, Г, 42*2, 0	00-00025074	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
509	1	2	Фитинг, d-32mm, DKF, Г, 52*2, 0°	00-00003307	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
510	1	2	Фитинг, d-38mm, DKF, Г, 52*2, 0°	00-00004116	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
511	1	2	Фитинг, d-38mm, DKF, Г, 60*4, 0, (HS)	00-00009477	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
512	1	2	Фитинг, d-6mm, DKF, Г, 14*1,5, 0°	00-00003294	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
513	1	2	Фитинг, d-6mm, DKF, Г, 14*1,5, 45°	00-00003711	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
514	1	2	Фитинг, d-6mm, DKF, Г, 14*1,5, 90°	00-00008127	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
515	1	2	Фитинг, d-6mm, DKF, Г, 16*1,5, 0°	00-00003295	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
516	1	2	Фитинг, d-6mm, DKF, Г, 16*1,5, 45°	00-00008128	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
517	1	2	Фитинг, d-6mm, DKF, Г, 16*1,5, 90°	00-00008129	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
518	1	2	Фитинг, d-6mm, DKF, Г, 20*1,5, 0°	00-00003309	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
519	1	2	Фитинг, d-8mm, DKF, Г, 14*1,5, 0°	00-00001245	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
520	1	2	Фитинг, d-8mm, DKF, Г, 14*1,5, 45°	00-00008130	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
521	1	2	Фитинг, d-8mm, DKF, Г, 14*1,5, 90°	00-00008131	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
522	1	2	Фитинг, d-8mm, DKF, Г, 16*1,5, 0°	00-00003296	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
523	1	2	Фитинг, d-8mm, DKF, Г, 16*1,5, 45°	00-00003712	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
524	1	2	Фитинг, d-8mm, DKF, Г, 16*1,5, 90°	00-00008134	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
525	1	3	Фитинг, d-8mm, DKF, Ш, 14*1,5, 0	00-00013253	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
526	1	2	Фитинг, d-10mm, DKOL, Г, 14*1,5, 0	00-00005969	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
527	1	2	Фитинг, d-10mm, DKOL, Г, 14*1,5, 45°	00-00013144	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
528	1	2	Фитинг, d-10mm, DKOL, Г, 14*1,5, 90°	00-00005970	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
529	1	2	Фитинг, d-10mm, DKOL, Г, 16*1,5, 0, Italy	00-00011737	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
530	1	2	Фитинг, d-10mm, DKOL, Г, 16*1,5, 0°	00-00000345	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
531	1	2	Фитинг, d-10mm, DKOL, Г, 16*1,5, 45	00-00000346	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
532	1	2	Фитинг, d-10mm, DKOL, Г, 16*1,5, 45°, Italy	00-00011738	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
533	1	2	Фитинг, d-10mm, DKOL, Г, 16*1,5, 90°	00-00000347	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
534	1	2	Фитинг, d-10mm, DKOL, Г, 16*1,5, 90°, Italy	00-00011739	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
535	1	2	Фитинг, d-10mm, DKOL, Г, 18*1,5, 0°	00-00002323	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
536	1	2	Фитинг, d-10mm, DKOL, Г, 18*1,5, 0°, Italy	00-00008803	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
537	1	2	Фитинг, d-10mm, DKOL, Г, 18*1,5, 45	00-00000341	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
538	1	2	Фитинг, d-10mm, DKOL, Г, 18*1,5, 45°, Italy	00-00011740	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
539	1	2	Фитинг, d-10mm, DKOL, Г, 18*1,5, 90°	00-00000342	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
540	1	2	Фитинг, d-10mm, DKOL, Г, 18*1,5, 90°, Italy	00-00008212	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
541	1	2	Фитинг, d-10mm, DKOL, Г, 20*1,5, 0°	00-00000460	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
542	1	2	Фитинг, d-10mm, DKOL, Г, 20*1,5, 45°	00-00000461	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
543	1	2	Фитинг, d-10mm, DKOL, Г, 20*1,5, 90°	00-00000462	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
544	1	2	Фитинг, d-10mm, DKOL, Г, 22*1,5, 0, Italy	00-00011741	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
545	1	2	Фитинг, d-10mm, DKOL, Г, 22*1,5, 0°	00-00000463	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
546	1	2	Фитинг, d-10mm, DKOL, Г, 22*1,5, 45°	00-00000464	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
547	1	2	Фитинг, d-10mm, DKOL, Г, 22*1,5, 45°, Italy	00-00011742	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
548	1	2	Фитинг, d-10mm, DKOL, Г, 22*1,5, 90°	00-00000465	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
549	1	2	Фитинг, d-10mm, DKOL, Г, 22*1,5, 90°, Italy	00-00011743	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
550	1	3	Фитинг, d-10mm, DKOL, Ш, 14*1,5, 0°	00-00027845	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
551	1	3	Фитинг, d-10mm, DKOL, Ш, 16*1,5, 0, Italy	00-00011744	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
552	1	3	Фитинг, d-10mm, DKOL, Ш, 16*1,5, 0°	00-00000344	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
553	1	3	Фитинг, d-10mm, DKOL, Ш, 18*1,5, 0, Italy	00-00011664	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
554	1	3	Фитинг, d-10mm, DKOL, Ш, 18*1,5, 0°	00-00000343	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
555	1	3	Фитинг, d-10mm, DKOL, Ш, 22*1,5, 0	00-00011745	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
556	1	3	Фитинг, d-10mm, DKOL, Ш, 22*1,5, 0, Italy	00-00011746	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
557	1	2	Фитинг, d-12mm, DKOL, Г, 16*1,5, 0°	00-00006347	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
558	1	2	Фитинг, d-12mm, DKOL, Г, 18*1,5, 0°	00-00000340	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
559	1	2	Фитинг, d-12mm, DKOL, Г, 18*1,5, 0°, Italy	00-00003328	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
560	1	2	Фитинг, d-12mm, DKOL, Г, 18*1,5, 45°	00-00000458	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
561	1	2	Фитинг, d-12mm, DKOL, Г, 18*1,5, 90°	00-00000459	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
562	1	2	Фитинг, d-12mm, DKOL, Г, 20*1,5, 0°	00-00000316	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
563	1	2	Фитинг, d-12mm, DKOL, Г, 20*1,5, 45	00-00000317	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
564	1	2	Фитинг, d-12mm, DKOL, Г, 20*1,5, 90°	00-00000318	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
565	1	2	Фитинг, d-12mm, DKOL, Г, 22*1,5, 0	00-00000311	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
566	1	2	Фитинг, d-12mm, DKOL, Г, 22*1,5, 0°, Italy	00-00008805	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
567	1	2	Фитинг, d-12mm, DKOL, Г, 22*1,5, 45	00-00000312	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
568	1	2	Фитинг, d-12mm, DKOL, Г, 22*1,5, 90°	00-00000313	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
569	1	2	Фитинг, d-12mm, DKOL, Г, 22*1,5, 90°, Italy	00-00008806	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
570	1	2	Фитинг, d-12mm, DKOL, Г, 24*1,5, 0°	00-00001284	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
571	1	2	Фитинг, d-12mm, DKOL, Г, 24*1,5, 45	00-00000267	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
572	1	2	Фитинг, d-12mm, DKOL, Г, 24*1,5, 90°	00-00000310	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
573	1	2	Фитинг, d-12mm, DKOL, Г, 26*1,5, 0°	00-00000454	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
574	1	2	Фитинг, d-12mm, DKOL, Г, 26*1,5, 45°	00-00000453	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
575	1	2	Фитинг, d-12mm, DKOL, Г, 26*1,5, 45°, Italy	00-00011762	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
576	1	2	Фитинг, d-12mm, DKOL, Г, 26*1,5, 90°	00-00000452	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
577	1	3	Фитинг, d-12mm, DKOL, Ш, 16*1,5, 0°	00-00006348	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
578	1	3	Фитинг, d-12mm, DKOL, Ш, 18*1,5, 0°	00-00003329	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
579	1	3	Фитинг, d-12mm, DKOL, Ш, 20*1,5, 0°	00-00000315	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
580	1	3	Фитинг, d-12mm, DKOL, Ш, 22*1,5, 0°	00-00000314	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
581	1	3	Фитинг, d-12mm, DKOL, Ш, 22*1,5, 0°, токар.	00-00002884	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
582	1	3	Фитинг, d-12mm, DKOL, Ш, 24*1,5, 0°	00-00003678	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
583	1	3	Фитинг, d-12mm, DKOL, Ш, 26*1,5, 0°	00-00003679	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
584	1	2	Фитинг, d-16mm, DKOL, Г, 22*1,5, 0°	00-00003680	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
585	1	2	Фитинг, d-16mm, DKOL, Г, 22*1,5, 45°	00-00032065	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
586	1	2	Фитинг, d-16mm, DKOL, Г, 22*1,5, 90°	00-00023466	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
587	1	2	Фитинг, d-16mm, DKOL, Г, 24*1,5, 0, Внимание!!!	00-00009033	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
588	1	2	Фитинг, d-16mm, DKOL, Г, 24*1,5, 45°, Внимание!!!	00-00009034	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
589	1	2	Фитинг, d-16mm, DKOL, Г, 24*1,5, 90°, Внимание!!!	00-00009035	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
590	1	2	Фитинг, d-16mm, DKOL, Г, 26*1,5, 0	00-00000324	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
591	1	2	Фитинг, d-16mm, DKOL, Г, 26*1,5, 0, Italy	00-00000321	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
592	1	2	Фитинг, d-16mm, DKOL, Г, 26*1,5, 45	00-00000325	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
593	1	2	Фитинг, d-16mm, DKOL, Г, 26*1,5, 45°, Italy	00-00003330	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
594	1	2	Фитинг, d-16mm, DKOL, Г, 26*1,5, 90°	00-00010823	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
595	1	2	Фитинг, d-16mm, DKOL, Г, 26*1,5, 90°, Italy	00-00000326	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
596	1	2	Фитинг, d-16mm, DKOL, Г, 27*1,5, 0	00-00010536	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
597	1	2	Фитинг, d-16mm, DKOL, Г, 27*1,5, 45°	00-00000320	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
598	1	2	Фитинг, d-16mm, DKOL, Г, 27*1,5, 90°	00-00000319	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
599	1	2	Фитинг, d-16mm, DKOL, Г, 30*2, 0°	00-00003681	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
600	1	2	Фитинг, d-16mm, DKOL, Г, 30*2, 45°	00-00003682	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
601	1	2	Фитинг, d-16mm, DKOL, Г, 30*2, 90°	00-00003683	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
602	1	2	Фитинг, d-16mm, DKOL, Г, 36*2, 0	00-00018373	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
603	1	2	Фитинг, d-16mm, DKOL, Г, 36*2, 45°	00-00018374	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
604	1	3	Фитинг, d-16mm, DKOL, Ш, 26*1,5, 0°	00-00000323	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
605	1	3	Фитинг, d-16mm, DKOL, Ш, 27*1,5, 0	00-00000322	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
606	1	2	Фитинг, d-19mm, DKOL, Г, 30*2, 90°	00-00008182	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
607	1	2	Фитинг, d-20mm, DKOL, Г, 26*1,5, 0°	00-00004726	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
608	1	2	Фитинг, d-20mm, DKOL, Г, 26*1,5, 45°	00-00003567	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
609	1	2	Фитинг, d-20mm, DKOL, Г, 26*1,5, 90°	00-00016433	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
610	1	2	Фитинг, d-20mm, DKOL, Г, 27*1,5, 0	00-00004509	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
611	1	2	Фитинг, d-20mm, DKOL, Г, 27*1,5, 90°	00-00004510	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
612	1	2	Фитинг, d-20mm, DKOL, Г, 30*1,5, 0°	00-00000332	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
613	1	2	Фитинг, d-20mm, DKOL, Г, 30*1,5, 45	00-00000333	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
614	1	2	Фитинг, d-20mm, DKOL, Г, 30*1,5, 90°	00-00000334	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
615	1	2	Фитинг, d-20mm, DKOL, Г, 30*2, 0, Italy	00-00011769	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
616	1	2	Фитинг, d-20mm, DKOL, Г, 30*2, 0°, AG	00-00002378	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
617	1	2	Фитинг, d-20mm, DKOL, Г, 30*2, 0°, GV	00-00004651	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
618	1	2	Фитинг, d-20mm, DKOL, Г, 30*2, 180°	00-00027105	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
619	1	2	Фитинг, d-20mm, DKOL, Г, 30*2, 45°	00-00008231	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
620	1	2	Фитинг, d-20mm, DKOL, Г, 30*2, 45°, st	00-00000328	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
621	1	2	Фитинг, d-20mm, DKOL, Г, 30*2, 90°	00-00000327	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
622	1	2	Фитинг, d-20mm, DKOL, Г, 30*2, 90°, Italy	00-00011770	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
623	1	2	Фитинг, d-20mm, DKOL, Г, 30х2, 0	00-00000329	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
624	1	2	Фитинг, d-20mm, DKOL, Г, 33*1,5, 0°	00-00000434	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
625	1	2	Фитинг, d-20mm, DKOL, Г, 33*1,5, 45	00-00000435	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
626	1	2	Фитинг, d-20mm, DKOL, Г, 33*1,5, 90°	00-00000436	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
627	1	2	Фитинг, d-20mm, DKOL, Г, 33*2, 0°	00-00000439	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
628	1	2	Фитинг, d-20mm, DKOL, Г, 33*2, 45	00-00000438	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
629	1	2	Фитинг, d-20mm, DKOL, Г, 33*2, 90°	00-00000437	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
630	1	2	Фитинг, d-20mm, DKOL, Г, 36*2, 0°	00-00003332	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
631	1	2	Фитинг, d-20mm, DKOL, Г, 36*2, 90°	00-00002334	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
632	1	3	Фитинг, d-20mm, DKOL, Ш, 26*1,5, 0°	00-00001330	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
633	1	3	Фитинг, d-20mm, DKOL, Ш, 30*1,5, 0°	00-00000331	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
634	1	3	Фитинг, d-20mm, DKOL, Ш, 30*2, 0°	00-00000330	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
635	1	3	Фитинг, d-20mm, DKOL, Ш, 30*2, 0°, токар.	00-00003331	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
636	1	3	Фитинг, d-20mm, DKOL, Ш, 36*1,5, 0°	00-00003339	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
637	1	2	Фитинг, d-25mm, DKOL, Г, 33*1,5, 0°	00-00004323	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
638	1	2	Фитинг, d-25mm, DKOL, Г, 33*1,5, 45°	00-00004324	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
639	1	2	Фитинг, d-25mm, DKOL, Г, 33*1,5, 90°	00-00004325	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
640	1	2	Фитинг, d-25mm, DKOL, Г, 33*2, 0°	00-00004327	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
641	1	2	Фитинг, d-25mm, DKOL, Г, 33*2, 45°	00-00004328	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
642	1	2	Фитинг, d-25mm, DKOL, Г, 33*2, 90°	00-00004329	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
643	1	2	Фитинг, d-25mm, DKOL, Г, 36*2, 0°	00-00000336	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
644	1	2	Фитинг, d-25mm, DKOL, Г, 36*2, 180°	00-00025292	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
645	1	2	Фитинг, d-25mm, DKOL, Г, 36*2, 45°	00-00003340	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
646	1	2	Фитинг, d-25mm, DKOL, Г, 36*2, 90°	00-00000335	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
647	1	2	Фитинг, d-25mm, DKOL, Г, 39*2, 0, GV	00-00016841	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
648	1	2	Фитинг, d-25mm, DKOL, Г, 39*2, 0°	00-00003556	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
649	1	2	Фитинг, d-25mm, DKOL, Г, 42*2, 0°	00-00000451	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
650	1	2	Фитинг, d-25mm, DKOL, Г, 42*2, 90°	00-00000449	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
651	1	2	Фитинг, d-25mm, DKOL, Г, 45*2, 0	00-00017256	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
652	1	2	Фитинг, d-25mm, DKOL, Г, 45*2, 45°	00-00030838	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
653	1	2	Фитинг, d-25mm, DKOL, Г, 45*2, 90°	00-00026139	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
654	1	3	Фитинг, d-25mm, DKOL, Ш, 33*1,5, 0°	00-00004322	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
655	1	3	Фитинг, d-25mm, DKOL, Ш, 33*2, 0°	00-00004326	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
656	1	3	Фитинг, d-25mm, DKOL, Ш, 42*2, 0°	00-00002916	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
657	1	2	Фитинг, d-32mm, DKOL, Г, 45*2, 0°	00-00001286	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
658	1	2	Фитинг, d-32mm, DKOL, Г, 45*2, 45	00-00000447	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
659	1	2	Фитинг, d-32mm, DKOL, Г, 45*2, 90°	00-00000448	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
660	1	2	Фитинг, d-32mm, DKOL, Г, 52*2, 0°	00-00000445	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
661	1	2	Фитинг, d-32mm, DKOL, Г, 52*2, 45	00-00000444	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
662	1	2	Фитинг, d-32mm, DKOL, Г, 52*2, 90°	00-00000443	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
663	1	3	Фитинг, d-32mm, DKOL, Ш, 45*2, 0°	00-00000446	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
664	1	2	Фитинг, d-38mm, DKOL, Г, 52*2, 0°	00-00000440	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
665	1	2	Фитинг, d-4mm, DKOL, Г, 12*1,5, 0	00-00025931	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
666	1	2	Фитинг, d-4mm, DKOL, Г, 12*1,5, 90°	00-00025932	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
667	1	2	Фитинг, d-5mm, DKOL, Г, 12*1,5, 0, Italy	00-00015152	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
668	1	2	Фитинг, d-5mm, DKOL, Г, 12*1,5, 0°	00-00003673	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
669	1	2	Фитинг, d-5mm, DKOL, Г, 12*1,5, 45°	00-00017779	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
670	1	2	Фитинг, d-5mm, DKOL, Г, 12*1,5, 90°	00-00014747	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
671	1	2	Фитинг, d-5mm, DKOL, Г, 12*1,5, 90°, Italy	00-00003674	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
672	1	3	Фитинг, d-5mm, DKOL, Ш, 12*1,5, 0°, Italy	00-00003675	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
673	1	2	Фитинг, d-6mm, DKOL, Г, 12*1,5, 0, Italy	00-00011778	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
674	1	2	Фитинг, d-6mm, DKOL, Г, 12*1,5, 0°	00-00000359	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
675	1	2	Фитинг, d-6mm, DKOL, Г, 12*1,5, 45	00-00000358	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
676	1	2	Фитинг, d-6mm, DKOL, Г, 12*1,5, 45°, Italy	00-00011779	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
677	1	2	Фитинг, d-6mm, DKOL, Г, 12*1,5, 90°	00-00000357	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
678	1	2	Фитинг, d-6mm, DKOL, Г, 12*1,5, 90°, Italy	00-00011780	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
679	1	2	Фитинг, d-6mm, DKOL, Г, 14*1,5, 0, Italy	00-00011781	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
680	1	2	Фитинг, d-6mm, DKOL, Г, 14*1,5, 0°	00-00001280	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
681	1	2	Фитинг, d-6mm, DKOL, Г, 14*1,5, 45	00-00000355	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
682	1	2	Фитинг, d-6mm, DKOL, Г, 14*1,5, 90	00-00000356	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
683	1	2	Фитинг, d-6mm, DKOL, Г, 16*1,5, 0, Italy	00-00011783	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
684	1	2	Фитинг, d-6mm, DKOL, Г, 16*1,5, 0, токар.	00-00012830	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
685	1	2	Фитинг, d-6mm, DKOL, Г, 16*1,5, 0°	00-00000455	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
686	1	2	Фитинг, d-6mm, DKOL, Г, 16*1,5, 45°	00-00000456	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
687	1	2	Фитинг, d-6mm, DKOL, Г, 16*1,5, 45°, Italy	00-00011784	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
688	1	2	Фитинг, d-6mm, DKOL, Г, 16*1,5, 90°	00-00000457	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
689	1	2	Фитинг, d-6mm, DKOL, Г, 16*1,5, 90°, Italy	00-00011786	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
690	1	2	Фитинг, d-6mm, DKOL, Г, 18*1,5, 0, Italy	00-00011787	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
691	1	2	Фитинг, d-6mm, DKOL, Г, 18*1,5, 0°	00-00003315	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
692	1	2	Фитинг, d-6mm, DKOL, Г, 18*1,5, 45°	00-00005954	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
693	1	2	Фитинг, d-6mm, DKOL, Г, 18*1,5, 90°	00-00003314	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
694	1	2	Фитинг, d-6mm, DKOL, Г, 18*1,5, 90°, Italy	00-00011788	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
695	1	3	Фитинг, d-6mm, DKOL, Ш, 12*1,5, 0, Italy	00-00011789	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
696	1	3	Фитинг, d-6mm, DKOL, Ш, 12*1,5, 0°	00-00001283	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
697	1	3	Фитинг, d-6mm, DKOL, Ш, 14*1,5, 0, Italy	00-00011790	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
698	1	3	Фитинг, d-6mm, DKOL, Ш, 14*1,5, 0°, st	00-00000354	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
699	1	3	Фитинг, d-6mm, DKOL, Ш, 16*1,5, 0	00-00010826	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
700	1	3	Фитинг, d-6mm, DKOL, Ш, 16*1,5, 90°	00-00011791	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
701	1	3	Фитинг, d-6mm, DKOL, Ш, 16*1,5, 90°, Italy	00-00011792	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
702	1	3	Фитинг, d-6mm, DKOL, Ш, 18*1,5, 0	00-00011793	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
703	1	2	Фитинг, d-8mm, DKOL, Г, 14*1,5, 0°	00-00000353	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
704	1	2	Фитинг, d-8mm, DKOL, Г, 14*1,5, 45	00-00000352	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
705	1	2	Фитинг, d-8mm, DKOL, Г, 14*1,5, 90°	00-00000351	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
706	1	2	Фитинг, d-8mm, DKOL, Г, 16*1,5, 0, Italy	00-00015153	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
707	1	2	Фитинг, d-8mm, DKOL, Г, 16*1,5, 90°, Italy	00-00011815	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
708	1	2	Фитинг, d-8mm, DKOL, Г, 18*1,5, 0, Italy	00-00011816	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
709	1	2	Фитинг, d-8mm, DKOL, Г, 18*1,5, 0°	00-00003327	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
710	1	2	Фитинг, d-8mm, DKOL, Г, 18*1,5, 45°	00-00009954	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
711	1	2	Фитинг, d-8mm, DKOL, Г, 18*1,5, 45°, Italy	00-00011817	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
712	1	2	Фитинг, d-8mm, DKOL, Г, 18*1,5, 90°	00-00016818	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
713	1	2	Фитинг, d-8mm, DKOL, Г, 18*1,5, 90°, Italy	00-00011818	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
714	1	3	Фитинг, d-8mm, DKOL, Ш, 14*1,5, 0	00-00021429	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
715	1	3	Фитинг, d-8mm, DKOL, Ш, 16х1,5, 0°	00-00003326	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
716	1	3	Фитинг, d-8mm, DKOL, Ш, 18*1,5, 0	00-00011819	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
717	1	3	Фитинг, d-8mm, DKOL, Ш, 18*1,5, 0, Italy	00-00011820	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
718	1	2	Фитинг Интерлок, d-20mm, DKOS, Г, 36*2, 90°, Italy	00-00011730	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
719	1	2	Фитинг, d-10mm, DKOS, Г, 18*1,5, 0°	00-00000406	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
720	1	2	Фитинг, d-10mm, DKOS, Г, 18*1,5, 0°, Italy	00-00003320	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
721	1	2	Фитинг, d-10mm, DKOS, Г, 18*1,5, 45	00-00000407	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
722	1	2	Фитинг, d-10mm, DKOS, Г, 18*1,5, 45°, Italy	00-00011747	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
723	1	2	Фитинг, d-10mm, DKOS, Г, 18*1,5, 90°	00-00000408	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
724	1	2	Фитинг, d-10mm, DKOS, Г, 18*1,5, 90°, Italy	00-00011748	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
725	1	2	Фитинг, d-10mm, DKOS, Г, 20*1,5, 0, Italy	00-00011749	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
726	1	2	Фитинг, d-10mm, DKOS, Г, 20*1,5, 0°	00-00000405	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
727	1	2	Фитинг, d-10mm, DKOS, Г, 20*1,5, 45	00-00000404	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
728	1	2	Фитинг, d-10mm, DKOS, Г, 20*1,5, 45°, Italy	00-00011750	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
729	1	2	Фитинг, d-10mm, DKOS, Г, 20*1,5, 90°	00-00000403	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
730	1	2	Фитинг, d-10mm, DKOS, Г, 20*1,5, 90°, Italy	00-00011751	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
731	1	2	Фитинг, d-10mm, DKOS, Г, 22*1,5, 0	00-00013147	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
732	1	2	Фитинг, d-10mm, DKOS, Г, 22*1,5, 0, Italy	00-00011752	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
733	1	2	Фитинг, d-10mm, DKOS, Г, 22*1,5, 45°	00-00013148	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
734	1	2	Фитинг, d-10mm, DKOS, Г, 22*1,5, 45°, Italy	00-00011753	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
735	1	2	Фитинг, d-10mm, DKOS, Г, 22*1,5, 90°	00-00011754	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
736	1	2	Фитинг, d-10mm, DKOS, Г, 22*1,5, 90°, Italy	00-00011755	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
737	1	3	Фитинг, d-10mm, DKOS, Ш, 18*1,5, 0°	00-00003321	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
738	1	3	Фитинг, d-10mm, DKOS, Ш, 20*1,5, 0, Italy	00-00011758	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
739	1	3	Фитинг, d-10mm, DKOS, Ш, 20*1,5, 0°	00-00003322	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
740	1	3	Фитинг, d-10mm, DKOS, Ш, 22*1,5, 0	00-00017196	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
741	1	3	Фитинг, d-10mm, DKOS, Ш, 22*1,5, 0, Italy	00-00011759	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
742	1	2	Фитинг, d-12mm, DKOS, Г, 20*1,5, 0°	00-00000400	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
743	1	2	Фитинг, d-12mm, DKOS, Г, 20*1,5, 45	00-00000401	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
744	1	2	Фитинг, d-12mm, DKOS, Г, 20*1,5, 45°, Italy	00-00011763	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
745	1	2	Фитинг, d-12mm, DKOS, Г, 20*1,5, 90°	00-00000402	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
746	1	2	Фитинг, d-12mm, DKOS, Г, 22*1,5, 0°	00-00003323	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
747	1	2	Фитинг, d-12mm, DKOS, Г, 22*1,5, 90°	00-00015834	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
748	1	2	Фитинг, d-12mm, DKOS, Г, 24*1,5, 0°	00-00000360	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
749	1	2	Фитинг, d-12mm, DKOS, Г, 24*1,5, 45	00-00000422	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
750	1	2	Фитинг, d-12mm, DKOS, Г, 24*1,5, 90°, Italy	00-00000423	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	1	шт.	\N
751	1	3	Фитинг, d-12mm, DKOS, Ш, 18*1,5, 0°	00-00003325	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
752	1	3	Фитинг, d-12mm, DKOS, Ш, 20*1,5, 0°	00-00003333	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
753	1	3	Фитинг, d-12mm, DKOS, Ш, 22*1,5, 0°	00-00003324	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
754	1	3	Фитинг, d-12mm, DKOS, Ш, 24*1,5, 0°	00-00001240	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
755	1	2	Фитинг, d-16mm, DKOS, Г, 24*1,5, 0°	00-00003334	\N	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
756	1	2	Фитинг, d-16mm, DKOS, Г, 24*1,5, 45°	00-00015835	45	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
757	1	2	Фитинг, d-16mm, DKOS, Г, 24*1,5, 90°	00-00003335	90	\N	t	2026-10-14 08:30:57	2026-10-14 08:30:57	\N	\N	шт.	\N
758	1	2	Фитинг, d-16mm, DKOS, Г, 26*1,5, 90°, Italy	00-00011765	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
759	1	2	Фитинг, d-16mm, DKOS, Г, 27*1,5, 0	00-00009715	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
760	1	2	Фитинг, d-16mm, DKOS, Г, 30*2, 0°	00-00000418	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
761	1	2	Фитинг, d-16mm, DKOS, Г, 30*2, 45°	00-00013149	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
762	1	2	Фитинг, d-16mm, DKOS, Г, 30*2, 90°	00-00011766	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
763	1	2	Фитинг, d-16mm, DKOS, Г, 30*2, 90°, Italy	00-00011767	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
764	1	3	Фитинг, d-16mm, DKOS, Ш, 24*1,5, 0	00-00017208	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
765	1	3	Фитинг, d-16mm, DKOS, Ш, 30*2, 0°	00-00003336	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
766	1	2	Фитинг, d-20mm, DKOS, Г, 30*1,5, 0	00-00009720	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
767	1	2	Фитинг, d-20mm, DKOS, Г, 30*1,5, 90°	00-00009716	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
768	1	2	Фитинг, d-20mm, DKOS, Г, 30*2, 0°	00-00000417	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
769	1	2	Фитинг, d-20mm, DKOS, Г, 30*2, 45	00-00000416	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
770	1	2	Фитинг, d-20mm, DKOS, Г, 30*2, 90°	00-00000415	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
771	1	2	Фитинг, d-20mm, DKOS, Г, 33*1,5, 0°	00-00000412	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
772	1	2	Фитинг, d-20mm, DKOS, Г, 33*1,5, 45	00-00000413	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
773	1	2	Фитинг, d-20mm, DKOS, Г, 33*1,5, 90°	00-00000414	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
774	1	2	Фитинг, d-20mm, DKOS, Г, 33*2, 0°	00-00000411	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
775	1	2	Фитинг, d-20mm, DKOS, Г, 33*2, 45	00-00000410	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
776	1	2	Фитинг, d-20mm, DKOS, Г, 33*2, 90°	00-00000409	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
777	1	2	Фитинг, d-20mm, DKOS, Г, 36*2, 0, Italy	00-00011771	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
778	1	2	Фитинг, d-20mm, DKOS, Г, 36*2, 45	00-00000420	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
779	1	2	Фитинг, d-20mm, DKOS, Г, 36*2, 90°, Italy	00-00011772	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
780	1	2	Фитинг, d-20mm, DKOS, Г, 42*2, 45°	00-00011773	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
781	1	2	Фитинг, d-20mm, DKOS, Г, 42*2, 90°	00-00011775	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
782	1	3	Фитинг, d-20mm, DKOS, Ш, 30*1,5, 0°	00-00003337	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
783	1	3	Фитинг, d-20mm, DKOS, Ш, 30*2, 0°	00-00005929	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
784	1	3	Фитинг, d-20mm, DKOS, Ш, 33*2, 0	00-00017198	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
785	1	3	Фитинг, d-20mm, DKOS, Ш, 36*2, 0°	00-00003338	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
786	1	2	Фитинг, d-25mm, DKOS, Г, 36*2, 45°	00-00013150	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
787	1	2	Фитинг, d-25mm, DKOS, Г, 36*2, 90°	00-00002881	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
788	1	2	Фитинг, d-25mm, DKOS, Г, 42*2, 0	00-00011776	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
789	1	2	Фитинг, d-25mm, DKOS, Г, 42*2, 45°	00-00019036	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
790	1	2	Фитинг, d-25mm, DKOS, Г, 42*2, 90°	00-00011777	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
791	1	3	Фитинг, d-25mm, DKOS, Ш, 36*2, 0°	00-00029166	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
792	1	2	Фитинг, d-32mm, DKOS, Г, 42*2, 0	00-00018733	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
793	1	2	Фитинг, d-32mm, DKOS, Г, 52*2, 0°	00-00001244	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
794	1	2	Фитинг, d-32mm, DKOS, Г, 52*2, 45°	00-00001242	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
795	1	2	Фитинг, d-32mm, DKOS, Г, 52*2, 90°	00-00001243	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
796	1	3	Фитинг, d-32mm, DKOS, Ш, 52*2, 0	00-00015781	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
797	1	2	Фитинг, d-38mm, DKOS, Г, 52*2, 0°	00-00001241	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
798	1	2	Фитинг, d-38mm, DKOS, Г, 52*2, 45°	00-00001260	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
799	1	2	Фитинг, d-38mm, DKOS, Г, 52*2, 90°	00-00001261	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
800	1	3	Фитинг, d-38mm, DKOS, Ш, 52*2, 0°	00-00006172	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
801	1	2	Фитинг, d-6mm, DKOS, Г, 12*1, 0°	00-00003313	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
802	1	2	Фитинг, d-6mm, DKOS, Г, 12*1,5, 0°	00-00002978	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
803	1	2	Фитинг, d-6mm, DKOS, Г, 12*1,5, 45°	00-00006909	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
804	1	2	Фитинг, d-6mm, DKOS, Г, 12*1,5, 90°	00-00002979	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
805	1	2	Фитинг, d-6mm, DKOS, Г, 14*1,5, 0	00-00011794	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
806	1	2	Фитинг, d-6mm, DKOS, Г, 14*1,5, 0, Italy	00-00001249	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
807	1	2	Фитинг, d-6mm, DKOS, Г, 14*1,5, 45°	00-00001250	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
808	1	2	Фитинг, d-6mm, DKOS, Г, 14*1,5, 90°	00-00022265	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
809	1	2	Фитинг, d-6mm, DKOS, Г, 14*1,5, 90°, Italy	00-00001251	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
810	1	2	Фитинг, d-6mm, DKOS, Г, 16*1,5, 0, Italy	00-00011795	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
811	1	2	Фитинг, d-6mm, DKOS, Г, 16*1,5, 0°	00-00003827	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
812	1	2	Фитинг, d-6mm, DKOS, Г, 16*1,5, 45°	00-00013163	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
813	1	2	Фитинг, d-6mm, DKOS, Г, 16*1,5, 45°, Italy	00-00011796	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
814	1	2	Фитинг, d-6mm, DKOS, Г, 16*1,5, 90°	00-00005930	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
815	1	2	Фитинг, d-6mm, DKOS, Г, 16*1,5, 90°, Italy	00-00011797	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
816	1	2	Фитинг, d-6mm, DKOS, Г, 18*1,5, 0	00-00011060	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
817	1	2	Фитинг, d-6mm, DKOS, Г, 18*1,5, 0, Italy	00-00011798	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
818	1	2	Фитинг, d-6mm, DKOS, Г, 18*1,5, 45°	00-00013164	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
819	1	2	Фитинг, d-6mm, DKOS, Г, 18*1,5, 45°, Italy	00-00011799	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
820	1	2	Фитинг, d-6mm, DKOS, Г, 18*1,5, 90°	00-00011800	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
821	1	2	Фитинг, d-6mm, DKOS, Г, 18*1,5, 90°, Italy	00-00011801	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
822	1	3	Фитинг, d-6mm, DKOS, Ш, 14*1,5, 0°	00-00003316	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
823	1	3	Фитинг, d-6mm, DKOS, Ш, 16*1,5, 0, Italy	00-00011802	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
824	1	3	Фитинг, d-6mm, DKOS, Ш, 16*1,5, 0°	00-00003317	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
825	1	3	Фитинг, d-6mm, DKOS, Ш, 18*1,5, 0, Italy	00-00011803	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
826	1	3	Фитинг, d-6mm, DKOS, Ш, 18*1,5, 0°	00-00003318	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
827	1	3	Фитинг, d-6mm, DKOS, Ш, 20*1,5, 0, Italy	00-00011807	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
828	1	2	Фитинг, d-8mm, DKOS, Г, 16*1,5, 0°	00-00029114	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
829	1	2	Фитинг, d-8mm, DKOS, Г, 16*1,5, 45°	00-00029115	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
830	1	2	Фитинг, d-8mm, DKOS, Г, 16*1,5, 90°	00-00029116	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
831	1	2	Фитинг, d-8mm, DKOS, Г, 18*1,5, 0	00-00010401	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
832	1	2	Фитинг, d-8mm, DKOS, Г, 18*1,5, 0, Italy	00-00011821	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
833	1	2	Фитинг, d-8mm, DKOS, Г, 18*1,5, 45°	00-00010402	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
834	1	2	Фитинг, d-8mm, DKOS, Г, 18*1,5, 45°, Italy	00-00011822	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
835	1	2	Фитинг, d-8mm, DKOS, Г, 18*1,5, 90°	00-00003319	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
836	1	2	Фитинг, d-8mm, DKOS, Г, 20*1,5, 0, Italy	00-00011823	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
837	1	2	Фитинг, d-8mm, DKOS, Г, 20*1,5, 0°	00-00005933	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
838	1	2	Фитинг, d-8mm, DKOS, Г, 20*1,5, 45°	00-00015833	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
839	1	2	Фитинг, d-8mm, DKOS, Г, 20*1,5, 45°, Italy	00-00011824	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
840	1	3	Фитинг, d-8mm, DKOS, Ш, 16*1,5, 0° S=17	00-00029117	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
841	1	3	Фитинг, d-8mm, DKOS, Ш, 18*1,5, 0°	00-00001285	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
842	1	3	Фитинг, d-8mm, DKOS, Ш, 20*1,5, 0°	00-00005934	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
843	1	3	Фитинг, d-8mm, DKOS, Ш, 22*1,5, 0°	00-00005932	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
844	1	\N	Фитинг, d-10mm, Banjo, 1/2, 0	00-00016546	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
845	1	\N	Фитинг, d-10mm, Banjo, 1/4, 0°	00-00004335	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
846	1	\N	Фитинг, d-10mm, Banjo, 10*1,5, 0	00-00017778	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
847	1	\N	Фитинг, d-10mm, Banjo, 12*1,5, 0°	00-00003075	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
848	1	\N	Фитинг, d-10mm, Banjo, 14*1,5, 0°	00-00001216	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
849	1	\N	Фитинг, d-10mm, Banjo, 16*1,5, 0°	00-00001221	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
850	1	\N	Фитинг, d-10mm, Banjo, 18*1,5, 0°	00-00003067	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
851	1	\N	Фитинг, d-10mm, Banjo, 20*1,5, 0	00-00003068	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
852	1	\N	Фитинг, d-10mm, Banjo, 22*1,5, 0°	00-00003070	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
853	1	\N	Фитинг, d-10mm, Banjo, 22*1,5/h 25, 0°	00-00008615	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
854	1	\N	Фитинг, d-10mm, Banjo, 3/8, 0°	00-00004336	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
855	1	\N	Фитинг, d-12mm, Banjo, 1/2, 0°	00-00004337	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
856	1	\N	Фитинг, d-12mm, Banjo, 14*1,5, 0	00-00026800	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
857	1	\N	Фитинг, d-12mm, Banjo, 16*1,5, 0	00-00026801	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
858	1	\N	Фитинг, d-12mm, Banjo, 18*1,5, 0°	00-00001252	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
859	1	\N	Фитинг, d-12mm, Banjo, 20*1,5, 0°	00-00001222	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
860	1	\N	Фитинг, d-12mm, Banjo, 22*1,5, 0°	00-00003071	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
861	1	\N	Фитинг, d-12mm, Banjo, 22*1,5/h 25, 0°	00-00008616	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
862	1	\N	Фитинг, d-12mm, Banjo, 24*1,5, 0	00-00013162	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
863	1	\N	Фитинг, d-12mm, Banjo, 3/8, 0°	00-00004339	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
864	1	\N	Фитинг, d-16mm, Banjo, 1/2, 0°	00-00029313	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
865	1	\N	Фитинг, d-16mm, Banjo, 20*1,5, 0°	00-00001223	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
866	1	\N	Фитинг, d-16mm, Banjo, 22*1,5, 0°	00-00001224	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
867	1	\N	Фитинг, d-16mm, Banjo, 24*1,5, 0	00-00023718	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
868	1	\N	Фитинг, d-16mm, Banjo, 26*1,5, 0°	00-00003523	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
869	1	\N	Фитинг, d-16mm, Banjo, 27	00-00008098	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
870	1	\N	Фитинг, d-16mm, Banjo, 27*1,5, 0	00-00003629	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
871	1	\N	Фитинг, d-16mm, Banjo, 3/4, 0°	00-00004340	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
872	1	\N	Фитинг, d-20mm, Banjo, 22*1,5, 0°	00-00001225	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
873	1	\N	Фитинг, d-20mm, Banjo, 26*1,5, 0°	00-00006665	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
874	1	\N	Фитинг, d-20mm, Banjo, 26*1,5, 0°, Italy	00-00006666	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
875	1	\N	Фитинг, d-20mm, Banjo, 27*1,5, 0	00-00005530	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
876	1	\N	Фитинг, d-20mm, Banjo, 27, 0°	00-00008100	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
877	1	\N	Фитинг, d-20mm, Banjo, 3/4, 0°	00-00003072	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
878	1	\N	Фитинг, d-20mm, Banjo, 30*1,5, 0	00-00023719	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
879	1	\N	Фитинг, d-3mm, Banjo, 10x1, 0°	00-00031753	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
880	1	\N	Фитинг, d-3mm, Banjo, 8x1, 0°	00-00031752	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
881	1	\N	Фитинг, d-4mm, Banjo, 10x1, 0°	00-00031754	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
882	1	\N	Фитинг, d-4mm, Banjo, 14x1,5, 0°	00-00031755	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
883	1	\N	Фитинг, d-4mm, Banjo, 8x1, 0°	00-00031756	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
884	1	\N	Фитинг, d-5mm, Banjo, 8*1,5, 0°	00-00006162	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
885	1	\N	Фитинг, d-6mm, Banjo, 1/4, 0°	00-00003074	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
886	1	\N	Фитинг, d-6mm, Banjo, 10*1,5, 0°	00-00001218	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
887	1	\N	Фитинг, d-6mm, Banjo, 12*1,5, 0	00-00001226	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
888	1	\N	Фитинг, d-6mm, Banjo, 14*1,5, 0°	00-00001220	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
889	1	\N	Фитинг, d-6mm, Banjo, 3/8, 0°	00-00003073	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
890	1	\N	Фитинг, d-6mm, Banjo, 8*1,5, 0	00-00015838	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
891	1	2	Фитинг, d-6mm, Banjo, Г, 16*1,5, 0	00-00003066	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
894	1	\N	Фитинг, d-8mm, Banjo, 12*1,5, 0°	00-00003065	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
895	1	\N	Фитинг, d-8mm, Banjo, 14*1,5, 0°	00-00001219	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
896	1	\N	Фитинг, d-8mm, Banjo, 16*1,5, 0°	00-00002759	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
897	1	\N	Фитинг, d-8mm, Banjo, 18*1,5, 0°	00-00001331	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
898	1	\N	Фитинг, d-8mm, Banjo, 20*1,5, 0°	00-00003069	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
899	1	\N	Фитинг, d-8mm, Banjo, 3/8, 0°	00-00004334	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
900	1	2	Фитинг Интерлок, d-20mm, JIC, Г, 1,1/16, 0, Italy	00-00011582	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
901	1	2	Фитинг Интерлок, d-20mm, JIC, Г, 1,1/16, 45°, Italy	00-00011583	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
902	1	2	Фитинг Интерлок, d-20mm, JIC, Г, 1,1/16, 90°, Italy	00-00011584	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
903	1	2	Фитинг Интерлок, d-20mm, JIC, Г, 1,5/16, 0, Italy	00-00012023	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
904	1	2	Фитинг Интерлок, d-20mm, JIC, Г, 1,5/16, 0°	00-00003132	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
905	1	2	Фитинг Интерлок, d-20mm, JIC, Г, 1,5/16, 90°, Italy	00-00012024	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
906	1	3	Фитинг Интерлок, d-20mm, JIC, Ш, 1,1/16, 0, Italy	00-00012025	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
907	1	3	Фитинг Интерлок, d-20mm, JIC, Ш, 1,1/16, 0°	00-00003139	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
908	1	2	Фитинг Интерлок, d-25mm, JIC, Г, 1,5/16, 0, Italy	00-00012094	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
909	1	2	Фитинг Интерлок, d-25mm, JIC, Г, 1,5/16, 0°	00-00001328	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
910	1	2	Фитинг Интерлок, d-25mm, JIC, Г, 1,5/16, 45°, Italy	00-00011585	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
911	1	2	Фитинг Интерлок, d-25mm, JIC, Г, 1,5/16, 90°, Italy	00-00029846	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
912	1	2	Фитинг Интерлок, d-25mm, JIC, Г, 1,5/8, 45°, Italy	00-00012026	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
913	1	2	Фитинг Интерлок, d-25mm, JIC, Г, 1,5/8, 90°, Italy	00-00012027	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
914	1	3	Фитинг Интерлок, d-25mm, JIC, Ш, 1,5/16, 0, Italy	00-00012028	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
915	1	2	Фитинг Интерлок, d-32mm, JIC, Г, 1,5/8, 0, Italy	00-00012029	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
916	1	2	Фитинг Интерлок, d-32mm, JIC, Г, 1,5/8, 0°	00-00003142	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
917	1	2	Фитинг Интерлок, d-32mm, JIC, Г, 1,7/8, 0, Italy	00-00011586	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
918	1	3	Фитинг Интерлок, d-32mm, JIC, Ш, 1,5/16, 0, Italy	00-00012030	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
919	1	3	Фитинг Интерлок, d-32mm, JIC, Ш, 1,5/8, 0, Italy	00-00012033	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
920	1	\N	Фитинг под приварку JIC (Ш) 7/16	00-00008682	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
921	1	2	Фитинг, d-10mm, JIC, Г, 1/2, 0°	00-00003147	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
922	1	2	Фитинг, d-10mm, JIC, Г, 1/2, 45°	00-00008111	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
923	1	2	Фитинг, d-10mm, JIC, Г, 1/2, 90°	00-00008112	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
924	1	2	Фитинг, d-10mm, JIC, Г, 3/4, 0°	00-00000604	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
925	1	2	Фитинг, d-10mm, JIC, Г, 3/4, 0°, Italy	00-00007501	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
926	1	2	Фитинг, d-10mm, JIC, Г, 3/4, 45°	00-00000605	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
927	1	2	Фитинг, d-10mm, JIC, Г, 3/4, 45°, Italy	00-00020114	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
928	1	2	Фитинг, d-10mm, JIC, Г, 3/4, 90°	00-00000606	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
929	1	2	Фитинг, d-10mm, JIC, Г, 3/4, 90°, Italy с муфтой	00-00003149	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
930	1	2	Фитинг, d-10mm, JIC, Г, 3/4, 90°, Parker с муфтой	00-00012096	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
931	1	2	Фитинг, d-10mm, JIC, Г, 5/8, 0	00-00008113	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
932	1	2	Фитинг, d-10mm, JIC, Г, 5/8, 45°	00-00003689	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
933	1	2	Фитинг, d-10mm, JIC, Г, 5/8, 90°	00-00003690	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
934	1	2	Фитинг, d-10mm, JIC, Г, 7/8, 0, Italy	00-00011587	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
935	1	2	Фитинг, d-10mm, JIC, Г, 7/8, 0°	00-00003151	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
936	1	2	Фитинг, d-10mm, JIC, Г, 7/8, 45°	00-00011589	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
937	1	2	Фитинг, d-10mm, JIC, Г, 7/8, 45°, Italy	00-00011590	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
938	1	2	Фитинг, d-10mm, JIC, Г, 7/8, 90°	00-00026524	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
939	1	2	Фитинг, d-10mm, JIC, Г, 7/8, 90°, Italy	00-00011607	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
940	1	2	Фитинг, d-10mm, JIC, Г, 9/16, 0, Gates с муфтой	00-00012097	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
941	1	2	Фитинг, d-10mm, JIC, Г, 9/16, 0, Parker с муфтой	00-00012098	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
942	1	2	Фитинг, d-10mm, JIC, Г, 9/16, 0°	00-00000597	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
943	1	2	Фитинг, d-10mm, JIC, Г, 9/16, 0°, Italy	00-00006711	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
944	1	2	Фитинг, d-10mm, JIC, Г, 9/16, 45°	00-00002325	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
945	1	2	Фитинг, d-10mm, JIC, Г, 9/16, 45°, Gates с муфтой	00-00029841	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
946	1	2	Фитинг, d-10mm, JIC, Г, 9/16, 45°, Italy	00-00006712	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
947	1	2	Фитинг, d-10mm, JIC, Г, 9/16, 90°	00-00000598	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
948	1	2	Фитинг, d-10mm, JIC, Г, 9/16, 90°, Gates	00-00012037	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
949	1	2	Фитинг, d-10mm, JIC, Г, 9/16, 90°, Italy	00-00006713	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
950	1	2	Фитинг, d-10mm, JIC, Г, 9/16, 90°, Parker с муфтой	00-00012099	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
951	1	3	Фитинг, d-10mm, JIC, Ш, 3/4, 0°	00-00000607	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
952	1	3	Фитинг, d-10mm, JIC, Ш, 5/8, 0°	00-00000603	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
953	1	3	Фитинг, d-10mm, JIC, Ш, 9/16, 0, Italy	00-00010506	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
954	1	3	Фитинг, d-10mm, JIC, Ш, 9/16, 0°	00-00000596	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
955	1	2	Фитинг, d-10mm, JICS, Г, 9/16, 90°	00-00008043	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
956	1	2	Фитинг, d-12mm, JIC, Г, 1,1/16, 0, Italy	00-00011609	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
957	1	2	Фитинг, d-12mm, JIC, Г, 1,1/16, 0°	00-00000620	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
958	1	2	Фитинг, d-12mm, JIC, Г, 1,1/16, 0°, Parker с муфтой	00-00012039	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
959	1	2	Фитинг, d-12mm, JIC, Г, 1,1/16, 45°	00-00000621	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
960	1	2	Фитинг, d-12mm, JIC, Г, 1,1/16, 45°, Italy	00-00011610	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
961	1	2	Фитинг, d-12mm, JIC, Г, 3/4, 0, Gates с муфтой	00-00012100	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
962	1	2	Фитинг, d-12mm, JIC, Г, 3/4, 0°	00-00000609	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
963	1	2	Фитинг, d-12mm, JIC, Г, 3/4, 0°, Italy	00-00006714	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
964	1	2	Фитинг, d-12mm, JIC, Г, 3/4, 0°, Parker с муфтой	00-00006048	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
965	1	2	Фитинг, d-12mm, JIC, Г, 3/4, 45°	00-00000610	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
966	1	2	Фитинг, d-12mm, JIC, Г, 3/4, 45°, Italy	00-00006715	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
967	1	2	Фитинг, d-12mm, JIC, Г, 3/4, 90°	00-00000611	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
968	1	2	Фитинг, d-12mm, JIC, Г, 3/4, 90°, c муфтой Italy	00-00012040	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
969	1	2	Фитинг, d-12mm, JIC, Г, 3/4, 90°, Italy	00-00008801	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
970	1	2	Фитинг, d-12mm, JIC, Г, 3/4, 90°, Parker с муфтой	00-00012101	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
971	1	2	Фитинг, d-12mm, JIC, Г, 5/8, 0°	00-00008114	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
972	1	2	Фитинг, d-12mm, JIC, Г, 7/8, 0, Italy	00-00010500	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
973	1	2	Фитинг, d-12mm, JIC, Г, 7/8, 0°	00-00000614	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
974	1	2	Фитинг, d-12mm, JIC, Г, 7/8, 45°	00-00000613	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
975	1	2	Фитинг, d-12mm, JIC, Г, 7/8, 45°, Italy	00-00010498	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
976	1	2	Фитинг, d-12mm, JIC, Г, 7/8, 90°	00-00000612	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
977	1	2	Фитинг, d-12mm, JIC, Г, 7/8, 90°, Italy	00-00010499	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
978	1	2	Фитинг, d-12mm, JIC, Г, 9/16, 0°	00-00000599	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
979	1	2	Фитинг, d-12mm, JIC, Г, 9/16, 45°	00-00000600	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
980	1	2	Фитинг, d-12mm, JIC, Г, 9/16, 45°, Italy	00-00003153	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
981	1	2	Фитинг, d-12mm, JIC, Г, 9/16, 90°	00-00000601	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
982	1	2	Фитинг, d-12mm, JIC, Г, 9/16, 90°, Italy	00-00003155	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
983	1	3	Фитинг, d-12mm, JIC, Ш, 1,1/16, 0, Italy	00-00011612	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
984	1	3	Фитинг, d-12mm, JIC, Ш, 1,1/16, 0°	00-00000619	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
985	1	3	Фитинг, d-12mm, JIC, Ш, 3/4, 0, Italy	00-00010503	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
986	1	3	Фитинг, d-12mm, JIC, Ш, 3/4, 0°	00-00000608	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
987	1	3	Фитинг, d-12mm, JIC, Ш, 3/4, 0°, Parker с муфтой	00-00012041	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
988	1	3	Фитинг, d-12mm, JIC, Ш, 5/8, 0	00-00011613	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
989	1	3	Фитинг, d-12mm, JIC, Ш, 7/8, 0, Italy	00-00011618	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
990	1	3	Фитинг, d-12mm, JIC, Ш, 7/8, 0°	00-00000266	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
991	1	3	Фитинг, d-12mm, JIC, Ш, 7/8, 0°, Parker	00-00004318	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
992	1	3	Фитинг, d-12mm, JIC, Ш, 7/8, 90°, Italy	00-00011619	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
993	1	3	Фитинг, d-12mm, JIC, Ш, 9/16, 0°	00-00000602	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
994	1	3	Фитинг, d-12mm, JIC, Ш, 9/16, 0°, Italy	00-00003156	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
995	1	2	Фитинг, d-12mm, JICS, Г, 3/4, 0°	00-00007900	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
996	1	2	Фитинг, d-12mm, JICS, Г, 3/4, 45°	00-00008036	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
997	1	2	Фитинг, d-12mm, JICS, Г, 3/4, 90°	00-00008046	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
998	1	2	Фитинг, d-12mm, JICS, Г, 7/8, 45°	00-00008037	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
999	1	2	Фитинг, d-12mm, JICS, Г, 7/8, 90°	00-00008044	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1000	1	3	Фитинг, d12mm, JICS, Ш, 7/8, 0°	00-00019994	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1001	1	3	Фитинг, d-12mm, JICS, Ш, 7/8, 0°	00-00008859	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1002	1	2	Фитинг, d-16mm, JIC, Г, 1,1/16, 0°	00-00000625	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1003	1	2	Фитинг, d-16mm, JIC, Г, 1,1/16, 0°, Italy	00-00029843	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1004	1	2	Фитинг, d-16mm, JIC, Г, 1,1/16, 45°	00-00000624	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1005	1	2	Фитинг, d-16mm, JIC, Г, 1,1/16, 90°	00-00000623	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1006	1	2	Фитинг, d-16mm, JIC, Г, 3/4, 0°	00-00003148	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1007	1	2	Фитинг, d-16mm, JIC, Г, 3/4, 45°	00-00004342	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1008	1	2	Фитинг, d-16mm, JIC, Г, 3/4, 90°	00-00004343	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1009	1	2	Фитинг, d-16mm, JIC, Г, 7/8, 0°	00-00000615	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1010	1	2	Фитинг, d-16mm, JIC, Г, 7/8, 0°, Italy	00-00002482	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1011	1	2	Фитинг, d-16mm, JIC, Г, 7/8, 45°	00-00000616	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1012	1	2	Фитинг, d-16mm, JIC, Г, 7/8, 45°, Italy	00-00012054	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1013	1	2	Фитинг, d-16mm, JIC, Г, 7/8, 90°	00-00000617	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1014	1	2	Фитинг, d-16mm, JIC, Г, 7/8, 90°, Italy	00-00011624	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1015	1	3	Фитинг, d-16mm, JIC, Ш, 1,1/16, 0, Italy	00-00011768	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1016	1	3	Фитинг, d-16mm, JIC, Ш, 1,1/16, 0°	00-00000626	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1017	1	3	Фитинг, d-16mm, JIC, Ш, 1,3/16, 0, Italy	00-00024608	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1018	1	3	Фитинг, d-16mm, JIC, Ш, 7/8, 0, Italy	00-00011631	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1019	1	3	Фитинг, d-16mm, JIC, Ш, 7/8, 0°	00-00000618	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1020	1	2	Фитинг, d-16mm, JICS, Г, 7/8, 0	00-00015040	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1021	1	2	Фитинг, d-20mm, JIC, Г, 1,1/16, 0, Gates	00-00012102	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1022	1	2	Фитинг, d-20mm, JIC, Г, 1,1/16, 0°	00-00000628	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1023	1	2	Фитинг, d-20mm, JIC, Г, 1,1/16, 0°, Italy	00-00003133	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1024	1	2	Фитинг, d-20mm, JIC, Г, 1,1/16, 45°	00-00000629	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1025	1	2	Фитинг, d-20mm, JIC, Г, 1,1/16, 45°, Gates	00-00012058	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1026	1	2	Фитинг, d-20mm, JIC, Г, 1,1/16, 45°, Italy	00-00003135	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1027	1	2	Фитинг, d-20mm, JIC, Г, 1,1/16, 90°	00-00000630	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1028	1	2	Фитинг, d-20mm, JIC, Г, 1,1/16, 90°, Gates	00-00012060	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1029	1	2	Фитинг, d-20mm, JIC, Г, 1,1/16, 90°, Italy	00-00003137	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1030	1	2	Фитинг, d-20mm, JIC, Г, 1,1/16, 90°, Parker с муфтой	00-00012059	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1031	1	2	Фитинг, d-20mm, JIC, Г, 1,3/16, 0, Italy	00-00012061	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1032	1	2	Фитинг, d-20mm, JIC, Г, 1,3/16, 0°	00-00000730	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1033	1	2	Фитинг, d-20mm, JIC, Г, 1,3/16, 45°	00-00000731	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1034	1	2	Фитинг, d-20mm, JIC, Г, 1,3/16, 45°, Italy	00-00012062	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1035	1	2	Фитинг, d-20mm, JIC, Г, 1,3/16, 90°	00-00000732	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1036	1	2	Фитинг, d-20mm, JIC, Г, 1,3/16, 90°, Italy	00-00011634	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1037	1	2	Фитинг, d-20mm, JIC, Г, 1,5/16, 0°	00-00000633	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1038	1	2	Фитинг, d-20mm, JIC, Г, 1,5/16, 0°, Italy	00-00003131	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1039	1	2	Фитинг, d-20mm, JIC, Г, 1,5/16, 45°	00-00000632	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1040	1	2	Фитинг, d-20mm, JIC, Г, 1,5/16, 45°, Italy	00-00012063	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1041	1	2	Фитинг, d-20mm, JIC, Г, 1,5/16, 90°	00-00000631	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1042	1	2	Фитинг, d-20mm, JIC, Г, 1,5/16, 90°, Italy	00-00012064	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1043	1	2	Фитинг, d-20mm, JIC, Г, 7/8, 0, Italy	00-00011635	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1044	1	2	Фитинг, d-20mm, JIC, Г, 7/8, 0°	00-00004345	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1045	1	2	Фитинг, d-20mm, JIC, Г, 7/8, 45°	00-00022853	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1046	1	2	Фитинг, d-20mm, JIC, Г, 7/8, 45°, Italy	00-00012065	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1047	1	2	Фитинг, d-20mm, JIC, Г, 7/8, 90°	00-00022854	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1048	1	2	Фитинг, d-20mm, JIC, Г, 7/8, 90°, Italy	00-00012066	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1049	1	3	Фитинг, d-20mm, JIC, Ш, 1,1/16, 0, Gates	00-00012103	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1050	1	3	Фитинг, d-20mm, JIC, Ш, 1,1/16, 0, Italy	00-00010502	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1051	1	3	Фитинг, d-20mm, JIC, Ш, 1,1/16, 0°	00-00000627	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1052	1	3	Фитинг, d-20mm, JIC, Ш, 1,1/16, 0°, Parker с муфтой	00-00012067	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1053	1	3	Фитинг, d-20mm, JIC, Ш, 1,3/16, 0°	00-00005976	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1054	1	3	Фитинг, d-20mm, JIC, Ш, 1,5/16, 0, Italy	00-00012068	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1055	1	3	Фитинг, d-20mm, JIC, Ш, 1,5/16, 0°	00-00003480	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1056	1	3	Фитинг, d-20mm, JIC, Ш, 7/8, 0, Italy	00-00010505	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1057	1	3	Фитинг, d-20mm, JIC, Ш, 7/8, 0°	00-00003152	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1058	1	2	Фитинг, d-20mm, JICS, Г, 1,1/16, 0°	00-00007902	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1059	1	2	Фитинг, d-20mm, JICS, Г, 1,1/16, 45°	00-00008039	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1060	1	2	Фитинг, d-20mm, JICS, Г, 1,1/16, 90°	00-00010054	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1061	1	3	Фитинг, d-20mm, JICS, Ш, 1,1/16, 0	00-00011681	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1062	1	3	Фитинг, d-20mm, JICS, Ш, 1,5/16, 0	00-00010825	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1063	1	2	Фитинг, d-25mm, JIC, Г, 1,1/16, 0°	00-00003134	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1064	1	2	Фитинг, d-25mm, JIC, Г, 1,1/16, 0°, Italy	00-00007502	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1065	1	2	Фитинг, d-25mm, JIC, Г, 1,1/16, 45°	00-00003136	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1066	1	2	Фитинг, d-25mm, JIC, Г, 1,1/16, 90°	00-00003138	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1067	1	2	Фитинг, d-25mm, JIC, Г, 1,1/16, 90°, Italy	00-00012070	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1068	1	2	Фитинг, d-25mm, JIC, Г, 1,3/16, 0, Gates	00-00012071	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1069	1	2	Фитинг, d-25mm, JIC, Г, 1,3/16, 0, Italy	00-00011637	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1070	1	2	Фитинг, d-25mm, JIC, Г, 1,3/16, 0°	00-00000735	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1071	1	2	Фитинг, d-25mm, JIC, Г, 1,3/16, 45°	00-00000734	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1072	1	2	Фитинг, d-25mm, JIC, Г, 1,3/16, 90°	00-00000733	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1073	1	2	Фитинг, d-25mm, JIC, Г, 1,5/16, 0, c муфтой Italy	00-00012072	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1074	1	2	Фитинг, d-25mm, JIC, Г, 1,5/16, 0, Parker с муфтой	00-00012104	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1075	1	2	Фитинг, d-25mm, JIC, Г, 1,5/16, 0°	00-00000635	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1076	1	2	Фитинг, d-25mm, JIC, Г, 1,5/16, 0°, Gates	00-00006044	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1077	1	2	Фитинг, d-25mm, JIC, Г, 1,5/16, 0°, Italy	00-00005975	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1078	1	2	Фитинг, d-25mm, JIC, Г, 1,5/16, 45°	00-00000636	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1079	1	2	Фитинг, d-25mm, JIC, Г, 1,5/16, 45°, Gates	00-00006045	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1080	1	2	Фитинг, d-25mm, JIC, Г, 1,5/16, 45°, Italy	00-00006717	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1081	1	2	Фитинг, d-25mm, JIC, Г, 1,5/16, 90°	00-00000637	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1082	1	2	Фитинг, d-25mm, JIC, Г, 1,5/16, 90°, Italy	00-00006716	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1083	1	2	Фитинг, d-25mm, JIC, Г, 1,5/8, 0, Italy	00-00012073	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1084	1	2	Фитинг, d-25mm, JIC, Г, 1,5/8, 90°	00-00012074	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1085	1	2	Фитинг, d-25mm, JIC, Г, 1,5/8, 90°, Italy	00-00029844	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1086	1	3	Фитинг, d-25mm, JIC, Ш, 1, 0°	00-00005977	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1087	1	3	Фитинг, d-25mm, JIC, Ш, 1,1/16, 0°	00-00003140	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1088	1	3	Фитинг, d-25mm, JIC, Ш, 1,1/16, 0°, Italy	00-00003141	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1089	1	3	Фитинг, d-25mm, JIC, Ш, 1,5/16, 0, Italy	00-00012075	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1090	1	3	Фитинг, d-25mm, JIC, Ш, 1,5/16, 0°	00-00000634	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1091	1	3	Фитинг, d-25mm, JIC, Ш, 1,5/8, 0, Italy	00-00012076	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1092	1	2	Фитинг, d-25mm, JICS, Г, 1,5/16, 0°	00-00007899	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1093	1	2	Фитинг, d-25mm, JICS, Г, 1,5/16, 45°	00-00008040	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1094	1	2	Фитинг, d-25mm, JICS, Г, 1,5/16, 90°	00-00008047	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1095	1	3	Фитинг, d-25mm, JICS, Ш, 1,5/16, 0°	00-00008860	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1096	1	2	Фитинг, d-32mm, JIC, Г, 1,5/16, 0	00-00011640	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1097	1	2	Фитинг, d-32mm, JIC, Г, 1,5/16, 90°, Italy	00-00012084	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1098	1	2	Фитинг, d-32mm, JIC, Г, 1,5/8, 0°	00-00000642	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1099	1	2	Фитинг, d-32mm, JIC, Г, 1,5/8, 0°, Italy	00-00003143	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1100	1	2	Фитинг, d-32mm, JIC, Г, 1,5/8, 45°	00-00000643	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1101	1	2	Фитинг, d-32mm, JIC, Г, 1,5/8, 45°, Italy	00-00006735	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1102	1	2	Фитинг, d-32mm, JIC, Г, 1,5/8, 90°	00-00000644	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1103	1	2	Фитинг, d-32mm, JIC, Г, 1,5/8, 90°, Italy	00-00007483	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1104	1	2	Фитинг, d-32mm, JIC, Г, 1,7/8, 0	00-00012085	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1105	1	2	Фитинг, d-32mm, JIC, Г, 1,7/8, 0°, Italy	00-00029847	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1106	1	2	Фитинг, d-32mm, JIC, Г, 1,7/8, 90°, Italy	00-00012086	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1107	1	3	Фитинг, d-32mm, JIC, Ш, 1,5/16, 0	00-00011641	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1108	1	3	Фитинг, d-32mm, JIC, Ш, 1,5/8, 0, Italy	00-00012087	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1109	1	3	Фитинг, d-32mm, JIC, Ш, 1,5/8, 0°	00-00000645	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1110	1	3	Фитинг, d-32mm, JIC, Ш, 1,7/8, 0	00-00024881	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1111	1	3	Фитинг, d-32mm, JIC, Ш, 1,7/8, 0, Italy	00-00024607	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1112	1	2	Фитинг, d-32mm, JICS, Г, 1,5/8, 0°	00-00007903	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1113	1	2	Фитинг, d-32mm, JICS, Г, 1,5/8, 45°	00-00008041	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1114	1	2	Фитинг, d-32mm, JICS, Г, 1,5/8, 90°	00-00008048	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1115	1	2	Фитинг, d-38mm, JIC, Г, 1,7/8, 0°	00-00000640	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1116	1	2	Фитинг, d-38mm, JIC, Г, 1,7/8, 0°, Italy	00-00008802	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1117	1	2	Фитинг, d-38mm, JIC, Г, 1,7/8, 45°	00-00000639	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1118	1	2	Фитинг, d-38mm, JIC, Г, 1,7/8, 45°, Italy	00-00003144	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1119	1	2	Фитинг, d-38mm, JIC, Г, 1,7/8, 90°	00-00000638	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1120	1	2	Фитинг, d-38mm, JIC, Г, 1,7/8, 90°, Italy	00-00006736	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1121	1	3	Фитинг, d-38mm, JIC, Ш, 1,7/8, 0°	00-00000641	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1122	1	3	Фитинг, d-38mm, JIC, Ш, 1,7/8, 0°, Italy	00-00003145	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1123	1	\N	Фитинг, d-4mm, JIC, 14*1, 0, токар.	00-00014256	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1124	1	2	Фитинг, d-50mm, JIC, Г, 2, 0°	00-00006176	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1125	1	2	Фитинг, d-50mm, JIC, Г, 2,1/2, 0°	00-00001276	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1126	1	2	Фитинг, d-50mm, JIC, Г, 2,1/2, 45°	00-00001277	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1127	1	2	Фитинг, d-50mm, JIC, Г, 2,1/2, 90°	00-00001278	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1128	1	3	Фитинг, d-50mm, JIC, Ш, 2,1/2, 0°	00-00001279	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1129	1	2	Фитинг, d-5mm, JIC, Г, 7/16, 0°	00-00008107	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1130	1	2	Фитинг, d-5mm, JIC, Г, 7/16, 45°	00-00016826	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1131	1	2	Фитинг, d-5mm, JIC, Г, 7/16, 90°	00-00016827	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1132	1	3	Фитинг, d-5mm, JIC, Ш, 7/16, 0°	00-00008108	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1133	1	2	Фитинг, d-6mm, JIC, Г, 1/2, 0, Italy	00-00010495	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1134	1	2	Фитинг, d-6mm, JIC, Г, 1/2, 0°	00-00000581	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1135	1	2	Фитинг, d-6mm, JIC, Г, 1/2, 45°	00-00000582	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1136	1	2	Фитинг, d-6mm, JIC, Г, 1/2, 45°, Italy	00-00010493	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1137	1	2	Фитинг, d-6mm, JIC, Г, 1/2, 90°	00-00000583	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1138	1	2	Фитинг, d-6mm, JIC, Г, 1/2, 90°, Italy	00-00011642	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1139	1	2	Фитинг, d-6mm, JIC, Г, 12*1, 0°	00-00008116	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1140	1	2	Фитинг, d-6mm, JIC, Г, 7/16, 0°	00-00000586	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1141	1	2	Фитинг, d-6mm, JIC, Г, 7/16, 0°, Italy	00-00007503	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1142	1	2	Фитинг, d-6mm, JIC, Г, 7/16, 45°	00-00000585	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1143	1	2	Фитинг, d-6mm, JIC, Г, 7/16, 45°, Italy	00-00006710	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1144	1	2	Фитинг, d-6mm, JIC, Г, 7/16, 90°	00-00000584	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1145	1	2	Фитинг, d-6mm, JIC, Г, 7/16, 90°, Gates	00-00012090	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1146	1	2	Фитинг, d-6mm, JIC, Г, 7/16, 90°, Italy	00-00008798	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1147	1	2	Фитинг, d-6mm, JIC, Г, 7/16, 90°, kompact	00-00003150	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1148	1	2	Фитинг, d-6mm, JIC, Г, 7/16, 90°, Parker с муфтой	00-00012109	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1149	1	2	Фитинг, d-6mm, JIC, Г, 9/16, 0°	00-00000589	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1150	1	2	Фитинг, d-6mm, JIC, Г, 9/16, 0°, Italy	00-00003154	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1151	1	2	Фитинг, d-6mm, JIC, Г, 9/16, 45°	00-00000590	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1152	1	2	Фитинг, d-6mm, JIC, Г, 9/16, 45°, Italy	00-00010501	45	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1153	1	2	Фитинг, d-6mm, JIC, Г, 9/16, 90°	00-00000591	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1154	1	2	Фитинг, d-6mm, JIC, Г, 9/16, 90°, Italy	00-00005978	90	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1155	1	3	Фитинг, d-6mm, JIC, Ш, 1/2, 0°	00-00000580	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1156	1	3	Фитинг, d-6mm, JIC, Ш, 7/16, 0, Italy	00-00010504	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	1	шт.	\N
1157	1	3	Фитинг, d-6mm, JIC, Ш, 7/16, 0°	00-00000587	\N	\N	t	2026-10-14 08:30:58	2026-10-14 08:30:58	\N	\N	шт.	\N
1158	1	3	Фитинг, d-6mm, JIC, Ш, 9/16, 0°	00-00000588	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1159	1	2	Фитинг, d-6mm, JICS, Г, 7/16, 90°	00-00008042	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1160	1	2	Фитинг, d-8mm, JIC, Г, 1/2, 0, Italy	00-00011645	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1161	1	2	Фитинг, d-8mm, JIC, Г, 1/2, 0°	00-00003146	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1162	1	2	Фитинг, d-8mm, JIC, Г, 1/2, 45°	00-00013153	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1163	1	2	Фитинг, d-8mm, JIC, Г, 1/2, 90°	00-00007031	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1164	1	2	Фитинг, d-8mm, JIC, Г, 1/2, 90°, Italy	00-00011648	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1165	1	2	Фитинг, d-8mm, JIC, Г, 3/4, 0	00-00011649	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1166	1	2	Фитинг, d-8mm, JIC, Г, 3/4, 90°	00-00016829	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1167	1	2	Фитинг, d-8mm, JIC, Г, 5/8, 0°	00-00008109	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1168	1	2	Фитинг, d-8mm, JIC, Г, 5/8, 90°	00-00008110	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1169	1	2	Фитинг, d-8mm, JIC, Г, 9/16, 0	00-00000594	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1170	1	2	Фитинг, d-8mm, JIC, Г, 9/16, 0, Italy	00-00011650	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1171	1	2	Фитинг, d-8mm, JIC, Г, 9/16, 45°	00-00000593	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1172	1	2	Фитинг, d-8mm, JIC, Г, 9/16, 45°, Italy	00-00011655	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1173	1	2	Фитинг, d-8mm, JIC, Г, 9/16, 90°	00-00000592	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1174	1	2	Фитинг, d-8mm, JIC, Г, 9/16, 90°, Italy	00-00011656	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1175	1	3	Фитинг, d-8mm, JIC, Ш, 1/2, 0	00-00011657	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1176	1	3	Фитинг, d-8mm, JIC, Ш, 3/4, 0	00-00011658	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1177	1	3	Фитинг, d-8mm, JIC, Ш, 9/16, 0, Italy	00-00011659	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1178	1	3	Фитинг, d-8mm, JIC, Ш, 9/16, 0°	00-00000595	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1179	1	2	Фитинг, d-10mm, JIS, Г, 1/4, 0	00-00011608	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1180	1	2	Фитинг, d-10mm, JIS, Г, 3/8, 0°	00-00000397	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1181	1	2	Фитинг, d-10mm, JIS, Г, 3/8, 45°	00-00003119	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1182	1	2	Фитинг, d-10mm, JIS, Г, 3/8, 90°	00-00000398	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1183	1	2	Фитинг, d-10mm, JIS, Г, 9/16, 90°	00-00008868	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1184	1	2	Фитинг, d-12mm, JIS, Г, 1/2, 0°	00-00000399	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1185	1	2	Фитинг, d-12mm, JIS, Г, 1/2, 45°	00-00003120	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1186	1	2	Фитинг, d-12mm, JIS, Г, 1/2, 90°	00-00003121	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1187	1	2	Фитинг, d-20mm, JIS, Г, 3/4, 0°	00-00000536	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1188	1	2	Фитинг, d-20mm, JIS, Г, 3/4, 45°	00-00003122	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1189	1	2	Фитинг, d-20mm, JIS, Г, 3/4, 90°	00-00000537	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1190	1	2	Фитинг, d-25mm, JIS, Г, 1, 0, Italy	00-00012078	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1191	1	2	Фитинг, d-25mm, JIS, Г, 1, 0°	00-00000538	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1192	1	2	Фитинг, d-25mm, JIS, Г, 1, 90°	00-00003123	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1193	1	2	Фитинг, d-6mm, JIS, Г, 1/4, 0°, st	00-00000396	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1194	1	2	Фитинг, d-6mm, JIS, Г, 1/4, 45°, st	00-00003116	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1195	1	2	Фитинг, d-6mm, JIS, Г, 1/4, 90°, st	00-00003117	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1196	1	2	Фитинг, d-6mm, JIS, Г, 1/8, 0°, HD	00-00003114	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1197	1	2	Фитинг, d-10mm, Komatsu, Г, 14*1,5, 0°	00-00000521	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1198	1	2	Фитинг, d-10mm, Komatsu, Г, 14*1,5, 45°	00-00000522	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1199	1	2	Фитинг, d-10mm, Komatsu, Г, 14*1,5, 90°	00-00000523	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1200	1	2	Фитинг, d-10mm, Komatsu, Г, 16*1, 0	00-00010194	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1201	1	2	Фитинг, d-10mm, Komatsu, Г, 16*1,5, 0°	00-00000370	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1202	1	2	Фитинг, d-10mm, Komatsu, Г, 16*1,5, 45	00-00000371	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1203	1	2	Фитинг, d10mm, Komatsu, Г, 16*1,5, 90°	00-00020041	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1204	1	2	Фитинг, d-10mm, Komatsu, Г, 16*1,5, 90°	00-00000372	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1205	1	2	Фитинг, d-10mm, Komatsu, Г, 18*1,5, 0°	00-00000373	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1206	1	2	Фитинг, d-10mm, Komatsu, Г, 18*1,5, 0°, удл.	00-00003485	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1207	1	2	Фитинг, d-10mm, Komatsu, Г, 18*1,5, 45	00-00000374	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1208	1	2	Фитинг, d-10mm, Komatsu, Г, 18*1,5, 90°	00-00000375	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1209	1	2	Фитинг, d-10mm, Komatsu, Г, 20*1,5, 0°	00-00000379	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1210	1	2	Фитинг, d-10mm, Komatsu, Г, 20*1,5, 45	00-00000380	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1211	1	2	Фитинг, d-10mm, Komatsu, Г, 20*1,5, 90°	00-00000381	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1212	1	3	Фитинг, d-10mm, Komatsu, Ш, 16*1,5, 0, GV удл.	00-00003253	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1213	1	3	Фитинг, d-10mm, Komatsu, Ш, 20*1,5, 0°	00-00003255	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1214	1	2	Фитинг, d-32mm, Komatsu, Г, 36*1,5, 0°, Italy	00-00029845	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1215	1	2	Фитинг, d-38mm, Komatsu, Г, 42*1,5, 0°	00-00004246	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1216	1	2	Фитинг, d-38mm, Komatsu, Г, 42*1,5, 45°	00-00017780	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1217	1	2	Фитинг, d-38mm, Komatsu, Г, 42*1,5, 90°	00-00017781	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1218	1	2	Фитинг, d-38mm, Komatsu, Г, 52*2, 0°	00-00003293	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1219	1	2	Фитинг, d-6mm, Komatsu, Г, 10*1, 0°	00-00002681	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1220	1	2	Фитинг, d-6mm, Komatsu, Г, 10*1, 0°, st	00-00000395	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1221	1	2	Фитинг, d-6mm, Komatsu, Г, 10*1, 90°	00-00008115	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1222	1	2	Фитинг, d-6mm, Komatsu, Г, 10*1,5, 0°	00-00000394	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1223	1	2	Фитинг, d-6mm, Komatsu, Г, 12*1, 0°	00-00000519	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1224	1	2	Фитинг, d-6mm, Komatsu, Г, 12*1,5, 0°	00-00000361	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1225	1	2	Фитинг, d-6mm, Komatsu, Г, 12*1,5, 45	00-00000362	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1226	1	2	Фитинг, d-6mm, Komatsu, Г, 12*1,5, 90°	00-00000363	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1227	1	2	Фитинг, d-6mm, Komatsu, Г, 14*1, 0°	00-00000520	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1228	1	2	Фитинг, d-6mm, Komatsu, Г, 14*1, 90°	00-00010195	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1229	1	2	Фитинг, d-6mm, Komatsu, Г, 14*1,5, 0°	00-00000365	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1230	1	2	Фитинг, d-6mm, Komatsu, Г, 14*1,5, 45	00-00000366	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1231	1	2	Фитинг, d-6mm, Komatsu, Г, 14*1,5, 90°	00-00000364	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1232	1	2	Фитинг, d-6mm, Komatsu, Г, 14*2 0°, GV	00-00029312	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1233	1	2	Фитинг, d-6mm, Komatsu, Г, 16*1, 0	00-00013350	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1234	1	2	Фитинг, d-6mm, Komatsu, Г, 16*1,5, 0°	00-00000524	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1235	1	2	Фитинг, d-6mm, Komatsu, Г, 16*1,5, 45°	00-00000525	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1236	1	2	Фитинг, d-6mm, Komatsu, Г, 16*1,5, 90°	00-00000526	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1237	1	3	Фитинг, d-6mm, Komatsu, Ш, 10*1, 0, удл.	00-00010201	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1238	1	3	Фитинг, d-6mm, Komatsu, Ш, 10*1, 0°	00-00003247	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1239	1	3	Фитинг, d-6mm, Komatsu, Ш, 10*1, 0°, st	00-00008117	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1240	1	3	Фитинг, d-6mm, Komatsu, Ш, 12*1, 0, удл.	00-00010203	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1241	1	3	Фитинг, d-6mm, Komatsu, Ш, 12*1, 0°	00-00003249	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1242	1	\N	Фитинг, d-6mm, Komatsu, ш, 12*1,5, 0, GV удл.	00-00023957	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1243	1	3	Фитинг, d-6mm, Komatsu, Ш, 12*1,5, 0°	00-00003251	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1244	1	3	Фитинг, d-6mm, Komatsu, Ш, 14*1,5, 0°	00-00031638	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1245	1	2	Фитинг, d-8mm, Komatsu, Г, 14*1,5, 0°	00-00000367	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1246	1	2	Фитинг, d-8mm, Komatsu, Г, 14*1,5, 45	00-00000368	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1247	1	2	Фитинг, d-8mm, Komatsu, Г, 14*1,5, 90°	00-00000369	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1248	1	2	Фитинг, d-8mm, Komatsu, Г, 16*1, 0	00-00013351	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1249	1	2	Фитинг, d-8mm, Komatsu, Г, 16*1, 0°, GV	00-00012968	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1250	1	2	Фитинг, d-8mm, Komatsu, Г, 16*1,5, 0°	00-00000527	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1251	1	2	Фитинг, d-8mm, Komatsu, Г, 16*1,5, 45°	00-00000528	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1252	1	2	Фитинг, d-8mm, Komatsu, Г, 16*1,5, 90°	00-00000529	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1253	1	2	Фитинг, d-8mm, Komatsu, Г, 18*1,5, 0°	00-00006668	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1254	1	2	Фитинг, d-8mm, Komatsu, Г, 18*1,5, 90°	00-00003698	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1255	1	3	Фитинг, d-8mm, Komatsu, Ш, 14*1,5, 0°	00-00003252	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1256	1	2	Фитинг, d-10mm, JIS Metric, Г, 14*1,5, 0°	00-00000376	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1257	1	2	Фитинг, d-10mm, JIS Metric, Г, 14*1,5, 45°	00-00001298	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1258	1	2	Фитинг, d-10mm, JIS Metric, Г, 14*1,5, 90°	00-00001299	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1259	1	2	Фитинг, d-10mm, JIS Metric, Г, 16*1, 0	00-00010144	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1260	1	2	Фитинг, d-10mm, JIS Metric, Г, 16*1, 0°, GV удл.	00-00012845	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1261	1	2	Фитинг, d-10mm, JIS Metric, Г, 16*1,5, 0°	00-00003388	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1262	1	2	Фитинг, d-10mm, JIS Metric, Г, 18*1,5, 0°	00-00001329	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1263	1	2	Фитинг, d-10mm, JIS Metric, Г, 18*1,5, 45	00-00000377	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1264	1	2	Фитинг, d-10mm, JIS Metric, Г, 18*1,5, 90°	00-00000378	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1265	1	2	Фитинг, d-10mm, JIS Metric, Г, 20*1,5, 0°	00-00003267	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1266	1	2	Фитинг, d-10mm, JIS Metric, Г, 20*1,5, 90°	00-00003268	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1267	1	3	Фитинг, d-10mm, JIS Metric, Ш, 14*1,5, 0, GV удл.	00-00027115	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1268	1	3	Фитинг, d-10mm, JIS Metric, Ш, 14*1,5, 0, удл.	00-00010207	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1269	1	3	Фитинг, d-10mm, JIS Metric, Ш, 14*1,5, 0°	00-00004319	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1270	1	3	Фитинг, d-10mm, JIS Metric, Ш, 16*1,5, 0	00-00010198	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1271	1	3	Фитинг, d-10mm, JIS Metric, Ш, 16*1,5, 0, удл.	00-00010208	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1272	1	3	Фитинг, d-10mm, JIS Metric, Ш, 16*1,5, 0°, GV удл.	00-00003389	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1273	1	3	Фитинг, d-10mm, JIS Metric, Ш, 18*1,5, 0	00-00010199	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1274	1	3	Фитинг, d-10mm, JIS Metric, Ш, 18*1,5, 0, удл.	00-00010209	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1275	1	3	Фитинг, d-10mm, JIS Metric, Ш, 20*1,5, 0, GV удл.	00-00027116	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1276	1	3	Фитинг, d-10mm, JIS Metric, Ш, 20*1,5, 0, удл.	00-00010210	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1277	1	3	Фитинг, d-10mm, JIS Metric, Ш, 20*1,5, 0°	00-00004320	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1278	1	2	Фитинг, d-12mm, JIS Metric, Г, 18*1,5, 0°	00-00000533	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1279	1	2	Фитинг, d-12mm, JIS Metric, Г, 18*1,5, 45°	00-00000534	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1280	1	2	Фитинг, d-12mm, JIS Metric, Г, 18*1,5, 90°	00-00000535	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1281	1	2	Фитинг, d-12mm, JIS Metric, Г, 20*1,5, 0°	00-00003269	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1282	1	2	Фитинг, d-12mm, JIS Metric, Г, 20*1,5, 45°	00-00003270	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1283	1	2	Фитинг, d-12mm, JIS Metric, Г, 22*1,5, 0°	00-00003279	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1284	1	2	Фитинг, d-12mm, JIS Metric, Г, 22*1,5, 45°	00-00003280	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1285	1	2	Фитинг, d-12mm, JIS Metric, Г, 22*1,5, 90°	00-00003281	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1286	1	2	Фитинг, d-12mm, JIS Metric, Г, 24*1,5, 0°	00-00003035	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1287	1	2	Фитинг, d-12mm, JIS Metric, Г, 24*1,5, 90°	00-00003283	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1288	1	3	Фитинг, d-12mm, JIS Metric, Ш, 20*1,5, 0°	00-00004321	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1289	1	3	Фитинг, d-12mm, JIS Metric, Ш, 22*1,5, 0	00-00010034	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1290	1	3	Фитинг, d-12mm, JIS Metric, Ш, 22*1,5, 0, удл.	00-00010211	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1291	1	3	Фитинг, d-12mm, JIS Metric, Ш, 24*1,5, 0	00-00010200	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1292	1	3	Фитинг, d-12mm, JIS Metric, Ш, 24*1,5, 0, удл.	00-00010212	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1293	1	2	Фитинг, d-16mm, JIS Metric, Г, 24*1,5, 0, Italy	00-00026092	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1294	1	2	Фитинг, d-16mm, JIS Metric, Г, 24*1,5, 0°	00-00002855	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1295	1	2	Фитинг, d-16mm, JIS Metric, Г, 24*1,5, 45°	00-00013160	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1296	1	2	Фитинг, d-16mm, JIS Metric, Г, 24*1,5, 90°	00-00003282	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1297	1	2	Фитинг, d-16mm, JIS Metric, Г, 27*1,5, 0	00-00003897	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1298	1	2	Фитинг, d-16mm, JIS Metric, Г, 27*1,5, 0, (HS)	00-00009568	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1299	1	2	Фитинг, d-16mm, JIS Metric, Г, 33*1,5, 0°	00-00003284	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1300	1	2	Фитинг, d-16mm, JIS Metric, Г, 33*1,5, 45°	00-00003285	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1301	1	2	Фитинг, d-16mm, JIS Metric, Г, 33*1,5, 90°	00-00003286	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1302	1	2	Фитинг, d-20mm, JIS Metric, Г, 24*1,5, 0	00-00026525	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1303	1	2	Фитинг, d-20mm, JIS Metric, Г, 30*1,5, 0°	00-00000391	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1304	1	2	Фитинг, d-20mm, JIS Metric, Г, 30*1,5, 45°	00-00000392	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1305	1	2	Фитинг, d-20mm, JIS Metric, Г, 30*1,5, 90°	00-00000393	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1306	1	2	Фитинг, d-20mm, JIS Metric, Г, 33*1,5, 0°	00-00000508	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1307	1	2	Фитинг, d-20mm, JIS Metric, Г, 33*1,5, 45°	00-00000509	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1308	1	2	Фитинг, d-20mm, JIS Metric, Г, 33*1,5, 90°	00-00000510	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1309	1	2	Фитинг, d-25mm, JIS Metric, Г, 33*1,5, 0, Italy	00-00026093	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1310	1	2	Фитинг, d-25mm, JIS Metric, Г, 33*1,5, 0°	00-00000505	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1311	1	2	Фитинг, d-25mm, JIS Metric, Г, 33*1,5, 45°	00-00000506	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1312	1	2	Фитинг, d-25mm, JIS Metric, Г, 33*1,5, 90°	00-00000507	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1313	1	2	Фитинг, d-25mm, JIS Metric, Г, 33*2, 0°	00-00003287	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1314	1	2	Фитинг, d-25mm, JIS Metric, Г, 36*1,5, 0, Italy	00-00012077	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1315	1	2	Фитинг, d-25mm, JIS Metric, Г, 36*1,5, 0°	00-00003288	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1316	1	2	Фитинг, d-25mm, JIS Metric, Г, 36*1,5, 45°	00-00003289	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1317	1	2	Фитинг, d-25mm, JIS Metric, Г, 36*1,5, 90°	00-00003290	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1318	1	2	Фитинг, d-25mm, JIS Metric, Г, 36*2, 0°	00-00000511	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1319	1	2	Фитинг, d-25mm, JIS Metric, Г, 36*2, 45°	00-00000512	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1320	1	2	Фитинг, d-25mm, JIS Metric, Г, 36*2, 90°	00-00000513	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1321	1	2	Фитинг, d-32mm, JIS Metric, Г, 42*1,5, 0°	00-00000516	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1322	1	2	Фитинг, d-32mm, JIS Metric, Г, 42*1,5, 45°	00-00000515	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1323	1	2	Фитинг, d-32mm, JIS Metric, Г, 42*1,5, 90°	00-00000514	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1324	1	2	Фитинг, d-32mm, JIS Metric, Г, 42*1,5, 90°, Italy	00-00005941	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1325	1	3	Фитинг, d-32mm, JIS Metric, Ш, 42*1,5, 0°	00-00000517	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1326	1	2	Фитинг, d-6mm, JIS Metric, Г, 1/8, 0	00-00010146	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1327	1	2	Фитинг, d-6mm, JIS Metric, Г, 10*1, 0°, st	00-00003034	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1328	1	2	Фитинг, d-6mm, JIS Metric, Г, 10*1,5, 0	00-00010193	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1329	1	2	Фитинг, d-6mm, JIS Metric, Г, 12*1, 90°	00-00028469	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1330	1	2	Фитинг, d-6mm, JIS Metric, Г, 12*1,5, 0, удл.	00-00010205	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1331	1	2	Фитинг, d-6mm, JIS Metric, Г, 12*1,5, 0°	00-00003258	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1332	1	2	Фитинг, d-6mm, JIS Metric, Г, 12*1,5, 45°	00-00003259	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1333	1	2	Фитинг, d-6mm, JIS Metric, Г, 12*1,5, 90°	00-00032242	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1334	1	2	Фитинг, d-6mm, JIS Metric, Г, 14*1, 0	00-00010143	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1335	1	2	Фитинг, d-6mm, JIS Metric, Г, 14*1, 90°	00-00010145	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1336	1	2	Фитинг, d-6mm, JIS Metric, Г, 14*1,5, 0°	00-00003260	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1337	1	2	Фитинг, d-6mm, JIS Metric, Г, 14*1,5, 45°	00-00003261	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1338	1	2	Фитинг, d-6mm, JIS Metric, Г, 14*1,5, 90°	00-00003262	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1339	1	2	Фитинг, d-6mm, JIS Metric, Г, 16*1,5, 0°	00-00003264	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1340	1	3	Фитинг, d-6mm, JIS Metric, Ш, 10*1,5, 0	00-00010196	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1341	1	3	Фитинг, d-6mm, JIS Metric, Ш, 10*1,5, 0, удл.	00-00010202	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1342	1	3	Фитинг, d-6mm, JIS Metric, Ш, 12*1, 0	00-00010197	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1343	1	3	Фитинг, d-6mm, JIS Metric, Ш, 12*1, 0°, GV	00-00026562	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1344	1	3	Фитинг, d-6mm, JIS Metric, Ш, 12*1,25, 0, удл.	00-00010204	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1345	1	3	Фитинг, d-6mm, JIS Metric, Ш, 12*1,5, 0, удл.	00-00010206	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1346	1	2	Фитинг, d-8mm, JIS Metric, Г, 14*1,5, 0°	00-00003263	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1347	1	2	Фитинг, d-8mm, JIS Metric, Г, 16*1,5, 0	00-00016490	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1348	1	2	Фитинг, d-8mm, JIS Metric, Г, 16*1,5, 45°	00-00003265	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1349	1	2	Фитинг, d-8mm, JIS Metric, Г, 16*1,5, 90°	00-00003266	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1350	1	2	Фитинг, d-10mm, Karсher, Г, 22*1,5, 0°, пласт.	00-00003130	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1351	1	2	Фитинг, d-6mm, Karсher EASY LOCK, Г, 22*1,5, 0°, латунь	00-00029494	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1352	1	2	Фитинг, d-6mm, Karсher, Г, 22*1,5, 0°, GV	00-00030556	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1353	1	2	Фитинг, d-6mm, Karсher, Г, 22*1,5, 0°, металл.	00-00003128	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1354	1	2	Фитинг, d-6mm, Karсher, Г, 22*1,5, 0°, пласт.	00-00003129	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1355	1	2	Фитинг, d-6mm, Karсher, Г, 22*1,5, 0°, пласт. длин.гайка	00-00020095	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1356	1	3	Фитинг, d-6mm, Karсher, Ш, 10мм, 0°	00-00010152	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1357	1	3	Фитинг, d-6mm, Karсher, Ш, 11мм, 0°	00-00003694	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1358	1	3	Фитинг, d-6mm, Karсher, Ш, К2-К4, 0°	00-00003693	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1359	1	2	Фитинг, d-8mm, Karсher EASY LOCK, Г, 22*1,5, 0°, латунь	00-00029495	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1360	1	2	Фитинг, d-8mm, Karсher, Г, 22*1,5, 0°, металл.	00-00003127	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1361	1	2	Фитинг, d-8mm, Karсher, Г, 22*1,5, 0°, пласт.	00-00005928	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1362	1	2	Фитинг, d-8mm, Karсher, Г, 22*1,5, 0°, пласт. длин.гайка	00-00020096	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1363	1	3	Фитинг, d-8mm, Karсher, Ш, 10мм, 0°	00-00003696	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1364	1	3	Фитинг, d-8mm, Karсher, Ш, 11мм, 0°	00-00003695	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1365	1	2	Фитинг Интерлок, d-20mm, ORFS, Г, 1,3/16, 0°	00-00008120	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1366	1	2	Фитинг Интерлок, d-25mm, ORFS, Г, 1,7/16, 0°	00-00003170	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1367	1	2	Фитинг Интерлок, d-25mm, ORFS, Г, 1,7/16, 90°	00-00008122	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1368	1	2	Фитинг Интерлок, d-25mm, ORFS, Г, 1,7/16, 90°, Italy	00-00012095	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1369	1	2	Фитинг Интерлок, d-32mm, ORFS, Г, 1,11/16, 0	00-00016239	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1370	1	2	Фитинг Интерлок, d-32mm, ORFS, Г, 1,11/16, 0, токар.	00-00016140	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1371	1	2	Фитинг Интерлок, d-32mm, ORFS, Г, 1,11/16, 45°	00-00020916	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1372	1	2	Фитинг Интерлок, d-32mm, ORFS, Г, 1,11/16, 45°, Italy	00-00020628	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1373	1	2	Фитинг Интерлок, d-32mm, ORFS, Г, 1,11/16, 90°	00-00013358	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1374	1	2	Фитинг, d-10mm, ORFS, Г, 11/16, 0°	00-00000658	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1375	1	2	Фитинг, d-10mm, ORFS, Г, 11/16, 45°	00-00000659	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1376	1	2	Фитинг, d-10mm, ORFS, Г, 11/16, 90°	00-00000660	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1377	1	2	Фитинг, d-10mm, ORFS, Г, 11/16, 90°, Italy	00-00004227	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1378	1	2	Фитинг, d-10mm, ORFS, Г, 13/16, 0°	00-00000666	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1379	1	2	Фитинг, d-10mm, ORFS, Г, 13/16, 45°	00-00000667	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1380	1	2	Фитинг, d-10mm, ORFS, Г, 13/16, 90°	00-00000668	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1381	1	2	Фитинг, d-10mm, ORFS, Г, 13/16, 90°, Italy	00-00026151	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1382	1	2	Фитинг, d-10mm, ORFS, Г, 9/16, 0°	00-00003173	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1383	1	2	Фитинг, d-10mm, ORFS, Г, 9/16, 45°	00-00017203	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1384	1	2	Фитинг, d-10mm, ORFS, Г, 9/16, 90°	00-00017204	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1385	1	3	Фитинг, d-10mm, ORFS, Ш, 11/16, 0°	00-00000657	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1386	1	3	Фитинг, d-10mm, ORFS, Ш, 13/16, 0°	00-00000665	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1387	1	3	Фитинг, d-10mm, ORFS, Ш, 9/16, 0	00-00017205	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1388	1	2	Фитинг, d-12mm, ORFS, Г, 1, 90°	00-00003159	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1389	1	2	Фитинг, d-12mm, ORFS, Г, 1,3/16, 0°	00-00000646	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1390	1	2	Фитинг, d-12mm, ORFS, Г, 1,3/16, 0°, Italy	00-00003161	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1391	1	2	Фитинг, d-12mm, ORFS, Г, 1,3/16, 45°	00-00000647	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1392	1	2	Фитинг, d-12mm, ORFS, Г, 1,3/16, 90°	00-00000648	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1393	1	2	Фитинг, d-12mm, ORFS, Г, 11/16, 0°	00-00000663	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1394	1	2	Фитинг, d-12mm, ORFS, Г, 11/16, 45°	00-00000662	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1395	1	2	Фитинг, d-12mm, ORFS, Г, 11/16, 90°	00-00000661	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1396	1	2	Фитинг, d-12mm, ORFS, Г, 13/16, 0°	00-00000671	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1397	1	2	Фитинг, d-12mm, ORFS, Г, 13/16, 0°, Italy	00-00006051	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1398	1	2	Фитинг, d-12mm, ORFS, Г, 13/16, 45°	00-00000670	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1399	1	2	Фитинг, d-12mm, ORFS, Г, 13/16, 45°, c муфтой Italy	00-00006049	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1400	1	2	Фитинг, d-12mm, ORFS, Г, 13/16, 45°, Italy	00-00003172	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1401	1	2	Фитинг, d-12mm, ORFS, Г, 13/16, 90°	00-00000669	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1402	1	2	Фитинг, d-12mm, ORFS, Г, 13/16, 90°, c муфтой Italy	00-00006050	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1403	1	3	Фитинг, d-12mm, ORFS, Ш, 1, 0°	00-00002876	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1404	1	3	Фитинг, d-12mm, ORFS, Ш, 1, 0°, Italy	00-00003850	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1405	1	3	Фитинг, d-12mm, ORFS, Ш, 1, 0°, L35	00-00031412	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1406	1	3	Фитинг, d-12mm, ORFS, Ш, 1,3/16, 0°	00-00004793	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1407	1	3	Фитинг, d-12mm, ORFS, Ш, 11/16, 0°	00-00000664	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1408	1	3	Фитинг, d-12mm, ORFS, Ш, 13/16, 0°	00-00000672	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1409	1	3	Фитинг, d-12mm, ORFS, Ш, 13/16, 0°, Italy	00-00006053	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1410	1	2	Фитинг, d-16mm, ORFS, Г, 1, 0°	00-00000674	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1411	1	2	Фитинг, d-16mm, ORFS, Г, 1, 45°	00-00004685	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1412	1	2	Фитинг, d-16mm, ORFS, Г, 1, 90°	00-00000676	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1413	1	2	Фитинг, d-16mm, ORFS, Г, 1,3/16, 0°	00-00003160	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1414	1	2	Фитинг, d-16mm, ORFS, Г, 1,3/16, 45°	00-00003165	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1415	1	2	Фитинг, d-16mm, ORFS, Г, 1,3/16, 90°	00-00003166	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1416	1	3	Фитинг, d-16mm, ORFS, Ш, 1, 0°	00-00000673	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1417	1	3	Фитинг, d-16mm, ORFS, Ш, 1,3/16, 0°	00-00003582	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1418	1	2	Фитинг, d-20mm, ORFS, Г, 1, 0°	00-00000675	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1419	1	2	Фитинг, d-20mm, ORFS, Г, 1, 90°	00-00015841	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1420	1	2	Фитинг, d-20mm, ORFS, Г, 1,3/16, 0°	00-00000649	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1421	1	2	Фитинг, d-20mm, ORFS, Г, 1,3/16, 0°, c муфтой Italy	00-00006047	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1422	1	2	Фитинг, d-20mm, ORFS, Г, 1,3/16, 45°	00-00000650	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1423	1	2	Фитинг, d-20mm, ORFS, Г, 1,3/16, 90°	00-00000651	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1424	1	2	Фитинг, d-20mm, ORFS, Г, 1,7/16, 0°	00-00003168	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1425	1	2	Фитинг, d-20mm, ORFS, Г, 1,7/16, 0°, Italy	00-00003169	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1426	1	2	Фитинг, d-20mm, ORFS, Г, 30*1,5, 0°	00-00008836	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1427	1	3	Фитинг, d-20mm, ORFS, Ш, 1, 0	00-00017206	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1428	1	3	Фитинг, d-20mm, ORFS, Ш, 1,3/16, 0°	00-00000652	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1429	1	2	Фитинг, d-25mm, ORFS, Г, 1,11/16, 0°	00-00029157	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1430	1	2	Фитинг, d-25mm, ORFS, Г, 1,11/16, 45°	00-00029167	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1431	1	2	Фитинг, d-25mm, ORFS, Г, 1,11/16, 90°	00-00029158	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1432	1	2	Фитинг, d-25mm, ORFS, Г, 1,3/16, 0°	00-00003162	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1433	1	2	Фитинг, d-25mm, ORFS, Г, 1,3/16, 45°	00-00015837	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1434	1	2	Фитинг, d-25mm, ORFS, Г, 1,3/16, 90°	00-00003167	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1435	1	2	Фитинг, d-25mm, ORFS, Г, 1,7/16, 0°	00-00000679	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1436	1	2	Фитинг, d-25mm, ORFS, Г, 1,7/16, 45°	00-00000678	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1437	1	2	Фитинг, d-25mm, ORFS, Г, 1,7/16, 90°	00-00000677	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1438	1	3	Фитинг, d-25mm, ORFS, Ш, 1,7/16, 0°	00-00000680	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1439	1	2	Фитинг, d-32mm, ORFS, Г, 1,11/16, 0°	00-00000682	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1440	1	2	Фитинг, d-32mm, ORFS, Г, 1,11/16, 45°	00-00000683	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1441	1	2	Фитинг, d-32mm, ORFS, Г, 1,11/16, 90°	00-00000684	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1442	1	3	Фитинг, d-32mm, ORFS, Ш, 1,11/16, 0°	00-00000681	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1443	1	2	Фитинг, d-38mm, ORFS, Г, 1,11/16, 0°	00-00006083	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1444	1	2	Фитинг, d-38mm, ORFS, Г, 1,11/16, 45°	00-00005982	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1445	1	2	Фитинг, d-38mm, ORFS, Г, 1,11/16, 90°	00-00006084	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1446	1	3	Фитинг, d-38mm, ORFS, Ш, 2, 0°	00-00005981	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1447	1	2	Фитинг, d-6mm, ORFS, Г, 11/16, 0	00-00025520	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1448	1	2	Фитинг, d-6mm, ORFS, Г, 11/16, 0°, Italy	00-00005923	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1449	1	2	Фитинг, d-6mm, ORFS, Г, 11/16, 45°	00-00005922	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1450	1	2	Фитинг, d-6mm, ORFS, Г, 11/16, 90°	00-00005921	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1451	1	2	Фитинг, d-6mm, ORFS, Г, 9/16, 0, L11	00-00023716	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1452	1	2	Фитинг, d-6mm, ORFS, Г, 9/16, 0, Parker с муфтой	00-00018480	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1453	1	2	Фитинг, d-6mm, ORFS, Г, 9/16, 0°	00-00000653	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1454	1	2	Фитинг, d-6mm, ORFS, Г, 9/16, 0°, Italy	00-00005924	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1455	1	2	Фитинг, d-6mm, ORFS, Г, 9/16, 45°	00-00000654	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1456	1	2	Фитинг, d-6mm, ORFS, Г, 9/16, 90°	00-00000655	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1457	1	2	Фитинг, d-6mm, ORFS, Г, 9/16, 90°, c муфтой Italy	00-00005983	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1458	1	2	Фитинг, d-6mm, ORFS, Г, 9/16, 90°, Italy	00-00026150	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	1	шт.	\N
1459	1	3	Фитинг, d-6mm, ORFS, Ш, 11/16, 0°	00-00005920	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1460	1	3	Фитинг, d-6mm, ORFS, Ш, 9/16, 0°	00-00000656	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1461	1	2	Фитинг, d-8mm, ORFS, Г, 11/16, 0°	00-00003171	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1462	1	2	Фитинг, d-8mm, ORFS, Г, 11/16, 45°	00-00025521	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1463	1	2	Фитинг, d-8mm, ORFS, Г, 11/16, 90°	00-00025509	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1464	1	2	Фитинг, d-8mm, ORFS, Г, 9/16, 0°	00-00003174	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1465	1	2	Фитинг, d-8mm, ORFS, Г, 9/16, 45°	00-00017200	45	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1466	1	2	Фитинг, d-8mm, ORFS, Г, 9/16, 90°	00-00017201	90	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1467	1	3	Фитинг, d-8mm, ORFS, Ш, 11/16, 0	00-00025522	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1468	1	3	Фитинг, d-8mm, ORFS, Ш, 9/16, 0	00-00017202	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1469	1	3	Фитинг, d-10mm, NPTF, Ш, 1/4, 0°	00-00003124	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1470	1	3	Фитинг, d-10mm, NPTF, Ш, 3/8, 0°	00-00000188	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1471	1	3	Фитинг, d-12mm, NPTF, Ш, 1/2, 0°	00-00000187	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1472	1	3	Фитинг, d-12mm, NPTF, Ш, 3/8, 0°	00-00003703	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1473	1	3	Фитинг, d-16mm, NPTF, Ш, 3/4, 0°	00-00003704	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1474	1	3	Фитинг, d-20mm, NPTF, Ш, 1, 0°	00-00003705	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1475	1	3	Фитинг, d-20mm, NPTF, Ш, 3/4, 0°	00-00000189	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1476	1	3	Фитинг, d-25mm, NPTF, Ш, 1, 0°	00-00003706	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1477	1	3	Фитинг, d-25mm, NPTF, Ш, 1,1/4, 0°	00-00000539	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1478	1	3	Фитинг, d-32mm, NPTF, Ш, 1,1/4, 0°	00-00003707	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1479	1	3	Фитинг, d-38mm, NPTF, Ш, 1,1/2, 0°	00-00003708	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1480	1	3	Фитинг, d-50mm, NPTF, Ш, 2, 0°	00-00003709	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1481	1	3	Фитинг, d-6mm, NPTF, Ш, 1/4, 0°	00-00001327	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1482	1	3	Фитинг, d-6mm, NPTF, Ш, 1/8, 0°	00-00003700	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1483	1	3	Фитинг, d-6mm, NPTF, Ш, 3/8, 0°	00-00000309	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1484	1	3	Фитинг, d-8mm, NPTF, Ш, 1/4, 0°	00-00003701	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1485	1	3	Фитинг, d-8mm, NPTF, Ш, 1/8, 0°	00-00000186	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1486	1	3	Фитинг, d-8mm, NPTF, Ш, 3/8, 0°	00-00003702	\N	\N	t	2026-10-14 08:30:59	2026-10-14 08:30:59	\N	\N	шт.	\N
1487	2	6	Муфта, 2SN, d-25, желтая	00-00032408	\N	\N	t	2026-10-14 09:38:21	2026-10-14 09:38:21	\N	\N	шт.	\N
1489	2	6	Муфта, 2SN, d-16, желтая	00-00032406	\N	\N	t	2026-10-14 09:55:10	2026-10-14 09:55:10	\N	\N	шт.	\N
1488	2	6	Муфта, 2SN, d-20, желтая	00-00032407	\N	\N	t	2026-10-14 09:54:44	2026-10-14 09:55:21	\N	\N	шт.	\N
1490	1	\N	Фитинг Интерлок, d-20mm, SF Cat, Г, 41,3, 0	00-00018004	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1491	1	\N	Фитинг Интерлок, d-20mm, SF Cat, Г, 41,3, 45°	00-00018005	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1492	1	\N	Фитинг Интерлок, d-20mm, SF Cat, Г, 41,3, 90°	00-00018006	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1493	1	\N	Фитинг Интерлок, d-20mm, SF, 41,3, 90°, удл. 127	00-00003189	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1494	1	\N	Фитинг Интерлок, d-20mm, SF, Г, 41,3, 0°	00-00000780	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1495	1	\N	Фитинг Интерлок, d-20mm, SF, Г, 41,3, 45°	00-00000779	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1496	1	\N	Фитинг Интерлок, d-20mm, SF, Г, 41,3, 90°	00-00000778	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1497	1	\N	Фитинг Интерлок, d-20mm, SF, Г, 44, 90°, удл. 127	00-00008147	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1498	1	\N	Фитинг Интерлок, d-20mm, SF, Г, 47,6, 0°	00-00000775	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1499	1	\N	Фитинг Интерлок, d-20mm, SF, Г, 47,6, 45°	00-00000776	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1500	1	\N	Фитинг Интерлок, d-20mm, SF, Г, 47,6, 90°	00-00000777	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1501	1	\N	Фитинг Интерлок, d-25mm, SF Cat, Г, 47,6, 0	00-00018018	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1502	1	\N	Фитинг Интерлок, d-25mm, SF Cat, Г, 47,6, 45°	00-00018007	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1503	1	\N	Фитинг Интерлок, d-25mm, SF Cat, Г, 47,6, 90°	00-00018127	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1504	1	\N	Фитинг Интерлок, d-25mm, SF Cat, Г, 54, 45°	00-00018008	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1505	1	\N	Фитинг Интерлок, d-25mm, SF Cat, Г, 54, 90°	00-00019169	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1506	1	\N	Фитинг Интерлок, d-25mm, SF, 54, 90°	00-00008237	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1507	1	\N	Фитинг Интерлок, d-25mm, SF, Г, 41,3, 90°, удл. 150	00-00008154	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1508	1	\N	Фитинг Интерлок, d-25mm, SF, Г, 44, 0°	00-00015264	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1509	1	\N	Фитинг Интерлок, d-25mm, SF, Г, 44, 45°	00-00019147	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1510	1	\N	Фитинг Интерлок, d-25mm, SF, Г, 44, 90°	00-00008150	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1511	1	\N	Фитинг Интерлок, d-25mm, SF, Г, 47,6, 0°	00-00000774	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1512	1	\N	Фитинг Интерлок, d-25mm, SF, Г, 47,6, 45°	00-00000773	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1513	1	\N	Фитинг Интерлок, d-25mm, SF, Г, 47,6, 90°	00-00000772	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1514	1	\N	Фитинг Интерлок, d-25mm, SF, Г, 50,8, 90°	00-00003190	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1515	1	\N	Фитинг Интерлок, d-25mm, SF, Г, 54, 0°	00-00000768	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1516	1	\N	Фитинг Интерлок, d-25mm, SF, Г, 54, 45°	00-00008156	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1517	1	\N	Фитинг Интерлок, d-25mm, SF, Г, 54, 90°	00-00000767	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1518	1	\N	Фитинг Интерлок, d-32mm, SF Cat, Г, 54, 0°	00-00016337	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1519	1	\N	Фитинг Интерлок, d-32mm, SF Cat, Г, 54, 0°, Italy	00-00032261	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1520	1	\N	Фитинг Интерлок, d-32mm, SF Cat, Г, 54, 45°	00-00018010	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1521	1	\N	Фитинг Интерлок, d-32mm, SF Cat, Г, 54, 90°	00-00018011	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1522	1	\N	Фитинг Интерлок, d-32mm, SF Cat, Г, 63,5, 0°	00-00030395	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1523	1	\N	Фитинг Интерлок, d-32mm, SF Cat, Г, 63,5, 45°	00-00030334	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1524	1	\N	Фитинг Интерлок, d-32mm, SF Cat, Г, 63,5, 90°	00-00030335	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1525	1	\N	Фитинг Интерлок, d-32mm, SF, Г, 50,8, 0	00-00019168	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1526	1	\N	Фитинг Интерлок, d-32mm, SF, Г, 50,8, 90°, удл. 130	00-00017578	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1527	1	\N	Фитинг Интерлок, d-32mm, SF, Г, 54, 0°	00-00000769	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1528	1	\N	Фитинг Интерлок, d-32mm, SF, Г, 54, 0° токарный	00-00016601	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1529	1	\N	Фитинг Интерлок, d-32mm, SF, Г, 54, 45°	00-00000770	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1530	1	\N	Фитинг Интерлок, d-32mm, SF, Г, 54, 90°	00-00000771	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1531	1	\N	Фитинг Интерлок, d-32mm, SF, Г, 54, 90°, L 220	00-00030846	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1532	1	\N	Фитинг Интерлок, d-32mm, SF, Г, 63,5, 0°	00-00000764	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1533	1	\N	Фитинг Интерлок, d-32mm, SF, Г, 63,5, 45°	00-00000765	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1534	1	\N	Фитинг Интерлок, d-32mm, SF, Г, 63,5, 90°	00-00000766	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1535	1	\N	Фитинг Интерлок, d-38mm, SF Cat, Г, 63,5, 0°	00-00030396	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1536	1	\N	Фитинг Интерлок, d-38mm, SF Cat, Г, 63,5, 0°, Italy	00-00029479	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1537	1	\N	Фитинг Интерлок, d-38mm, SF Cat, Г, 63,5, 90°	00-00030336	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1538	1	\N	Фитинг Интерлок, d-38mm, SF Cat, Г, 63,5, 90°, Italy	00-00029480	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1539	1	\N	Фитинг Интерлок, d-38mm, SF, Г, 54, 0°	00-00031672	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1540	1	\N	Фитинг Интерлок, d-38mm, SF, Г, 54, 45°	00-00031671	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1541	1	\N	Фитинг Интерлок, d-38mm, SF, Г, 54, 90°	00-00003191	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1542	1	\N	Фитинг Интерлок, d-38mm, SF, Г, 60,3, 0	00-00022391	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1543	1	\N	Фитинг Интерлок, d-38mm, SF, Г, 60,3, 45°	00-00025055	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1544	1	\N	Фитинг Интерлок, d-38mm, SF, Г, 60,3, 90°	00-00025056	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1545	1	\N	Фитинг Интерлок, d-38mm, SF, Г, 63,5, 0	00-00020503	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1546	1	\N	Фитинг Интерлок, d-38mm, SF, Г, 63,5, 45°	00-00023667	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1547	1	\N	Фитинг Интерлок, d-38mm, SF, Г, 63,5, 90°	00-00003732	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1548	1	\N	Фитинг Интерлок, d-38mm, SF, Г, 79,4, 0, Italy	00-00027301	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1549	1	\N	Фитинг Интерлок, d-50mm, SF, Г, 71,4, 0, Italy	00-00027303	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1550	1	\N	Фитинг Интерлок, d-50mm, SF, Г, 79,4, 0	00-00024525	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1551	1	\N	Фитинг Интерлок, d-50mm, SF, Г, 79,4, 45°	00-00005949	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1552	1	\N	Фитинг Интерлок, d-50mm, SF, Г, 79,4, 90°	00-00005948	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1553	1	\N	Фитинг, d-12mm, SF, Г, 30,2, 0°	00-00000753	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1554	1	\N	Фитинг, d-12mm, SF, Г, 30,2, 45°	00-00000762	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1555	1	\N	Фитинг, d-12mm, SF, Г, 30,2, 90°	00-00000763	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1556	1	\N	Фитинг, d-12mm, SF, Г, 31,7, 0, Italy	00-00011856	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1557	1	\N	Фитинг, d-12mm, SF, Г, 31,7, 0°	00-00000752	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1558	1	\N	Фитинг, d-12mm, SF, Г, 31,7, 45°	00-00000760	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1559	1	\N	Фитинг, d-12mm, SF, Г, 31,7, 45°, Italy	00-00011857	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1560	1	\N	Фитинг, d-12mm, SF, Г, 31,7, 90°	00-00000761	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1561	1	\N	Фитинг, d-12mm, SF, Г, 34,2, 0°	00-00000759	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1562	1	\N	Фитинг, d-12mm, SF, Г, 34,2, 45°	00-00000758	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1563	1	\N	Фитинг, d-12mm, SF, Г, 34,2, 90°	00-00000757	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1564	1	\N	Фитинг, d-12mm, SF, Г, 38,1, 0, Italy	00-00011858	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1565	1	\N	Фитинг, d-12mm, SF, Г, 38,1, 0°	00-00000748	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1566	1	\N	Фитинг, d-12mm, SF, Г, 38,1, 45°	00-00000754	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1567	1	\N	Фитинг, d-12mm, SF, Г, 38,1, 45°, Italy	00-00011859	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1568	1	\N	Фитинг, d-12mm, SF, Г, 38,1, 90°	00-00000755	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1569	1	\N	Фитинг, d-12mm, SF, Г, 38,1, 90°, Italy	00-00011860	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1570	1	\N	Фитинг, d-12mm, SF, Г, 41,3, 0	00-00011620	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1571	1	\N	Фитинг, d-12mm, SF, Г, 41,3, 0, Italy	00-00011861	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1572	1	\N	Фитинг, d-12mm, SF, Г, 41,3, 45°	00-00011621	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1573	1	\N	Фитинг, d-12mm, SF, Г, 41,3, 45°, Italy	00-00011862	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1574	1	\N	Фитинг, d-12mm, SF, Г, 41,3, 90°	00-00011622	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1575	1	\N	Фитинг, d-12mm, SF, Г, 41,3, 90°, Italy	00-00011863	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1576	1	\N	Фитинг, d-12mm, SF, Г, 44, 90°	00-00027082	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1577	1	\N	Фитинг, d-16mm, SF, Г, 30,2, 0, Italy	00-00011865	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1578	1	\N	Фитинг, d-16mm, SF, Г, 31,7, 0	00-00011632	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1579	1	\N	Фитинг, d-16mm, SF, Г, 31,7, 90°	00-00011633	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1580	1	\N	Фитинг, d-16mm, SF, Г, 34,2, 0°	00-00003185	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1581	1	\N	Фитинг, d-16mm, SF, Г, 34,2, 45°	00-00000751	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1582	1	\N	Фитинг, d-16mm, SF, Г, 34,2, 90°	00-00000756	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1583	1	\N	Фитинг, d-16mm, SF, Г, 38,1, 0, Italy	00-00011866	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1584	1	\N	Фитинг, d-16mm, SF, Г, 38,1, 0°	00-00003186	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1585	1	\N	Фитинг, d-16mm, SF, Г, 38,1, 45°	00-00000749	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1586	1	\N	Фитинг, d-16mm, SF, Г, 38,1, 90°	00-00000750	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1587	1	\N	Фитинг, d-16mm, SF, Г, 41,3, 0°	00-00000741	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1588	1	\N	Фитинг, d-16mm, SF, Г, 41,3, 45°	00-00000740	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1589	1	\N	Фитинг, d-16mm, SF, Г, 41,3, 90°	00-00000739	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1590	1	\N	Фитинг, d-20mm, SF, 38,1, 90°, удл.	00-00003716	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1591	1	\N	Фитинг, d-20mm, SF, 41,3, 90°, удл. 120	00-00005944	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1592	1	\N	Фитинг, d-20mm, SF, 44, 0°, удл.	00-00005943	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1593	1	\N	Фитинг, d-20mm, SF, 44, 90°, удл. 100	00-00029776	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1594	1	\N	Фитинг, d-20mm, SF, 44, 90°, удл. 127	00-00003717	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1595	1	\N	Фитинг, d-20mm, SF, 44, 90°, удл. 150	00-00005818	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1596	1	\N	Фитинг, d-20mm, SF, 47,6, 0°	00-00008875	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1597	1	\N	Фитинг, d-20mm, SF, 47,6, 90°, удл. 150	00-00003719	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1598	1	\N	Фитинг, d-20mm, SF, Г, 38,1, 0°	00-00000747	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1599	1	\N	Фитинг, d-20mm, SF, Г, 38,1, 45°	00-00000746	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1600	1	\N	Фитинг, d-20mm, SF, Г, 38,1, 90°	00-00000745	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1601	1	\N	Фитинг, d-20mm, SF, Г, 38,1, 90°, Italy	00-00011868	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1602	1	\N	Фитинг, d-20mm, SF, Г, 41,3, 0, Italy	00-00011869	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1603	1	\N	Фитинг, d-20mm, SF, Г, 41,3, 0°	00-00000736	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1604	1	\N	Фитинг, d-20mm, SF, Г, 41,3, 45°	00-00000737	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1605	1	\N	Фитинг, d-20mm, SF, Г, 41,3, 90°	00-00000738	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1606	1	\N	Фитинг, d-20mm, SF, Г, 44, 0°	00-00000726	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1607	1	\N	Фитинг, d-20mm, SF, Г, 44, 0°, Italy	00-00003187	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1608	1	\N	Фитинг, d-20mm, SF, Г, 44, 45°	00-00000725	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1609	1	\N	Фитинг, d-20mm, SF, Г, 44, 45°, Italy	00-00003188	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1610	1	\N	Фитинг, d-20mm, SF, Г, 44, 90°	00-00000724	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1611	1	\N	Фитинг, d-20mm, SF, Г, 44, 90°, Italy	00-00011870	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1612	1	\N	Фитинг, d-20mm, SF, Г, 44, 90°, удл. 110	00-00003507	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1613	1	\N	Фитинг, d-20mm, SF, Г, 44, 90°, удл. 127	00-00017580	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1614	1	\N	Фитинг, d-20mm, SF, Г, 47,6, 0, Italy	00-00011871	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1615	1	\N	Фитинг, d-20mm, SF, Г, 47,6, 0°	00-00000721	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1616	1	\N	Фитинг, d-20mm, SF, Г, 47,6, 45°	00-00000722	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1617	1	\N	Фитинг, d-20mm, SF, Г, 47,6, 90°	00-00000723	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1618	1	\N	Фитинг, d-20mm, SF, Г, 47,6, 90°, Italy	00-00011872	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1619	1	\N	Фитинг, d-20mm, SF, Г, 47,6, 90°, удл. 140	00-00008149	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1620	1	\N	Фитинг, d-25mm, SF, 44, 90°, Н100	00-00029775	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1621	1	\N	Фитинг, d-25mm, SF, 44, 90°, Н180	00-00032045	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1622	1	\N	Фитинг, d-25mm, SF, 44, 90°, удл. 127	00-00003720	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1623	1	\N	Фитинг, d-25mm, SF, 44, 90°, удл. 135	00-00030623	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1624	1	\N	Фитинг, d-25mm, SF, 44, 90°, удл. 150	00-00003721	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1625	1	\N	Фитинг, d-25mm, SF, 47,6, 0	00-00018375	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1626	1	\N	Фитинг, d-25mm, SF, 47,6, 90°, удл. 127	00-00003728	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1627	1	\N	Фитинг, d-25mm, SF, 47,6, 90°, удл. 140	00-00003718	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1628	1	\N	Фитинг, d-25mm, SF, Г, 38,1, 0°	00-00000742	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1629	1	\N	Фитинг, d-25mm, SF, Г, 38,1, 45°	00-00000743	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1630	1	\N	Фитинг, d-25mm, SF, Г, 38,1, 90°	00-00000744	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1631	1	\N	Фитинг, d-25mm, SF, Г, 38,1, 90°, удл. 127	00-00005947	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1632	1	\N	Фитинг, d-25mm, SF, Г, 41,3, 0	00-00011638	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1633	1	\N	Фитинг, d-25mm, SF, Г, 41,3, 45°	00-00023941	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1634	1	\N	Фитинг, d-25mm, SF, Г, 41,3, 90°	00-00011639	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1635	1	\N	Фитинг, d-25mm, SF, Г, 41,3, 90°, удл. 127	00-00008152	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1636	1	\N	Фитинг, d-25mm, SF, Г, 44, 0, Italy	00-00012079	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1637	1	\N	Фитинг, d-25mm, SF, Г, 44, 0°	00-00000727	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1638	1	\N	Фитинг, d-25mm, SF, Г, 44, 45°	00-00000728	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1639	1	\N	Фитинг, d-25mm, SF, Г, 44, 45°, Italy	00-00011878	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1640	1	\N	Фитинг, d-25mm, SF, Г, 44, 90°	00-00000729	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1641	1	\N	Фитинг, d-25mm, SF, Г, 44, 90°, Italy	00-00011879	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1642	1	\N	Фитинг, d-25mm, SF, Г, 44, 90°, удл. 127	00-00017574	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1643	1	\N	Фитинг, d-25mm, SF, Г, 44, 90°, удл. 150	00-00017575	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1644	1	\N	Фитинг, d-25mm, SF, Г, 47,6, 0, удл. 127	00-00010151	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1645	1	\N	Фитинг, d-25mm, SF, Г, 47,6, 0°	00-00000715	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1646	1	\N	Фитинг, d-25mm, SF, Г, 47,6, 0°, Italy	00-00005951	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1647	1	\N	Фитинг, d-25mm, SF, Г, 47,6, 170°	00-00026735	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1648	1	\N	Фитинг, d-25mm, SF, Г, 47,6, 45°	00-00000716	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1649	1	\N	Фитинг, d-25mm, SF, Г, 47,6, 90°	00-00000717	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1650	1	\N	Фитинг, d-25mm, SF, Г, 47,6, 90°, Italy	00-00012080	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1651	1	\N	Фитинг, d-25mm, SF, Г, 47,6, 90°, удл. 127	00-00008155	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1652	1	\N	Фитинг, d-25mm, SF, Г, 47,6, 90°, удл. 150	00-00024705	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1653	1	\N	Фитинг, d-25mm, SF, Г, 50,8, 0, Italy	00-00012081	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1654	1	\N	Фитинг, d-25mm, SF, Г, 50,8, 0°	00-00000714	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1655	1	\N	Фитинг, d-25mm, SF, Г, 50,8, 45°	00-00000713	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1656	1	\N	Фитинг, d-25mm, SF, Г, 50,8, 90°	00-00000712	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1657	1	\N	Фитинг, d-25mm, SF, Г, 50,8, 90°, Italy	00-00012082	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1658	1	\N	Фитинг, d-25mm, SF, Г, 50,8, 90°, удл. 127	00-00008151	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1659	1	\N	Фитинг, d-25mm, SF, Г, 50,8, 90°, удл. 150	00-00017883	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1660	1	\N	Фитинг, d-25mm, SF, Г, 50,8, 90°, удл. 200	00-00026831	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1661	1	\N	Фитинг, d-25mm, SF, Г, 54, 0, Italy	00-00012083	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1662	1	\N	Фитинг, d-25mm, SF, Г, 54, 0°	00-00000708	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1663	1	\N	Фитинг, d-25mm, SF, Г, 54, 45°	00-00000707	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1664	1	\N	Фитинг, d-25mm, SF, Г, 54, 90°	00-00000706	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1665	1	\N	Фитинг, d-25mm, SF, Г, 54, 90°, Italy	00-00005952	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1666	1	\N	Фитинг, d-25mm, SF, Г, 54, 90°, удл. 130	00-00003727	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1667	1	\N	Фитинг, d-32mm, SF, Г, 44, 0°	00-00005953	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1668	1	\N	Фитинг, d-32mm, SF, Г, 44, 45°	00-00022055	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1669	1	\N	Фитинг, d-32mm, SF, Г, 47,6, 0°	00-00000720	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1670	1	\N	Фитинг, d-32mm, SF, Г, 47,6, 45°	00-00000719	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1671	1	\N	Фитинг, d-32mm, SF, Г, 47,6, 90°	00-00000718	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1672	1	\N	Фитинг, d-32mm, SF, Г, 50,8, 0°	00-00000709	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1673	1	\N	Фитинг, d-32mm, SF, Г, 50,8, 45°	00-00000710	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1674	1	\N	Фитинг, d-32mm, SF, Г, 50,8, 90°	00-00000711	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1675	1	\N	Фитинг, d-32mm, SF, Г, 50,8, 90°, удл. 127	00-00017576	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1676	1	\N	Фитинг, d-32mm, SF, Г, 50,8, 90°, удл. 130	00-00003729	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1677	1	\N	Фитинг, d-32mm, SF, Г, 50,8, 90°, удл. 150	00-00003730	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1678	1	\N	Фитинг, d-32mm, SF, Г, 54, 0°	00-00000703	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1679	1	\N	Фитинг, d-32mm, SF, Г, 54, 45°	00-00000704	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1680	1	\N	Фитинг, d-32mm, SF, Г, 54, 45°, Italy	00-00012088	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1681	1	\N	Фитинг, d-32mm, SF, Г, 54, 90°	00-00000705	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1682	1	\N	Фитинг, d-32mm, SF, Г, 54, 90°, удл. 127	00-00008158	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1683	1	\N	Фитинг, d-32mm, SF, Г, 54, 90°, удл. 130	00-00003731	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1684	1	\N	Фитинг, d-32mm, SF, Г, 54, 90°, удл. 150	00-00008160	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1685	1	\N	Фитинг, d-32mm, SF, Г, 54, 90°, удл. 220	00-00008161	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1686	1	\N	Фитинг, d-32mm, SF, Г, 60,3, 0, Italy	00-00011882	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1687	1	\N	Фитинг, d-32mm, SF, Г, 60,3, 0°	00-00000696	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1688	1	\N	Фитинг, d-32mm, SF, Г, 60,3, 45°	00-00000695	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1689	1	\N	Фитинг, d-32mm, SF, Г, 60,3, 90°	00-00000694	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1690	1	\N	Фитинг, d-32mm, SF, Г, 60,3, 90°, Italy	00-00011883	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1691	1	\N	Фитинг, d-32mm, SF, Г, 63,5, 0°	00-00000702	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1692	1	\N	Фитинг, d-32mm, SF, Г, 63,5, 45°	00-00000701	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1693	1	\N	Фитинг, d-32mm, SF, Г, 63,5, 90°	00-00000700	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1694	1	\N	Фитинг, d-38mm, SF, Г, 60,3, 0, Italy	00-00011884	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1695	1	\N	Фитинг, d-38mm, SF, Г, 60,3, 0°	00-00000691	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1696	1	\N	Фитинг, d-38mm, SF, Г, 60,3, 45°	00-00000692	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1697	1	\N	Фитинг, d-38mm, SF, Г, 60,3, 90°	00-00000693	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1698	1	\N	Фитинг, d-38mm, SF, Г, 60,3, 90°, Italy	00-00011885	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1699	1	\N	Фитинг, d-38mm, SF, Г, 63,5, 0°	00-00000697	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1700	1	\N	Фитинг, d-38mm, SF, Г, 63,5, 45°	00-00000698	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1701	1	\N	Фитинг, d-38mm, SF, Г, 63,5, 90°	00-00000699	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1702	1	\N	Фитинг, d-38mm, SF, Г, 71,4, 0°	00-00003192	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1703	1	\N	Фитинг, d-38mm, SF, Г, 71,4, 45°	00-00003193	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1704	1	\N	Фитинг, d-38mm, SF, Г, 71,4, 90°	00-00011888	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1705	1	\N	Фитинг, d-38mm, SF, Г, 71,4, 90°, Italy	00-00027302	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	1	шт.	0.000
1706	1	\N	Фитинг, d-38mm, SF, Г, 79,4, 0°	00-00000685	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1707	1	\N	Фитинг, d-38mm, SF, Г, 79,4, 45°	00-00000686	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1708	1	\N	Фитинг, d-38mm, SF, Г, 79,4, 90°	00-00000687	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1709	1	\N	Фитинг, d-50mm, SF, Г, 71,4, 0°	00-00000690	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1710	1	\N	Фитинг, d-50mm, SF, Г, 71,4, 45°	00-00000689	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1711	1	\N	Фитинг, d-50mm, SF, Г, 71,4, 90°	00-00000688	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1712	1	\N	Фитинг, d-50mm, SF, Г, 79,4, 0°	00-00003194	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1713	1	\N	Фитинг, d-50mm, SF, Г, 79,4, 45°	00-00003195	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1714	1	\N	Фитинг, d-50mm, SF, Г, 79,4, 90°	00-00003196	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1715	1	\N	Фитинг, d-50mm, SF, Г, 84, 45°	00-00025052	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1716	1	\N	Фитинг, d-50mm, SF, Г, 84.1, 0	00-00025057	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1717	1	\N	Фитинг, d-50mm, SF, Г, 84.1, 90°	00-00025053	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1718	1	\N	Фитинг, d-10mm, WEO, 147 100 606, 0°	00-00006539	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1719	1	\N	Фитинг, d-10mm, WEO, 147 100 806, 0°	00-00006540	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1720	1	\N	Фитинг, d-10mm, WEO, 148 100 606, 0	00-00018805	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1721	1	\N	Фитинг, d-12mm, WEO, 147 100 808, 0°	00-00006541	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1722	1	\N	Фитинг, d-12mm, WEO, 147 140 810, 90°	00-00006542	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1723	1	\N	Фитинг, d-12mm, WEO, 148 100 808, 0	00-00018806	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1724	1	\N	Фитинг, d-20mm, WEO d-22,2 (45град)	00-00024322	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1725	1	\N	Фитинг, d-6mm, WEO, 147 100 404, 0°	00-00006535	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1726	1	\N	Фитинг, d-6mm, WEO, 147 100 604, 0°	00-00006536	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1727	1	\N	Фитинг, d-6mm, WEO, 148 100 404, 0	00-00018804	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1728	1	\N	Фитинг, d-8mm, WEO, 147 100 605, 0°	00-00006537	\N	\N	t	2026-10-15 01:16:08	2026-10-15 01:16:08	\N	\N	шт.	0.000
1729	2	8	Муфта, Interlock Italy, 4SH, d-38mm	00-00006726	\N	\N	t	2026-10-15 01:55:22	2026-10-15 01:55:22	\N	1	шт.	\N
1730	2	5	Муфта, Стандарт, 2SN, d-6mm	00-00000128	\N	\N	t	2026-10-15 02:04:58	2026-10-15 02:04:58	\N	\N	шт.	\N
1731	2	9	Муфта, Italy, 4SP, d-38mm	00-00006724	\N	\N	t	2026-10-15 02:48:58	2026-10-15 02:48:58	\N	1	шт.	\N
1732	2	5	Муфта, Italy, 2SN, d-25mm	00-00006719	\N	\N	t	2026-10-15 02:51:03	2026-10-15 02:51:03	\N	1	шт.	\N
1733	2	8	Муфта, Italy, 4SH, d-20mm	00-00011827	\N	\N	t	2026-10-15 03:10:57	2026-10-15 03:10:57	\N	1	шт.	\N
1734	2	8	Муфта, Italy, 4SH, d-32mm	00-00005497	\N	\N	t	2026-10-15 03:33:47	2026-10-15 03:33:47	\N	1	шт.	\N
1735	2	9	Муфта, Italy, 4SP, d-16mm	00-00009496	\N	\N	t	2026-10-15 03:34:52	2026-10-15 03:34:52	\N	1	шт.	\N
1736	2	9	Муфта, Italy, 4SP, d-25mm	00-00006722	\N	\N	t	2026-10-15 03:36:05	2026-10-15 03:36:05	\N	1	шт.	\N
1737	2	10	Муфта, Стандарт, 1SN, d-50mm	00-00000127	\N	\N	t	2026-10-15 03:49:09	2026-10-15 03:49:09	\N	\N	шт.	\N
1738	2	5	Муфта, Italy, 2SN, d-50mm	00-00027294	\N	\N	t	2026-10-15 03:50:23	2026-10-15 03:50:23	\N	1	шт.	\N
1739	2	5	Муфта, Italy, 2SN, d-32mm	00-00006720	\N	\N	t	2026-10-15 04:05:23	2026-10-15 04:05:23	\N	1	шт.	\N
1740	2	10	Муфта, Стандарт, 1SN, d-38mm	00-00000126	\N	\N	t	2026-10-15 04:20:59	2026-10-15 04:20:59	\N	\N	шт.	\N
1741	2	9	Муфта, Italy, 4SP, d-32mm	00-00006723	\N	\N	t	2026-10-15 04:23:04	2026-10-15 04:23:04	\N	1	шт.	\N
1742	2	10	Муфта, Стандарт, 1SN, d-32mm	00-00000125	\N	\N	t	2026-10-15 04:25:52	2026-10-15 04:25:52	\N	\N	шт.	\N
1743	2	9	Муфта, Italy, 4SP, d-12mm	00-00009495	\N	\N	t	2026-10-15 04:27:12	2026-10-15 04:27:12	\N	1	шт.	\N
1744	2	10	Муфта, Italy, 1SN, d-16mm	00-00013318	\N	\N	t	2026-10-15 04:30:40	2026-10-15 04:30:40	\N	1	шт.	\N
1745	2	5	Муфта, Стандарт, 2SN, d-10mm	00-00000130	\N	\N	t	2026-10-15 04:33:34	2026-10-15 04:33:34	\N	\N	шт.	\N
1746	2	5	Муфта, Стандарт, 2SN, d-12mm	00-00000007	\N	\N	t	2026-10-15 04:34:26	2026-10-15 04:34:26	\N	\N	шт.	\N
1747	2	8	Муфта, Parker, 4SH, d-25mm	00-00012093	\N	\N	t	2026-10-15 08:52:13	2026-10-15 08:52:13	3	2	шт.	\N
1749	3	\N	Адаптер DKL 90° ш/ш 27*1,5 - 20*1,5	00-00027211	\N	\N	t	2026-10-16 06:27:52	2026-10-16 06:27:52	\N	\N	шт.	\N
1750	3	\N	Адаптер DKL ш/ш 27*1,5 - 27*1,5	00-00003595	\N	\N	t	2026-10-16 06:29:58	2026-10-16 06:29:58	\N	\N	шт.	\N
1751	3	\N	Адаптер DKL ш/ш/ш 27*1,5 - 27*1,5 - 27*1,5	00-00022906	\N	\N	t	2026-10-16 06:32:32	2026-10-16 06:32:32	\N	\N	шт.	\N
1752	3	\N	Адаптер DKL 90° ш/ш 27*1,5 - 27*1,5	00-00002720	\N	\N	t	2026-10-16 06:34:07	2026-10-16 06:34:07	\N	\N	шт.	\N
1753	2	5	Муфта, Italy, 2SN, d-8mm	00-00004752	\N	\N	t	2026-10-16 06:38:28	2026-10-16 06:38:28	\N	\N	шт.	\N
1754	2	11	Муфта, Italy, 3SN, d-6mm	00-00009494	\N	\N	t	2026-10-16 06:39:52	2026-10-16 06:39:52	\N	\N	шт.	\N
1755	2	8	Муфта, Gates, 4SH, d-25mm	00-00011893	\N	\N	t	2026-10-16 06:40:30	2026-10-16 06:40:30	4	\N	шт.	\N
1756	4	12	Хомут силовой шарнирный 040-43/20 W1	00-00003237	\N	\N	t	2026-10-16 07:12:27	2026-10-16 07:12:27	\N	\N	шт.	\N
1757	4	12	Хомут силовой шарнирный 056-59/22 W1	00-00003030	\N	\N	t	2026-10-16 07:13:09	2026-10-16 07:13:09	\N	\N	шт.	\N
1758	4	12	Хомут силовой шарнирный 074-79 W1	00-00003243	\N	\N	t	2026-10-16 07:13:29	2026-10-16 07:13:29	\N	\N	шт.	\N
1759	4	12	Хомут силовой шарнирный 080-85/24 W1	00-00007296	\N	\N	t	2026-10-16 07:13:48	2026-10-16 07:13:48	\N	\N	шт.	\N
1760	4	12	Хомут силовой шарнирный 086-91/24 W1	00-00002576	\N	\N	t	2026-10-16 07:14:05	2026-10-16 07:14:05	\N	\N	шт.	\N
1761	4	12	Хомут силовой шарнирный 104-112/24 W1	00-00012238	\N	\N	t	2026-10-16 07:14:24	2026-10-16 07:14:24	\N	\N	шт.	\N
1762	4	12	Хомут силовой шарнирный 113-121/24 W1	00-00002580	\N	\N	t	2026-10-16 07:14:40	2026-10-16 07:14:40	\N	\N	шт.	\N
1763	4	12	Хомут силовой шарнирный 149-161 W2	00-00012818	\N	\N	t	2026-10-16 07:15:01	2026-10-16 07:15:01	\N	\N	шт.	\N
1764	4	12	Хомут силовой шарнирный 162-174 W1	00-00002585	\N	\N	t	2026-10-16 07:15:21	2026-10-16 07:15:21	\N	\N	шт.	\N
1765	4	12	Хомут силовой шарнирный 188-200/26 W1	00-00002587	\N	\N	t	2026-10-16 07:15:37	2026-10-16 07:15:37	\N	\N	шт.	\N
1766	4	12	Хомут силовой шарнирный 26-28 W1	00-00002571	\N	\N	t	2026-10-16 07:16:11	2026-10-16 07:16:11	\N	\N	шт.	\N
1767	4	12	Хомут силовой шарнирный 92-97/24 W1	00-00002577	\N	\N	t	2026-10-16 07:16:29	2026-10-16 07:16:29	\N	\N	шт.	\N
1748	3	\N	Адаптер DKL 90° ш/ш 22*1,5 - 20*1,5	00-00027212	90	\N	t	2026-10-16 02:11:39	2026-10-16 08:59:01	\N	\N	шт.	0.000
1768	4	13	Хомут червячный 16-27/12 W1	00-00009403	\N	\N	t	2026-10-19 02:14:12	2026-10-19 02:14:12	\N	\N	шт.	\N
1769	4	13	Хомут червячный 16-27/9 W1	00-00009265	\N	\N	t	2026-10-19 02:14:30	2026-10-19 02:14:30	\N	\N	шт.	\N
1770	4	13	Хомут червячный 20-32/12 W1	00-00009404	\N	\N	t	2026-10-19 02:14:47	2026-10-19 02:14:47	\N	\N	шт.	\N
1771	4	13	Хомут червячный 25-40/12 W1	00-00009405	\N	\N	t	2026-10-19 02:15:05	2026-10-19 02:15:05	\N	\N	шт.	\N
1772	4	13	Хомут червячный 25-40/9 W1	00-00009267	\N	\N	t	2026-10-19 02:15:22	2026-10-19 02:15:22	\N	\N	шт.	\N
1773	4	13	Хомут червячный 30-45/12 W1	00-00009406	\N	\N	t	2026-10-19 02:15:38	2026-10-19 02:15:38	\N	\N	шт.	\N
1774	4	13	Хомут червячный 30-45/9 W1	00-00009268	\N	\N	t	2026-10-19 02:15:55	2026-10-19 02:15:55	\N	\N	шт.	\N
1775	4	13	Хомут червячный 32-50/12 W1	00-00029404	\N	\N	t	2026-10-19 02:16:10	2026-10-19 02:16:10	\N	\N	шт.	\N
1776	4	13	Хомут червячный 32-50/9 W2	00-00023106	\N	\N	t	2026-10-19 02:16:28	2026-10-19 02:16:28	\N	\N	шт.	\N
1777	4	13	Хомут червячный 40-60/12 W1	00-00009408	\N	\N	t	2026-10-19 02:16:44	2026-10-19 02:16:44	\N	\N	шт.	\N
1778	4	13	Хомут червячный 40-60/9 W1	00-00029244	\N	\N	t	2026-10-19 02:16:59	2026-10-19 02:16:59	\N	\N	шт.	\N
1779	4	13	Хомут червячный 50-70/9 W1	00-00009269	\N	\N	t	2026-10-19 02:17:16	2026-10-19 02:17:16	\N	\N	шт.	\N
1780	4	13	Хомут червячный 60-80/12 W1	00-00009410	\N	\N	t	2026-10-19 02:17:34	2026-10-19 02:17:34	\N	\N	шт.	\N
1781	4	13	Хомут червячный 70-90/12 W1	00-00009411	\N	\N	t	2026-10-19 02:17:55	2026-10-19 02:17:55	\N	\N	шт.	\N
1782	4	13	Хомут червячный 70-90/9 W1	00-00013624	\N	\N	t	2026-10-19 02:18:14	2026-10-19 02:18:14	\N	\N	шт.	\N
1783	4	13	Хомут червячный 80-100/12 W1	00-00009412	\N	\N	t	2026-10-19 02:18:31	2026-10-19 02:18:31	\N	\N	шт.	\N
1784	6	\N	Трубка возд.10*1 (полиамид) чёрная	00-00027230	\N	\N	t	2026-10-19 02:52:02	2026-10-19 02:52:02	\N	\N	м	\N
1785	6	\N	Трубка возд.12*1,5 (полиамид) черная	00-00007962	\N	\N	t	2026-10-19 02:52:21	2026-10-19 02:52:21	\N	\N	шт.	\N
1786	6	\N	Трубка возд.4*1 (полиамид) черная	00-00007957	\N	\N	t	2026-10-19 02:52:36	2026-10-19 02:52:36	\N	\N	шт.	\N
1787	6	\N	Трубка возд.5*1 полиамид черная	00-00007958	\N	\N	t	2026-10-19 02:52:51	2026-10-19 02:52:51	\N	\N	шт.	\N
1788	6	\N	Трубка возд.6*1 (полиамид) черная от 2,6 до 3,2 МПа от -40 до +80	00-00007959	\N	\N	t	2026-10-19 02:53:09	2026-10-19 02:53:09	\N	\N	шт.	\N
1789	7	14	Рукав ТЭП, -40 °С до +110 °С, 1химостойкий/воздух, d-50mm	00-00029681	\N	\N	t	2026-10-19 03:18:27	2026-10-19 03:18:27	\N	\N	шт.	\N
1790	7	14	Рукав ТЭП, -40 °С до +110 °С, 1химостойкий/воздух, d-60mm	00-00029682	\N	\N	t	2026-10-19 03:20:14	2026-10-19 03:20:14	\N	\N	шт.	\N
1791	7	15	Рукав газ/дым, -40 °С до +110 °С, 1химостойкий, d-50mm (7,5м.)	00-00029687	\N	\N	t	2026-10-19 03:22:55	2026-10-19 03:23:31	\N	\N	шт.	\N
1792	7	15	Рукав газ/дым, -40 °С до +110 °С, 1химостойкий, d-50mm (10м.)	00-00029688	\N	\N	t	2026-10-19 03:25:25	2026-10-19 03:25:25	\N	\N	шт.	\N
\.


--
-- Data for Name: racks; Type: TABLE DATA; Schema: public; Owner: gidrovik-admin
--

COPY racks (id, code, name, created_at, updated_at) FROM stdin;
1	A	Стеллаж A	2026-10-09 05:00:53	2026-10-09 05:00:53
2	B	Стеллаж B	2026-10-12 07:14:55	2026-10-12 07:14:55
3	C	Стеллаж C	2026-10-12 07:36:59	2026-10-12 07:36:59
4	D	Стеллаж D	2026-10-12 07:37:42	2026-10-12 07:37:42
6	E	Стеллаж E	2026-10-16 08:04:01	2026-10-16 08:04:01
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: gidrovik-admin
--

COPY sessions (id, user_id, ip_address, user_agent, payload, last_activity) FROM stdin;
bOHRaHw0d2PpRCGiQoh3KMKhzUc6cuR7DmIFvAAj	\N	182.138.158.176		eyJfdG9rZW4iOiJ6ZnM4d283cVhQZDRJTDhGYmRtaDRuaG1QU0NsaVhwVmxoWjkzY21KIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzE5NC4yMjYuOTkuMTEiLCJyb3V0ZSI6ImhvbWUifSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==	1792555371
UKSBndhn45rhOBPb15FNjHGPOjBRkOZtNNdcKDYA	\N	165.232.79.200		eyJfdG9rZW4iOiJSanJ4SjdpY1BvazlPSW9zQ3VZNExNYk9YSHhXamZtVHRDQ2Y1ckVyIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL2xvY2FsaG9zdCIsInJvdXRlIjoiaG9tZSJ9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19	1792560653
ioK20E5FDshZzjIBP2R3yRaUiHAT5a6FjXIUPNkG	\N	165.232.79.200		eyJfdG9rZW4iOiJXcEVUNnhnTEhGUG9uQUZUM0NiQnNieFdWRlJYemRaUTVXNThhRWhhIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL2xvY2FsaG9zdCIsInJvdXRlIjoiaG9tZSJ9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19	1792560654
ffjjAAweDop8uzMLT3B5QGo3f7z8PhS5mZDpuBQe	\N	157.230.107.250	Mozilla/5.0 (compatible; Odin; https://docs.getodin.com/)	eyJfdG9rZW4iOiJuYW5iOWRYRDVsUFJSOE9IRkpPUllGNU04dlhpNjRXdnBsTlFiQUFNIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzE5NC4yMjYuOTkuMTEiLCJyb3V0ZSI6ImhvbWUifSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==	1792560655
eII32OjOHW9q0Irz7WRzTJNMNRtvAqeM2e2qcJtP	\N	31.184.195.244	fasthttp	eyJfdG9rZW4iOiJhcUxxZkhqbEpYWVZrVTBrdXZ2ZFp0OFgzVEhveXFtSUtsRUdEc1RlIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzE5NC4yMjYuOTkuMTEiLCJyb3V0ZSI6ImhvbWUifSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==	1792561148
TivqlLFiqzI0k3DeC9T4gnLlhDWxvGgQdrDLDlT7	\N	31.184.195.244	fasthttp	eyJfdG9rZW4iOiJxMFN3OHhVUXhINHAyMDVqcnQxVzZxZ04wdXR0VEwzNnVhbGlUM25SIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzE5NC4yMjYuOTkuMTEiLCJyb3V0ZSI6ImhvbWUifSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==	1792561148
IR3KUEzvb5HnbC5pdRLNeklPhxqZtAynk3SeANdu	\N	52.90.129.148	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/136.0.0.0 Safari/537.36	eyJfdG9rZW4iOiJOVFJKMUNKYVFnbzhDVzE1cjJpMDBmSTZGSG56RnQ3NFhRUVNybXZxIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzE5NC4yMjYuOTkuMTEiLCJyb3V0ZSI6ImhvbWUifSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==	1792570566
T3AguldS89n56IbWMbPUvecXOcPTauihwTYsmsOO	\N	223.83.130.195		eyJfdG9rZW4iOiJsaXM0TkJlYWVHQ2N5aU5HTmNzanZ0dU01c3dKMWtxQjVrN0pCZWZiIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzE5NC4yMjYuOTkuMTEiLCJyb3V0ZSI6ImhvbWUifSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==	1792555382
DbS2cacm3OraMbk0BcRykLKNREeSxapeOc7qEWLB	\N	165.232.79.200		eyJfdG9rZW4iOiJSdHpwUkl5MFkwZ3ZCanppTnpndmtkaVFoZHJ5UG1CaWxqeUYxNGxzIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cL2xvY2FsaG9zdCIsInJvdXRlIjoiaG9tZSJ9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19	1792560654
MZCkPKRTStWXOtE40TpNi67Wne76P3vs81rnzJra	\N	165.232.79.200		eyJfdG9rZW4iOiJxMTR6VnBpUXdWT1p2WWpTc3V6RTBKd1FpbEltbkM3RjZkUml5MHJDIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzE5NC4yMjYuOTkuMTEiLCJyb3V0ZSI6ImhvbWUifSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==	1792560654
Yr9pGBjYw8GtgkKqscO9eBmSCo6glYALAzdXWFiw	\N	31.184.195.244	fasthttp	eyJfdG9rZW4iOiJIS3pEQk5rNHkwd3poRDZ6Tlp3TXcyVXAzS2J2cnBEMHBqYUpFY0RaIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzE5NC4yMjYuOTkuMTEiLCJyb3V0ZSI6ImhvbWUifSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==	1792561148
5PReeHrKTBEU9WCYs6h3Ien8FXgpphKlKPt6XIPb	\N	31.184.195.244	fasthttp	eyJfdG9rZW4iOiJXYUNna1NVc0RCTzZwT2dZY3YyWVlTTk5tbThZb24zZmJIZnhhR0ZMIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzE5NC4yMjYuOTkuMTEiLCJyb3V0ZSI6ImhvbWUifSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==	1792561148
G5Hh8gxgiKurqnblYTYj7Y9MxrZxKAAf2RLufblB	\N	31.184.195.244	fasthttp	eyJfdG9rZW4iOiJwcksxcm9nMmRUanVKUlNWM3Y5cGpNbmpDS3NkZEEwTmMwYUViem9lIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzE5NC4yMjYuOTkuMTEiLCJyb3V0ZSI6ImhvbWUifSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==	1792561148
XpoOIx4oWHmijkfVZbCU8kZUYSvjWMBbRfXXeTDK	32	90.188.41.168	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	eyJfdG9rZW4iOiJxMlJTeVJvN01reng0OWYzVGJMVzhLUUhnRVVuYkNrTUJ6RWN3NGhlIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzE5NC4yMjYuOTkuMTFcL2xvZ2luIiwicm91dGUiOiJsb2dpbiJ9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX0sImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjozMiwicGFzc3dvcmRfaGFzaF93ZWIiOiIyZWIzZjM5NjZlZGZhMjcxYmE1ZTUxMTg1MWIwYThiYjQ3MTE0NGQ3ZDZiZTU0N2RiNzk3MDhhYjQ5NjU0ODJlIn0=	1792575407
\.


--
-- Data for Name: standards; Type: TABLE DATA; Schema: public; Owner: gidrovik-admin
--

COPY standards (id, code, name, is_active, created_at, updated_at) FROM stdin;
1	BSP	British Standart Pipe	t	2026-10-12 08:10:52	2026-10-12 08:10:52
2	DK	Dichtkegel	t	2026-10-14 02:07:47	2026-10-14 02:07:47
3	DKF	Dichtkegel - Flat	t	2026-10-14 02:11:49	2026-10-14 02:11:49
4	DKOL	Dichtkegel mit O-Ring Light	t	2026-10-14 02:12:33	2026-10-14 02:12:33
5	DKOS	Dichtkegel mit O-Ring Schwer	t	2026-10-14 02:13:01	2026-10-14 02:13:01
6	Banjo	Banjo	t	2026-10-14 02:13:54	2026-10-14 02:13:54
7	JIC	Joint Industry Council	t	2026-10-14 02:14:43	2026-10-14 02:14:43
8	JICS	JICS	t	2026-10-14 02:16:06	2026-10-14 02:16:06
9	JIS	Japanese Industrial Standard	t	2026-10-14 02:16:43	2026-10-14 02:16:43
10	Komatsu	Komatsu	t	2026-10-14 02:17:05	2026-10-14 02:17:05
12	Karcher	Karcher	t	2026-10-14 02:18:39	2026-10-14 02:18:39
13	ORFS	O-Ring Face Seal	t	2026-10-14 02:19:20	2026-10-14 02:19:20
14	NPTF	National Pipe Taper Fuel	t	2026-10-14 02:20:11	2026-10-14 02:20:11
15	SF	Society of Automotive Engineers Flange	t	2026-10-14 02:20:49	2026-10-14 02:22:03
16	WEO	WEO	t	2026-10-14 02:23:50	2026-10-14 02:23:50
17	SF_Cat	Society of Automotive Engineers Flange Caterpillar	t	2026-10-15 01:08:23	2026-10-15 01:08:23
11	JIS_Metric	Japanese Industrial Standard(metrick)	t	2026-10-14 02:18:17	2026-10-15 01:08:35
\.


--
-- Data for Name: stock_movements; Type: TABLE DATA; Schema: public; Owner: gidrovik-admin
--

COPY stock_movements (id, product_id, from_location_id, to_location_id, quantity, type, comment, user_id, created_at, updated_at) FROM stdin;
13	11	\N	5	8.000	receipt	\N	32	2026-10-14 03:27:41	2026-10-14 03:27:41
14	13	\N	10	11.000	receipt	\N	32	2026-10-14 03:32:09	2026-10-14 03:32:09
15	14	\N	5	5.000	receipt	\N	32	2026-10-14 03:35:20	2026-10-14 03:35:20
16	15	\N	10	10.000	receipt	\N	32	2026-10-14 03:37:53	2026-10-14 03:37:53
17	17	\N	11	1.000	receipt	\N	32	2026-10-14 03:41:50	2026-10-14 03:41:50
18	18	\N	11	1.000	receipt	\N	32	2026-10-14 03:42:58	2026-10-14 03:42:58
19	19	\N	11	6.000	receipt	\N	32	2026-10-14 03:46:05	2026-10-14 03:46:05
20	20	\N	11	4.000	receipt	\N	32	2026-10-14 03:50:10	2026-10-14 03:50:10
21	21	\N	11	3.000	receipt	\N	32	2026-10-14 03:55:18	2026-10-14 03:55:18
22	22	\N	11	2.000	receipt	\N	32	2026-10-14 03:55:32	2026-10-14 03:55:32
23	23	\N	11	8.000	receipt	\N	32	2026-10-14 03:56:48	2026-10-14 03:56:48
24	24	\N	11	15.000	receipt	\N	32	2026-10-14 03:57:52	2026-10-14 03:57:52
25	25	\N	11	6.000	receipt	\N	32	2026-10-14 04:05:50	2026-10-14 04:05:50
26	26	\N	11	6.000	receipt	\N	32	2026-10-14 04:11:44	2026-10-14 04:11:44
27	27	\N	11	3.000	receipt	\N	32	2026-10-14 04:13:22	2026-10-14 04:13:22
28	28	\N	11	6.000	receipt	\N	32	2026-10-14 04:15:17	2026-10-14 04:15:17
29	29	\N	66	1.000	receipt	\N	32	2026-10-14 04:27:09	2026-10-14 04:27:09
30	30	\N	66	1.000	receipt	\N	32	2026-10-14 04:27:24	2026-10-14 04:27:24
31	31	\N	15	28.000	receipt	\N	32	2026-10-14 05:55:59	2026-10-14 05:55:59
32	32	\N	12	17.000	receipt	\N	32	2026-10-14 06:36:33	2026-10-14 06:36:33
33	33	\N	54	6.000	receipt	\N	32	2026-10-14 06:44:05	2026-10-14 06:44:05
34	34	\N	54	6.000	receipt	\N	32	2026-10-14 07:25:13	2026-10-14 07:25:13
35	35	\N	15	72.000	receipt	\N	32	2026-10-14 07:27:41	2026-10-14 07:27:41
36	36	\N	15	73.000	receipt	\N	32	2026-10-14 07:30:00	2026-10-14 07:30:00
37	37	\N	15	46.000	receipt	\N	32	2026-10-14 07:31:36	2026-10-14 07:31:36
38	38	\N	15	19.000	receipt	\N	32	2026-10-14 07:32:34	2026-10-14 07:32:34
39	646	\N	31	7.000	receipt	\N	32	2026-10-14 09:20:00	2026-10-14 09:20:00
40	565	\N	3	46.000	receipt	\N	32	2026-10-14 09:28:10	2026-10-14 09:28:10
41	658	\N	31	2.000	receipt	\N	32	2026-10-14 09:31:07	2026-10-14 09:31:07
42	659	\N	31	4.000	receipt	\N	32	2026-10-14 09:35:28	2026-10-14 09:35:28
43	657	\N	31	8.000	receipt	\N	32	2026-10-14 09:36:27	2026-10-14 09:36:27
44	1487	\N	54	39.000	receipt	\N	32	2026-10-14 09:38:45	2026-10-14 09:38:45
45	646	\N	9	10.000	receipt	\N	32	2026-10-14 09:41:08	2026-10-14 09:41:08
46	582	\N	5	10.000	receipt	\N	32	2026-10-14 09:45:13	2026-10-14 09:45:13
47	604	\N	5	7.000	receipt	\N	32	2026-10-14 09:45:59	2026-10-14 09:45:59
48	583	\N	5	2.000	receipt	\N	32	2026-10-14 09:48:57	2026-10-14 09:48:57
49	643	\N	5	6.000	receipt	\N	32	2026-10-14 09:50:10	2026-10-14 09:50:10
50	1488	\N	54	26.000	receipt	\N	32	2026-10-14 09:59:37	2026-10-14 09:59:37
51	795	\N	9	6.000	receipt	\N	32	2026-10-15 00:53:39	2026-10-15 00:53:39
52	646	9	\N	4.000	write_off	ошибка	32	2026-10-15 00:54:13	2026-10-15 00:54:13
53	1530	\N	47	17.000	receipt	\N	32	2026-10-15 01:18:57	2026-10-15 01:18:57
54	643	\N	3	12.000	receipt	\N	32	2026-10-15 01:37:04	2026-10-15 01:37:04
55	1526	\N	9	21.000	receipt	\N	32	2026-10-15 01:40:02	2026-10-15 01:40:02
56	1420	\N	40	25.000	receipt	\N	32	2026-10-15 01:48:37	2026-10-15 01:48:37
57	1262	\N	40	11.000	receipt	\N	32	2026-10-15 01:51:39	2026-10-15 01:51:39
58	1208	\N	40	15.000	receipt	\N	32	2026-10-15 01:52:15	2026-10-15 01:52:15
59	61	\N	40	20.000	receipt	\N	32	2026-10-15 01:53:13	2026-10-15 01:53:13
60	1369	\N	40	20.000	receipt	\N	32	2026-10-15 01:54:07	2026-10-15 01:54:07
61	1729	\N	36	117.000	receipt	\N	32	2026-10-15 01:57:00	2026-10-15 01:57:00
62	1303	\N	2	15.000	receipt	\N	32	2026-10-15 02:01:10	2026-10-15 02:01:10
63	1294	\N	2	3.000	receipt	\N	32	2026-10-15 02:01:44	2026-10-15 02:01:44
64	1373	\N	2	5.000	receipt	\N	32	2026-10-15 02:02:24	2026-10-15 02:02:24
65	1373	2	29	5.000	transfer	\N	32	2026-10-15 02:02:55	2026-10-15 02:02:55
66	451	\N	41	14.000	receipt	\N	32	2026-10-15 02:04:08	2026-10-15 02:04:08
67	1730	\N	16	123.000	receipt	\N	32	2026-10-15 02:05:25	2026-10-15 02:05:25
68	1396	\N	66	3.000	receipt	\N	32	2026-10-15 02:06:34	2026-10-15 02:06:34
69	1078	\N	66	26.000	receipt	\N	32	2026-10-15 02:08:01	2026-10-15 02:08:01
70	1078	66	8	26.000	transfer	\N	32	2026-10-15 02:08:23	2026-10-15 02:08:23
71	1078	\N	55	2.000	receipt	\N	32	2026-10-15 02:10:12	2026-10-15 02:10:12
72	928	\N	55	2.000	receipt	\N	32	2026-10-15 02:10:57	2026-10-15 02:10:57
73	157	\N	8	19.000	receipt	\N	32	2026-10-15 02:11:36	2026-10-15 02:11:36
74	967	\N	55	3.000	receipt	\N	32	2026-10-15 02:12:30	2026-10-15 02:12:30
75	953	\N	55	6.000	receipt	\N	32	2026-10-15 02:16:27	2026-10-15 02:16:27
76	746	\N	7	13.000	receipt	\N	32	2026-10-15 02:17:13	2026-10-15 02:17:13
77	115	\N	7	6.000	receipt	\N	32	2026-10-15 02:21:56	2026-10-15 02:21:56
78	1283	\N	7	19.000	receipt	\N	32	2026-10-15 02:22:49	2026-10-15 02:22:49
79	153	\N	7	2.000	receipt	\N	32	2026-10-15 02:23:34	2026-10-15 02:23:34
80	747	\N	29	5.000	receipt	\N	32	2026-10-15 02:25:41	2026-10-15 02:25:41
81	791	\N	29	4.000	receipt	\N	32	2026-10-15 02:26:24	2026-10-15 02:26:24
82	791	29	\N	4.000	write_off	ошибка	32	2026-10-15 02:27:05	2026-10-15 02:27:05
83	306	\N	29	7.000	receipt	\N	32	2026-10-15 02:27:45	2026-10-15 02:27:45
84	761	\N	29	18.000	receipt	\N	32	2026-10-15 02:28:27	2026-10-15 02:28:27
85	761	29	\N	18.000	write_off	ошибка	32	2026-10-15 02:29:03	2026-10-15 02:29:03
86	778	\N	29	18.000	receipt	\N	32	2026-10-15 02:29:32	2026-10-15 02:29:32
87	761	\N	29	18.000	receipt	\N	32	2026-10-15 02:30:13	2026-10-15 02:30:13
88	761	29	\N	18.000	write_off	1	32	2026-10-15 02:30:36	2026-10-15 02:30:36
89	778	29	\N	9.000	write_off	1	32	2026-10-15 02:30:45	2026-10-15 02:30:45
90	760	\N	29	18.000	receipt	\N	32	2026-10-15 02:31:16	2026-10-15 02:31:16
91	790	\N	29	11.000	receipt	\N	32	2026-10-15 02:31:54	2026-10-15 02:31:54
92	790	29	30	11.000	transfer	\N	32	2026-10-15 02:32:11	2026-10-15 02:32:11
93	1023	\N	57	46.000	receipt	\N	32	2026-10-15 02:33:38	2026-10-15 02:33:38
94	1023	\N	57	214.000	receipt	\N	32	2026-10-15 02:35:37	2026-10-15 02:35:37
95	1029	\N	56	34.000	receipt	\N	32	2026-10-15 02:36:42	2026-10-15 02:36:42
96	1077	\N	56	80.000	receipt	\N	32	2026-10-15 02:37:34	2026-10-15 02:37:34
97	35	\N	17	1236.000	receipt	\N	32	2026-10-15 02:39:14	2026-10-15 02:39:14
98	1731	\N	18	21.000	receipt	\N	32	2026-10-15 02:49:38	2026-10-15 02:49:38
99	1732	\N	13	55.000	receipt	\N	32	2026-10-15 03:08:21	2026-10-15 03:08:21
100	34	\N	21	311.000	receipt	\N	32	2026-10-15 03:10:17	2026-10-15 03:10:17
101	1733	\N	22	182.000	receipt	\N	32	2026-10-15 03:11:37	2026-10-15 03:11:37
102	1081	\N	58	60.000	receipt	\N	32	2026-10-15 03:31:42	2026-10-15 03:31:42
103	1734	\N	19	27.000	receipt	\N	32	2026-10-15 03:34:07	2026-10-15 03:34:07
104	1735	\N	23	88.000	receipt	\N	32	2026-10-15 03:35:20	2026-10-15 03:35:20
105	1736	\N	20	74.000	receipt	\N	32	2026-10-15 03:36:27	2026-10-15 03:36:27
106	1026	\N	56	20.000	receipt	\N	32	2026-10-15 03:43:06	2026-10-15 03:43:06
107	1737	\N	32	27.000	receipt	\N	32	2026-10-15 03:49:39	2026-10-15 03:49:39
108	1738	\N	33	46.000	receipt	\N	32	2026-10-15 03:51:00	2026-10-15 03:51:00
109	1739	\N	14	41.000	receipt	\N	32	2026-10-15 04:05:48	2026-10-15 04:05:48
110	1740	\N	35	30.000	receipt	\N	32	2026-10-15 04:22:06	2026-10-15 04:22:06
111	1741	\N	19	55.000	receipt	\N	32	2026-10-15 04:24:07	2026-10-15 04:24:07
112	1742	\N	35	15.000	receipt	\N	32	2026-10-15 04:26:20	2026-10-15 04:26:20
113	1735	\N	54	9.000	receipt	\N	32	2026-10-15 04:28:09	2026-10-15 04:28:09
114	1743	\N	54	30.000	receipt	\N	32	2026-10-15 04:28:32	2026-10-15 04:28:32
115	1744	\N	12	10.000	receipt	\N	32	2026-10-15 04:31:04	2026-10-15 04:31:04
116	1730	\N	15	77.000	receipt	\N	32	2026-10-15 04:32:51	2026-10-15 04:32:51
117	1745	\N	15	15.000	receipt	\N	32	2026-10-15 04:33:55	2026-10-15 04:33:55
118	1746	\N	15	9.000	receipt	\N	32	2026-10-15 04:34:39	2026-10-15 04:34:39
119	1489	\N	54	22.000	receipt	\N	32	2026-10-15 04:35:09	2026-10-15 04:35:09
120	1410	\N	51	37.000	receipt	\N	32	2026-10-15 04:46:09	2026-10-15 04:46:09
121	1411	\N	51	32.000	receipt	\N	32	2026-10-15 04:47:07	2026-10-15 04:47:07
122	1410	\N	51	9.000	receipt	\N	32	2026-10-15 04:47:26	2026-10-15 04:47:26
123	1413	\N	51	35.000	receipt	\N	32	2026-10-15 04:47:55	2026-10-15 04:47:55
124	168	\N	2	18.000	receipt	\N	32	2026-10-15 04:48:45	2026-10-15 04:48:45
125	99	\N	2	3.000	receipt	\N	32	2026-10-15 04:49:21	2026-10-15 04:49:21
126	154	\N	2	17.000	receipt	\N	32	2026-10-15 04:49:45	2026-10-15 04:49:45
127	99	2	\N	3.000	write_off	-	32	2026-10-15 04:51:34	2026-10-15 04:51:34
128	154	2	\N	17.000	write_off	-	32	2026-10-15 04:51:44	2026-10-15 04:51:44
129	276	\N	2	18.000	receipt	\N	32	2026-10-15 04:52:26	2026-10-15 04:52:26
130	1423	\N	2	11.000	receipt	\N	32	2026-10-15 04:53:05	2026-10-15 04:53:05
131	1422	\N	2	3.000	receipt	\N	32	2026-10-15 04:53:29	2026-10-15 04:53:29
132	1429	\N	39	32.000	receipt	\N	32	2026-10-15 04:54:21	2026-10-15 04:54:21
133	1424	\N	41	25.000	receipt	\N	32	2026-10-15 04:55:44	2026-10-15 04:55:44
134	1424	\N	41	21.000	receipt	\N	32	2026-10-15 04:57:30	2026-10-15 04:57:30
135	1436	\N	38	25.000	receipt	\N	32	2026-10-15 04:58:07	2026-10-15 04:58:07
136	1423	\N	32	13.000	receipt	\N	32	2026-10-15 04:59:35	2026-10-15 04:59:35
137	1422	\N	32	22.000	receipt	\N	32	2026-10-15 05:00:08	2026-10-15 05:00:08
138	1392	\N	32	4.000	receipt	\N	32	2026-10-15 05:00:40	2026-10-15 05:00:40
139	1392	32	\N	4.000	write_off	-	32	2026-10-15 05:00:58	2026-10-15 05:00:58
140	1422	\N	32	4.000	receipt	\N	32	2026-10-15 05:01:33	2026-10-15 05:01:33
141	1422	32	\N	4.000	write_off	-	32	2026-10-15 05:01:58	2026-10-15 05:01:58
142	1423	\N	32	4.000	receipt	\N	32	2026-10-15 05:02:22	2026-10-15 05:02:22
143	1437	\N	38	39.000	receipt	\N	32	2026-10-15 05:48:03	2026-10-15 05:48:03
144	1431	\N	38	30.000	receipt	\N	32	2026-10-15 05:48:41	2026-10-15 05:48:41
145	1081	\N	42	39.000	receipt	\N	32	2026-10-15 05:49:34	2026-10-15 05:49:34
146	1078	\N	42	2.000	receipt	\N	32	2026-10-15 05:50:05	2026-10-15 05:50:05
147	157	\N	4	18.000	receipt	\N	32	2026-10-15 05:51:07	2026-10-15 05:51:07
148	92	\N	4	18.000	receipt	\N	32	2026-10-15 05:51:37	2026-10-15 05:51:37
149	95	\N	4	12.000	receipt	\N	32	2026-10-15 05:52:16	2026-10-15 05:52:16
150	74	\N	4	47.000	receipt	\N	32	2026-10-15 05:52:44	2026-10-15 05:52:44
151	104	\N	4	2.000	receipt	\N	32	2026-10-15 05:54:33	2026-10-15 05:54:33
152	580	\N	6	30.000	receipt	\N	32	2026-10-15 05:55:32	2026-10-15 05:55:32
153	565	\N	6	22.000	receipt	\N	32	2026-10-15 05:56:13	2026-10-15 05:56:13
154	364	\N	44	7.000	receipt	\N	32	2026-10-15 05:58:42	2026-10-15 05:58:42
155	368	\N	44	38.000	receipt	\N	32	2026-10-15 05:59:17	2026-10-15 05:59:17
156	385	\N	44	8.000	receipt	\N	32	2026-10-15 05:59:58	2026-10-15 05:59:58
157	854	\N	4	28.000	receipt	\N	32	2026-10-15 06:00:54	2026-10-15 06:00:54
158	885	\N	4	1.000	receipt	\N	32	2026-10-15 06:01:16	2026-10-15 06:01:16
159	888	\N	4	1.000	receipt	\N	32	2026-10-15 06:01:39	2026-10-15 06:01:39
160	1553	\N	4	14.000	receipt	\N	32	2026-10-15 06:02:10	2026-10-15 06:02:10
161	899	\N	4	1.000	receipt	\N	32	2026-10-15 06:02:27	2026-10-15 06:02:27
162	849	\N	4	17.000	receipt	\N	32	2026-10-15 06:02:51	2026-10-15 06:02:51
163	1022	\N	43	27.000	receipt	\N	32	2026-10-15 06:07:44	2026-10-15 06:07:44
164	1023	\N	43	8.000	receipt	\N	32	2026-10-15 06:08:17	2026-10-15 06:08:17
165	1051	\N	43	20.000	receipt	\N	32	2026-10-15 06:09:19	2026-10-15 06:09:19
166	1055	\N	43	20.000	receipt	\N	32	2026-10-15 06:10:06	2026-10-15 06:10:06
167	1009	\N	5	26.000	receipt	\N	32	2026-10-15 06:10:51	2026-10-15 06:10:51
168	954	\N	5	6.000	receipt	\N	32	2026-10-15 06:11:36	2026-10-15 06:11:36
169	986	\N	5	19.000	receipt	\N	32	2026-10-15 06:12:26	2026-10-15 06:12:26
170	962	\N	5	46.000	receipt	\N	32	2026-10-15 06:17:56	2026-10-15 06:17:56
171	1019	\N	6	16.000	receipt	\N	32	2026-10-15 06:18:44	2026-10-15 06:18:44
172	1654	\N	50	29.000	receipt	\N	32	2026-10-15 06:19:26	2026-10-15 06:19:26
173	1656	\N	50	29.000	receipt	\N	32	2026-10-15 06:22:50	2026-10-15 06:22:50
174	1637	\N	37	16.000	receipt	\N	32	2026-10-15 06:28:26	2026-10-15 06:28:26
175	1638	\N	37	20.000	receipt	\N	32	2026-10-15 06:29:00	2026-10-15 06:29:00
176	1640	\N	37	20.000	receipt	\N	32	2026-10-15 06:29:39	2026-10-15 06:29:39
177	1645	\N	47	22.000	receipt	\N	32	2026-10-15 06:30:42	2026-10-15 06:30:42
178	1648	\N	47	20.000	receipt	\N	32	2026-10-15 06:31:30	2026-10-15 06:31:30
179	1649	\N	47	18.000	receipt	\N	32	2026-10-15 06:31:53	2026-10-15 06:31:53
180	1598	\N	48	17.000	receipt	\N	32	2026-10-15 06:32:36	2026-10-15 06:32:36
181	1598	\N	48	2.000	receipt	\N	32	2026-10-15 06:33:02	2026-10-15 06:33:02
182	1603	\N	48	25.000	receipt	\N	32	2026-10-15 06:33:41	2026-10-15 06:33:41
183	1599	\N	48	2.000	receipt	\N	32	2026-10-15 06:34:19	2026-10-15 06:34:19
184	1565	\N	48	1.000	receipt	\N	32	2026-10-15 06:34:47	2026-10-15 06:34:47
185	1527	\N	46	20.000	receipt	\N	32	2026-10-15 06:36:08	2026-10-15 06:36:08
186	1525	\N	45	20.000	receipt	\N	32	2026-10-15 06:37:02	2026-10-15 06:37:02
187	973	\N	68	7.000	receipt	\N	32	2026-10-15 06:41:39	2026-10-15 06:41:39
188	1396	\N	68	14.000	receipt	\N	32	2026-10-15 06:42:01	2026-10-15 06:42:01
189	748	\N	68	11.000	receipt	\N	32	2026-10-15 06:42:41	2026-10-15 06:42:41
190	573	\N	68	14.000	receipt	\N	32	2026-10-15 06:43:20	2026-10-15 06:43:20
191	307	\N	68	16.000	receipt	\N	32	2026-10-15 06:43:55	2026-10-15 06:43:55
192	568	\N	68	16.000	receipt	\N	32	2026-10-15 06:44:19	2026-10-15 06:44:19
193	309	\N	68	4.000	receipt	\N	32	2026-10-15 06:44:51	2026-10-15 06:44:51
194	925	\N	61	5.000	receipt	\N	32	2026-10-15 06:46:29	2026-10-15 06:46:29
195	1074	\N	61	8.000	receipt	\N	32	2026-10-15 06:47:38	2026-10-15 06:47:38
196	941	\N	61	19.000	receipt	\N	32	2026-10-15 06:48:46	2026-10-15 06:48:46
197	940	\N	61	9.000	receipt	\N	32	2026-10-15 07:23:43	2026-10-15 07:23:43
198	950	\N	61	3.000	receipt	\N	32	2026-10-15 07:24:36	2026-10-15 07:24:36
199	945	\N	61	2.000	receipt	\N	32	2026-10-15 07:25:29	2026-10-15 07:25:29
200	969	\N	61	28.000	receipt	\N	32	2026-10-15 07:28:40	2026-10-15 07:28:40
201	966	\N	61	53.000	receipt	\N	32	2026-10-15 07:29:08	2026-10-15 07:29:08
202	1080	\N	62	10.000	receipt	\N	32	2026-10-15 07:29:59	2026-10-15 07:29:59
203	1026	\N	63	36.000	receipt	\N	32	2026-10-15 07:30:50	2026-10-15 07:30:50
204	1079	\N	62	3.000	receipt	\N	32	2026-10-15 07:31:48	2026-10-15 07:31:48
205	949	\N	65	40.000	receipt	\N	32	2026-10-15 08:12:35	2026-10-15 08:12:35
206	943	\N	65	66.000	receipt	\N	32	2026-10-15 08:13:03	2026-10-15 08:13:03
207	1077	\N	62	43.000	receipt	\N	32	2026-10-15 08:13:47	2026-10-15 08:13:47
208	35	\N	17	500.000	receipt	\N	32	2026-10-15 08:14:20	2026-10-15 08:14:20
209	1029	\N	63	17.000	receipt	\N	32	2026-10-15 08:16:36	2026-10-15 08:16:36
210	1026	\N	63	2.000	receipt	\N	32	2026-10-15 08:19:07	2026-10-15 08:19:07
211	958	\N	63	3.000	receipt	\N	32	2026-10-15 08:19:42	2026-10-15 08:19:42
212	1052	\N	63	3.000	receipt	\N	32	2026-10-15 08:20:23	2026-10-15 08:20:23
213	1030	\N	63	7.000	receipt	\N	32	2026-10-15 08:22:12	2026-10-15 08:22:12
214	1023	\N	61	62.000	receipt	\N	32	2026-10-15 08:23:00	2026-10-15 08:23:00
215	1003	\N	61	2.000	receipt	\N	32	2026-10-15 08:24:32	2026-10-15 08:24:32
216	963	\N	61	20.000	receipt	\N	32	2026-10-15 08:25:16	2026-10-15 08:25:16
217	963	\N	62	299.000	receipt	\N	32	2026-10-15 08:25:51	2026-10-15 08:25:51
218	968	\N	61	5.000	receipt	\N	32	2026-10-15 08:28:05	2026-10-15 08:28:05
219	961	\N	61	13.000	receipt	\N	32	2026-10-15 08:28:37	2026-10-15 08:28:37
220	930	\N	61	4.000	receipt	\N	32	2026-10-15 08:29:31	2026-10-15 08:29:31
221	964	\N	61	1.000	receipt	\N	32	2026-10-15 08:30:14	2026-10-15 08:30:14
222	970	\N	61	1.000	receipt	\N	32	2026-10-15 08:32:01	2026-10-15 08:32:01
223	1046	\N	64	6.000	receipt	\N	32	2026-10-15 08:33:34	2026-10-15 08:33:34
224	1048	\N	64	11.000	receipt	\N	32	2026-10-15 08:34:14	2026-10-15 08:34:14
225	1043	\N	64	10.000	receipt	\N	32	2026-10-15 08:34:49	2026-10-15 08:34:49
226	1056	\N	64	3.000	receipt	\N	32	2026-10-15 08:35:21	2026-10-15 08:35:21
227	1029	\N	64	45.000	receipt	\N	32	2026-10-15 08:36:04	2026-10-15 08:36:04
228	1148	\N	64	20.000	receipt	\N	32	2026-10-15 08:37:26	2026-10-15 08:37:26
229	1029	64	67	45.000	transfer	\N	32	2026-10-15 08:37:58	2026-10-15 08:37:58
230	1074	\N	62	6.000	receipt	\N	32	2026-10-15 08:38:47	2026-10-15 08:38:47
231	1747	\N	64	30.000	receipt	\N	32	2026-10-15 08:52:59	2026-10-15 08:52:59
232	970	\N	66	36.000	receipt	\N	32	2026-10-15 08:55:39	2026-10-15 08:55:39
233	964	\N	66	23.000	receipt	\N	32	2026-10-15 08:56:29	2026-10-15 08:56:29
234	987	\N	66	1.000	receipt	\N	32	2026-10-15 08:56:52	2026-10-15 08:56:52
235	1021	\N	63	1.000	receipt	\N	32	2026-10-15 08:57:39	2026-10-15 08:57:39
236	1025	\N	63	3.000	receipt	\N	32	2026-10-15 08:58:09	2026-10-15 08:58:09
237	1028	\N	63	12.000	receipt	\N	32	2026-10-15 08:58:41	2026-10-15 08:58:41
238	975	\N	63	25.000	receipt	\N	32	2026-10-15 09:05:24	2026-10-15 09:05:24
239	1036	\N	63	6.000	receipt	\N	32	2026-10-15 09:06:04	2026-10-15 09:06:04
240	1036	63	65	6.000	transfer	\N	32	2026-10-15 09:06:33	2026-10-15 09:06:33
241	975	63	65	25.000	transfer	\N	32	2026-10-15 09:06:44	2026-10-15 09:06:44
242	1054	\N	65	3.000	receipt	\N	32	2026-10-15 09:07:22	2026-10-15 09:07:22
243	1042	\N	65	5.000	receipt	\N	32	2026-10-15 09:16:05	2026-10-15 09:16:05
244	1040	\N	65	1.000	receipt	\N	32	2026-10-15 09:16:49	2026-10-15 09:16:49
245	1038	\N	65	5.000	receipt	\N	32	2026-10-15 09:17:21	2026-10-15 09:17:21
246	1083	\N	65	3.000	receipt	\N	32	2026-10-15 09:21:14	2026-10-15 09:21:14
247	1085	\N	65	2.000	receipt	\N	32	2026-10-15 09:21:41	2026-10-15 09:21:41
248	1018	\N	65	5.000	receipt	\N	32	2026-10-15 09:22:23	2026-10-15 09:22:23
249	1012	\N	65	6.000	receipt	\N	32	2026-10-15 09:29:34	2026-10-15 09:29:34
250	1031	\N	65	5.000	receipt	\N	32	2026-10-15 09:30:06	2026-10-15 09:30:06
251	1064	\N	65	5.000	receipt	\N	32	2026-10-15 09:30:44	2026-10-15 09:30:44
252	1748	\N	53	2.000	receipt	\N	32	2026-10-16 02:12:11	2026-10-16 02:12:11
253	1749	\N	53	2.000	receipt	\N	32	2026-10-16 06:28:29	2026-10-16 06:28:29
254	1750	\N	53	2.000	receipt	\N	32	2026-10-16 06:30:27	2026-10-16 06:30:27
255	1751	\N	53	22.000	receipt	\N	32	2026-10-16 06:33:00	2026-10-16 06:33:00
256	1753	\N	16	150.000	receipt	\N	32	2026-10-16 06:41:17	2026-10-16 06:41:17
257	1754	\N	16	38.000	receipt	\N	32	2026-10-16 06:41:52	2026-10-16 06:41:52
258	35	\N	17	60.000	receipt	\N	32	2026-10-16 06:42:25	2026-10-16 06:42:25
259	1755	\N	66	1.000	receipt	\N	32	2026-10-16 06:43:00	2026-10-16 06:43:00
260	1076	\N	66	10.000	receipt	\N	32	2026-10-16 06:43:38	2026-10-16 06:43:38
261	1752	\N	53	3.000	receipt	\N	32	2026-10-16 07:17:02	2026-10-16 07:17:02
262	1764	\N	75	34.000	receipt	\N	32	2026-10-16 08:20:07	2026-10-16 08:20:07
263	1758	\N	75	48.000	receipt	\N	32	2026-10-16 08:20:30	2026-10-16 08:20:30
264	1764	\N	82	14.000	receipt	\N	32	2026-10-16 08:20:47	2026-10-16 08:20:47
265	1759	\N	75	100.000	receipt	\N	32	2026-10-16 08:21:07	2026-10-16 08:21:07
266	1756	\N	75	250.000	receipt	\N	32	2026-10-16 08:21:32	2026-10-16 08:21:32
267	1767	\N	75	150.000	receipt	\N	32	2026-10-16 08:21:44	2026-10-16 08:21:44
268	1767	75	79	20.000	transfer	\N	32	2026-10-16 08:22:17	2026-10-16 08:22:17
269	1761	\N	75	30.000	receipt	\N	32	2026-10-16 08:22:45	2026-10-16 08:22:45
270	1761	75	77	30.000	transfer	\N	32	2026-10-16 08:23:21	2026-10-16 08:23:21
271	1767	75	79	100.000	transfer	\N	32	2026-10-16 08:24:09	2026-10-16 08:24:09
272	1767	75	79	30.000	transfer	\N	32	2026-10-16 08:24:34	2026-10-16 08:24:34
273	1767	79	77	1.000	transfer	\N	32	2026-10-16 08:24:58	2026-10-16 08:24:58
274	1767	79	77	99.000	transfer	\N	32	2026-10-16 08:25:15	2026-10-16 08:25:15
275	1756	75	77	1.000	transfer	\N	32	2026-10-16 08:25:50	2026-10-16 08:25:50
276	1756	75	77	249.000	transfer	\N	32	2026-10-16 08:26:17	2026-10-16 08:26:17
277	1758	\N	75	132.000	receipt	\N	32	2026-10-16 08:27:07	2026-10-16 08:27:07
278	1763	\N	79	20.000	receipt	\N	32	2026-10-16 08:27:57	2026-10-16 08:27:57
279	1765	\N	79	29.000	receipt	\N	32	2026-10-16 08:28:13	2026-10-16 08:28:13
280	1766	\N	76	100.000	receipt	\N	32	2026-10-16 08:28:31	2026-10-16 08:28:31
281	1762	\N	78	40.000	receipt	\N	32	2026-10-16 08:28:52	2026-10-16 08:28:52
282	1757	\N	80	181.000	receipt	\N	32	2026-10-16 08:29:29	2026-10-16 08:29:29
283	1760	\N	80	20.000	receipt	\N	32	2026-10-16 08:29:45	2026-10-16 08:29:45
284	1765	\N	81	18.000	receipt	\N	32	2026-10-16 08:30:11	2026-10-16 08:30:11
285	1772	\N	82	30.000	receipt	\N	32	2026-10-19 02:39:38	2026-10-19 02:39:38
286	1771	\N	82	425.000	receipt	\N	32	2026-10-19 02:40:01	2026-10-19 02:40:01
287	1774	\N	77	100.000	receipt	\N	32	2026-10-19 02:40:24	2026-10-19 02:40:24
288	1773	\N	77	175.000	receipt	\N	32	2026-10-19 02:40:39	2026-10-19 02:40:39
289	1776	\N	77	450.000	receipt	\N	32	2026-10-19 02:40:59	2026-10-19 02:40:59
290	1775	\N	77	300.000	receipt	\N	32	2026-10-19 02:42:14	2026-10-19 02:42:14
291	1769	\N	76	100.000	receipt	\N	32	2026-10-19 02:42:44	2026-10-19 02:42:44
292	1778	\N	76	250.000	receipt	\N	32	2026-10-19 02:43:11	2026-10-19 02:43:11
293	1777	\N	76	25.000	receipt	\N	32	2026-10-19 02:43:32	2026-10-19 02:43:32
294	1782	\N	78	50.000	receipt	\N	32	2026-10-19 02:44:01	2026-10-19 02:44:01
295	1781	\N	78	30.000	receipt	\N	32	2026-10-19 02:44:19	2026-10-19 02:44:19
296	1780	\N	78	175.000	receipt	\N	32	2026-10-19 02:44:40	2026-10-19 02:44:40
297	1779	\N	78	50.000	receipt	\N	32	2026-10-19 02:45:03	2026-10-19 02:45:03
298	1783	\N	80	75.000	receipt	\N	32	2026-10-19 02:45:24	2026-10-19 02:45:24
299	1770	\N	77	100.000	receipt	\N	32	2026-10-19 02:45:46	2026-10-19 02:45:46
300	1785	\N	73	450.000	receipt	\N	32	2026-10-19 02:53:58	2026-10-19 02:53:58
301	1784	\N	73	275.000	receipt	\N	32	2026-10-19 02:55:13	2026-10-19 02:55:13
302	1784	\N	74	300.000	receipt	\N	32	2026-10-19 02:55:50	2026-10-19 02:55:50
303	1788	\N	74	325.000	receipt	\N	32	2026-10-19 02:56:16	2026-10-19 02:56:16
304	1787	\N	74	400.000	receipt	\N	32	2026-10-19 02:56:38	2026-10-19 02:56:38
305	1786	\N	74	425.000	receipt	\N	32	2026-10-19 02:56:57	2026-10-19 02:56:57
306	1792	\N	1	1.000	receipt	\N	32	2026-10-19 03:26:00	2026-10-19 03:26:00
307	1791	\N	1	1.000	receipt	\N	32	2026-10-19 03:26:19	2026-10-19 03:26:19
308	1789	\N	1	10.000	receipt	\N	32	2026-10-19 03:26:31	2026-10-19 03:26:31
309	1790	\N	1	10.000	receipt	\N	32	2026-10-19 03:26:43	2026-10-19 03:26:43
\.


--
-- Data for Name: threads; Type: TABLE DATA; Schema: public; Owner: gidrovik-admin
--

COPY threads (id, system, designation, name, is_active, created_at, updated_at) FROM stdin;
2	inch	1/4	1/4	t	2026-10-12 08:48:58	2026-10-14 02:29:38
1	inch	1/2	1/2	t	2026-10-12 08:48:47	2026-10-13 09:27:28
3	inch	3/4	3/4	t	2026-10-14 02:34:49	2026-10-14 02:34:49
4	inch	1	1	t	2026-10-14 02:35:01	2026-10-14 02:35:01
5	inch	1 1/4	1 1/4	t	2026-10-14 02:35:25	2026-10-14 02:35:25
6	inch	1 1/2	1 1/2	t	2026-10-14 02:36:01	2026-10-14 02:36:01
7	inch	2	2	t	2026-10-14 02:36:13	2026-10-14 02:36:13
8	inch	3/8	3/8	t	2026-10-14 02:36:49	2026-10-14 02:36:49
9	inch	5/8	5/8	t	2026-10-14 02:37:20	2026-10-14 02:37:20
10	inch	1/8	1/8	t	2026-10-14 02:39:04	2026-10-14 02:39:04
11	inch	1 1/16	1 1/16	t	2026-10-14 02:40:33	2026-10-14 02:40:33
12	inch	1 5/16	1 5/16	t	2026-10-14 02:40:58	2026-10-14 02:40:58
13	inch	1 5/8	1 5/8	t	2026-10-14 02:41:23	2026-10-14 02:41:23
14	inch	1 7/8	1 7/8	t	2026-10-14 02:41:55	2026-10-14 02:41:55
16	inch	7/16	7/16	t	2026-10-14 02:43:12	2026-10-14 02:43:12
17	inch	7/8	7/8	t	2026-10-14 02:43:32	2026-10-14 02:43:32
18	inch	9/16	9/16	t	2026-10-14 02:43:48	2026-10-14 02:43:48
19	inch	1 3/16	1 3/16	t	2026-10-14 02:44:32	2026-10-14 02:44:32
20	inch	2 1/2	2 1/2	t	2026-10-14 02:45:59	2026-10-14 02:45:59
21	inch	1 7/16	1 7/16	t	2026-10-14 02:47:08	2026-10-14 02:47:08
22	inch	1 11/16	1 11/16	t	2026-10-14 02:47:18	2026-10-14 02:47:18
23	inch	11/16	11/16	t	2026-10-14 02:47:35	2026-10-14 02:47:35
24	inch	13/16	13/16	t	2026-10-14 02:47:43	2026-10-14 02:47:43
25	other	147 100 606	147 100 606	t	2026-10-14 02:50:20	2026-10-14 02:50:20
26	other	147 100 806	147 100 806	t	2026-10-14 02:50:43	2026-10-14 02:50:43
27	other	147 100 808	147 100 808	t	2026-10-14 02:51:01	2026-10-14 02:51:01
28	other	147 140 810	147 140 810	t	2026-10-14 02:51:25	2026-10-14 02:51:25
29	other	148 100 808	148 100 808	t	2026-10-14 02:51:51	2026-10-14 02:51:51
30	other	148 100 606	148 100 606	t	2026-10-14 02:52:33	2026-10-14 02:52:33
31	other	d-22,2	d-22,2	t	2026-10-14 02:52:49	2026-10-14 02:52:49
32	other	147 100 404	147 100 404	t	2026-10-14 02:53:28	2026-10-14 02:53:28
33	other	147 100 604	147 100 604	t	2026-10-14 02:53:42	2026-10-14 02:53:42
34	other	148 100 404	148 100 404	t	2026-10-14 02:53:56	2026-10-14 02:53:56
35	other	147 100 605	147 100 605	t	2026-10-14 02:54:09	2026-10-14 02:54:09
36	metric	M10x1	M10x1	t	2026-10-14 02:55:04	2026-10-14 02:55:04
37	metric	M14x1.5	M14x1.5	t	2026-10-14 02:55:42	2026-10-14 02:55:42
38	metric	M16x1.5	M16x1.5	t	2026-10-14 02:55:57	2026-10-14 02:55:57
39	metric	M18x1.5	M18x1.5	t	2026-10-14 02:56:08	2026-10-14 02:56:08
40	metric	M20x1.5	M20x1.5	t	2026-10-14 02:56:27	2026-10-14 02:56:27
41	metric	M22x1.5	M22x1.5	t	2026-10-14 02:56:48	2026-10-14 02:56:48
42	metric	M24x1.5	M24x1.5	t	2026-10-14 02:56:58	2026-10-14 02:56:58
43	metric	M26x1.5	M26x1.5	t	2026-10-14 02:57:25	2026-10-14 02:57:25
44	metric	M27x1.5	M27x1.5	t	2026-10-14 02:57:35	2026-10-14 02:57:35
45	metric	M30x1.5	M30x1.5	t	2026-10-14 02:58:07	2026-10-14 02:58:07
46	metric	M33x1.5	M33x1.5	t	2026-10-14 02:58:25	2026-10-14 02:58:25
47	metric	M36x1.5	M36x1.5	t	2026-10-14 02:58:36	2026-10-14 02:58:36
48	metric	M39x1.5	M39x1.5	t	2026-10-14 02:59:06	2026-10-14 02:59:06
49	metric	M48x1.5	M48x1.5	t	2026-10-14 02:59:24	2026-10-14 02:59:24
50	metric	M27x2	M27x2	t	2026-10-14 02:59:57	2026-10-14 02:59:57
51	metric	M30x2	M30x2	t	2026-10-14 03:00:07	2026-10-14 03:00:07
52	metric	M33x2	M33x2	t	2026-10-14 03:00:22	2026-10-14 03:00:22
53	metric	M36x2	M36x2	t	2026-10-14 03:00:35	2026-10-14 03:00:35
54	metric	M39x2	M39x2	t	2026-10-14 03:00:56	2026-10-14 03:00:56
55	metric	M42x2	M42x2	t	2026-10-14 03:01:20	2026-10-14 03:01:20
56	metric	M45x2	M45x2	t	2026-10-14 03:01:28	2026-10-14 03:01:28
57	metric	M48x2	M48x2	t	2026-10-14 03:01:47	2026-10-14 03:01:47
58	metric	M52x2	M52x2	t	2026-10-14 03:02:10	2026-10-14 03:02:10
59	metric	M12x1.5	M12x1.5	t	2026-10-14 03:02:35	2026-10-14 03:02:35
60	metric	M12x1	M12x1	t	2026-10-14 03:02:43	2026-10-14 03:02:43
61	metric	M14x1	M14x1	t	2026-10-14 03:03:14	2026-10-14 03:03:14
62	metric	M60x4	M60x4	t	2026-10-14 03:03:55	2026-10-14 03:03:55
63	metric	M16x1	M16x1	t	2026-10-14 03:05:30	2026-10-14 03:05:30
64	metric	M42x1.5	M42x1.5	t	2026-10-14 03:06:28	2026-10-14 03:06:28
66	other	44	44	t	2026-10-14 03:08:50	2026-10-14 03:08:50
69	other	50.8	50.8	t	2026-10-14 03:09:43	2026-10-14 03:09:43
65	other	41.3	41.3	t	2026-10-14 03:08:39	2026-10-14 03:10:08
67	other	47.6	47.6	t	2026-10-14 03:09:15	2026-10-14 03:10:24
70	other	54	54	t	2026-10-14 03:10:49	2026-10-14 03:10:49
71	other	63.5	63.5	t	2026-10-14 03:11:34	2026-10-14 03:11:34
72	other	60.3	60.3	t	2026-10-14 03:12:08	2026-10-14 03:12:08
73	other	71.4	71.4	t	2026-10-14 03:12:36	2026-10-14 03:12:36
74	other	79.4	79.4	t	2026-10-14 03:12:47	2026-10-14 03:12:47
75	other	30.2	30.2	t	2026-10-14 03:13:08	2026-10-14 03:13:08
76	other	31.7	31.7	t	2026-10-14 03:13:21	2026-10-14 03:13:21
77	other	34.2	34.2	t	2026-10-14 03:13:31	2026-10-14 03:13:31
78	other	38.1	38.1	t	2026-10-14 03:14:25	2026-10-14 03:14:25
79	other	84.1	84.1	t	2026-10-14 03:15:50	2026-10-14 03:15:50
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: gidrovik-admin
--

COPY users (id, name, email, email_verified_at, password, remember_token, created_at, updated_at, two_factor_secret, two_factor_recovery_codes, two_factor_confirmed_at, role) FROM stdin;
32	Solbon	solbongomboev1995@gmail.com	2026-10-09 04:59:33	$2y$12$ihXKS3yniPEZTkkswovDReSpnprkrcEtF3oFjJBui6waU/itNTjuu	\N	2026-10-09 04:59:12	2026-10-09 04:59:33	\N	\N	\N	admin
33	Солбон Аюшеевич Гомбоев	mactrahersuper@mail.ru	\N	$2y$12$u5O3.FkpBcb3wNU2T13bf.O5c26PNFeDE97HCtEhswFbZnbRiEJJm	\N	2026-10-20 02:52:26	2026-10-21 09:36:47	\N	\N	\N	warehouse
\.


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gidrovik-admin
--

SELECT pg_catalog.setval('categories_id_seq', 7, true);


--
-- Name: category_characteristic_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gidrovik-admin
--

SELECT pg_catalog.setval('category_characteristic_id_seq', 5, true);


--
-- Name: characteristics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gidrovik-admin
--

SELECT pg_catalog.setval('characteristics_id_seq', 5, true);


--
-- Name: countries_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gidrovik-admin
--

SELECT pg_catalog.setval('countries_id_seq', 2, true);


--
-- Name: diameters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gidrovik-admin
--

SELECT pg_catalog.setval('diameters_id_seq', 13, true);


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gidrovik-admin
--

SELECT pg_catalog.setval('failed_jobs_id_seq', 1, false);


--
-- Name: jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gidrovik-admin
--

SELECT pg_catalog.setval('jobs_id_seq', 1, false);


--
-- Name: locations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gidrovik-admin
--

SELECT pg_catalog.setval('locations_id_seq', 82, true);


--
-- Name: manufacturers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gidrovik-admin
--

SELECT pg_catalog.setval('manufacturers_id_seq', 4, true);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gidrovik-admin
--

SELECT pg_catalog.setval('migrations_id_seq', 29, true);


--
-- Name: passkeys_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gidrovik-admin
--

SELECT pg_catalog.setval('passkeys_id_seq', 1, false);


--
-- Name: product_characteristic_values_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gidrovik-admin
--

SELECT pg_catalog.setval('product_characteristic_values_id_seq', 131, true);


--
-- Name: product_connections_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gidrovik-admin
--

SELECT pg_catalog.setval('product_connections_id_seq', 1529, true);


--
-- Name: product_location_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gidrovik-admin
--

SELECT pg_catalog.setval('product_location_id_seq', 276, true);


--
-- Name: product_types_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gidrovik-admin
--

SELECT pg_catalog.setval('product_types_id_seq', 15, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gidrovik-admin
--

SELECT pg_catalog.setval('products_id_seq', 1792, true);


--
-- Name: racks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gidrovik-admin
--

SELECT pg_catalog.setval('racks_id_seq', 6, true);


--
-- Name: standards_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gidrovik-admin
--

SELECT pg_catalog.setval('standards_id_seq', 17, true);


--
-- Name: stock_movements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gidrovik-admin
--

SELECT pg_catalog.setval('stock_movements_id_seq', 309, true);


--
-- Name: threads_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gidrovik-admin
--

SELECT pg_catalog.setval('threads_id_seq', 79, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: gidrovik-admin
--

SELECT pg_catalog.setval('users_id_seq', 33, true);


--
-- Name: cache_locks cache_locks_pkey; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY cache_locks
    ADD CONSTRAINT cache_locks_pkey PRIMARY KEY (key);


--
-- Name: cache cache_pkey; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY cache
    ADD CONSTRAINT cache_pkey PRIMARY KEY (key);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: categories categories_slug_unique; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_slug_unique UNIQUE (slug);


--
-- Name: category_characteristic category_characteristic_category_id_characteristic_id_unique; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY category_characteristic
    ADD CONSTRAINT category_characteristic_category_id_characteristic_id_unique UNIQUE (category_id, characteristic_id);


--
-- Name: category_characteristic category_characteristic_pkey; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY category_characteristic
    ADD CONSTRAINT category_characteristic_pkey PRIMARY KEY (id);


--
-- Name: characteristics characteristics_pkey; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY characteristics
    ADD CONSTRAINT characteristics_pkey PRIMARY KEY (id);


--
-- Name: characteristics characteristics_slug_unique; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY characteristics
    ADD CONSTRAINT characteristics_slug_unique UNIQUE (slug);


--
-- Name: countries countries_code_unique; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_code_unique UNIQUE (code);


--
-- Name: countries countries_name_unique; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_name_unique UNIQUE (name);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: diameters diameters_pkey; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY diameters
    ADD CONSTRAINT diameters_pkey PRIMARY KEY (id);


--
-- Name: diameters diameters_value_unit_unique; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY diameters
    ADD CONSTRAINT diameters_value_unit_unique UNIQUE (value, unit);


--
-- Name: failed_jobs failed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);


--
-- Name: failed_jobs failed_jobs_uuid_unique; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY failed_jobs
    ADD CONSTRAINT failed_jobs_uuid_unique UNIQUE (uuid);


--
-- Name: job_batches job_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY job_batches
    ADD CONSTRAINT job_batches_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: locations locations_rack_id_number_unique; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY locations
    ADD CONSTRAINT locations_rack_id_number_unique UNIQUE (rack_id, number);


--
-- Name: manufacturers manufacturers_name_unique; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY manufacturers
    ADD CONSTRAINT manufacturers_name_unique UNIQUE (name);


--
-- Name: manufacturers manufacturers_pkey; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY manufacturers
    ADD CONSTRAINT manufacturers_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: passkeys passkeys_credential_id_unique; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY passkeys
    ADD CONSTRAINT passkeys_credential_id_unique UNIQUE (credential_id);


--
-- Name: passkeys passkeys_pkey; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY passkeys
    ADD CONSTRAINT passkeys_pkey PRIMARY KEY (id);


--
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (email);


--
-- Name: product_characteristic_values product_characteristic_values_pkey; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY product_characteristic_values
    ADD CONSTRAINT product_characteristic_values_pkey PRIMARY KEY (id);


--
-- Name: product_characteristic_values product_characteristic_values_product_id_characteristic_id_uniq; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY product_characteristic_values
    ADD CONSTRAINT product_characteristic_values_product_id_characteristic_id_uniq UNIQUE (product_id, characteristic_id);


--
-- Name: product_connections product_connections_pkey; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY product_connections
    ADD CONSTRAINT product_connections_pkey PRIMARY KEY (id);


--
-- Name: product_connections product_connections_product_id_position_unique; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY product_connections
    ADD CONSTRAINT product_connections_product_id_position_unique UNIQUE (product_id, "position");


--
-- Name: product_location product_location_pkey; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY product_location
    ADD CONSTRAINT product_location_pkey PRIMARY KEY (id);


--
-- Name: product_location product_location_product_id_location_id_unique; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY product_location
    ADD CONSTRAINT product_location_product_id_location_id_unique UNIQUE (product_id, location_id);


--
-- Name: product_types product_types_category_id_slug_unique; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY product_types
    ADD CONSTRAINT product_types_category_id_slug_unique UNIQUE (category_id, slug);


--
-- Name: product_types product_types_pkey; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY product_types
    ADD CONSTRAINT product_types_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: products products_sku_unique; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_sku_unique UNIQUE (sku);


--
-- Name: racks racks_code_unique; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY racks
    ADD CONSTRAINT racks_code_unique UNIQUE (code);


--
-- Name: racks racks_pkey; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY racks
    ADD CONSTRAINT racks_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: standards standards_code_unique; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY standards
    ADD CONSTRAINT standards_code_unique UNIQUE (code);


--
-- Name: standards standards_pkey; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY standards
    ADD CONSTRAINT standards_pkey PRIMARY KEY (id);


--
-- Name: stock_movements stock_movements_pkey; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY stock_movements
    ADD CONSTRAINT stock_movements_pkey PRIMARY KEY (id);


--
-- Name: threads threads_pkey; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY threads
    ADD CONSTRAINT threads_pkey PRIMARY KEY (id);


--
-- Name: threads threads_system_designation_unique; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY threads
    ADD CONSTRAINT threads_system_designation_unique UNIQUE (system, designation);


--
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: cache_expiration_index; Type: INDEX; Schema: public; Owner: gidrovik-admin
--

CREATE INDEX cache_expiration_index ON cache USING btree (expiration);


--
-- Name: cache_locks_expiration_index; Type: INDEX; Schema: public; Owner: gidrovik-admin
--

CREATE INDEX cache_locks_expiration_index ON cache_locks USING btree (expiration);


--
-- Name: failed_jobs_connection_queue_failed_at_index; Type: INDEX; Schema: public; Owner: gidrovik-admin
--

CREATE INDEX failed_jobs_connection_queue_failed_at_index ON failed_jobs USING btree (connection, queue, failed_at);


--
-- Name: jobs_queue_index; Type: INDEX; Schema: public; Owner: gidrovik-admin
--

CREATE INDEX jobs_queue_index ON jobs USING btree (queue);


--
-- Name: passkeys_user_id_index; Type: INDEX; Schema: public; Owner: gidrovik-admin
--

CREATE INDEX passkeys_user_id_index ON passkeys USING btree (user_id);


--
-- Name: product_location_location_id_quantity_index; Type: INDEX; Schema: public; Owner: gidrovik-admin
--

CREATE INDEX product_location_location_id_quantity_index ON product_location USING btree (location_id, quantity);


--
-- Name: product_location_product_id_quantity_index; Type: INDEX; Schema: public; Owner: gidrovik-admin
--

CREATE INDEX product_location_product_id_quantity_index ON product_location USING btree (product_id, quantity);


--
-- Name: product_location_quantity_index; Type: INDEX; Schema: public; Owner: gidrovik-admin
--

CREATE INDEX product_location_quantity_index ON product_location USING btree (quantity);


--
-- Name: products_category_id_is_active_index; Type: INDEX; Schema: public; Owner: gidrovik-admin
--

CREATE INDEX products_category_id_is_active_index ON products USING btree (category_id, is_active);


--
-- Name: products_is_active_name_index; Type: INDEX; Schema: public; Owner: gidrovik-admin
--

CREATE INDEX products_is_active_name_index ON products USING btree (is_active, name);


--
-- Name: products_name_index; Type: INDEX; Schema: public; Owner: gidrovik-admin
--

CREATE INDEX products_name_index ON products USING btree (name);


--
-- Name: products_sku_index; Type: INDEX; Schema: public; Owner: gidrovik-admin
--

CREATE INDEX products_sku_index ON products USING btree (sku);


--
-- Name: sessions_last_activity_index; Type: INDEX; Schema: public; Owner: gidrovik-admin
--

CREATE INDEX sessions_last_activity_index ON sessions USING btree (last_activity);


--
-- Name: sessions_user_id_index; Type: INDEX; Schema: public; Owner: gidrovik-admin
--

CREATE INDEX sessions_user_id_index ON sessions USING btree (user_id);


--
-- Name: stock_movements_from_location_id_created_at_index; Type: INDEX; Schema: public; Owner: gidrovik-admin
--

CREATE INDEX stock_movements_from_location_id_created_at_index ON stock_movements USING btree (from_location_id, created_at);


--
-- Name: stock_movements_product_id_created_at_index; Type: INDEX; Schema: public; Owner: gidrovik-admin
--

CREATE INDEX stock_movements_product_id_created_at_index ON stock_movements USING btree (product_id, created_at);


--
-- Name: stock_movements_product_id_type_created_at_index; Type: INDEX; Schema: public; Owner: gidrovik-admin
--

CREATE INDEX stock_movements_product_id_type_created_at_index ON stock_movements USING btree (product_id, type, created_at);


--
-- Name: stock_movements_to_location_id_created_at_index; Type: INDEX; Schema: public; Owner: gidrovik-admin
--

CREATE INDEX stock_movements_to_location_id_created_at_index ON stock_movements USING btree (to_location_id, created_at);


--
-- Name: stock_movements_type_created_at_index; Type: INDEX; Schema: public; Owner: gidrovik-admin
--

CREATE INDEX stock_movements_type_created_at_index ON stock_movements USING btree (type, created_at);


--
-- Name: users_role_index; Type: INDEX; Schema: public; Owner: gidrovik-admin
--

CREATE INDEX users_role_index ON users USING btree (role);


--
-- Name: category_characteristic category_characteristic_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY category_characteristic
    ADD CONSTRAINT category_characteristic_category_id_foreign FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE;


--
-- Name: category_characteristic category_characteristic_characteristic_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY category_characteristic
    ADD CONSTRAINT category_characteristic_characteristic_id_foreign FOREIGN KEY (characteristic_id) REFERENCES characteristics(id) ON DELETE CASCADE;


--
-- Name: locations locations_rack_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY locations
    ADD CONSTRAINT locations_rack_id_foreign FOREIGN KEY (rack_id) REFERENCES racks(id) ON DELETE CASCADE;


--
-- Name: passkeys passkeys_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY passkeys
    ADD CONSTRAINT passkeys_user_id_foreign FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: product_characteristic_values product_characteristic_values_characteristic_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY product_characteristic_values
    ADD CONSTRAINT product_characteristic_values_characteristic_id_foreign FOREIGN KEY (characteristic_id) REFERENCES characteristics(id) ON DELETE CASCADE;


--
-- Name: product_characteristic_values product_characteristic_values_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY product_characteristic_values
    ADD CONSTRAINT product_characteristic_values_product_id_foreign FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE;


--
-- Name: product_connections product_connections_diameter_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY product_connections
    ADD CONSTRAINT product_connections_diameter_id_foreign FOREIGN KEY (diameter_id) REFERENCES diameters(id) ON DELETE SET NULL;


--
-- Name: product_connections product_connections_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY product_connections
    ADD CONSTRAINT product_connections_product_id_foreign FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE;


--
-- Name: product_connections product_connections_standard_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY product_connections
    ADD CONSTRAINT product_connections_standard_id_foreign FOREIGN KEY (standard_id) REFERENCES standards(id) ON DELETE SET NULL;


--
-- Name: product_connections product_connections_thread_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY product_connections
    ADD CONSTRAINT product_connections_thread_id_foreign FOREIGN KEY (thread_id) REFERENCES threads(id) ON DELETE SET NULL;


--
-- Name: product_location product_location_location_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY product_location
    ADD CONSTRAINT product_location_location_id_foreign FOREIGN KEY (location_id) REFERENCES locations(id) ON DELETE CASCADE;


--
-- Name: product_location product_location_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY product_location
    ADD CONSTRAINT product_location_product_id_foreign FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE;


--
-- Name: product_types product_types_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY product_types
    ADD CONSTRAINT product_types_category_id_foreign FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE;


--
-- Name: products products_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_category_id_foreign FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT;


--
-- Name: products products_country_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_country_id_foreign FOREIGN KEY (country_id) REFERENCES countries(id) ON DELETE RESTRICT;


--
-- Name: products products_manufacturer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_manufacturer_id_foreign FOREIGN KEY (manufacturer_id) REFERENCES manufacturers(id) ON DELETE RESTRICT;


--
-- Name: products products_product_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_product_type_id_foreign FOREIGN KEY (product_type_id) REFERENCES product_types(id) ON DELETE SET NULL;


--
-- Name: stock_movements stock_movements_from_location_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY stock_movements
    ADD CONSTRAINT stock_movements_from_location_id_foreign FOREIGN KEY (from_location_id) REFERENCES locations(id) ON DELETE RESTRICT;


--
-- Name: stock_movements stock_movements_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY stock_movements
    ADD CONSTRAINT stock_movements_product_id_foreign FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT;


--
-- Name: stock_movements stock_movements_to_location_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY stock_movements
    ADD CONSTRAINT stock_movements_to_location_id_foreign FOREIGN KEY (to_location_id) REFERENCES locations(id) ON DELETE RESTRICT;


--
-- Name: stock_movements stock_movements_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: gidrovik-admin
--

ALTER TABLE ONLY stock_movements
    ADD CONSTRAINT stock_movements_user_id_foreign FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

