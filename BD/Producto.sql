DROP TABLE producto CASCADE CONSTRAINTS;
DROP TABLE marca CASCADE CONSTRAINTS;

CREATE TABLE producto(
    codigo VARCHAR2(10) PRIMARY KEY,
    nombre_producto VARCHAR2(80) NOT NULL,
    id_marca NUMBER NOT NULL,
    precio NUMBER NOT NULL,
    stock NUMBER NOT NULL,
    fecha DATE  NOT NULL
);

CREATE TABLE marca(
    id_marca NUMBER PRIMARY KEY,
    nombre_marca VARCHAR2(60) NOT NULL
);

ALTER TABLE producto ADD(
     CONSTRAINT fk_marca_producto FOREIGN KEY (id_marca) REFERENCES marca(id_marca)
);

--marcas de libros:
INSERT INTO marca VALUES(1,'Bosch');
INSERT INTO marca VALUES(2,'Makita');
INSERT INTO marca VALUES(3,'Stanley');
--insertar 3 libros:
INSERT INTO producto VALUES('1111','Martillo',1,12,6,sysdate);
INSERT INTO producto VALUES('1112','maquina de soldar',2,14,4,sysdate);
INSERT INTO producto VALUES('1113','Taladro',3,14,7,sysdate);

COMMIT;
/
--PROCEDIMIENTOS ALMACENADOS PARA EL CONSUMO DE MI API:
CREATE OR REPLACE PROCEDURE sp_get_productos(p_cursor OUT SYS_REFCURSOR, p_out OUT NUMBER)
IS
BEGIN
    OPEN p_cursor FOR SELECT p.codigo,
                           p.nombre_producto,
                           p.id_marca,
                           (SELECT nombre_marca FROM marca m WHERE p.id_marca = m.id_marca) AS marca,
                           p.precio,
                           p.stock,
                           p.fecha
                      FROM producto p;
    p_out := 1;
    
    EXCEPTION
    WHEN OTHERS THEN
        p_out := 0;
END sp_get_productos;
/
CREATE OR REPLACE PROCEDURE sp_get_producto(p_codigo VARCHAR2,p_cursor OUT SYS_REFCURSOR, p_out OUT NUMBER)
IS
BEGIN
    OPEN p_cursor FOR SELECT p.codigo,
                           p.nombre_producto,
                           p.id_marca,
                           (SELECT nombre_marca FROM marca m WHERE p.id_marca = m.id_marca) AS marca,
                           p.precio,
                           p.stock,
                           p.fecha
                      FROM producto p
                      WHERE p.codigo = p_codigo;
    p_out := 1;
    
    EXCEPTION
    WHEN OTHERS THEN
        p_out := 0;
END sp_get_producto;
/
CREATE OR REPLACE PROCEDURE sp_post_producto(p_codigo VARCHAR2, p_nombre VARCHAR2, p_id_marca NUMBER,
                                            p_precio NUMBER, p_stock NUMBER,p_fecha date,
                                          p_out OUT NUMBER)
IS
BEGIN
    INSERT INTO producto VALUES(p_codigo, p_nombre, p_id_marca, p_precio, p_stock,p_fecha);
    p_out := 1;
    
    EXCEPTION
    WHEN OTHERS THEN
        p_out := 0;
END sp_post_producto;
/
CREATE OR REPLACE PROCEDURE sp_put_producto(p_codigo VARCHAR2, p_nombre VARCHAR2, p_id_marca NUMBER,
                                            p_precio NUMBER, p_stock NUMBER,p_fecha date,
                                            p_out OUT NUMBER)
IS
BEGIN
    UPDATE producto
    SET nombre_producto = p_nombre,
        id_marca = p_id_marca,
        precio = p_precio,
        stock = p_stock,
        fecha = p_fecha
    WHERE codigo = p_codigo;
    p_out := 1;
    
    EXCEPTION
    WHEN OTHERS THEN
        p_out := 0;
END sp_put_producto;
/
CREATE OR REPLACE PROCEDURE sp_delete_producto(p_codigo VARCHAR2, p_out OUT NUMBER)
IS
BEGIN
    DELETE FROM producto
    WHERE codigo = p_codigo;
    p_out := 1;
    
    EXCEPTION
    WHEN OTHERS THEN
        p_out := 0;
END sp_delete_producto;
/
CREATE OR REPLACE PROCEDURE sp_patch_producto(p_codigo VARCHAR2, p_nombre VARCHAR2, p_id_marca NUMBER,
                                            p_precio NUMBER, p_stock NUMBER,p_fecha date,
                                            p_out OUT NUMBER)
IS
BEGIN
    INSERT INTO producto VALUES(p_codigo, p_nombre, p_id_marca, p_precio, p_stock,p_fecha);
    p_out := 1;
    
    EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        UPDATE producto
        SET nombre_producto = p_nombre,
            id_marca = p_id_marca,
            precio = p_precio,
            stock = p_stock,
            fecha = p_fecha
        WHERE codigo = p_codigo;
        p_out := 1;
    WHEN OTHERS THEN
        p_out := 0;
END sp_patch_producto;
/
COMMIT;