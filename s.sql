-- Необходимо чтобы включить вывод в sqlplus
-- FORMAT WRAPPED позволяет оставлять ведущие пробелы в строке
SET SERVEROUTPUT ON FORMAT WRAPPED;

CREATE OR REPLACE PROCEDURE LS_COLUMNS
IS
    tableName VARCHAR2(40) := 'Н_ЛЮДИ';

    colNo VARCHAR2(128) := 'No.';
    colName VARCHAR2(128) := 'Имя столбца';
    colAttr VARCHAR2(128) := 'Атрибуты';

    NO_LEN NUMBER := 3;
    COLUMN_LEN NUMBER := 30;
    ATTRIBUTE_LEN NUMBER := 40;
    ATTRIBUTE_NAME_LEN NUMBER := 15;

    DATA_TYPE VARCHAR2(128);
    COMMEN VARCHAR2(128);

    CURSOR RESULT IS
        SELECT ALL_TAB_COLUMNS.COLUMN_ID AS COLUMN_ID,
               ALL_TAB_COLUMNS.COLUMN_NAME AS COLUMN_NAME,
               ALL_TAB_COLUMNS.DATA_TYPE AS DATA_TYPE,
               ALL_TAB_COLUMNS.NULLABLE AS NULLABLE,
               ALL_TAB_COLUMNS.DATA_PRECISION AS DATA_PRECISION,
               ALL_TAB_COLUMNS.CHAR_LENGTH AS CHAR_LENGTH,
               ALL_COL_COMMENTS.COMMENTS AS COMMENTS
        FROM ALL_TAB_COLUMNS, ALL_COL_COMMENTS
        WHERE ALL_TAB_COLUMNS.TABLE_NAME = tableName
        AND ALL_COL_COMMENTS.TABLE_NAME = ALL_TAB_COLUMNS.TABLE_NAME
        AND ALL_TAB_COLUMNS.COLUMN_NAME = ALL_COL_COMMENTS.COLUMN_NAME
        ORDER BY ALL_TAB_COLUMNS.COLUMN_ID;

    CURSOR CONSTRS IS
        SELECT ALL_CONS_COLUMNS.COLUMN_NAME, ALL_CONSTRAINTS.CONSTRAINT_NAME, ALL_CONSTRAINTS.CONSTRAINT_TYPE
        FROM ALL_CONS_COLUMNS, ALL_CONSTRAINTS
        WHERE ALL_CONS_COLUMNS.TABLE_NAME = tableName
        AND ALL_CONSTRAINTS.TABLE_NAME = tableName
        AND ALL_CONS_COLUMNS.CONSTRAINT_NAME = ALL_CONSTRAINTS.CONSTRAINT_NAME;

    CURSOR INDEX_COLUMNS IS
        SELECT ALL_IND_COLUMNS.INDEX_NAME, ALL_IND_COLUMNS.COLUMN_NAME
        FROM ALL_IND_COLUMNS
        WHERE ALL_IND_COLUMNS.TABLE_NAME = tableName;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Таблица: ' || tableName);
    DBMS_OUTPUT.NEW_LINE; 

    -- HEADER START
    DBMS_OUTPUT.PUT_LINE(RPAD(colNo, NO_LEN) || ' ' ||
                         RPAD(colName, COLUMN_LEN) || ' ' ||
                         RPAD(colAttr, ATTRIBUTE_LEN));

    DBMS_OUTPUT.PUT_LINE(RPAD('-', NO_LEN, '-') || ' ' ||
                         RPAD('-', COLUMN_LEN, '-') || ' ' ||
                         RPAD('-', ATTRIBUTE_LEN, '-'));
    -- HEADER END

    FOR ROW IN RESULT
    LOOP
        colNo := TO_CHAR(ROW.COLUMN_ID);
        colName := ROW.COLUMN_NAME;
        DATA_TYPE := RPAD('Type: ', ATTRIBUTE_NAME_LEN) || ROW.DATA_TYPE;

        -- DATA START
        IF ROW.DATA_PRECISION IS NOT NULL THEN
            DATA_TYPE := DATA_TYPE || '(' || ROW.DATA_PRECISION || ')';
        END IF;

        IF ROW.CHAR_LENGTH > 0 THEN
            DATA_TYPE := DATA_TYPE || '(' || ROW.CHAR_LENGTH || ')';
        END IF;

        IF ROW.NULLABLE = 'N' THEN
            DATA_TYPE := DATA_TYPE || ' Not null';
        END IF;
        -- DATA END

        -- FIRST LINE START
        DBMS_OUTPUT.PUT_LINE(RPAD(colNo, NO_LEN, ' ') || ' ' ||
                             RPAD(colName, COLUMN_LEN, ' ') || ' ' ||
                             RPAD(DATA_TYPE, ATTRIBUTE_LEN, ' '));
        -- FIRST LINE END

        -- COMMEN START
        IF LENGTH(ROW.COMMENTS) > 0 THEN
            COMMEN := SUBSTR(RPAD('Commen: ', ATTRIBUTE_NAME_LEN) || ROW.COMMENTS, 0, ATTRIBUTE_LEN);
            DBMS_OUTPUT.PUT_LINE(RPAD(' ', NO_LEN + COLUMN_LEN + 2) || COMMEN); -- +2 из-за пробелов между столбцами
        END IF;
        -- COMMEN END


        -- INDEX START
        FOR D IN INDEX_COLUMNS
        LOOP
            IF D.COLUMN_NAME = ROW.COLUMN_NAME THEN
                -- Вывод отформатированного ограничения на новой строке
                DBMS_OUTPUT.PUT_LINE(RPAD(' ', NO_LEN + COLUMN_LEN + 2) ||
                                     RPAD('Index: ', ATTRIBUTE_NAME_LEN) || D.INDEX_NAME);
            END IF;
        END LOOP;

        -- INDEX END

        DBMS_OUTPUT.NEW_LINE; 
    END LOOP;
END;
/