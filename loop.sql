SET SERVEROUTPUT ON FORMAT WRAPPED;

CREATE OR REPLACE PROCEDURE LUN
(
    n IN INTEGER
)
IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Example loop');

    FOR i IN 1..n LOOP
        DBMS_OUTPUT.PUT_LINE(i);
    END LOOP;
END;
/