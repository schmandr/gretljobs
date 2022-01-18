-- Drop table
CREATE SCHEMA IF NOT EXISTS afu_isboden_pub AUTHORIZATION "user";

DROP TABLE IF EXISTS afu_isboden_pub.bodeneinheit;

CREATE TABLE 
    afu_isboden_pub.bodeneinheit (
	t_id int8 NOT NULL,
	gemnr int2 NULL,
	objnr int4 NULL,
	wasserhhgr varchar(2) NULL,
	wasserhhgr_beschreibung varchar(255) NULL,
	charakter_wasserhaushalt varchar(255) NULL,
	wasserhaushalt_spezifisch varchar(255) NULL,
	wasserhaushalt_uebergreifend varchar(255) NULL,
	bodentyp varchar(2) NULL,
	bodentyp_beschreibung varchar(255) NULL,
	gelform varchar(2) NULL,
	gelform_text text NULL,
	gelform_beschreibung varchar(255) NULL,
	geologie varchar(30) NULL,
	skelett_ob int4 NULL,
	skelett_ob_text varchar(255) NULL,
	skelett_ob_beschreibung varchar(255) NULL,
	skelett_ub int4 NULL,
	skelett_ub_text varchar(255) NULL,
	skelett_ub_beschreibung varchar(255) NULL,
	koernkl_ob int4 NULL,
	koernkl_ob_beschreibung varchar(255) NULL,
	bodenart_bodenbearbeitbarkeit varchar(255) NULL,
	koernkl_ub int4 NULL,
	koernkl_ub_beschreibung varchar(255) NULL,
	ton_ob int4 NULL,
	ton_ub int4 NULL,
	schluff_ob int4 NULL,
	schluff_ub int4 NULL,
	karbgrenze int4 NULL,
	kalkgeh_ob int4 NULL,
	kalkgeh_ob_beschreibung varchar(255) NULL,
	kalkgeh_ub int4 NULL,
	kalkgeh_ub_beschreibung varchar(255) NULL,
	ph_ob float8 NULL,
	ph_ob_text varchar(255) NULL,
	ph_ub float8 NULL,
	ph_ub_text varchar(255) NULL,
	maechtigk_ah int2 NULL,
	humusgeh_ah float8 NULL,
	humusgeh_ah_text varchar(255) NULL,
	humusform_wa varchar(3) NULL,
	humusform_wa_beschreibung varchar(255) NULL,
	humusform_wa_text varchar(255) NULL,
	maechtigk_ahh float8 NULL,
	gefuegeform_ob varchar(3) NULL,
	gefuegeform_ob_beschreibung varchar(255) NULL,
	gefuegeform_ob_int int2 NULL,
	gefuegeform_ub varchar(3) NULL,
	gefuegeform_ub_beschreibung varchar(255) NULL,
	gefueggr_ob int4 NULL,
	gefueggr_ob_beschreibung varchar(255) NULL,
	gefueggr_ub int4 NULL,
	gefueggr_ub_beschreibung varchar(255) NULL,
	pflngr int4 NULL,
	pflngr_qgis_int int4 NULL,
	pflngr_text varchar(255) NULL,
	bodpktzahl int4 NULL,
	bodpktzahl_text varchar(255) NULL,
	bemerkungen varchar(300) NULL,
	los varchar(25) NULL,
	kartierjahr int2 NULL,
	kartierer int8 NULL,
	kartierquartal int2 NULL,
	is_wald bool NULL,
	bindst_cd float8 NULL,
	bindst_zn float8 NULL,
	bindst_cu float8 NULL,
	bindst_pb float8 NULL,
	nfkapwe_ob float8 NULL,
	nfkapwe_ub float8 NULL,
	nfkapwe float8 NULL,
	nfkapwe_text varchar(255) NULL,
	verdempf int2 NULL,
	verdempf_text varchar(255) NULL,
	drain_wel float8 NULL,
	wassastoss float8 NULL,
	is_hauptauspraegung bool NULL,
	gewichtung_auspraegung int2 NULL,
	geometrie geometry(POLYGON, 2056) NULL,
	untertyp text NULL,
	gemnr_aktuell int4 NULL,
	CONSTRAINT afu_isboden_pub_bodeneinheit_pkey PRIMARY KEY (t_id)
    )
;

CREATE INDEX 
    idx_afu_isboden_bodeneinheit_wkb_geometery 
    ON 
    afu_isboden_pub.bodeneinheit 
USING gist (geometrie)
;
