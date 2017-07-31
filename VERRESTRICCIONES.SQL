CREATE OR REPLACE  PROCEDURE VERRESTRICCIONES  (TABLA IN  VARCHAR2)
AS
-- PARA COLUMNAS DE LA TABLA
CURSOR CCOL (PTABLA VARCHAR2) IS SELECT COLUMN_NAME columna ,
                                       DATA_TYPE  tipo ,
                                       DATA_LENGTH longitud,
                                       DATA_PRECISION P_Entera,
                                       DATA_SCALE decimales,
                                       NULLABLE nulo
                               FROM USER_TAB_COLUMNS
                               WHERE TABLE_NAME=upper(PTABLA);
 TEXTO VARCHAR2(200);
 TEXTO1 VARCHAR2(8);
-- PARA LA CLAVE PRIMARIA

CURSOR C1 IS select column_name
             from user_cons_columns
             where constraint_name in (select CONSTRAINT_NAME
                                       from user_constraints
                                       where CONSTRAINT_TYPE='P' and table_name=Upper(tabla));
FILAC1 C1%ROWTYPE;
columna user_cons_columns.column_name%TYPE;




-- PARA CLAVES ALTERNATIVAS

CURSOR C2 IS select column_name,constraint_name
             from user_cons_columns
             where constraint_name in (select CONSTRAINT_NAME
                                       from user_constraints
                                       where CONSTRAINT_TYPE='U' and table_name=Upper(tabla))
             order by constraint_name;
FILAC2 C2%ROWTYPE;
columnaC2 user_cons_columns.column_name%TYPE;
CONSTRAINTC2 USER_CONS_COLUMNS.CONSTRAINT_NAME%TYPE;



-- PARA RESTRICCIONES CHECK

CURSOR C3 IS select constraint_name,search_condition
             from user_constraints
             where CONSTRAINT_TYPE='C' and table_name=Upper(tabla);

FILAC3 C3%ROWTYPE;




-- PARA CLAVES AJENAS

CURSOR C4 IS select constraint_name,column_name
             from user_cons_columns
             where constraint_name in (select constraint_name
                                       from user_constraints
                                       where CONSTRAINT_TYPE='R' 
                                             and 
                                             table_name=Upper(tabla));
FILAC4 C4%ROWTYPE;
CONSTRAINTC4 USER_CONS_COLUMNS.CONSTRAINT_NAME%TYPE;
COLUMNAC4 USER_CONS_COLUMNS.COLUMN_NAME%TYPE;

CURSOR C5(X VARCHAR2) IS select table_name,column_name
             from user_cons_columns
             where constraint_name in (select r_constraint_name
                                       from user_constraints
                                       where constraint_name = X);
FILAC5 C5%ROWTYPE;



-- PARA VER TABLAS QUE ME REFERENCIAN

CURSOR C6 IS select table_name
             from user_constraints
             where constraint_type='R'
                   and
                   r_constraint_name in (select constraint_name
                                         from user_cons_columns
                                         where table_name=Upper(tabla));
FILAC6 C6%ROWTYPE;


BEGIN
 DBMS_OUTPUT.PUT_LINE('. ');
DBMS_OUTPUT.PUT_LINE('La tabla '||Upper(tabla)||' tiene las siguientes COLUMNAS:');
 DBMS_OUTPUT.PUT_LINE('. ');
-- PARA LAS COLUMNAS TIPO Y PRECISION
  FOR LINEA IN CCOL(TABLA) LOOP
  IF LINEA.TIPO='NUMBER' THEN
      TEXTO:='('||LINEA.P_ENTERA||','||LINEA.DECIMALES||')';
  ELSIF  LINEA.TIPO='DATE'   THEN
      TEXTO:='';
  ELSE
      TEXTO:='('||LINEA.LONGITUD||')';
  END IF;

  IF   LINEA.NULO ='N' THEN
    TEXTO1:='NOT NULL';
  ELSE
    TEXTO1:='';
  END IF;

  DBMS_OUTPUT.PUT_LINE(LINEA.columna||'   '||LINEA.TIPO||TEXTO||' '|| TEXTO1);
  END LOOP;


 DBMS_OUTPUT.PUT_LINE('. ');
DBMS_OUTPUT.PUT_LINE('La tabla '||Upper(tabla)||' tiene las siguientes restricciones:');
DBMS_OUTPUT.PUT_LINE('.');
-- PARA VER LA CLAVE PRIMARIA
  DBMS_OUTPUT.PUT_LINE('. ');
  DBMS_OUTPUT.PUT_LINE('**************************************************************');
  DBMS_OUTPUT.PUT_LINE('***************CLAVE PRIMARIA**********************************');
  DBMS_OUTPUT.PUT_LINE('**************************************************************');
    DBMS_OUTPUT.PUT_LINE('.');
    COLUMNA:='CLAVE PRIMARIA--> (';
    OPEN C1;
    FETCH C1 INTO FILAC1;
    IF C1%FOUND THEN
      COLUMNA:=COLUMNA||FILAC1.column_name;
      FETCH C1 INTO FILAC1; 
      WHILE C1%FOUND LOOP
       COLUMNA:=COLUMNA||','||FILAC1.column_name;
        FETCH C1 INTO FILAC1;
      END LOOP;
      DBMS_OUTPUT.PUT_LINE(COLUMNA||')');
    END IF;
    CLOSE C1;





-- FIN  VER LAS CLAVE PRIMARIA

-- PARA VER LAS CLAVES ALTERNATIVAS
 DBMS_OUTPUT.PUT_LINE('. ');
DBMS_OUTPUT.PUT_LINE('**************************************************************');
  DBMS_OUTPUT.PUT_LINE('***************CLAVES UNICAS**********************************');
  DBMS_OUTPUT.PUT_LINE('**************************************************************');
  DBMS_OUTPUT.PUT_LINE('.');
  OPEN C2;
  FETCH C2 INTO FILAC2;
  WHILE C2%FOUND LOOP
    CONSTRAINTC2:=FILAC2.CONSTRAINT_NAME;
    COLUMNAC2:=FILAC2.CONSTRAINT_NAME||'-->('||FILAC2.COLUMN_NAME;
    FETCH C2 INTO FILAC2;    
    WHILE C2%FOUND AND CONSTRAINTC2=FILAC2.CONSTRAINT_NAME LOOP
      COLUMNAC2:=COLUMNAC2||','||FILAC2.COLUMN_NAME;
      FETCH C2 INTO FILAC2;
    END LOOP;
    COLUMNAC2:=COLUMNAC2||');';
    dbms_output.put_line(columnac2);
  END LOOP;
  CLOSE C2;
  


-- FIN  VER LAS CLAVES ALTERNATIVAS

-- PARA VER LAS CHECK
 DBMS_OUTPUT.PUT_LINE('. ');
DBMS_OUTPUT.PUT_LINE('**************************************************************');
  DBMS_OUTPUT.PUT_LINE('***************RESTRICCIONES CHECK**********************************');
  DBMS_OUTPUT.PUT_LINE('**************************************************************');
  DBMS_OUTPUT.PUT_LINE('.');
  OPEN C3;
  FETCH C3 INTO FILAC3;
  WHILE C3%FOUND LOOP
    DBMS_OUTPUT.PUT_LINE(FILAC3.CONSTRAINT_NAME||'        '||FILAC3.SEARCH_CONDITION);
    FETCH C3 INTO FILAC3;
  END LOOP;
  CLOSE C3;


-- FIN  VER LAS CHECK

-- PARA VER LAS CLAVES AJENAS

   DBMS_OUTPUT.PUT_LINE('. ');
  DBMS_OUTPUT.PUT_LINE('**************************************************************');
  DBMS_OUTPUT.PUT_LINE('***************CLAVES AJENAS**********************************');
  DBMS_OUTPUT.PUT_LINE('**************************************************************');
  DBMS_OUTPUT.PUT_LINE('. ');
  OPEN C4;
  FETCH C4 INTO FILAC4;
  WHILE C4%FOUND LOOP
    CONSTRAINTC4:=FILAC4.CONSTRAINT_NAME;
    COLUMNAC4:=FILAC4.CONSTRAINT_NAME||'-->('||FILAC4.COLUMN_NAME;
    FETCH C4 INTO FILAC4;    
    WHILE C4%FOUND AND CONSTRAINTC4=FILAC4.CONSTRAINT_NAME LOOP
      COLUMNAC4:=COLUMNAC4||','||FILAC4.COLUMN_NAME;
      FETCH C4 INTO FILAC4;
    END LOOP;
    COLUMNAC4:=COLUMNAC4||') Referencia a la tabla ';
    
    OPEN C5(CONSTRAINTC4); 
    FETCH C5 INTO FILAC5;
    COLUMNAC4:=COLUMNAC4||FILAC5.TABLE_NAME||'-->('||FILAC5.COLUMN_NAME;
    FETCH C5 INTO FILAC5;  
    WHILE C5%FOUND LOOP
      COLUMNAC4:=COLUMNAC4||','||FILAC5.COLUMN_NAME;
      FETCH C5 INTO FILAC5;
    END LOOP;
    CLOSE C5;
    DBMS_OUTPUT.PUT_LINE(COLUMNAC4||')');
  END LOOP;
  CLOSE C4;


-- FIN VER CLAVES AJENAS
-- PARA VER TABLAS QUE ME REFERENCIAN
DBMS_OUTPUT.PUT_LINE('. ');
DBMS_OUTPUT.PUT_LINE('**************************************************************');
  DBMS_OUTPUT.PUT_LINE('***************TABLAS QUE ME REFERENCIAN**********************************');
  DBMS_OUTPUT.PUT_LINE('**************************************************************');
  DBMS_OUTPUT.PUT_LINE('. ');
  OPEN C6;
  FETCH C6 INTO FILAC6;
  WHILE C6%FOUND LOOP
    DBMS_OUTPUT.PUT_LINE(FILAC6.TABLE_NAME);
    FETCH C6 INTO FILAC6;
  END LOOP;
  CLOSE C6;
  

-- FIN  VER TABLAS QUE ME REFERENCIAN

END VERRESTRICCIONES;