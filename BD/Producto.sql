DROP TABLE producto CASCADE CONSTRAINTS;
DROP TABLE marca CASCADE CONSTRAINTS;

CREATE TABLE producto(
   codigo number NOT NULL,
  imagen varchar(100) ,
  nombre varchar(50) NOT NULL,
  descripcion varchar(500) NOT NULL,
  id_marca number NOT NULL,
   precio number NOT NULL,
  stock number NOT NULL,
  creado_en date NOT NULL
  
  
);

CREATE TABLE marca(
    id_marca NUMBER PRIMARY KEY,
    nombre_marca VARCHAR2(60) NOT NULL
);

ALTER TABLE producto ADD(
     CONSTRAINT fk_marca_producto FOREIGN KEY (id_marca) REFERENCES marca(id_marca)
);

--marcas de productos:
INSERT INTO marca VALUES(1,'Bosch');
INSERT INTO marca VALUES(2,'Makitas');
INSERT INTO marca VALUES(3,'Stanley');
--insertar 3 productos:
INSERT INTO producto VALUES('1111','','Martillo','martillo es una herramienta manual de manejo simple, compuesta por una cabeza metálica generalmente en forma de cubo, conectada a un mango de madera o metal, utilizada para golpear y manipular objetos.',1,12,6,sysdate);
INSERT INTO producto VALUES('1112','','maquina de soldar','máquina de soldar es un dispositivo que utiliza corriente eléctrica para fundir y unir metales. Suele constar de un transformador o inversor que convierte la corriente eléctrica en un voltaje adecuado para soldar, junto con controles para ajustar la intensidad y otros parámetros del proceso.',2,14,4,sysdate);
INSERT INTO producto VALUES('1113','','Taladro','Un taladro es una herramienta eléctrica que se utiliza para perforar agujeros en diversos materiales, como madera, metal, plástico o concreto. Consiste en un motor eléctrico que impulsa una broca giratoria, la cual corta el material al entrar en contacto con él. Los taladros pueden ser de mano o estacionarios, y suelen tener diversas configuraciones de velocidad y potencia para adaptarse a diferentes tipos de trabajo.',3,14,7,sysdate);



COMMIT;
/
--PROCEDIMIENTOS ALMACENADOS PARA EL CONSUMO DE MI API:
CREATE OR REPLACE PROCEDURE sp_get_productos(p_cursor OUT SYS_REFCURSOR, p_out OUT NUMBER)
IS
BEGIN
    OPEN p_cursor FOR SELECT p.codigo,
                             p.imagen,
                             p.nombre,
                             p.descripcion,
                             p.id_marca,
                             (SELECT nombre_marca FROM marca m WHERE p.id_marca = m.id_marca) AS marca,
                             p.precio,
                             p.stock,
                             p.creado_en
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
                             p.imagen,
                             p.nombre,
                             p.descripcion,
                             p.id_marca,
                             (SELECT nombre_marca FROM marca m WHERE p.id_marca = m.id_marca) AS marca,
                             p.precio,
                             p.stock,
                             p.creado_en
                      FROM producto p
                      WHERE p.codigo = p_codigo;
    p_out := 1;
    
    EXCEPTION
    WHEN OTHERS THEN
        p_out := 0;
END sp_get_producto;
/
CREATE OR REPLACE PROCEDURE sp_post_producto(p_codigo VARCHAR2,p_imagen VARCHAR2, p_nombre VARCHAR2,p_descripcion VARCHAR2, p_id_marca NUMBER,
                                            p_precio NUMBER, p_stock NUMBER,p_creado_en date,
                                          p_out OUT NUMBER)
                                          
IS
BEGIN
    INSERT INTO producto VALUES(p_codigo,p_imagen, p_nombre,p_descripcion, p_id_marca, p_precio, p_stock,p_creado_en);
    p_out := 1;
    
    EXCEPTION
    WHEN OTHERS THEN
        p_out := 0;
END sp_post_producto;
/
CREATE OR REPLACE PROCEDURE sp_put_producto(p_codigo VARCHAR2,p_imagen VARCHAR2, p_nombre VARCHAR2,p_descripcion VARCHAR2, p_id_marca NUMBER,
                                            p_precio NUMBER, p_stock NUMBER,p_creado_en date,
                                          p_out OUT NUMBER)
IS
BEGIN
    UPDATE producto
    SET imagen = p_imagen,
        nombre = p_nombre,
        descripcion = p_descripcion,
        id_marca = p_id_marca,
        precio = p_precio,
        stock = p_stock,
        creado_en = p_creado_en
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
CREATE OR REPLACE PROCEDURE sp_patch_producto(p_codigo VARCHAR2,p_imagen VARCHAR2, p_nombre VARCHAR2,p_descripcion VARCHAR2, p_id_marca NUMBER,
                                            p_precio NUMBER, p_stock NUMBER,p_creado_en date,
                                          p_out OUT NUMBER)
IS
BEGIN
    INSERT INTO producto VALUES(p_codigo,p_imagen, p_nombre,p_descripcion, p_id_marca, p_precio, p_stock,p_creado_en);
    p_out := 1;
    
    EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        UPDATE producto
        SET imagen = p_imagen,
            nombre = p_nombre,
            descripcion = p_descripcion,
            id_marca = p_id_marca,
            precio = p_precio,
            stock = p_stock,
            creado_en = p_creado_en
    WHERE codigo = p_codigo;
        p_out := 1;
    WHEN OTHERS THEN
        p_out := 0;
END sp_patch_producto;
/
COMMIT;