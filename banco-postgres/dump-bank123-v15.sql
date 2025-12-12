--
-- PostgreSQL database dump
--

\restrict 0ru3J1mVye6XD5m8sOFF1QpPzjwWX5MVeWx2FfmxCRbPNqHY52rxgafCRj0rKik

-- Dumped from database version 15.15
-- Dumped by pg_dump version 15.15

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: contas; Type: TABLE; Schema: public; Owner: bank123
--

CREATE TABLE public.contas (
    numeroconta integer NOT NULL,
    datacriacao timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    saldo numeric(15,2) NOT NULL
);


ALTER TABLE public.contas OWNER TO bank123;

--
-- Name: livrocaixa; Type: TABLE; Schema: public; Owner: bank123
--

CREATE TABLE public.livrocaixa (
    idtransacao integer NOT NULL,
    datatransacao timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    valortransacao numeric(15,2) NOT NULL,
    numeroconta integer NOT NULL,
    operacao character varying(10),
    destino character varying(255),
    origem character varying(255),
    CONSTRAINT livrocaixa_operacao_check CHECK (((operacao)::text = ANY ((ARRAY['ENTRADA'::character varying, 'SAIDA'::character varying])::text[])))
);


ALTER TABLE public.livrocaixa OWNER TO bank123;

--
-- Name: livrocaixa_idtransacao_seq; Type: SEQUENCE; Schema: public; Owner: bank123
--

CREATE SEQUENCE public.livrocaixa_idtransacao_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.livrocaixa_idtransacao_seq OWNER TO bank123;

--
-- Name: livrocaixa_idtransacao_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: bank123
--

ALTER SEQUENCE public.livrocaixa_idtransacao_seq OWNED BY public.livrocaixa.idtransacao;


--
-- Name: livrocaixa idtransacao; Type: DEFAULT; Schema: public; Owner: bank123
--

ALTER TABLE ONLY public.livrocaixa ALTER COLUMN idtransacao SET DEFAULT nextval('public.livrocaixa_idtransacao_seq'::regclass);


--
-- Data for Name: contas; Type: TABLE DATA; Schema: public; Owner: bank123
--

COPY public.contas (numeroconta, datacriacao, saldo) FROM stdin;
123456	2025-12-12 22:54:40.030255	1000.00
\.


--
-- Data for Name: livrocaixa; Type: TABLE DATA; Schema: public; Owner: bank123
--

COPY public.livrocaixa (idtransacao, datatransacao, valortransacao, numeroconta, operacao, destino, origem) FROM stdin;
1	2025-12-12 22:54:40.031526	60.00	123456	SAIDA	Fabio Pereira	Tatiana Favoretti
\.


--
-- Name: livrocaixa_idtransacao_seq; Type: SEQUENCE SET; Schema: public; Owner: bank123
--

SELECT pg_catalog.setval('public.livrocaixa_idtransacao_seq', 1, true);


--
-- Name: contas contas_pkey; Type: CONSTRAINT; Schema: public; Owner: bank123
--

ALTER TABLE ONLY public.contas
    ADD CONSTRAINT contas_pkey PRIMARY KEY (numeroconta);


--
-- Name: livrocaixa livrocaixa_pkey; Type: CONSTRAINT; Schema: public; Owner: bank123
--

ALTER TABLE ONLY public.livrocaixa
    ADD CONSTRAINT livrocaixa_pkey PRIMARY KEY (idtransacao);


--
-- Name: livrocaixa fk_conta; Type: FK CONSTRAINT; Schema: public; Owner: bank123
--

ALTER TABLE ONLY public.livrocaixa
    ADD CONSTRAINT fk_conta FOREIGN KEY (numeroconta) REFERENCES public.contas(numeroconta);


--
-- PostgreSQL database dump complete
--

\unrestrict 0ru3J1mVye6XD5m8sOFF1QpPzjwWX5MVeWx2FfmxCRbPNqHY52rxgafCRj0rKik

