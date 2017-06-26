{-# LANGUAGE OverloadedStrings #-}
------------------------------------------------------------------------------
-- |
-- Module:      Database.PostgreSQL.Simple.TypeInfo
-- Copyright:   (c) 2011-2012 Leon P Smith
-- License:     BSD3
-- Maintainer:  Leon P Smith <leon@melding-monads.com>
-- Stability:   experimental
--
-- This module contains portions of the @pg_type@ table that are relevant
-- to postgresql-simple and are believed to not change between PostgreSQL
-- versions.
--
------------------------------------------------------------------------------

-- Note that this file is generated by tools/GenTypeInfo.hs, and should
-- not be edited directly

module Database.PostgreSQL.Simple.TypeInfo.Static
     ( TypeInfo(..)
     , staticTypeInfo
     , bool
     , bytea
     , char
     , name
     , int8
     , int2
     , int4
     , regproc
     , text
     , oid
     , tid
     , xid
     , cid
     , xml
     , point
     , lseg
     , path
     , box
     , polygon
     , line
     , cidr
     , float4
     , float8
     , unknown
     , circle
     , money
     , macaddr
     , inet
     , bpchar
     , varchar
     , date
     , time
     , timestamp
     , timestamptz
     , interval
     , timetz
     , bit
     , varbit
     , numeric
     , refcursor
     , record
     , void
     , array_record
     , regprocedure
     , regoper
     , regoperator
     , regclass
     , regtype
     , uuid
     , json
     , jsonb
     , int2vector
     , oidvector
     , array_xml
     , array_json
     , array_line
     , array_cidr
     , array_circle
     , array_money
     , array_bool
     , array_bytea
     , array_char
     , array_name
     , array_int2
     , array_int2vector
     , array_int4
     , array_regproc
     , array_text
     , array_tid
     , array_xid
     , array_cid
     , array_oidvector
     , array_bpchar
     , array_varchar
     , array_int8
     , array_point
     , array_lseg
     , array_path
     , array_box
     , array_float4
     , array_float8
     , array_polygon
     , array_oid
     , array_macaddr
     , array_inet
     , array_timestamp
     , array_date
     , array_time
     , array_timestamptz
     , array_interval
     , array_numeric
     , array_timetz
     , array_bit
     , array_varbit
     , array_refcursor
     , array_regprocedure
     , array_regoper
     , array_regoperator
     , array_regclass
     , array_regtype
     , array_uuid
     , array_jsonb
     , int4range
     , _int4range
     , numrange
     , _numrange
     , tsrange
     , _tsrange
     , tstzrange
     , _tstzrange
     , daterange
     , _daterange
     , int8range
     , _int8range
     ) where

import Database.PostgreSQL.LibPQ (Oid(..))
import Database.PostgreSQL.Simple.TypeInfo.Types

staticTypeInfo :: Oid -> Maybe TypeInfo
staticTypeInfo (Oid x) = case x of
    16   -> Just bool
    17   -> Just bytea
    18   -> Just char
    19   -> Just name
    20   -> Just int8
    21   -> Just int2
    23   -> Just int4
    24   -> Just regproc
    25   -> Just text
    26   -> Just oid
    27   -> Just tid
    28   -> Just xid
    29   -> Just cid
    142  -> Just xml
    600  -> Just point
    601  -> Just lseg
    602  -> Just path
    603  -> Just box
    604  -> Just polygon
    628  -> Just line
    650  -> Just cidr
    700  -> Just float4
    701  -> Just float8
    705  -> Just unknown
    718  -> Just circle
    790  -> Just money
    829  -> Just macaddr
    869  -> Just inet
    1042 -> Just bpchar
    1043 -> Just varchar
    1082 -> Just date
    1083 -> Just time
    1114 -> Just timestamp
    1184 -> Just timestamptz
    1186 -> Just interval
    1266 -> Just timetz
    1560 -> Just bit
    1562 -> Just varbit
    1700 -> Just numeric
    1790 -> Just refcursor
    2249 -> Just record
    2278 -> Just void
    2287 -> Just array_record
    2202 -> Just regprocedure
    2203 -> Just regoper
    2204 -> Just regoperator
    2205 -> Just regclass
    2206 -> Just regtype
    2950 -> Just uuid
    114  -> Just json
    3802 -> Just jsonb
    22   -> Just int2vector
    30   -> Just oidvector
    143  -> Just array_xml
    199  -> Just array_json
    629  -> Just array_line
    651  -> Just array_cidr
    719  -> Just array_circle
    791  -> Just array_money
    1000 -> Just array_bool
    1001 -> Just array_bytea
    1002 -> Just array_char
    1003 -> Just array_name
    1005 -> Just array_int2
    1006 -> Just array_int2vector
    1007 -> Just array_int4
    1008 -> Just array_regproc
    1009 -> Just array_text
    1010 -> Just array_tid
    1011 -> Just array_xid
    1012 -> Just array_cid
    1013 -> Just array_oidvector
    1014 -> Just array_bpchar
    1015 -> Just array_varchar
    1016 -> Just array_int8
    1017 -> Just array_point
    1018 -> Just array_lseg
    1019 -> Just array_path
    1020 -> Just array_box
    1021 -> Just array_float4
    1022 -> Just array_float8
    1027 -> Just array_polygon
    1028 -> Just array_oid
    1040 -> Just array_macaddr
    1041 -> Just array_inet
    1115 -> Just array_timestamp
    1182 -> Just array_date
    1183 -> Just array_time
    1185 -> Just array_timestamptz
    1187 -> Just array_interval
    1231 -> Just array_numeric
    1270 -> Just array_timetz
    1561 -> Just array_bit
    1563 -> Just array_varbit
    2201 -> Just array_refcursor
    2207 -> Just array_regprocedure
    2208 -> Just array_regoper
    2209 -> Just array_regoperator
    2210 -> Just array_regclass
    2211 -> Just array_regtype
    2951 -> Just array_uuid
    3807 -> Just array_jsonb
    3904 -> Just int4range
    3905 -> Just _int4range
    3906 -> Just numrange
    3907 -> Just _numrange
    3908 -> Just tsrange
    3909 -> Just _tsrange
    3910 -> Just tstzrange
    3911 -> Just _tstzrange
    3912 -> Just daterange
    3913 -> Just _daterange
    3926 -> Just int8range
    3927 -> Just _int8range
    _ -> Nothing

bool :: TypeInfo
bool =  Basic {
    typoid      = Oid 16,
    typcategory = 'B',
    typdelim    = ',',
    typname     = "bool"
  }

bytea :: TypeInfo
bytea =  Basic {
    typoid      = Oid 17,
    typcategory = 'U',
    typdelim    = ',',
    typname     = "bytea"
  }

char :: TypeInfo
char =  Basic {
    typoid      = Oid 18,
    typcategory = 'S',
    typdelim    = ',',
    typname     = "char"
  }

name :: TypeInfo
name =  Basic {
    typoid      = Oid 19,
    typcategory = 'S',
    typdelim    = ',',
    typname     = "name"
  }

int8 :: TypeInfo
int8 =  Basic {
    typoid      = Oid 20,
    typcategory = 'N',
    typdelim    = ',',
    typname     = "int8"
  }

int2 :: TypeInfo
int2 =  Basic {
    typoid      = Oid 21,
    typcategory = 'N',
    typdelim    = ',',
    typname     = "int2"
  }

int4 :: TypeInfo
int4 =  Basic {
    typoid      = Oid 23,
    typcategory = 'N',
    typdelim    = ',',
    typname     = "int4"
  }

regproc :: TypeInfo
regproc =  Basic {
    typoid      = Oid 24,
    typcategory = 'N',
    typdelim    = ',',
    typname     = "regproc"
  }

text :: TypeInfo
text =  Basic {
    typoid      = Oid 25,
    typcategory = 'S',
    typdelim    = ',',
    typname     = "text"
  }

oid :: TypeInfo
oid =  Basic {
    typoid      = Oid 26,
    typcategory = 'N',
    typdelim    = ',',
    typname     = "oid"
  }

tid :: TypeInfo
tid =  Basic {
    typoid      = Oid 27,
    typcategory = 'U',
    typdelim    = ',',
    typname     = "tid"
  }

xid :: TypeInfo
xid =  Basic {
    typoid      = Oid 28,
    typcategory = 'U',
    typdelim    = ',',
    typname     = "xid"
  }

cid :: TypeInfo
cid =  Basic {
    typoid      = Oid 29,
    typcategory = 'U',
    typdelim    = ',',
    typname     = "cid"
  }

xml :: TypeInfo
xml =  Basic {
    typoid      = Oid 142,
    typcategory = 'U',
    typdelim    = ',',
    typname     = "xml"
  }

point :: TypeInfo
point =  Basic {
    typoid      = Oid 600,
    typcategory = 'G',
    typdelim    = ',',
    typname     = "point"
  }

lseg :: TypeInfo
lseg =  Basic {
    typoid      = Oid 601,
    typcategory = 'G',
    typdelim    = ',',
    typname     = "lseg"
  }

path :: TypeInfo
path =  Basic {
    typoid      = Oid 602,
    typcategory = 'G',
    typdelim    = ',',
    typname     = "path"
  }

box :: TypeInfo
box =  Basic {
    typoid      = Oid 603,
    typcategory = 'G',
    typdelim    = ';',
    typname     = "box"
  }

polygon :: TypeInfo
polygon =  Basic {
    typoid      = Oid 604,
    typcategory = 'G',
    typdelim    = ',',
    typname     = "polygon"
  }

line :: TypeInfo
line =  Basic {
    typoid      = Oid 628,
    typcategory = 'G',
    typdelim    = ',',
    typname     = "line"
  }

cidr :: TypeInfo
cidr =  Basic {
    typoid      = Oid 650,
    typcategory = 'I',
    typdelim    = ',',
    typname     = "cidr"
  }

float4 :: TypeInfo
float4 =  Basic {
    typoid      = Oid 700,
    typcategory = 'N',
    typdelim    = ',',
    typname     = "float4"
  }

float8 :: TypeInfo
float8 =  Basic {
    typoid      = Oid 701,
    typcategory = 'N',
    typdelim    = ',',
    typname     = "float8"
  }

unknown :: TypeInfo
unknown =  Basic {
    typoid      = Oid 705,
    typcategory = 'X',
    typdelim    = ',',
    typname     = "unknown"
  }

circle :: TypeInfo
circle =  Basic {
    typoid      = Oid 718,
    typcategory = 'G',
    typdelim    = ',',
    typname     = "circle"
  }

money :: TypeInfo
money =  Basic {
    typoid      = Oid 790,
    typcategory = 'N',
    typdelim    = ',',
    typname     = "money"
  }

macaddr :: TypeInfo
macaddr =  Basic {
    typoid      = Oid 829,
    typcategory = 'U',
    typdelim    = ',',
    typname     = "macaddr"
  }

inet :: TypeInfo
inet =  Basic {
    typoid      = Oid 869,
    typcategory = 'I',
    typdelim    = ',',
    typname     = "inet"
  }

bpchar :: TypeInfo
bpchar =  Basic {
    typoid      = Oid 1042,
    typcategory = 'S',
    typdelim    = ',',
    typname     = "bpchar"
  }

varchar :: TypeInfo
varchar =  Basic {
    typoid      = Oid 1043,
    typcategory = 'S',
    typdelim    = ',',
    typname     = "varchar"
  }

date :: TypeInfo
date =  Basic {
    typoid      = Oid 1082,
    typcategory = 'D',
    typdelim    = ',',
    typname     = "date"
  }

time :: TypeInfo
time =  Basic {
    typoid      = Oid 1083,
    typcategory = 'D',
    typdelim    = ',',
    typname     = "time"
  }

timestamp :: TypeInfo
timestamp =  Basic {
    typoid      = Oid 1114,
    typcategory = 'D',
    typdelim    = ',',
    typname     = "timestamp"
  }

timestamptz :: TypeInfo
timestamptz =  Basic {
    typoid      = Oid 1184,
    typcategory = 'D',
    typdelim    = ',',
    typname     = "timestamptz"
  }

interval :: TypeInfo
interval =  Basic {
    typoid      = Oid 1186,
    typcategory = 'T',
    typdelim    = ',',
    typname     = "interval"
  }

timetz :: TypeInfo
timetz =  Basic {
    typoid      = Oid 1266,
    typcategory = 'D',
    typdelim    = ',',
    typname     = "timetz"
  }

bit :: TypeInfo
bit =  Basic {
    typoid      = Oid 1560,
    typcategory = 'V',
    typdelim    = ',',
    typname     = "bit"
  }

varbit :: TypeInfo
varbit =  Basic {
    typoid      = Oid 1562,
    typcategory = 'V',
    typdelim    = ',',
    typname     = "varbit"
  }

numeric :: TypeInfo
numeric =  Basic {
    typoid      = Oid 1700,
    typcategory = 'N',
    typdelim    = ',',
    typname     = "numeric"
  }

refcursor :: TypeInfo
refcursor =  Basic {
    typoid      = Oid 1790,
    typcategory = 'U',
    typdelim    = ',',
    typname     = "refcursor"
  }

record :: TypeInfo
record =  Basic {
    typoid      = Oid 2249,
    typcategory = 'P',
    typdelim    = ',',
    typname     = "record"
  }

void :: TypeInfo
void =  Basic {
    typoid      = Oid 2278,
    typcategory = 'P',
    typdelim    = ',',
    typname     = "void"
  }

array_record :: TypeInfo
array_record =  Array {
    typoid      = Oid 2287,
    typcategory = 'P',
    typdelim    = ',',
    typname     = "_record",
    typelem     = record
  }

regprocedure :: TypeInfo
regprocedure =  Basic {
    typoid      = Oid 2202,
    typcategory = 'N',
    typdelim    = ',',
    typname     = "regprocedure"
  }

regoper :: TypeInfo
regoper =  Basic {
    typoid      = Oid 2203,
    typcategory = 'N',
    typdelim    = ',',
    typname     = "regoper"
  }

regoperator :: TypeInfo
regoperator =  Basic {
    typoid      = Oid 2204,
    typcategory = 'N',
    typdelim    = ',',
    typname     = "regoperator"
  }

regclass :: TypeInfo
regclass =  Basic {
    typoid      = Oid 2205,
    typcategory = 'N',
    typdelim    = ',',
    typname     = "regclass"
  }

regtype :: TypeInfo
regtype =  Basic {
    typoid      = Oid 2206,
    typcategory = 'N',
    typdelim    = ',',
    typname     = "regtype"
  }

uuid :: TypeInfo
uuid =  Basic {
    typoid      = Oid 2950,
    typcategory = 'U',
    typdelim    = ',',
    typname     = "uuid"
  }

json :: TypeInfo
json =  Basic {
    typoid      = Oid 114,
    typcategory = 'U',
    typdelim    = ',',
    typname     = "json"
  }

jsonb :: TypeInfo
jsonb =  Basic {
    typoid      = Oid 3802,
    typcategory = 'U',
    typdelim    = ',',
    typname     = "jsonb"
  }

int2vector :: TypeInfo
int2vector =  Array {
    typoid      = Oid 22,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "int2vector",
    typelem     = int2
  }

oidvector :: TypeInfo
oidvector =  Array {
    typoid      = Oid 30,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "oidvector",
    typelem     = oid
  }

array_xml :: TypeInfo
array_xml =  Array {
    typoid      = Oid 143,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_xml",
    typelem     = xml
  }

array_json :: TypeInfo
array_json =  Array {
    typoid      = Oid 199,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_json",
    typelem     = json
  }

array_line :: TypeInfo
array_line =  Array {
    typoid      = Oid 629,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_line",
    typelem     = line
  }

array_cidr :: TypeInfo
array_cidr =  Array {
    typoid      = Oid 651,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_cidr",
    typelem     = cidr
  }

array_circle :: TypeInfo
array_circle =  Array {
    typoid      = Oid 719,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_circle",
    typelem     = circle
  }

array_money :: TypeInfo
array_money =  Array {
    typoid      = Oid 791,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_money",
    typelem     = money
  }

array_bool :: TypeInfo
array_bool =  Array {
    typoid      = Oid 1000,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_bool",
    typelem     = bool
  }

array_bytea :: TypeInfo
array_bytea =  Array {
    typoid      = Oid 1001,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_bytea",
    typelem     = bytea
  }

array_char :: TypeInfo
array_char =  Array {
    typoid      = Oid 1002,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_char",
    typelem     = char
  }

array_name :: TypeInfo
array_name =  Array {
    typoid      = Oid 1003,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_name",
    typelem     = name
  }

array_int2 :: TypeInfo
array_int2 =  Array {
    typoid      = Oid 1005,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_int2",
    typelem     = int2
  }

array_int2vector :: TypeInfo
array_int2vector =  Array {
    typoid      = Oid 1006,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_int2vector",
    typelem     = int2vector
  }

array_int4 :: TypeInfo
array_int4 =  Array {
    typoid      = Oid 1007,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_int4",
    typelem     = int4
  }

array_regproc :: TypeInfo
array_regproc =  Array {
    typoid      = Oid 1008,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_regproc",
    typelem     = regproc
  }

array_text :: TypeInfo
array_text =  Array {
    typoid      = Oid 1009,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_text",
    typelem     = text
  }

array_tid :: TypeInfo
array_tid =  Array {
    typoid      = Oid 1010,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_tid",
    typelem     = tid
  }

array_xid :: TypeInfo
array_xid =  Array {
    typoid      = Oid 1011,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_xid",
    typelem     = xid
  }

array_cid :: TypeInfo
array_cid =  Array {
    typoid      = Oid 1012,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_cid",
    typelem     = cid
  }

array_oidvector :: TypeInfo
array_oidvector =  Array {
    typoid      = Oid 1013,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_oidvector",
    typelem     = oidvector
  }

array_bpchar :: TypeInfo
array_bpchar =  Array {
    typoid      = Oid 1014,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_bpchar",
    typelem     = bpchar
  }

array_varchar :: TypeInfo
array_varchar =  Array {
    typoid      = Oid 1015,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_varchar",
    typelem     = varchar
  }

array_int8 :: TypeInfo
array_int8 =  Array {
    typoid      = Oid 1016,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_int8",
    typelem     = int8
  }

array_point :: TypeInfo
array_point =  Array {
    typoid      = Oid 1017,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_point",
    typelem     = point
  }

array_lseg :: TypeInfo
array_lseg =  Array {
    typoid      = Oid 1018,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_lseg",
    typelem     = lseg
  }

array_path :: TypeInfo
array_path =  Array {
    typoid      = Oid 1019,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_path",
    typelem     = path
  }

array_box :: TypeInfo
array_box =  Array {
    typoid      = Oid 1020,
    typcategory = 'A',
    typdelim    = ';',
    typname     = "_box",
    typelem     = box
  }

array_float4 :: TypeInfo
array_float4 =  Array {
    typoid      = Oid 1021,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_float4",
    typelem     = float4
  }

array_float8 :: TypeInfo
array_float8 =  Array {
    typoid      = Oid 1022,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_float8",
    typelem     = float8
  }

array_polygon :: TypeInfo
array_polygon =  Array {
    typoid      = Oid 1027,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_polygon",
    typelem     = polygon
  }

array_oid :: TypeInfo
array_oid =  Array {
    typoid      = Oid 1028,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_oid",
    typelem     = oid
  }

array_macaddr :: TypeInfo
array_macaddr =  Array {
    typoid      = Oid 1040,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_macaddr",
    typelem     = macaddr
  }

array_inet :: TypeInfo
array_inet =  Array {
    typoid      = Oid 1041,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_inet",
    typelem     = inet
  }

array_timestamp :: TypeInfo
array_timestamp =  Array {
    typoid      = Oid 1115,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_timestamp",
    typelem     = timestamp
  }

array_date :: TypeInfo
array_date =  Array {
    typoid      = Oid 1182,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_date",
    typelem     = date
  }

array_time :: TypeInfo
array_time =  Array {
    typoid      = Oid 1183,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_time",
    typelem     = time
  }

array_timestamptz :: TypeInfo
array_timestamptz =  Array {
    typoid      = Oid 1185,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_timestamptz",
    typelem     = timestamptz
  }

array_interval :: TypeInfo
array_interval =  Array {
    typoid      = Oid 1187,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_interval",
    typelem     = interval
  }

array_numeric :: TypeInfo
array_numeric =  Array {
    typoid      = Oid 1231,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_numeric",
    typelem     = numeric
  }

array_timetz :: TypeInfo
array_timetz =  Array {
    typoid      = Oid 1270,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_timetz",
    typelem     = timetz
  }

array_bit :: TypeInfo
array_bit =  Array {
    typoid      = Oid 1561,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_bit",
    typelem     = bit
  }

array_varbit :: TypeInfo
array_varbit =  Array {
    typoid      = Oid 1563,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_varbit",
    typelem     = varbit
  }

array_refcursor :: TypeInfo
array_refcursor =  Array {
    typoid      = Oid 2201,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_refcursor",
    typelem     = refcursor
  }

array_regprocedure :: TypeInfo
array_regprocedure =  Array {
    typoid      = Oid 2207,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_regprocedure",
    typelem     = regprocedure
  }

array_regoper :: TypeInfo
array_regoper =  Array {
    typoid      = Oid 2208,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_regoper",
    typelem     = regoper
  }

array_regoperator :: TypeInfo
array_regoperator =  Array {
    typoid      = Oid 2209,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_regoperator",
    typelem     = regoperator
  }

array_regclass :: TypeInfo
array_regclass =  Array {
    typoid      = Oid 2210,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_regclass",
    typelem     = regclass
  }

array_regtype :: TypeInfo
array_regtype =  Array {
    typoid      = Oid 2211,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_regtype",
    typelem     = regtype
  }

array_uuid :: TypeInfo
array_uuid =  Array {
    typoid      = Oid 2951,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_uuid",
    typelem     = uuid
  }

array_jsonb :: TypeInfo
array_jsonb =  Array {
    typoid      = Oid 3807,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_jsonb",
    typelem     = jsonb
  }

int4range :: TypeInfo
int4range =  Range {
    typoid      = Oid 3904,
    typcategory = 'R',
    typdelim    = ',',
    typname     = "int4range",
    rngsubtype  = int4
  }

_int4range :: TypeInfo
_int4range =  Array {
    typoid      = Oid 3905,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_int4range",
    typelem     = int4range
  }

numrange :: TypeInfo
numrange =  Range {
    typoid      = Oid 3906,
    typcategory = 'R',
    typdelim    = ',',
    typname     = "numrange",
    rngsubtype  = numeric
  }

_numrange :: TypeInfo
_numrange =  Array {
    typoid      = Oid 3907,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_numrange",
    typelem     = numrange
  }

tsrange :: TypeInfo
tsrange =  Range {
    typoid      = Oid 3908,
    typcategory = 'R',
    typdelim    = ',',
    typname     = "tsrange",
    rngsubtype  = timestamp
  }

_tsrange :: TypeInfo
_tsrange =  Array {
    typoid      = Oid 3909,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_tsrange",
    typelem     = tsrange
  }

tstzrange :: TypeInfo
tstzrange =  Range {
    typoid      = Oid 3910,
    typcategory = 'R',
    typdelim    = ',',
    typname     = "tstzrange",
    rngsubtype  = timestamptz
  }

_tstzrange :: TypeInfo
_tstzrange =  Array {
    typoid      = Oid 3911,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_tstzrange",
    typelem     = tstzrange
  }

daterange :: TypeInfo
daterange =  Range {
    typoid      = Oid 3912,
    typcategory = 'R',
    typdelim    = ',',
    typname     = "daterange",
    rngsubtype  = date
  }

_daterange :: TypeInfo
_daterange =  Array {
    typoid      = Oid 3913,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_daterange",
    typelem     = daterange
  }

int8range :: TypeInfo
int8range =  Range {
    typoid      = Oid 3926,
    typcategory = 'R',
    typdelim    = ',',
    typname     = "int8range",
    rngsubtype  = int8
  }

_int8range :: TypeInfo
_int8range =  Array {
    typoid      = Oid 3927,
    typcategory = 'A',
    typdelim    = ',',
    typname     = "_int8range",
    typelem     = int8range
  }