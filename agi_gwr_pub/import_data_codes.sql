SELECT 
    CAST(NULLIF(CECODID, '') AS int) AS CECODID,
    NULLIF(CMERKM, '') AS CMERKM,
    NULLIF(CODTXTLD, '') AS CODTXTLD,
    NULLIF(CODTXTKD, '') AS CODTXTKD,
    NULLIF(CODTXTLF, '') AS CODTXTLF,
    NULLIF(CODTXTKF, '') AS CODTXTKF,
    NULLIF(CODTXTLI, '') AS CODTXTLI,
    NULLIF(CODTXTKI, '') AS CODTXTKI,
    NULLIF(CEXPDAT, '') AS CEXPDAT
FROM
    codes
;
